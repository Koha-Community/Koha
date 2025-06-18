package Koha::Checkouts::Renewal;

# Copyright PTFS Europe 2022
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use base qw(Koha::Object);

use Koha::Checkouts;
use Koha::Exceptions::Object;
use Koha::Old::Checkouts;
use Koha::Patrons;

=head1 NAME

Koha::Checkouts::Renewal - Koha Renewal object class

=head1 API

=head2 Class methods

=cut

=head3 store

    my $renewal = Koha::Checkout::Renewal->new($args)->store;

Overloaded I<store> method that validates the attributes and raises relevant
exceptions as needed.

=cut

sub store {
    my ($self) = @_;

    unless ( ( !$self->checkout_id && $self->in_storage )
        || Koha::Checkouts->find( $self->checkout_id )
        || Koha::Old::Checkouts->find( $self->checkout_id ) )
    {
        Koha::Exceptions::Object::FKConstraint->throw(
            error     => 'Broken FK constraint',
            broken_fk => 'checkout_id'
        );
    }

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

=head3 renewer

=cut

sub renewer {
    my ($self) = @_;

    my $renewer = $self->_result->renewer;
    return Koha::Patron->_new_from_dbic($renewer) if $renewer;
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'CheckoutRenewal';
}

=head1 AUTHOR

Martin Renvoize <martin.renvoize@ptfs-europe.com>

=cut

1;
