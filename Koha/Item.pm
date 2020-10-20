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

use Carp;
use List::MoreUtils qw(any);
use Data::Dumper;
use Try::Tiny;

use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

use C4::Context;
use C4::Circulation;
use C4::Reserves;
use C4::ClassSource; # FIXME We would like to avoid that
use C4::Log qw( logaction );

use Koha::Checkouts;
use Koha::CirculationRules;
use Koha::SearchEngine::Indexer;
use Koha::Item::Transfer::Limits;
use Koha::Item::Transfers;
use Koha::Patrons;
use Koha::Plugins;
use Koha::Libraries;
use Koha::StockRotationItem;
use Koha::StockRotationRotas;

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

NOTE: This is a temporary fix to answer a performance issue when lot of items
are added (or modified) at the same time.
The correct way to fix this is to make the ES reindexation process async.
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

    my $today = dt_from_string;
    unless ( $self->in_storage ) { #AddItem
        unless ( $self->permanent_location ) {
            $self->permanent_location($self->location);
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

        logaction( "CATALOGUING", "ADD", $self->itemnumber, "item" )
          if $log_action && C4::Context->preference("CataloguingLog");

        $self->_after_item_action_hooks({ action => 'create' });

    } else { # ModItem

        { # Update *_on  fields if needed
          # Why not for AddItem as well?
            my @fields = qw( itemlost withdrawn damaged );

            # Only retrieve the item if we need to set an "on" date field
            if ( $self->itemlost || $self->withdrawn || $self->damaged ) {
                my $pre_mod_item = $self->get_from_storage;
                for my $field (@fields) {
                    if (    $self->$field
                        and not $pre_mod_item->$field )
                    {
                        my $field_on = "${field}_on";
                        $self->$field_on(
                          DateTime::Format::MySQL->format_datetime( dt_from_string() )
                        );
                    }
                }
            }

            # If the field is defined but empty, we are removing and,
            # and thus need to clear out the 'on' field as well
            for my $field (@fields) {
                if ( defined( $self->$field ) && !$self->$field ) {
                    my $field_on = "${field}_on";
                    $self->$field_on(undef);
                }
            }
        }

        my %updated_columns = $self->_result->get_dirty_columns;
        return $self->SUPER::store unless %updated_columns;

        if (   exists $updated_columns{itemcallnumber}
            or exists $updated_columns{cn_source} )
        {
            my $cn_sort = GetClassSort( $self->cn_source, $self->itemcallnumber, "" );
            $self->cn_sort($cn_sort);
        }


        if (    exists $updated_columns{location}
            and $self->location ne 'CART'
            and $self->location ne 'PROC'
            and not exists $updated_columns{permanent_location} )
        {
            $self->permanent_location( $self->location );
        }

        $self->_after_item_action_hooks({ action => 'modify' });

        logaction( "CATALOGUING", "MODIFY", $self->itemnumber, "item " . Dumper($self->unblessed) )
          if $log_action && C4::Context->preference("CataloguingLog");
    }

    unless ( $self->dateaccessioned ) {
        $self->dateaccessioned($today);
    }

    my $result = $self->SUPER::store;
    my $indexer = Koha::SearchEngine::Indexer->new({ index => $Koha::SearchEngine::BIBLIOS_INDEX });
    $indexer->index_records( $self->biblionumber, "specialUpdate", "biblioserver" )
        unless $params->{skip_record_index};

    return $result;
}

=head3 delete

=cut

sub delete {
    my $self = shift;
    my $params = @_ ? shift : {};

    # FIXME check the item has no current issues
    # i.e. raise the appropriate exception

    my $result = $self->SUPER::delete;

    my $indexer = Koha::SearchEngine::Indexer->new({ index => $Koha::SearchEngine::BIBLIOS_INDEX });
    $indexer->index_records( $self->biblionumber, "specialUpdate", "biblioserver" )
        unless $params->{skip_record_index};

    $self->_after_item_action_hooks({ action => 'delete' });

    logaction( "CATALOGUING", "DELETE", $self->itemnumber, "item" )
      if C4::Context->preference("CataloguingLog");

    return $result;
}

=head3 safe_delete

=cut

sub safe_delete {
    my $self = shift;
    my $params = @_ ? shift : {};

    my $safe_to_delete = $self->safe_to_delete;
    return $safe_to_delete unless $safe_to_delete eq '1';

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

    return "book_on_loan" if $self->checkout;

    return "not_same_branch"
      if defined C4::Context->userenv
      and !C4::Context->IsSuperLibrarian()
      and C4::Context->preference("IndependentBranches")
      and ( C4::Context->userenv->{branch} ne $self->homebranch );

    # check it doesn't have a waiting reserve
    return "book_reserved"
      if $self->holds->search( { found => [ 'W', 'T' ] } )->count;

    return "linked_analytics"
      if C4::Items::GetAnalyticsCount( $self->itemnumber ) > 0;

    return "last_item_for_hold"
      if $self->biblio->items->count == 1
      && $self->biblio->holds->search(
          {
              itemnumber => undef,
          }
        )->count;

    return 1;
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

    $self->{_home_branch} ||= Koha::Libraries->find( $self->homebranch() );

    return $self->{_home_branch};
}

=head3 holding_branch

=cut

