package Koha::REST::V1::StockRotation::Rotas;

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

use Koha::StockRotationRotas;

use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $rotas = $c->objects->search( Koha::StockRotationRotas->new );
        return $c->render( status => 200, openapi => $rotas );
    } catch {
        $c->unhandled_exception($_);
    };

}

=head3 get

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $rota = Koha::StockRotationRotas->find( $c->param('rota_id') );

        return $c->render_resource_not_found("Rota")
            unless $rota;

        return $c->render(
            status  => 200,
            openapi => $c->objects->to_api($rota),
        );
    } catch {
        $c->unhandled_exception($_);
    }
}

=head3 add

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $rota = Koha::StockRotationRota->new_from_api( $c->req->json );
        $rota->store;
        $c->res->headers->location( $c->req->url->to_string . '/' . $rota->rota_id );
        return $c->render(
            status  => 201,
            openapi => $c->objects->to_api($rota),
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 update

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $rota = Koha::StockRotationRotas->find( $c->param('rota_id') );

    return $c->render_resource_not_found("Rota")
        unless $rota;

    return try {
        $rota->set_from_api( $c->req->json );
        $rota->store();
        return $c->render(
            status  => 200,
            openapi => $c->objects->to_api($rota),
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 delete

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $rota = Koha::StockRotationRotas->find( $c->param('rota_id') );

    return $c->render_resource_not_found("Rota")
        unless $rota;

    return try {
        $rota->delete;
        return $c->render_resource_deleted;
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
