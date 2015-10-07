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

use Koha::Database;

use C4::Context;
use C4::Circulation qw(GetIssuingRule);
use Koha::Item::Transfer;
use Koha::Patrons;
use Koha::Libraries;

use base qw(Koha::Object);

=head1 NAME

Koha::Item - Koha Item object class

=head1 API

=head2 Class Methods

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
    my $rules = C4::Circulation::GetIssuingRule( $borrowertype, $itemtype, $branchcode );

    return $rules->{article_requests} || q{};
}

=head3 type

=cut

sub _type {
    return 'Item';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
