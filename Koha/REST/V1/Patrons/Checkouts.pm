package Koha::REST::V1::Patrons::Checkouts;

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

use Mojo::Base 'Mojolicious::Controller';

use Koha::Patrons;

=head1 NAME

Koha::REST::V1::Patrons::Checkouts

=head1 API

=head2 Methods

=head3 list

Controller function that handles listing Koha::Checkout objects for the requested patron

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    my $patron = Koha::Patrons->find( $c->param('patron_id') );

    return $c->render_resource_not_found("Patron")
        unless $patron;

    return try {

        return $c->render(
            status  => 200,
            openapi => $c->objects->search( $patron->checkouts ),
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
