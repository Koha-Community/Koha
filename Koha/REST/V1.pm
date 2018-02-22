package Koha::REST::V1;

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
use Mojo::Base 'Mojolicious';

use C4::Context;

use Koha::Logger::Mojo;

=head1 NAME

Koha::REST::V1 - Main v.1 REST api class

=head1 API

=head2 Class Methods

=head3 startup

Overloaded Mojolicious->startup method. It is called at application startup.

=cut

sub startup {
    my $self = shift;

    C4::Context->interface('rest');

    $self->log(Koha::Logger::Mojo->get);

    # Force charset=utf8 in Content-Type header for JSON responses
    $self->types->type(json => 'application/json; charset=utf8');

    my $secret_passphrase = C4::Context->config('api_secret_passphrase');
    if ($secret_passphrase) {
        $self->secrets([$secret_passphrase]);
    }

    $self->app->hook(before_dispatch => \&log_request);
    $self->app->hook(before_render => \&default_exception_handling);
    $self->app->hook(before_render => \&log_response);

    $self->plugin(OpenAPI => {
        url => $self->home->rel_file("api/v1/swagger/swagger.json"),
        route => $self->routes->under('/api/v1')->to('Auth#under'),
        allow_invalid_ref => 1, # required by our spec because $ref directly under
                                # Paths-, Parameters-, Definitions- & Info-object
                                # is not allowed by the OpenAPI specification.
    });

    push @{$self->app->static->paths}, C4::Context->config('intranetdir');
    $self->routes->get('/api/v1/doc' => sub {
        if ($_[0]->req->url->path->to_string eq 'api/v1/doc') {
            $_[0]->res->headers->location('/api/v1/doc/');
            return $_[0]->render(status => 301, text => '');
        }
        return $_[0]->reply->static('api/v1/swagger-ui/dist/index.html');
    });
    $self->routes->get('/api/v1/doc/*path' => sub {
        return $_[0]->reply->static('api/v1/swagger-ui/dist/'.$_[0]->stash->{path});
    });
}

=head3 default_exception_handling

A before_render hook for handling default exceptions.

=cut

sub default_exception_handling {
    my ($c, $args) = @_;

    if ($args->{exception} && $args->{exception}->{message}) {
        my $e = $args->{exception}->{message};
        $c->app->log->error(Koha::Exceptions::to_str($e));
        %$args = (
            status => 500,
            # TODO: Do we want a configuration for displaying either
            # a detailed description of the error or simply a "Something
            # went wrong, check the logs."? Now that we can stringify all
            # exceptions with Koha::Exceptions::to_str($e), we could also
            # display the detailed error if some DEBUG variable is enabled.
            # Of course the error is still logged if log4perl is configured
            # appropriately...
            json => { error => 'Something went wrong, check the logs.' }
        );
    }
}

=head3 log_request

=cut

sub log_request {
    my ($c) = @_;

    eval {
        $c->app->log->trace(
            'Request JSON body ' . Mojo::JSON::encode_json($c->req->json)
        );
        $c->app->log->trace(
            'Request params ' . Mojo::JSON::encode_json($c->req->params->to_hash)
        );
    };
}

=head3 log_response

=cut

sub log_response {
    my ($c, $args) = @_;

    eval {
        $c->app->log->trace(
            'Rendering response ' . Mojo::JSON::encode_json($args)
        );
    };
}

sub hateoas {
    my ($c, $responseBody, @refAndUrls) = @_;

    my @links;
    for(my $i=0 ; $i<scalar(@refAndUrls) ; $i+=2) {
        my $ref  = $refAndUrls[$i];
        my $href = $refAndUrls[$i+1];
        push(@links, {ref => ''.$ref,
                      href => ''.$c->url_for($href),
                     }
        );
    }
    $responseBody->{links} = \@links;
}

1;
