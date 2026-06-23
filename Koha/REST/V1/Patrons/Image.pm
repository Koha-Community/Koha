package Koha::REST::V1::Patrons::Image;

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

use Try::Tiny qw( catch try );

=head1 NAME

Koha::REST::V1::Patrons::Image

=head1 API

=head2 Methods

=head3 get

Controller method that gets a patron's image

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    unless ( C4::Context->preference('patronimages') ) {
        return $c->render(
            status  => 403,
            openapi => { error => "Patron images are disabled." }
        );
    }

    my $patron = Koha::Patrons->find( $c->param('patron_id') );

    unless ($patron) {
        return $c->render(
            status  => 404,
            openapi => { error => "Patron not found." }
        );
    }

    return try {
        my $image = $patron->image;

        unless ($image) {
            return $c->render(
                status  => 404,
                openapi => { error => "Patron image not found." }
            );
        }

        return $c->render(
            status => 200,
            format => "png",              # currently all patron images are converted to png upon upload
            data   => $image->imagefile
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
