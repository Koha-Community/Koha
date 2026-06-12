package Koha::REST::V1::Holds::Queue;

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

use Mojo::Base 'Mojolicious::Controller';

use Clone qw( clone );

use Koha::Biblios;
use Koha::Hold::HoldsQueueItems;

use C4::Context;
use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $queue = Koha::Hold::HoldsQueueItems->new;
        my @query_fixers;

        my $embed = $c->stash('koha.embed');
        if ( exists $embed->{biblio} ) {
            my $fixed_embed = clone($embed);
            $fixed_embed->{biblio}->{children}->{biblioitem} = {};
            $c->stash( 'koha.embed', $fixed_embed );
            push @query_fixers, ( sub { Koha::Biblios->new->api_query_fixer( $_[0], 'biblio', $_[1] ) } );
        }

        my $items = $c->objects->search( $queue, \@query_fixers );

        # TODO: HidePatronName should be handled generically in Koha::Patron->to_api
        # so all endpoints respect it without per-controller redaction logic.
        if ( C4::Context->preference('HidePatronName') && !$c->stash('koha.user')->is_superlibrarian ) {
            for my $item (@$items) {
                next unless $item->{patron};
                my $patron = $item->{patron};
                $item->{patron} = {
                    patron_id   => $patron->{patron_id},
                    cardnumber  => $patron->{cardnumber},
                    category_id => $patron->{category_id},
                    ( category => $patron->{category} ) x !!$patron->{category},
                };
            }
        }

        return $c->render( status => 200, openapi => $items );
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
