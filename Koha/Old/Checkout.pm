package Koha::Old::Checkout;

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

use Koha::Database;

use base qw(Koha::Object);

=head1 NAME

Koha::Old:Checkout - Koha checkout object for returned items

=head1 API

=head2 Class Methods

=head3 item

my $item = $checkout->item;

Return the checked out item

=cut

sub item {
    my ( $self ) = @_;
    my $item_rs = $self->_result->item;
    return Koha::Item->_new_from_dbic( $item_rs );
}

=head3 patron

my $patron = $checkout->patron

Return the patron for who the checkout has been done

=cut

sub patron {
    my ( $self ) = @_;
    my $patron_rs = $self->_result->borrower;
    return Koha::Patron->_new_from_dbic( $patron_rs );
}

sub _type {
    return 'OldIssue';
}

1;
