package Koha::REST::V1::Illbackends;

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

use Mojo::Base 'Mojolicious::Controller';

use Koha::Illrequest::Config;
use Koha::Illrequests;
use Koha::Illbackend;

=head1 NAME

Koha::REST::V1::Illbackends

=head2 Operations

=head3 list

Return a list of available ILL backends and its capabilities

=cut

sub list {
    my $c = shift->openapi->valid_input;

    my $config   = Koha::Illrequest::Config->new;
    my $backends = $config->available_backends;

    my @data;
    foreach my $b (@$backends) {
        my $backend = Koha::Illrequest->new->load_backend($b);
        push @data,
          {
            ill_backend_id => $b,
            capabilities   => $backend->capabilities,
          };
    }
    return $c->render( status => 200, openapi => \@data );
}

=head3 get

Get one backend

=cut

sub get {
    my $c = shift->openapi->valid_input;

    my $backend_id = $c->validation->param('ill_backend_id');

    return try {

        #FIXME: Should we move load_backend into Koha::Illbackend...
        #       or maybe make Koha::Ill::Backend a base class for all
        #       backends?
        my $backend = Koha::Illrequest->new->load_backend($backend_id);

        my $backend_module = Koha::Illbackend->new;

        my $embed =
          $backend_module->embed( $backend_id,
            $c->req->headers->header('x-koha-embed') );

        #TODO: We need a to_api method in Koha::Illbackend
        my $return = {
            ill_backend_id => $backend_id,
            capabilities   => $backend->capabilities,
        };

        return $c->render(
            status  => 200,
            openapi => $embed ? { %$return, %$embed } : $return,
        );
    }
    catch {
        return $c->render(
            status  => 404,
            openapi => { error => "ILL backend does not exist" }
        );
    };
}

1;