sub holding_branch {
    my ($self) = @_;

    $self->{_holding_branch} ||= Koha::Libraries->find( $self->holdingbranch() );

    return $self->{_holding_branch};
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

=head3 get_transfer

my $transfer = $item->get_transfer;

Return the transfer if the item is in transit or undef

=cut

sub get_transfer {
    my ( $self ) = @_;
    my $transfer_rs = $self->_result->branchtransfers->search({ datearrived => undef })->first;
    return unless $transfer_rs;
    return Koha::Item::Transfer->_new_from_dbic( $transfer_rs );
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

$pickup_locations = $item->pickup_locations( {patron => $patron } )

Returns possible pickup locations for this item, according to patron's home library (if patron is defined and holds are allowed only from hold groups)
and if item can be transferred to each pickup location.

=cut

sub pickup_locations {
    my ($self, $params) = @_;

    my $patron = $params->{patron};

    my $circ_control_branch =
      C4::Reserves::GetReservesControlBranch( $self->unblessed(), $patron->unblessed );
    my $branchitemrule =
      C4::Circulation::GetBranchItemRule( $circ_control_branch, $self->itype );

    my @libs;
    if(defined $patron) {
        return \@libs if $branchitemrule->{holdallowed} == 3 && !$self->home_branch->validate_hold_sibling( {branchcode => $patron->branchcode} );
        return \@libs if $branchitemrule->{holdallowed} == 1 && $self->home_branch->branchcode ne $patron->branchcode;
    }

    if ($branchitemrule->{hold_fulfillment_policy} eq 'holdgroup') {
        @libs  = $self->home_branch->get_hold_libraries;
        push @libs, $self->home_branch unless scalar(@libs) > 0;
    } elsif ($branchitemrule->{hold_fulfillment_policy} eq 'patrongroup') {
        my $plib = Koha::Libraries->find({ branchcode => $patron->branchcode});
        @libs  = $plib->get_hold_libraries;
        push @libs, $self->home_branch unless scalar(@libs) > 0;
    } elsif ($branchitemrule->{hold_fulfillment_policy} eq 'homebranch') {
        push @libs, $self->home_branch;
    } elsif ($branchitemrule->{hold_fulfillment_policy} eq 'holdingbranch') {
        push @libs, $self->holding_branch;
    } else {
        @libs = Koha::Libraries->search({
            pickup_location => 1
        }, {
            order_by => ['branchname']
        })->as_list;
    }

    my @pickup_locations;
    foreach my $library (@libs) {
        if ($library->pickup_location && $self->can_be_transferred({ to => $library })) {
            push @pickup_locations, $library;
        }
    }

    return \@pickup_locations;
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

=head3 as_marc_field

    my $mss   = C4::Biblio::GetMarcSubfieldStructure( '', { unsafe => 1 } );
    my $field = $item->as_marc_field({ [ mss => $mss ] });

This method returns a MARC::Field object representing the Koha::Item object
with the current mappings configuration.

=cut

sub as_marc_field {
    my ( $self, $params ) = @_;

    my $mss = $params->{mss} // C4::Biblio::GetMarcSubfieldStructure( '', { unsafe => 1 } );
    my $item_tag = $mss->{'items.itemnumber'}[0]->{tagfield};

    my @subfields;

    my @columns = $self->_result->result_source->columns;

    foreach my $item_field ( @columns ) {
        my $mapping = $mss->{ "items.$item_field"}[0];
        my $tagfield    = $mapping->{tagfield};
        my $tagsubfield = $mapping->{tagsubfield};
        next if !$tagfield; # TODO: Should we raise an exception instead?
                            # Feels like safe fallback is better

        push @subfields, $tagsubfield => $self->$item_field
            if defined $self->$item_field and $item_field ne '';
    }

    my $unlinked_item_subfields = C4::Items::_parse_unlinked_item_subfields_from_xml($self->more_subfields_xml);
    push( @subfields, @{$unlinked_item_subfields} )
        if defined $unlinked_item_subfields and $#$unlinked_item_subfields > -1;

    my $field;

    $field = MARC::Field->new(
        "$item_tag", ' ', ' ', @subfields
    ) if @subfields;

    return $field;
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
        paidfor                  => undef,
        timestamp                => 'timestamp',
        location                 => 'location',
        permanent_location       => 'permanent_location',
        onloan                   => 'checked_out_date',
        cn_source                => 'call_number_source',
        cn_sort                  => 'call_number_sort',
        ccode                    => 'collection_code',
        materials                => 'materials_notes',
        uri                      => 'uri',
        itype                    => 'item_type',
        more_subfields_xml       => 'extended_subfields',
        enumchron                => 'serial_issue_number',
        copynumber               => 'copy_number',
        stocknumber              => 'inventory_number',
        new_status               => 'new_status'
    };
}

=head2 Internal methods

=head3 _after_item_action_hooks

Helper method that takes care of calling all plugin hooks

=cut

sub _after_item_action_hooks {
    my ( $self, $params ) = @_;

    my $action = $params->{action};

    if ( C4::Context->config("enable_plugins") ) {

        my @plugins = Koha::Plugins->new->GetPlugins({
            method => 'after_item_action',
        });

        if (@plugins) {

            foreach my $plugin ( @plugins ) {
                try {
                    $plugin->after_item_action({ action => $action, item => $self, item_id => $self->itemnumber });
                }
                catch {
                    warn "$_";
                };
            }
        }
    }
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
