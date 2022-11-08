package Koha::Item;

# Copyright ByWater Solutions 2014
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use List::MoreUtils qw( any );
use Try::Tiny qw( catch try );

use Koha::Database;
use Koha::DateUtils qw( dt_from_string output_pref );

use C4::Context;
use C4::Circulation qw( barcodedecode GetBranchItemRule );
use C4::Reserves;
use C4::ClassSource qw( GetClassSort );
use C4::Log qw( logaction );

use Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue;
use Koha::Biblio::ItemGroups;
use Koha::Checkouts;
use Koha::CirculationRules;
use Koha::CoverImages;
use Koha::Exceptions;
use Koha::Exceptions::Checkin;
use Koha::Exceptions::Item::Bundle;
use Koha::Exceptions::Item::Transfer;
use Koha::Item::Attributes;
use Koha::Exceptions::Item::Bundle;
use Koha::Item::Transfer::Limits;
use Koha::Item::Transfers;
use Koha::ItemTypes;
use Koha::Libraries;
use Koha::Patrons;
use Koha::Plugins;
use Koha::Recalls;
use Koha::Result::Boolean;
use Koha::SearchEngine::Indexer;
use Koha::StockRotationItem;
use Koha::StockRotationRotas;
use Koha::TrackedLinks;

use base qw(Koha::Object);

=head1 NAME

Koha::Item - Koha Item object class

=head1 API

=head2 Class methods

=cut

=head3 store

    $item->store;

$params can take an optional 'skip_record_index' parameter.
If set, the reindexation process will not happen (index_records not called)
You should not turn it on if you do not understand what it is doing exactly.

=cut

sub store {
    my $self = shift;
    my $params = @_ ? shift : {};

    my $log_action = $params->{log_action} // 1;

    # We do not want to oblige callers to pass this value
    # Dev conveniences vs performance?
    unless ( $self->biblioitemnumber ) {
        $self->biblioitemnumber( $self->biblio->biblioitem->biblioitemnumber );
    }

    # See related changes from C4::Items::AddItem
    unless ( $self->itype ) {
        $self->itype($self->biblio->biblioitem->itemtype);
    }

    $self->barcode( C4::Circulation::barcodedecode( $self->barcode ) );

    my $today  = dt_from_string;
    my $action = 'create';

    unless ( $self->in_storage ) { #AddItem

        unless ( $self->permanent_location ) {
            $self->permanent_location($self->location);
        }

        my $default_location = C4::Context->preference('NewItemsDefaultLocation');
        unless ( $self->location || !$default_location ) {
            $self->permanent_location( $self->location || $default_location )
              unless $self->permanent_location;
            $self->location($default_location);
        }

        unless ( $self->replacementpricedate ) {
            $self->replacementpricedate($today);
        }
        unless ( $self->datelastseen ) {
            $self->datelastseen($today);
        }

        unless ( $self->dateaccessioned ) {
            $self->dateaccessioned($today);
        }

        if (   $self->itemcallnumber
            or $self->cn_source )
        {
            my $cn_sort = GetClassSort( $self->cn_source, $self->itemcallnumber, "" );
            $self->cn_sort($cn_sort);
        }

    } else { # ModItem

        $action = 'modify';

        my %updated_columns = $self->_result->get_dirty_columns;
        return $self->SUPER::store unless %updated_columns;

        # Retrieve the item for comparison if we need to
        my $pre_mod_item = (
                 exists $updated_columns{itemlost}
              or exists $updated_columns{withdrawn}
              or exists $updated_columns{damaged}
        ) ? $self->get_from_storage : undef;

        # Update *_on  fields if needed
        # FIXME: Why not for AddItem as well?
        my @fields = qw( itemlost withdrawn damaged );
        for my $field (@fields) {

            # If the field is defined but empty or 0, we are
            # removing/unsetting and thus need to clear out
            # the 'on' field
            if (   exists $updated_columns{$field}
                && defined( $self->$field )
                && !$self->$field )
            {
                my $field_on = "${field}_on";
                $self->$field_on(undef);
            }
            # If the field has changed otherwise, we much update
            # the 'on' field
            elsif (exists $updated_columns{$field}
                && $updated_columns{$field}
                && !$pre_mod_item->$field )
            {
                my $field_on = "${field}_on";
                $self->$field_on(dt_from_string);
            }
        }

        if (   exists $updated_columns{itemcallnumber}
            or exists $updated_columns{cn_source} )
        {
            my $cn_sort = GetClassSort( $self->cn_source, $self->itemcallnumber, "" );
            $self->cn_sort($cn_sort);
        }


        if (    exists $updated_columns{location}
            and ( !defined($self->location) or $self->location !~ /^(CART|PROC)$/ )
            and not exists $updated_columns{permanent_location} )
        {
            $self->permanent_location( $self->location );
        }

        # If item was lost and has now been found,
        # reverse any list item charges if necessary.
        if (    exists $updated_columns{itemlost}
            and $updated_columns{itemlost} <= 0
            and $pre_mod_item->itemlost > 0 )
        {
            $self->_set_found_trigger($pre_mod_item);
        }

    }

    my $result = $self->SUPER::store;
    if ( $log_action && C4::Context->preference("CataloguingLog") ) {
        $action eq 'create'
          ? logaction( "CATALOGUING", "ADD", $self->itemnumber, "item" )
          : logaction( "CATALOGUING", "MODIFY", $self->itemnumber, $self );
    }
    my $indexer = Koha::SearchEngine::Indexer->new({ index => $Koha::SearchEngine::BIBLIOS_INDEX });
    $indexer->index_records( $self->biblionumber, "specialUpdate", "biblioserver" )
        unless $params->{skip_record_index};
    $self->get_from_storage->_after_item_action_hooks({ action => $action });

    Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue->new->enqueue(
        {
            biblio_ids => [ $self->biblionumber ]
        }
    ) unless $params->{skip_holds_queue} or !C4::Context->preference('RealTimeHoldsQueue');

    return $result;
}

=head3 delete

=cut

sub delete {
    my $self = shift;
    my $params = @_ ? shift : {};

    # FIXME check the item has no current issues
    # i.e. raise the appropriate exception

    # Get the item group so we can delete it later if it has no items left
    my $item_group = C4::Context->preference('EnableItemGroups') ? $self->item_group : undef;

    my $result = $self->SUPER::delete;

    # Delete the item gorup if it has no items left
    $item_group->delete if ( $item_group && $item_group->items->count == 0 );

    my $indexer = Koha::SearchEngine::Indexer->new({ index => $Koha::SearchEngine::BIBLIOS_INDEX });
    $indexer->index_records( $self->biblionumber, "specialUpdate", "biblioserver" )
        unless $params->{skip_record_index};

    $self->_after_item_action_hooks({ action => 'delete' });

    logaction( "CATALOGUING", "DELETE", $self->itemnumber, "item" )
      if C4::Context->preference("CataloguingLog");

    Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue->new->enqueue(
        {
            biblio_ids => [ $self->biblionumber ]
        }
    ) unless $params->{skip_holds_queue} or !C4::Context->preference('RealTimeHoldsQueue');

    return $result;
}

=head3 safe_delete

=cut

sub safe_delete {
    my $self = shift;
    my $params = @_ ? shift : {};

    my $safe_to_delete = $self->safe_to_delete;
    return $safe_to_delete unless $safe_to_delete;

    $self->move_to_deleted;

    return $self->delete($params);
}

=head3 safe_to_delete

returns 1 if the item is safe to delete,

"book_on_loan" if the item is checked out,

"not_same_branch" if the item is blocked by independent branches,

"book_reserved" if the there are holds aganst the item, or

