package Koha::REST::V1::Clubs::Holds;

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

use C4::Reserves;

use Koha::Items;
use Koha::Patrons;
use Koha::Holds;
use Koha::Clubs;
use Koha::Club::Hold;

use Scalar::Util qw( blessed );
use Try::Tiny qw( catch try );

=head1 API

=head2 Class methods

=head3 add

Method that handles adding a new Koha::Hold object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $body    = $c->req->json;
        my $club_id = $c->param('club_id');

        my $biblio;

        my $biblio_id         = $body->{biblio_id};
        my $pickup_library_id = $body->{pickup_library_id};
        my $item_id           = $body->{item_id};
        my $item_type         = $body->{item_type};
        my $expiration_date   = $body->{expiration_date};
        my $notes             = $body->{notes};
        my $default_patron_home = $body->{default_patron_home};

        if ( $item_id and $biblio_id ) {

            # check they are consistent
            unless ( Koha::Items->search( { itemnumber => $item_id, biblionumber => $biblio_id } )
                ->count > 0 )
            {
                return $c->render(
                    status  => 400,
                    openapi => { error => "Item $item_id doesn't belong to biblio $biblio_id" }
                );
            }
            else {
                $biblio = Koha::Biblios->find($biblio_id);
            }
        }
        elsif ($item_id) {
            my $item = Koha::Items->find($item_id);

            unless ($item) {
                return $c->render(
                    status  => 404,
                    openapi => { error => "Item not found" }
                );
            }
            else {
                $biblio = $item->biblio;
            }
        }
        elsif ($biblio_id) {
            $biblio = Koha::Biblios->find($biblio_id);
        }
        else {
            return $c->render(
                status  => 400,
                openapi => { error => "At least one of biblio_id, item_id should be given" }
            );
        }

        unless ($biblio) {
            return $c->render(
                status  => 404,
                openapi => { error => "Biblio not found" }
            );
        }

        my $club_hold = Koha::Club::Hold::add(
            {
                club_id             => $club_id,
                biblio_id           => $biblio->biblionumber,
                item_id             => $item_id,
                pickup_library_id   => $pickup_library_id,
                expiration_date     => $expiration_date,
                notes               => $notes,
                item_type           => $item_type,
                default_patron_home => $default_patron_home
            }
        );

        return $c->render(
            status  => 201,
            openapi => $club_hold->to_api
        );
    }
    catch {
        if ( blessed $_ ) {
            if ($_->isa('Koha::Exceptions::ClubHold::NoPatrons')) {
                return $c->render(
                    status  => 409,
                    openapi => { error => $_->description }
                );
            }
        }

        $c->unhandled_exception($_);
    };
}

1;
