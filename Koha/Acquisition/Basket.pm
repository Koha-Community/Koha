package Koha::Acquisition::Basket;

# Copyright 2017 Aleisha Amohia <aleisha@catalyst.net.nz>
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

use Koha::Database;
use Koha::Acquisition::BasketGroups;

use base qw( Koha::Object );

=head1 NAME

Koha::Acquisition::Basket - Koha Basket Object class

=head1 API

=head2 Class Methods

=cut

=head3 bookseller

Returns the vendor

=cut

sub bookseller {
    my ($self) = @_;
    my $bookseller_rs = $self->_result->booksellerid;
    return Koha::Acquisition::Bookseller->_new_from_dbic( $bookseller_rs );
}

=head3 basket_group

Returns the basket group associated to this basket

=cut

sub basket_group {
    my ($self) = @_;
    my $basket_group_rs = $self->_result->basketgroupid;
    return unless $basket_group_rs;
    return Koha::Acquisition::BasketGroup->_new_from_dbic( $basket_group_rs );
}

=head3 effective_create_items

Returns C<create_items> for this basket, falling back to C<AcqCreateItem> if unset.

=cut

sub effective_create_items {
    my ( $self ) = @_;

    return $self->create_items || C4::Context->preference('AcqCreateItem');
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'Aqbasket';
}

=head1 AUTHOR

Aleisha Amohia <aleisha@catalyst.net.nz>
Catalyst IT

=cut

1;
