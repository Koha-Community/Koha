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
use Koha::Exceptions;
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

    # if issue_id is not found in issues or old_issues, set to null
    $self->issue_id(undef) unless ( !$self->issue_id
        || Koha::Checkouts->find( $self->issue_id )
        || Koha::Old::Checkouts->find( $self->issue_id ) );

    return $self->SUPER::store;
}

=head3 checkout

=cut

sub checkout {
    my ($self) = @_;

    my $checkout_rs = $self->_result->checkout;
    return unless $checkout_rs;
    return Koha::Checkout->_new_from_dbic($checkout_rs);
}

=head3 old_checkout

=cut

sub old_checkout {
    my ($self) = @_;

    my $old_checkout_rs = $self->_result->old_checkout;
    return unless $old_checkout_rs;
    return Koha::Old::Checkout->_new_from_dbic($old_checkout_rs);
}

=head3 patron

=cut

sub patron {
    my ( $self ) = @_;

    my $borrower = $self->_result->borrowernumber;
    return Koha::Patron->_new_from_dbic( $borrower ) if $borrower;
}

=head3 item

  my $item = $claim->item;

Return the return claim item

=cut

sub item {
    my ( $self ) = @_;
    my $item_rs = $self->_result->item;
    return Koha::Item->_new_from_dbic( $item_rs );
}

=head3 resolve

    $claim->resolve(
        {
            resolution      => $resolution,
            resolved_by     => $patron_id,
          [ resolved_on     => $dt
            new_lost_status => $status, ]
        }
    );

Resolve the claim.

=cut

sub resolve {
    my ( $self, $params ) = @_;

    my @mandatory = ( 'resolution', 'resolved_by' );
    for my $param (@mandatory) {
        unless ( defined( $params->{$param} ) ) {
            Koha::Exceptions::MissingParameter->throw( error => "The $param parameter is mandatory" );
        }
    }

    $self->_result->result_source->schema->txn_do(
        sub {
            $self->set(
                {   resolution  => $params->{resolution},
                    resolved_by => $params->{resolved_by},
                    resolved_on => $params->{resolved_on} // \'NOW()',
                    updated_by  => $params->{resolved_by}
                }
            )->store;

            if ( defined $params->{new_lost_status} ) {
                $self->item->itemlost( $params->{new_lost_status} )->store;
            }
        }
    );

    return $self;
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