"linked_analytics" if the item has linked analytic records.

"last_item_for_hold" if the item is the last one on a record on which a biblio-level hold is placed

=cut

sub safe_to_delete {
    my ($self) = @_;

    my $error;

    $error = "book_on_loan" if $self->checkout;

    $error //= "not_same_branch"
      if defined C4::Context->userenv
      and defined C4::Context->userenv->{number}
      and !Koha::Patrons->find( C4::Context->userenv->{number} )->can_edit_items_from( $self->homebranch );

    # check it doesn't have a waiting reserve
    $error //= "book_reserved"
      if $self->holds->filter_by_found->count;

    $error //= "linked_analytics"
      if C4::Items::GetAnalyticsCount( $self->itemnumber ) > 0;

    $error //= "last_item_for_hold"
      if $self->biblio->items->count == 1
      && $self->biblio->holds->search(
          {
              itemnumber => undef,
          }
        )->count;

    if ( $error ) {
        return Koha::Result::Boolean->new(0)->add_message({ message => $error });
    }

    return Koha::Result::Boolean->new(1);
}

=head3 move_to_deleted

my $is_moved = $item->move_to_deleted;

Move an item to the deleteditems table.
This can be done before deleting an item, to make sure the data are not completely deleted.

=cut

sub move_to_deleted {
    my ($self) = @_;
    my $item_infos = $self->unblessed;
    delete $item_infos->{timestamp}; #This ensures the timestamp date in deleteditems will be set to the current timestamp
    $item_infos->{deleted_on} = dt_from_string;
    return Koha::Database->new->schema->resultset('Deleteditem')->create($item_infos);
}


=head3 effective_itemtype

Returns the itemtype for the item based on whether item level itemtypes are set or not.

=cut

sub effective_itemtype {
    my ( $self ) = @_;

    return $self->_result()->effective_itemtype();
}

=head3 home_branch

=cut

sub home_branch {
    my ($self) = @_;

    my $hb_rs = $self->_result->homebranch;

    return Koha::Library->_new_from_dbic( $hb_rs );
}

=head3 holding_branch

=cut

sub holding_branch {
    my ($self) = @_;

    my $hb_rs = $self->_result->holdingbranch;

    return Koha::Library->_new_from_dbic( $hb_rs );
}

=head3 biblio

my $biblio = $item->biblio;

Return the bibliographic record of this item

=cut

sub biblio {
    my ( $self ) = @_;
    my $biblio_rs = $self->_result->biblio;
    return Koha::Biblio->_new_from_dbic( $biblio_rs );
}

=head3 biblioitem

my $biblioitem = $item->biblioitem;

Return the biblioitem record of this item

=cut

sub biblioitem {
    my ( $self ) = @_;
    my $biblioitem_rs = $self->_result->biblioitem;
    return Koha::Biblioitem->_new_from_dbic( $biblioitem_rs );
}

=head3 checkout

my $checkout = $item->checkout;

Return the checkout for this item

=cut

sub checkout {
    my ( $self ) = @_;
    my $checkout_rs = $self->_result->issue;
    return unless $checkout_rs;
    return Koha::Checkout->_new_from_dbic( $checkout_rs );
}

=head3 item_group

my $item_group = $item->item_group;

Return the item group for this item

=cut

sub item_group {
    my ( $self ) = @_;

    my $item_group_item = $self->_result->item_group_item;
    return unless $item_group_item;

    my $item_group_rs = $item_group_item->item_group;
    return unless $item_group_rs;

    my $item_group = Koha::Biblio::ItemGroup->_new_from_dbic( $item_group_rs );
    return $item_group;
}

=head3 return_claims

  my $return_claims = $item->return_claims;

Return any return_claims associated with this item

=cut

sub return_claims {
    my ( $self, $params, $attrs ) = @_;
    my $claims_rs = $self->_result->return_claims->search($params, $attrs);
    return Koha::Checkouts::ReturnClaims->_new_from_dbic( $claims_rs );
}

=head3 return_claim

  my $return_claim = $item->return_claim;

Returns the most recent unresolved return_claims associated with this item

=cut

sub return_claim {
    my ($self) = @_;
    my $claims_rs =
      $self->_result->return_claims->search( { resolution => undef },
        { order_by => { '-desc' => 'created_on' }, rows => 1 } )->single;
    return unless $claims_rs;
    return Koha::Checkouts::ReturnClaim->_new_from_dbic($claims_rs);
}

=head3 holds

my $holds = $item->holds();
my $holds = $item->holds($params);
my $holds = $item->holds({ found => 'W'});

Return holds attached to an item, optionally accept a hashref of params to pass to search

=cut

sub holds {
    my ( $self,$params ) = @_;
    my $holds_rs = $self->_result->reserves->search($params);
    return Koha::Holds->_new_from_dbic( $holds_rs );
}

=head3 request_transfer

  my $transfer = $item->request_transfer(
    {
        to     => $to_library,
        reason => $reason,
        [ ignore_limits => 0, enqueue => 1, replace => 1 ]
    }
  );

Add a transfer request for this item to the given branch for the given reason.

An exception will be thrown if the BranchTransferLimits would prevent the requested
transfer, unless 'ignore_limits' is passed to override the limits.

An exception will be thrown if an active transfer (i.e pending arrival date) is found;
The caller should catch such cases and retry the transfer request as appropriate passing
an appropriate override.

Overrides
* enqueue - Used to queue up the transfer when the existing transfer is found to be in transit.
* replace - Used to replace the existing transfer request with your own.

=cut

sub request_transfer {
    my ( $self, $params ) = @_;

    # check for mandatory params
    my @mandatory = ( 'to', 'reason' );
    for my $param (@mandatory) {
        unless ( defined( $params->{$param} ) ) {
            Koha::Exceptions::MissingParameter->throw(
                error => "The $param parameter is mandatory" );
        }
    }

    Koha::Exceptions::Item::Transfer::Limit->throw()
      unless ( $params->{ignore_limits}
        || $self->can_be_transferred( { to => $params->{to} } ) );

    my $request = $self->get_transfer;
    Koha::Exceptions::Item::Transfer::InQueue->throw( transfer => $request )
      if ( $request && !$params->{enqueue} && !$params->{replace} );

    $request->cancel( { reason => $params->{reason}, force => 1 } )
      if ( defined($request) && $params->{replace} );

    my $transfer = Koha::Item::Transfer->new(
        {
            itemnumber    => $self->itemnumber,
            daterequested => dt_from_string,
            frombranch    => $self->holdingbranch,
            tobranch      => $params->{to}->branchcode,
            reason        => $params->{reason},
            comments      => $params->{comment}
        }
    )->store();

    return $transfer;
}

=head3 get_transfer

  my $transfer = $item->get_transfer;

Return the active transfer request or undef

Note: Transfers are retrieved in a Modified FIFO (First In First Out) order
whereby the most recently sent, but not received, transfer will be returned
if it exists, otherwise the oldest unsatisfied transfer will be returned.

This allows for transfers to queue, which is the case for stock rotation and
rotating collections where a manual transfer may need to take precedence but
we still expect the item to end up at a final location eventually.

=cut

sub get_transfer {
    my ($self) = @_;

    return $self->get_transfers->search( {}, { rows => 1 } )->next;
}

=head3 get_transfers

  my $transfer = $item->get_transfers;

Return the list of outstanding transfers (i.e requested but not yet cancelled
or received).

Note: Transfers are retrieved in a Modified FIFO (First In First Out) order
whereby the most recently sent, but not received, transfer will be returned
first if it exists, otherwise requests are in oldest to newest request order.

