package Koha::REST::V1::SIP2::ServerParams;

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

use Koha::SIP2::ServerParam;
use Koha::SIP2::ServerParams;

use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $server_params = $c->objects->search( Koha::SIP2::ServerParams->new );
        return $c->render( status => 200, openapi => $server_params );
    } catch {
        $c->unhandled_exception($_);
    };

}

sub update_server_params {
    my ($c) = @_;

    my $body = $c->req->json;

    unless ( $body && ref $body eq 'ARRAY' ) {
        return $c->render(
            status  => 400,
            openapi => { error => "Invalid request body" }
        );
    }

    foreach my $server_param (@$body) {
        my $server_param_id  = $server_param->{key};
        my $server_param_obj = Koha::SIP2::ServerParams->search( { key => $server_param->{key} } )->last;

        if ( !$server_param_obj ) {
            try {
                Koha::Database->new->schema->txn_do(
                    sub {
                        $server_param_obj = Koha::SIP2::ServerParam->new_from_api($server_param)->store;
                    }
                );
            } catch {
                if ( blessed $_ ) {
                    if ( $_->isa('Koha::Exceptions::BadParameter') ) {
                        return $c->render(
                            status => 400,
                            json   => { message => 'Some error occurred' }
                        );
                    }
                }

                $c->unhandled_exception($_);
            }
        } else {
            try {
                Koha::Database->new->schema->txn_do(
                    sub {
                        $server_param_obj->set_from_api($server_param)->store;
                    }
                );
            } catch {
                if ( blessed $_ ) {
                    if ( $_->isa('Koha::Exceptions::BadParameter') ) {
                        return $c->render(
                            status => 400,
                            json   => { message => 'Some error occurred' }
                        );
                    }
                }

                $c->unhandled_exception($_);
            }
        }
    }

    $c->res->headers->location( $c->req->url->to_string );
    return $c->render(
        status => 200,
        json   => { message => 'Server params updated successfully' },
    );
}

1;
