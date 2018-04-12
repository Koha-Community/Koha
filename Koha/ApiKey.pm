package Koha::ApiKey;

# Copyright BibLibre 2015
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
use Koha::Exceptions;

use UUID;

use base qw(Koha::Object);

=head1 NAME

Koha::ApiKey - Koha API Key Object class

=head1 API

=head2 Class methods

=head3 store

    my $api_key = Koha::ApiKey->new({ patron_id => $patron_id })->store;

Overloaded I<store> method.

=cut

sub store {
    my ($self) = @_;

    my ( $uuid, $uuidstring );

    $self->client_id($self->_generate_unused_uuid('client_id'));
    $self->secret($self->_generate_unused_uuid('secret'));

    return $self->SUPER::store();
}

=head2 Internal methods

=cut

=head3 _type

=cut

sub _type {
    return 'ApiKey';
}

=head3 _generate_unused_uuid

    my $string = $self->_generate_unused_uuid($column);

$column can be 'client_id' or 'secret'.

=cut

sub _generate_unused_uuid {
    my ($self, $column) = @_;

    my ( $uuid, $uuidstring );

    UUID::generate($uuid);
    UUID::unparse( $uuid, $uuidstring );

    while ( Koha::ApiKeys->search({ $column => $uuidstring })->count > 0 ) {
        # Make sure $secret is unique
        UUID::generate($uuid);
        UUID::unparse( $uuid, $uuidstring );
    }

    return $uuidstring;
}

1;