This allows for transfers to queue, which is the case for stock rotation and
rotating collections where a manual transfer may need to take precedence but
we still expect the item to end up at a final location eventually.

=cut

sub get_transfers {
    my ($self) = @_;

    my $transfer_rs = $self->_result->branchtransfers;

    return Koha::Item::Transfers
                ->_new_from_dbic($transfer_rs)
                ->filter_by_current
                ->search( {}, { order_by => [ { -desc => 'datesent' }, { -asc => 'daterequested' } ], } );
}

=head3 last_returned_by

Gets and sets the last borrower to return an item.

Accepts and returns Koha::Patron objects

$item->last_returned_by( $borrowernumber );

$last_returned_by = $item->last_returned_by();

=cut

sub last_returned_by {
    my ( $self, $borrower ) = @_;

    my $items_last_returned_by_rs = Koha::Database->new()->schema()->resultset('ItemsLastBorrower');

    if ($borrower) {
        return $items_last_returned_by_rs->update_or_create(
            { borrowernumber => $borrower->borrowernumber, itemnumber => $self->id } );
    }
    else {
        unless ( $self->{_last_returned_by} ) {
            my $result = $items_last_returned_by_rs->single( { itemnumber => $self->id } );
            if ($result) {
                $self->{_last_returned_by} = Koha::Patrons->find( $result->get_column('borrowernumber') );
            }
        }

        return $self->{_last_returned_by};
    }
}

=head3 can_article_request

my $bool = $item->can_article_request( $borrower )

Returns true if item can be specifically requested

$borrower must be a Koha::Patron object

=cut

sub can_article_request {
    my ( $self, $borrower ) = @_;

    my $rule = $self->article_request_type($borrower);

    return 1 if $rule && $rule ne 'no' && $rule ne 'bib_only';
    return q{};
}

=head3 hidden_in_opac

my $bool = $item->hidden_in_opac({ [ rules => $rules ] })

Returns true if item fields match the hidding criteria defined in $rules.
Returns false otherwise.

Takes HASHref that can have the following parameters:
    OPTIONAL PARAMETERS:
    $rules : { <field> => [ value_1, ... ], ... }

Note: $rules inherits its structure from the parsed YAML from reading
the I<OpacHiddenItems> system preference.

=cut

sub hidden_in_opac {
    my ( $self, $params ) = @_;

    my $rules = $params->{rules} // {};

    return 1
        if C4::Context->preference('hidelostitems') and
           $self->itemlost > 0;

    my $hidden_in_opac = 0;

    foreach my $field ( keys %{$rules} ) {

        if ( any { $self->$field eq $_ } @{ $rules->{$field} } ) {
            $hidden_in_opac = 1;
            last;
        }
    }

    return $hidden_in_opac;
}

=head3 can_be_transferred

$item->can_be_transferred({ to => $to_library, from => $from_library })
Checks if an item can be transferred to given library.

This feature is controlled by two system preferences:
UseBranchTransferLimits to enable / disable the feature
BranchTransferLimitsType to use either an itemnumber or ccode as an identifier
                         for setting the limitations

Takes HASHref that can have the following parameters:
    MANDATORY PARAMETERS:
    $to   : Koha::Library
    OPTIONAL PARAMETERS:
    $from : Koha::Library  # if not given, item holdingbranch
                           # will be used instead

Returns 1 if item can be transferred to $to_library, otherwise 0.

To find out whether at least one item of a Koha::Biblio can be transferred, please
see Koha::Biblio->can_be_transferred() instead of using this method for
multiple items of the same biblio.

=cut

sub can_be_transferred {
    my ($self, $params) = @_;

    my $to   = $params->{to};
    my $from = $params->{from};

    $to   = $to->branchcode;
    $from = defined $from ? $from->branchcode : $self->holdingbranch;

    return 1 if $from eq $to; # Transfer to current branch is allowed
    return 1 unless C4::Context->preference('UseBranchTransferLimits');

    my $limittype = C4::Context->preference('BranchTransferLimitsType');
    return Koha::Item::Transfer::Limits->search({
        toBranch => $to,
        fromBranch => $from,
        $limittype => $limittype eq 'itemtype'
                        ? $self->effective_itemtype : $self->ccode
    })->count ? 0 : 1;

}

=head3 pickup_locations

    my $pickup_locations = $item->pickup_locations({ patron => $patron })

Returns possible pickup locations for this item, according to patron's home library
and if item can be transferred to each pickup location.

Throws a I<Koha::Exceptions::MissingParameter> exception if the B<mandatory> parameter I<patron>
is not passed.

=cut

sub pickup_locations {
    my ($self, $params) = @_;

    Koha::Exceptions::MissingParameter->throw( parameter => 'patron' )
      unless exists $params->{patron};

    my $patron = $params->{patron};

    my $circ_control_branch =
      C4::Reserves::GetReservesControlBranch( $self->unblessed(), $patron->unblessed );
    my $branchitemrule =
      C4::Circulation::GetBranchItemRule( $circ_control_branch, $self->itype );

    return Koha::Libraries->new()->empty if $branchitemrule->{holdallowed} eq 'from_local_hold_group' && !$self->home_branch->validate_hold_sibling( {branchcode => $patron->branchcode} );
    return Koha::Libraries->new()->empty if $branchitemrule->{holdallowed} eq 'from_home_library' && $self->home_branch->branchcode ne $patron->branchcode;

    my $pickup_libraries = Koha::Libraries->search();
    if ($branchitemrule->{hold_fulfillment_policy} eq 'holdgroup') {
        $pickup_libraries = $self->home_branch->get_hold_libraries;
    } elsif ($branchitemrule->{hold_fulfillment_policy} eq 'patrongroup') {
        my $plib = Koha::Libraries->find({ branchcode => $patron->branchcode});
        $pickup_libraries = $plib->get_hold_libraries;
    } elsif ($branchitemrule->{hold_fulfillment_policy} eq 'homebranch') {
        $pickup_libraries = Koha::Libraries->search({ branchcode => $self->homebranch });
    } elsif ($branchitemrule->{hold_fulfillment_policy} eq 'holdingbranch') {
        $pickup_libraries = Koha::Libraries->search({ branchcode => $self->holdingbranch });
    };

    return $pickup_libraries->search(
        {
            pickup_location => 1
        },
        {
            order_by => ['branchname']
        }
    ) unless C4::Context->preference('UseBranchTransferLimits');

    my $limittype = C4::Context->preference('BranchTransferLimitsType');
    my ($ccode, $itype) = (undef, undef);
    if( $limittype eq 'ccode' ){
        $ccode = $self->ccode;
    } else {
        $itype = $self->itype;
    }
    my $limits = Koha::Item::Transfer::Limits->search(
        {
            fromBranch => $self->holdingbranch,
            ccode      => $ccode,
            itemtype   => $itype,
        },
        { columns => ['toBranch'] }
    );

    return $pickup_libraries->search(
        {
            pickup_location => 1,
            branchcode      => {
                '-not_in' => $limits->_resultset->as_query
            }
        },
        {
            order_by => ['branchname']
        }
    );
}

=head3 article_request_type

my $type = $item->article_request_type( $borrower )

returns 'yes', 'no', 'bib_only', or 'item_only'

$borrower must be a Koha::Patron object

=cut

sub article_request_type {
    my ( $self, $borrower ) = @_;

    my $branch_control = C4::Context->preference('HomeOrHoldingBranch');
    my $branchcode =
        $branch_control eq 'homebranch'    ? $self->homebranch
      : $branch_control eq 'holdingbranch' ? $self->holdingbranch
      :                                      undef;
    my $borrowertype = $borrower->categorycode;
    my $itemtype = $self->effective_itemtype();
    my $rule = Koha::CirculationRules->get_effective_rule(
        {
            rule_name    => 'article_requests',
            categorycode => $borrowertype,
            itemtype     => $itemtype,
            branchcode   => $branchcode
        }
    );

    return q{} unless $rule;
    return $rule->rule_value || q{}
}

