package Koha::REST::V1::ILL::Backends;

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

use Koha::ILL::Request::Config;
use Koha::ILL::Requests;
use Koha::ILL::Backend;

=head1 NAME

Koha::REST::V1::ILL::Backends

=head2 Operations

=head3 list

Return a list of available ILL backends and its capabilities

=cut

sub list {
    my $c = shift->openapi->valid_input;

    my $config         = Koha::ILL::Request::Config->new;
    my $backends       = $config->available_backends;
    my $backend_module = Koha::ILL::Backend->new;

    my @data;
    foreach my $b (@$backends) {
        my $backend = Koha::ILL::Request->new->load_backend($b);

        my $embed = $backend_module->embed(
            $b,
            $c->req->headers->header('x-koha-embed')
        );

        my $return = {
            ill_backend_id => $b,
            capabilities   => $backend->capabilities,
        };
        push @data, $embed ? { %$return, %$embed } : $return;
    }
    return $c->render( status => 200, openapi => \@data );
}

=head3 get

Get one backend

=cut

sub get {
    my $c = shift->openapi->valid_input;

    my $backend_id = $c->param('ill_backend_id');

    return try {

        #FIXME: Should we move load_backend into Koha::ILL::Backend...
        #       or maybe make Koha::Ill::Backend a base class for all
        #       backends?
        my $backend = Koha::ILL::Request->new->load_backend($backend_id);

        my $backend_module = Koha::ILL::Backend->new;

        my $embed = $backend_module->embed(
            $backend_id,
            $c->req->headers->header('x-koha-embed')
        );

        #TODO: We need a to_api method in Koha::ILL::Backend
        my $return = {
            ill_backend_id => $backend_id,
            capabilities   => $backend->capabilities,
        };

        return $c->render(
            status  => 200,
            openapi => $embed ? { %$return, %$embed } : $return,
        );
    } catch {
        return $c->render_resource_not_found("ILL backend");
    };
}

1;
