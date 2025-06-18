package Koha::REST::V1::Lists;

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

use Koha::Virtualshelves;

use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 list_public

=cut

sub list_public {
    my $c = shift->openapi->valid_input or return;

    my $user = $c->stash('koha.user');

    my $only_mine   = $c->param('only_mine');
    my $only_public = $c->param('only_public');

    $c->req->params->remove('only_mine')->remove('only_public');

    if ( !$user && $only_mine ) {
        return $c->render(
            status  => 400,
            openapi => {
                error      => "Bad request - only_mine can only be passed by logged in users",
                error_code => "only_mine_forbidden",
            },
        );
    }

    return try {

        my $lists_set = Koha::Virtualshelves->new;

        if ($only_mine) {
            $lists_set = $lists_set->search( { owner => $user->id } );
        }

        if ( $only_public || !$user ) {
            $lists_set = $lists_set->filter_by_public;
        } else {
            $lists_set = $lists_set->filter_by_readable( { patron_id => $user->id } );
        }

        return $c->render(
            status  => 200,
            openapi => $c->objects->search($lists_set),
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