=head3 current_holds

=cut

sub current_holds {
    my ( $self ) = @_;
    my $attributes = { order_by => 'priority' };
    my $dtf = Koha::Database->new->schema->storage->datetime_parser;
    my $params = {
        itemnumber => $self->itemnumber,
        suspend => 0,
        -or => [
            reservedate => { '<=' => $dtf->format_date(dt_from_string) },
            waitingdate => { '!=' => undef },
        ],
    };
    my $hold_rs = $self->_result->reserves->search( $params, $attributes );
    return Koha::Holds->_new_from_dbic($hold_rs);
}

=head3 stockrotationitem

  my $sritem = Koha::Item->stockrotationitem;

Returns the stock rotation item associated with the current item.

=cut

sub stockrotationitem {
    my ( $self ) = @_;
    my $rs = $self->_result->stockrotationitem;
    return 0 if !$rs;
    return Koha::StockRotationItem->_new_from_dbic( $rs );
}

=head3 add_to_rota

  my $item = $item->add_to_rota($rota_id);

Add this item to the rota identified by $ROTA_ID, which means associating it
with the first stage of that rota.  Should this item already be associated
with a rota, then we will move it to the new rota.

=cut

sub add_to_rota {
    my ( $self, $rota_id ) = @_;
    Koha::StockRotationRotas->find($rota_id)->add_item($self->itemnumber);
    return $self;
}

=head3 has_pending_hold

  my $is_pending_hold = $item->has_pending_hold();

This method checks the tmp_holdsqueue to see if this item has been selected for a hold, but not filled yet and returns true or false

=cut

sub has_pending_hold {
    my ( $self ) = @_;
    my $pending_hold = $self->_result->tmp_holdsqueues;
    return $pending_hold->count ? 1: 0;
}

