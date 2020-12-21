package Koha::Checkouts::ReturnClaim;

# Copyright ByWater Solutions 2019
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

use base qw(Koha::Object);

use Koha::Checkouts;
use Koha::Exceptions::Checkouts::ReturnClaims;
use Koha::Old::Checkouts;
use Koha::Patrons;

=head1 NAME

Koha::Checkouts::ReturnClaim - Koha ReturnClaim object class

=head1 API

=head2 Class methods

=cut

=head3 store

    my $return_claim = Koha::Checkout::ReturnClaim->new($args)->store;

Overloaded I<store> method that validates the attributes and raises relevant
exceptions as needed.

=cut

sub store {
    my ( $self ) = @_;

    unless ( $self->in_storage || $self->created_by ) {
        Koha::Exceptions::Checkouts::ReturnClaims::NoCreatedBy->throw();
    }

    return $self->SUPER::store;
}

=head3 checkout

=cut

sub checkout {
    my ($self) = @_;

    my $checkout = Koha::Checkouts->find( $self->issue_id )
      || Koha::Old::Checkouts->find( $self->issue_id );

    return $checkout;
}

=head3 patron

=cut

sub patron {
    my ( $self ) = @_;

    my $borrower = $self->_result->borrowernumber;
    return Koha::Patron->_new_from_dbic( $borrower ) if $borrower;
}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::Checkouts::ReturnClaim object
on the API.

=cut

sub to_api_mapping {
    return {
        id             => 'claim_id',
        itemnumber     => 'item_id',
        borrowernumber => 'patron_id',
    };
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'ReturnClaim';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
