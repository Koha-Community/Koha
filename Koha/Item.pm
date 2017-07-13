package Koha::Item;

# Copyright ByWater Solutions 2014
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Carp;
use List::MoreUtils qw(any);

use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

use C4::Context;
use C4::Circulation;
use C4::Reserves;
use Koha::Checkouts;
use Koha::CirculationRules;
use Koha::Item::Transfer::Limits;
use Koha::Item::Transfers;
use Koha::Patrons;
use Koha::Libraries;
use Koha::StockRotationItem;
use Koha::StockRotationRotas;

use base qw(Koha::Object);

=head1 NAME

Koha::Item - Koha Item object class

=head1 API

=head2 Class methods

=cut

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

@pickup_locations = $item->pickup_locations( {patron => $patron } )

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
        return @libs if $branchitemrule->{holdallowed} == 3 && !$self->home_branch->validate_hold_sibling( {branchcode => $patron->branchcode} );
        return @libs if $branchitemrule->{holdallowed} == 1 && $self->home_branch->branchcode ne $patron->branchcode;
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

    return wantarray ? @pickup_locations : \@pickup_locations;
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

        push @subfields, $tagsubfield => $self->$item_field;
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

=head3 _type

=cut

sub _type {
    return 'Item';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