=head3 has_pending_recall {

  my $has_pending_recall

Return if whether has pending recall of not.

=cut

sub has_pending_recall {
    my ( $self ) = @_;

    # FIXME Must be moved to $self->recalls
    return Koha::Recalls->search(
        {
            item_id   => $self->itemnumber,
            status    => 'waiting',
        }
    )->count;
}

=head3 as_marc_field

    my $field = $item->as_marc_field;

This method returns a MARC::Field object representing the Koha::Item object
with the current mappings configuration.

=cut

sub as_marc_field {
    my ( $self ) = @_;

    my ( $itemtag, $itemtagsubfield) = C4::Biblio::GetMarcFromKohaField( "items.itemnumber" );

    my $tagslib = C4::Biblio::GetMarcStructure( 1, $self->biblio->frameworkcode, { unsafe => 1 });

    my @subfields;

    my $item_field = $tagslib->{$itemtag};

    my $more_subfields = $self->additional_attributes->to_hashref;
    foreach my $subfield (
        sort {
               $a->{display_order} <=> $b->{display_order}
            || $a->{subfield} cmp $b->{subfield}
        } grep { ref($_) && %$_ } values %$item_field
    ){

        my $kohafield = $subfield->{kohafield};
        my $tagsubfield = $subfield->{tagsubfield};
        my $value;
        if ( defined $kohafield && $kohafield ne '' ) {
            next if $kohafield !~ m{^items\.}; # That would be weird!
            ( my $attribute = $kohafield ) =~ s|^items\.||;
            $value = $self->$attribute # This call may fail if a kohafield is not a DB column but we don't want to add extra work for that there
                if defined $self->$attribute and $self->$attribute ne '';
        } else {
            $value = $more_subfields->{$tagsubfield}
        }

        next unless defined $value
            and $value ne q{};

        if ( $subfield->{repeatable} ) {
            my @values = split '\|', $value;
            push @subfields, ( $tagsubfield => $_ ) for @values;
        }
        else {
            push @subfields, ( $tagsubfield => $value );
        }

    }

    return unless @subfields;

    return MARC::Field->new(
        "$itemtag", ' ', ' ', @subfields
    );
}

=head3 renewal_branchcode

Returns the branchcode to be recorded in statistics renewal of the item

=cut

sub renewal_branchcode {

    my ($self, $params ) = @_;

    my $interface = C4::Context->interface;
    my $branchcode;
    if ( $interface eq 'opac' ){
        my $renewal_branchcode = C4::Context->preference('OpacRenewalBranch');
        if( !defined $renewal_branchcode || $renewal_branchcode eq 'opacrenew' ){
            $branchcode = 'OPACRenew';
        }
        elsif ( $renewal_branchcode eq 'itemhomebranch' ) {
            $branchcode = $self->homebranch;
        }
        elsif ( $renewal_branchcode eq 'patronhomebranch' ) {
            $branchcode = $self->checkout->patron->branchcode;
        }
        elsif ( $renewal_branchcode eq 'checkoutbranch' ) {
            $branchcode = $self->checkout->branchcode;
        }
        else {
            $branchcode = "";
        }
    } else {
        $branchcode = ( C4::Context->userenv && defined C4::Context->userenv->{branch} )
            ? C4::Context->userenv->{branch} : $params->{branch};
    }
    return $branchcode;
}

=head3 cover_images

Return the cover images associated with this item.

=cut

sub cover_images {
    my ( $self ) = @_;

    my $cover_image_rs = $self->_result->cover_images;
    return unless $cover_image_rs;
    return Koha::CoverImages->_new_from_dbic($cover_image_rs);
}

=head3 columns_to_str

    my $values = $items->columns_to_str;

Return a hashref with the string representation of the different attribute of the item.

This is meant to be used for display purpose only.

=cut

sub columns_to_str {
    my ( $self ) = @_;

    my $frameworkcode = $self->biblio->frameworkcode;
    my $tagslib = C4::Biblio::GetMarcStructure(1, $frameworkcode);
    my ( $itemtagfield, $itemtagsubfield) = C4::Biblio::GetMarcFromKohaField( "items.itemnumber" );

    my $columns_info = $self->_result->result_source->columns_info;

    my $mss = C4::Biblio::GetMarcSubfieldStructure( $frameworkcode, { unsafe => 1 } );
    my $values = {};
    for my $column ( keys %$columns_info ) {

        next if $column eq 'more_subfields_xml';

        my $value = $self->$column;
        # Maybe we need to deal with datetime columns here, but so far we have damaged_on, itemlost_on and withdrawn_on, and they are not linked with kohafield

        if ( not defined $value or $value eq "" ) {
            $values->{$column} = $value;
            next;
        }

        my $subfield =
          exists $mss->{"items.$column"}
          ? @{ $mss->{"items.$column"} }[0] # Should we deal with several subfields??
          : undef;

        $values->{$column} =
            $subfield
          ? $subfield->{authorised_value}
              ? C4::Biblio::GetAuthorisedValueDesc( $itemtagfield,
                  $subfield->{tagsubfield}, $value, '', $tagslib )
              : $value
          : $value;
    }

    my $marc_more=
      $self->more_subfields_xml
      ? MARC::Record->new_from_xml( $self->more_subfields_xml, 'UTF-8' )
      : undef;

    my $more_values;
    if ( $marc_more ) {
        my ( $field ) = $marc_more->fields;
        for my $sf ( $field->subfields ) {
            my $subfield_code = $sf->[0];
            my $value = $sf->[1];
            my $subfield = $tagslib->{$itemtagfield}->{$subfield_code};
            next unless $subfield; # We have the value but it's not mapped, data lose! No regression however.
            $value =
              $subfield->{authorised_value}
              ? C4::Biblio::GetAuthorisedValueDesc( $itemtagfield,
                $subfield->{tagsubfield}, $value, '', $tagslib )
              : $value;

            push @{$more_values->{$subfield_code}}, $value;
        }

        while ( my ( $k, $v ) = each %$more_values ) {
            $values->{$k} = join ' | ', @$v;
        }
    }

    return $values;
}

=head3 additional_attributes

    my $attributes = $item->additional_attributes;
    $attributes->{k} = 'new k';
    $item->update({ more_subfields => $attributes->to_marcxml });

Returns a Koha::Item::Attributes object that represents the non-mapped
attributes for this item.

=cut

sub additional_attributes {
    my ($self) = @_;

    return Koha::Item::Attributes->new_from_marcxml(
        $self->more_subfields_xml,
    );
}

=head3 _set_found_trigger

    $self->_set_found_trigger

Finds the most recent lost item charge for this item and refunds the patron
appropriately, taking into account any payments or writeoffs already applied
against the charge.

Internal function, not exported, called only by Koha::Item->store.

=cut

sub _set_found_trigger {
    my ( $self, $pre_mod_item ) = @_;

    # Reverse any lost item charges if necessary.
    my $no_refund_after_days =
      C4::Context->preference('NoRefundOnLostReturnedItemsAge');
    if ($no_refund_after_days) {
        my $today = dt_from_string();
        my $lost_age_in_days =
          dt_from_string( $pre_mod_item->itemlost_on )->delta_days($today)
          ->in_units('days');

        return $self unless $lost_age_in_days < $no_refund_after_days;
    }

    my $lost_proc_return_policy = Koha::CirculationRules->get_lostreturn_policy(
        {
            item          => $self,
            return_branch => C4::Context->userenv
            ? C4::Context->userenv->{'branch'}
            : undef,
        }
      );
    my $lostreturn_policy = $lost_proc_return_policy->{lostreturn};

    if ( $lostreturn_policy ) {

        # refund charge made for lost book
        my $lost_charge = Koha::Account::Lines->search(
            {
                itemnumber      => $self->itemnumber,
                debit_type_code => 'LOST',
                status          => [ undef, { '<>' => 'FOUND' } ]
            },
            {
                order_by => { -desc => [ 'date', 'accountlines_id' ] },
                rows     => 1
            }
        )->single;

        if ( $lost_charge ) {

            my $patron = $lost_charge->patron;
            if ( $patron ) {

                my $account = $patron->account;

                # Credit outstanding amount
                my $credit_total = $lost_charge->amountoutstanding;

                # Use cases
                if (
                    $lost_charge->amount > $lost_charge->amountoutstanding &&
                    $lostreturn_policy ne "refund_unpaid"
                ) {
                    # some amount has been cancelled. collect the offsets that are not writeoffs
                    # this works because the only way to subtract from this kind of a debt is
                    # using the UI buttons 'Pay' and 'Write off'

                    # We don't credit any payments if return policy is
                    # "refund_unpaid"
                    #
                    # In that case only unpaid/outstanding amount
                    # will be credited which settles the debt without
                    # creating extra credits

                    my $credit_offsets = $lost_charge->debit_offsets(
                        {
                            'credit_id'               => { '!=' => undef },
                            'credit.credit_type_code' => { '!=' => 'Writeoff' }
                        },
                        { join => 'credit' }
                    );

                    my $total_to_refund = ( $credit_offsets->count > 0 ) ?
                        # credits are negative on the DB
                        $credit_offsets->total * -1 :
                        0;
                    # Credit the outstanding amount, then add what has been
                    # paid to create a net credit for this amount
                    $credit_total += $total_to_refund;
                }

                my $credit;
                if ( $credit_total > 0 ) {
                    my $branchcode =
                      C4::Context->userenv ? C4::Context->userenv->{'branch'} : undef;
                    $credit = $account->add_credit(
                        {
                            amount      => $credit_total,
                            description => 'Item found ' . $self->itemnumber,
                            type        => 'LOST_FOUND',
                            interface   => C4::Context->interface,
                            library_id  => $branchcode,
                            item_id     => $self->itemnumber,
                            issue_id    => $lost_charge->issue_id
                        }
                    );

                    $credit->apply( { debits => [$lost_charge] } );
                    $self->add_message(
                        {
                            type    => 'info',
                            message => 'lost_refunded',
                            payload => { credit_id => $credit->id }
                        }
                    );
                }

                # Update the account status
                $lost_charge->status('FOUND');
                $lost_charge->store();

                # Reconcile balances if required
                if ( C4::Context->preference('AccountAutoReconcile') ) {
                    $account->reconcile_balance;
                }
            }
        }

        # possibly restore fine for lost book
        my $lost_overdue = Koha::Account::Lines->search(
            {
                itemnumber      => $self->itemnumber,
                debit_type_code => 'OVERDUE',
                status          => 'LOST'
            },
            {
                order_by => { '-desc' => 'date' },
                rows     => 1
            }
        )->single;
        if ( $lostreturn_policy eq 'restore' && $lost_overdue ) {

            my $patron = $lost_overdue->patron;
            if ($patron) {
                my $account = $patron->account;

                # Update status of fine
                $lost_overdue->status('FOUND')->store();

                # Find related forgive credit
                my $refund = $lost_overdue->credits(
                    {
                        credit_type_code => 'FORGIVEN',
                        itemnumber       => $self->itemnumber,
                        status           => [ { '!=' => 'VOID' }, undef ]
                    },
                    { order_by => { '-desc' => 'date' }, rows => 1 }
                )->single;

                if ( $refund ) {
                    # Revert the forgive credit
                    $refund->void({ interface => 'trigger' });
                    $self->add_message(
                        {
                            type    => 'info',
                            message => 'lost_restored',
                            payload => { refund_id => $refund->id }
                        }
                    );
                }

                # Reconcile balances if required
                if ( C4::Context->preference('AccountAutoReconcile') ) {
                    $account->reconcile_balance;
                }
            }

        } elsif ( $lostreturn_policy eq 'charge' && ( $lost_overdue || $lost_charge ) ) {
            $self->add_message(
                {
                    type    => 'info',
                    message => 'lost_charge',
                }
            );
        }
    }

    my $processingreturn_policy = $lost_proc_return_policy->{processingreturn};

    if ( $processingreturn_policy ) {

        # refund processing charge made for lost book
        my $processing_charge = Koha::Account::Lines->search(
            {
                itemnumber      => $self->itemnumber,
                debit_type_code => 'PROCESSING',
                status          => [ undef, { '<>' => 'FOUND' } ]
            },
            {
                order_by => { -desc => [ 'date', 'accountlines_id' ] },
                rows     => 1
            }
        )->single;

        if ( $processing_charge ) {

            my $patron = $processing_charge->patron;
            if ( $patron ) {

                my $account = $patron->account;

                # Credit outstanding amount
                my $credit_total = $processing_charge->amountoutstanding;

                # Use cases
                if (
                    $processing_charge->amount > $processing_charge->amountoutstanding &&
                    $processingreturn_policy ne "refund_unpaid"
                ) {
                    # some amount has been cancelled. collect the offsets that are not writeoffs
                    # this works because the only way to subtract from this kind of a debt is
                    # using the UI buttons 'Pay' and 'Write off'

                    # We don't credit any payments if return policy is
                    # "refund_unpaid"
                    #
                    # In that case only unpaid/outstanding amount
                    # will be credited which settles the debt without
                    # creating extra credits

                    my $credit_offsets = $processing_charge->debit_offsets(
                        {
                            'credit_id'               => { '!=' => undef },
                            'credit.credit_type_code' => { '!=' => 'Writeoff' }
                        },
                        { join => 'credit' }
                    );

                    my $total_to_refund = ( $credit_offsets->count > 0 ) ?
                        # credits are negative on the DB
                        $credit_offsets->total * -1 :
                        0;
                    # Credit the outstanding amount, then add what has been
                    # paid to create a net credit for this amount
                    $credit_total += $total_to_refund;
                }

                my $credit;
                if ( $credit_total > 0 ) {
                    my $branchcode =
                      C4::Context->userenv ? C4::Context->userenv->{'branch'} : undef;
                    $credit = $account->add_credit(
                        {
                            amount      => $credit_total,
                            description => 'Item found ' . $self->itemnumber,
                            type        => 'PROCESSING_FOUND',
                            interface   => C4::Context->interface,
                            library_id  => $branchcode,
                            item_id     => $self->itemnumber,
                            issue_id    => $processing_charge->issue_id
                        }
                    );

                    $credit->apply( { debits => [$processing_charge] } );
                    $self->add_message(
                        {
                            type    => 'info',
                            message => 'processing_refunded',
                            payload => { credit_id => $credit->id }
                        }
                    );
                }

                # Update the account status
                $processing_charge->status('FOUND');
                $processing_charge->store();

                # Reconcile balances if required
                if ( C4::Context->preference('AccountAutoReconcile') ) {
                    $account->reconcile_balance;
                }
            }
        }
    }

    return $self;
}

=head3 public_read_list

This method returns the list of publicly readable database fields for both API and UI output purposes

=cut

sub public_read_list {
    return [
        'itemnumber',     'biblionumber',    'homebranch',
        'holdingbranch',  'location',        'collectioncode',
        'itemcallnumber', 'copynumber',      'enumchron',
        'barcode',        'dateaccessioned', 'itemnotes',
        'onloan',         'uri',             'itype',
        'notforloan',     'damaged',         'itemlost',
        'withdrawn',      'restricted'
    ];
}

=head3 to_api

Overloaded to_api method to ensure item-level itypes is adhered to.

=cut

sub to_api {
    my ($self, $params) = @_;

    my $response = $self->SUPER::to_api($params);
    my $overrides = {};

    $overrides->{effective_item_type_id} = $self->effective_itemtype;
    $overrides->{effective_not_for_loan_status} = $self->notforloan ? $self->notforloan : $self->itemtype->notforloan;

    return { %$response, %$overrides };
}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::Item object
on the API.

=cut

sub to_api_mapping {
    return {
        itemnumber               => 'item_id',
        biblionumber             => 'biblio_id',
        biblioitemnumber         => undef,
        barcode                  => 'external_id',
        dateaccessioned          => 'acquisition_date',
        booksellerid             => 'acquisition_source',
        homebranch               => 'home_library_id',
        price                    => 'purchase_price',
        replacementprice         => 'replacement_price',
        replacementpricedate     => 'replacement_price_date',
        datelastborrowed         => 'last_checkout_date',
        datelastseen             => 'last_seen_date',
        stack                    => undef,
        notforloan               => 'not_for_loan_status',
        damaged                  => 'damaged_status',
        damaged_on               => 'damaged_date',
        itemlost                 => 'lost_status',
        itemlost_on              => 'lost_date',
        withdrawn                => 'withdrawn',
        withdrawn_on             => 'withdrawn_date',
        itemcallnumber           => 'callnumber',
        coded_location_qualifier => 'coded_location_qualifier',
        issues                   => 'checkouts_count',
        renewals                 => 'renewals_count',
        reserves                 => 'holds_count',
        restricted               => 'restricted_status',
        itemnotes                => 'public_notes',
        itemnotes_nonpublic      => 'internal_notes',
        holdingbranch            => 'holding_library_id',
        timestamp                => 'timestamp',
        location                 => 'location',
        permanent_location       => 'permanent_location',
        onloan                   => 'checked_out_date',
        cn_source                => 'call_number_source',
        cn_sort                  => 'call_number_sort',
        ccode                    => 'collection_code',
        materials                => 'materials_notes',
        uri                      => 'uri',
        itype                    => 'item_type_id',
        more_subfields_xml       => 'extended_subfields',
        enumchron                => 'serial_issue_number',
        copynumber               => 'copy_number',
        stocknumber              => 'inventory_number',
        new_status               => 'new_status',
        deleted_on               => undef,
    };
}

=head3 itemtype

    my $itemtype = $item->itemtype;

    Returns Koha object for effective itemtype

=cut

sub itemtype {
    my ( $self ) = @_;

    return Koha::ItemTypes->find( $self->effective_itemtype );
}

=head3 orders

  my $orders = $item->orders();

Returns a Koha::Acquisition::Orders object

=cut

sub orders {
    my ( $self ) = @_;

    my $orders = $self->_result->item_orders;
    return Koha::Acquisition::Orders->_new_from_dbic($orders);
}

=head3 tracked_links

  my $tracked_links = $item->tracked_links();

Returns a Koha::TrackedLinks object

=cut

sub tracked_links {
    my ( $self ) = @_;

    my $tracked_links = $self->_result->linktrackers;
    return Koha::TrackedLinks->_new_from_dbic($tracked_links);
}

=head3 move_to_biblio

  $item->move_to_biblio($to_biblio[, $params]);

Move the item to another biblio and update any references in other tables.

The final optional parameter, C<$params>, is expected to contain the
'skip_record_index' key, which is relayed down to Koha::Item->store.
There it prevents calling index_records, which takes most of the
time in batch adds/deletes. The caller must take care of calling
index_records separately.

$params:
    skip_record_index => 1|0

Returns undef if the move failed or the biblionumber of the destination record otherwise

=cut

sub move_to_biblio {
    my ( $self, $to_biblio, $params ) = @_;

    $params //= {};

    return if $self->biblionumber == $to_biblio->biblionumber;

    my $from_biblionumber = $self->biblionumber;
    my $to_biblionumber = $to_biblio->biblionumber;

    # Own biblionumber and biblioitemnumber
    $self->set({
        biblionumber => $to_biblionumber,
        biblioitemnumber => $to_biblio->biblioitem->biblioitemnumber
    })->store({ skip_record_index => $params->{skip_record_index} });

    unless ($params->{skip_record_index}) {
        my $indexer = Koha::SearchEngine::Indexer->new({ index => $Koha::SearchEngine::BIBLIOS_INDEX });
        $indexer->index_records( $from_biblionumber, "specialUpdate", "biblioserver" );
    }

    # Acquisition orders
    $self->orders->update({ biblionumber => $to_biblionumber }, { no_triggers => 1 });

    # Holds
    $self->holds->update({ biblionumber => $to_biblionumber }, { no_triggers => 1 });

    # hold_fill_target (there's no Koha object available yet)
    my $hold_fill_target = $self->_result->hold_fill_target;
    if ($hold_fill_target) {
        $hold_fill_target->update({ biblionumber => $to_biblionumber });
    }

    # tmp_holdsqueues - Can't update with DBIx since the table is missing a primary key
    # and can't even fake one since the significant columns are nullable.
    my $storage = $self->_result->result_source->storage;
    $storage->dbh_do(
        sub {
            my ($storage, $dbh, @cols) = @_;

            $dbh->do("UPDATE tmp_holdsqueue SET biblionumber=? WHERE itemnumber=?", undef, $to_biblionumber, $self->itemnumber);
        }
    );

    # tracked_links
    $self->tracked_links->update({ biblionumber => $to_biblionumber }, { no_triggers => 1 });

    return $to_biblionumber;
}

=head3 bundle_items

  my $bundle_items = $item->bundle_items;

Returns the items associated with this bundle

=cut

sub bundle_items {
    my ($self) = @_;

    if ( !$self->{_bundle_items_cached} ) {
        my $bundle_items = Koha::Items->search(
            { 'item_bundles_item.host' => $self->itemnumber },
            { join                     => 'item_bundles_item' } );
        $self->{_bundle_items}        = $bundle_items;
        $self->{_bundle_items_cached} = 1;
    }

    return $self->{_bundle_items};
}

=head3 is_bundle

  my $is_bundle = $item->is_bundle;

Returns whether the item is a bundle or not

=cut

sub is_bundle {
    my ($self) = @_;
    return $self->bundle_items->count ? 1 : 0;
}

=head3 bundle_host

  my $bundle = $item->bundle_host;

Returns the bundle item this item is attached to

=cut

sub bundle_host {
    my ($self) = @_;

    my $bundle_items_rs = $self->_result->item_bundles_item;
    return unless $bundle_items_rs;
    return Koha::Item->_new_from_dbic($bundle_items_rs->host);
}

=head3 in_bundle

  my $in_bundle = $item->in_bundle;

Returns whether this item is currently in a bundle

=cut

sub in_bundle {
    my ($self) = @_;
    return $self->bundle_host ? 1 : 0;
}

=head3 add_to_bundle

  my $link = $item->add_to_bundle($bundle_item);

Adds the bundle_item passed to this item

=cut

sub add_to_bundle {
    my ( $self, $bundle_item, $options ) = @_;

    $options //= {};

    Koha::Exceptions::Item::Bundle::IsBundle->throw()
      if ( $self->itemnumber eq $bundle_item->itemnumber
        || $bundle_item->is_bundle
        || $self->in_bundle );

    my $schema = Koha::Database->new->schema;

    my $BundleNotLoanValue = C4::Context->preference('BundleNotLoanValue');

    try {
        $schema->txn_do(
            sub {
                my $checkout = $bundle_item->checkout;
                if ($checkout) {
                    unless ($options->{force_checkin}) {
                        Koha::Exceptions::Item::Bundle::ItemIsCheckedOut->throw();
                    }

                    my $branchcode = C4::Context->userenv->{'branch'};
                    my ($success) = C4::Circulation::AddReturn($bundle_item->barcode, $branchcode);
                    unless ($success) {
                        Koha::Exceptions::Checkin::FailedCheckin->throw();
                    }
                }

                my $holds = $bundle_item->current_holds;
                if ($holds->count) {
                    unless ($options->{ignore_holds}) {
                        Koha::Exceptions::Item::Bundle::ItemHasHolds->throw();
                    }
                }

                $self->_result->add_to_item_bundles_hosts(
                    { item => $bundle_item->itemnumber } );

                $bundle_item->notforloan($BundleNotLoanValue)->store();
            }
        );
    }
    catch {

        # FIXME: See if we can move the below copy/paste from Koha::Object::store into it's own class and catch at a lower level in the Schema instantiation, take inspiration from DBIx::Error
        if ( ref($_) eq 'DBIx::Class::Exception' ) {
            if ( $_->{msg} =~ /Cannot add or update a child row: a foreign key constraint fails/ ) {
                # FK constraints
                # FIXME: MySQL error, if we support more DB engines we should implement this for each
                if ( $_->{msg} =~ /FOREIGN KEY \(`(?<column>.*?)`\)/ ) {
                    Koha::Exceptions::Object::FKConstraint->throw(
                        error     => 'Broken FK constraint',
                        broken_fk => $+{column}
                    );
                }
            }
            elsif (
                $_->{msg} =~ /Duplicate entry '(.*?)' for key '(?<key>.*?)'/ )
            {
                Koha::Exceptions::Object::DuplicateID->throw(
                    error        => 'Duplicate ID',
                    duplicate_id => $+{key}
                );
            }
            elsif ( $_->{msg} =~
/Incorrect (?<type>\w+) value: '(?<value>.*)' for column \W?(?<property>\S+)/
              )
            {    # The optional \W in the regex might be a quote or backtick
                my $type     = $+{type};
                my $value    = $+{value};
                my $property = $+{property};
                $property =~ s/['`]//g;
                Koha::Exceptions::Object::BadValue->throw(
                    type     => $type,
                    value    => $value,
                    property => $property =~ /(\w+\.\w+)$/
                    ? $1
                    : $property
                    ,    # results in table.column without quotes or backtics
                );
            }

            # Catch-all for foreign key breakages. It will help find other use cases
            $_->rethrow();
        }
        else {
            $_->rethrow();
        }
    };
}

=head3 remove_from_bundle

Remove this item from any bundle it may have been attached to.

=cut

sub remove_from_bundle {
    my ($self) = @_;

    my $bundle_item_rs = $self->_result->item_bundles_item;
    if ( $bundle_item_rs ) {
        $bundle_item_rs->delete;
        $self->notforloan(0)->store();
        return 1;
    }
    return 0;
}

=head2 Internal methods

=head3 _after_item_action_hooks

Helper method that takes care of calling all plugin hooks

=cut

sub _after_item_action_hooks {
    my ( $self, $params ) = @_;

    my $action = $params->{action};

    Koha::Plugins->call(
        'after_item_action',
        {
            action  => $action,
            item    => $self,
            item_id => $self->itemnumber,
        }
    );
}

=head3 recall

    my $recall = $item->recall;

Return the relevant recall for this item

=cut

sub recall {
    my ( $self ) = @_;
    my @recalls = Koha::Recalls->search(
        {
            biblio_id => $self->biblionumber,
            completed => 0,
        },
        { order_by => { -asc => 'created_date' } }
    )->as_list;
    foreach my $recall (@recalls) {
        if ( $recall->item_level and $recall->item_id == $self->itemnumber ){
            return $recall;
        }
    }
    # no item-level recall to return, so return earliest biblio-level
    # FIXME: eventually this will be based on priority
    return $recalls[0];
}

=head3 can_be_recalled

    if ( $item->can_be_recalled({ patron => $patron_object }) ) # do recall

Does item-level checks and returns if items can be recalled by this borrower

=cut

sub can_be_recalled {
    my ( $self, $params ) = @_;

    return 0 if !( C4::Context->preference('UseRecalls') );

    # check if this item is not for loan, withdrawn or lost
    return 0 if ( $self->notforloan != 0 );
    return 0 if ( $self->itemlost != 0 );
    return 0 if ( $self->withdrawn != 0 );

    # check if this item is not checked out - if not checked out, can't be recalled
    return 0 if ( !defined( $self->checkout ) );

    my $patron = $params->{patron};

    my $branchcode = C4::Context->userenv->{'branch'};
    if ( $patron ) {
        $branchcode = C4::Circulation::_GetCircControlBranch( $self->unblessed, $patron->unblessed );
    }

    # Check the circulation rule for each relevant itemtype for this item
    my $rule = Koha::CirculationRules->get_effective_rules({
        branchcode => $branchcode,
        categorycode => $patron ? $patron->categorycode : undef,
        itemtype => $self->effective_itemtype,
        rules => [
            'recalls_allowed',
            'recalls_per_record',
            'on_shelf_recalls',
        ],
    });

    # check recalls allowed has been set and is not zero
    return 0 if ( !defined($rule->{recalls_allowed}) || $rule->{recalls_allowed} == 0 );

    if ( $patron ) {
        # check borrower has not reached open recalls allowed limit
        return 0 if ( $patron->recalls->filter_by_current->count >= $rule->{recalls_allowed} );

        # check borrower has not reach open recalls allowed per record limit
        return 0 if ( $patron->recalls->filter_by_current->search({ biblio_id => $self->biblionumber })->count >= $rule->{recalls_per_record} );

        # check if this patron has already recalled this item
        return 0 if ( Koha::Recalls->search({ item_id => $self->itemnumber, patron_id => $patron->borrowernumber })->filter_by_current->count > 0 );

        # check if this patron has already checked out this item
        return 0 if ( Koha::Checkouts->search({ itemnumber => $self->itemnumber, borrowernumber => $patron->borrowernumber })->count > 0 );

        # check if this patron has already reserved this item
        return 0 if ( Koha::Holds->search({ itemnumber => $self->itemnumber, borrowernumber => $patron->borrowernumber })->count > 0 );
    }

    # check item availability
    # items are unavailable for recall if they are lost, withdrawn or notforloan
    my @items = Koha::Items->search({ biblionumber => $self->biblionumber, itemlost => 0, withdrawn => 0, notforloan => 0 })->as_list;

    # if there are no available items at all, no recall can be placed
    return 0 if ( scalar @items == 0 );

    my $checked_out_count = 0;
    foreach (@items) {
        if ( Koha::Checkouts->search({ itemnumber => $_->itemnumber })->count > 0 ){ $checked_out_count++; }
    }

    # can't recall if on shelf recalls only allowed when all unavailable, but items are still available for checkout
    return 0 if ( $rule->{on_shelf_recalls} eq 'all' && $checked_out_count < scalar @items );

    # can't recall if no items have been checked out
    return 0 if ( $checked_out_count == 0 );

    # can recall
    return 1;
}

=head3 can_be_waiting_recall

    if ( $item->can_be_waiting_recall ) { # allocate item as waiting for recall

Checks item type and branch of circ rules to return whether this item can be used to fill a recall.
At this point the item has already been recalled. We are now at the checkin and set waiting stage.

=cut

sub can_be_waiting_recall {
    my ( $self ) = @_;

    return 0 if !( C4::Context->preference('UseRecalls') );

    # check if this item is not for loan, withdrawn or lost
    return 0 if ( $self->notforloan != 0 );
    return 0 if ( $self->itemlost != 0 );
    return 0 if ( $self->withdrawn != 0 );

    my $branchcode = $self->holdingbranch;
    if ( C4::Context->preference('CircControl') eq 'PickupLibrary' and C4::Context->userenv and C4::Context->userenv->{'branch'} ) {
        $branchcode = C4::Context->userenv->{'branch'};
    } else {
        $branchcode = ( C4::Context->preference('HomeOrHoldingBranch') eq 'homebranch' ) ? $self->homebranch : $self->holdingbranch;
    }

    # Check the circulation rule for each relevant itemtype for this item
    my $rule = Koha::CirculationRules->get_effective_rules({
        branchcode => $branchcode,
        categorycode => $self->check_recalls ? $self->check_recalls->patron->categorycode : undef,
        itemtype => $self->effective_itemtype,
        rules => [
            'recalls_allowed',
        ],
    });

    # check recalls allowed has been set and is not zero
    return 0 if ( !defined($rule->{recalls_allowed}) || $rule->{recalls_allowed} == 0 );

    # can recall
    return 1;
}

=head3 check_recalls

    my $recall = $item->check_recalls;

Get the most relevant recall for this item.

=cut

sub check_recalls {
    my ( $self ) = @_;

    my @recalls = Koha::Recalls->search(
        {   biblio_id => $self->biblionumber,
            item_id   => [ $self->itemnumber, undef ]
        },
        { order_by => { -asc => 'created_date' } }
    )->filter_by_current->as_list;

    my $recall;
    # iterate through relevant recalls to find the best one.
    # if we come across a waiting recall, use this one.
    # if we have iterated through all recalls and not found a waiting recall, use the first recall in the array, which should be the oldest recall.
    foreach my $r ( @recalls ) {
        if ( $r->waiting ) {
            $recall = $r;
            last;
        }
    }
    unless ( defined $recall ) {
        $recall = $recalls[0];
    }

    return $recall;
}

=head3 is_notforloan

    my $is_notforloan = $item->is_notforloan;

Determine whether or not this item is "notforloan" based on
the item's notforloan status or its item type

=cut

sub is_notforloan {
    my ( $self ) = @_;
    my $is_notforloan = 0;

    if ( $self->notforloan ){
        $is_notforloan = 1;
    }
    else {
        my $itemtype = $self->itemtype;
        if ($itemtype){
            if ( $itemtype->notforloan ){
                $is_notforloan = 1;
            }
        }
    }

    return $is_notforloan;
}

=head3 is_denied_renewal

    my $is_denied_renewal = $item->is_denied_renewal;

Determine whether or not this item can be renewed based on the
rules set in the ItemsDeniedRenewal system preference.

=cut

sub is_denied_renewal {
    my ( $self ) = @_;

    my $denyingrules = Koha::Config::SysPrefs->find('ItemsDeniedRenewal')->get_yaml_pref_hash();
    return 0 unless $denyingrules;
    foreach my $field (keys %$denyingrules) {
        my $val = $self->$field;
        if( !defined $val) {
            if ( any { !defined $_ }  @{$denyingrules->{$field}} ){
                return 1;
            }
        } elsif (any { defined($_) && $val eq $_ } @{$denyingrules->{$field}}) {
           # If the results matches the values in the syspref
           # We return true if match found
            return 1;
        }
    }
    return 0;
}

=head3 strings_map

Returns a map of column name to string representations including the string,
the mapping type and the mapping category where appropriate.

Currently handles authorised value mappings, library, callnumber and itemtype
expansions.

Accepts a param hashref where the 'public' key denotes whether we want the public
or staff client strings.

=cut

sub strings_map {
    my ( $self, $params ) = @_;

    my $columns_info  = $self->_result->result_source->columns_info;
    my $frameworkcode = $self->biblio->frameworkcode;
    my $tagslib       = C4::Biblio::GetMarcStructure( 1, $frameworkcode );
    my $mss           = C4::Biblio::GetMarcSubfieldStructure( $frameworkcode, { unsafe => 1 } );

    my ( $itemtagfield, $itemtagsubfield ) = C4::Biblio::GetMarcFromKohaField("items.itemnumber");

    # Hardcoded known 'authorised_value' values mapped to API codes
    my $code_to_type = {
        branches  => 'library',
        cn_source => 'call_number_source',
        itemtypes => 'item_type',
    };

    # Handle not null and default values for integers and dates
    my $strings = {};

    foreach my $col ( keys %{$columns_info} ) {

        # By now, we are done with known columns, now check the framework for mappings
        my $field = $self->_result->result_source->name . '.' . $col;

        # Check there's an entry in the MARC subfield structure for the field
        if (   exists $mss->{$field}
            && scalar @{ $mss->{$field} } > 0
            && $mss->{$field}[0]->{authorised_value} )
        {
            my $subfield = $mss->{$field}[0];
            my $code     = $subfield->{authorised_value};

            my $str  = C4::Biblio::GetAuthorisedValueDesc( $itemtagfield, $subfield->{tagsubfield}, $self->$col, '', $tagslib, undef, $params->{public} );
            my $type = exists $code_to_type->{$code} ? $code_to_type->{$code} : 'av';
            $strings->{$col} = {
                str  => $str,
                type => $type,
                ( $type eq 'av' ? ( category => $code ) : () ),
            };
        }
    }

    return $strings;
}

=head3 _type

=cut

sub _type {
    return 'Item';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
