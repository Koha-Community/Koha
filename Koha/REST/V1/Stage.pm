package Koha::REST::V1::Stage;

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

use Koha::StockRotationRotas;
use Koha::StockRotationStages;

=head1 NAME

Koha::REST::V1::Stage

=head2 Operations

=head3 move

Move a stage up or down the stockrotation rota.

=cut

sub move {
    my $c = shift->openapi->valid_input or return;

    my $rota  = Koha::StockRotationRotas->find( $c->param('rota_id') );
    my $stage = Koha::StockRotationStages->find( $c->param('stage_id') );

    if ( $stage && $rota ) {
        my $result = $stage->move_to( $c->req->json );
        return $c->render( openapi => {}, status => 200 ) if $result;
        return $c->render(
            openapi => { error => "Bad request - new position invalid" },
            status  => 400
        );
    }
    else {
        return $c->render(
            openapi => { error => "Not found - Invalid rota or stage ID" },
            status  => 404
        );
    }
}

1;
