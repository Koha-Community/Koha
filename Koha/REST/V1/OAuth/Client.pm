package Koha::REST::V1::OAuth::Client;

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

use Koha::Auth::Client::OAuth;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::URL;
use Scalar::Util qw(blessed);
use Try::Tiny;
use Koha::Logger;
use Koha::Token;
use URI::Escape qw(uri_escape_utf8);

=head1 NAME

Koha::REST::V1::OAuth::Client - Controller library for handling OAuth2-related login attempts

=head1 API

=head2 Methods

=head3 login

Controller method handling login requests

=cut

sub login {
    my $c = shift->openapi->valid_input or return;

    my $provider  = $c->param('provider_code');
    my $interface = $c->param('interface');

    my $logger = Koha::Logger->get({ interface => 'api' });

    my $provider_config = $c->oauth2->providers->{$provider};

    my $uri;
    my $redirect_url;

    if ( $interface eq 'opac' ) {
        $redirect_url = C4::Context->preference('OPACBaseURL') . '/api/v1/public/oauth/login/';
        if ( C4::Context->preference('OpacPublic') ) {
            $uri = '/cgi-bin/koha/opac-user.pl';
        } else {
            $uri = '/cgi-bin/koha/opac-main.pl';
        }
    } else {
        $redirect_url = C4::Context->preference('staffClientBaseURL') . '/api/v1/oauth/login/';
        $uri = '/cgi-bin/koha/mainpage.pl';
    }

    unless ( $provider_config && $provider_config->{authorize_url} ) {
        my $error = "No configuration found for your provider";
        return $c->redirect_to($uri."?auth_error=$error");
    }

    unless ( $provider_config->{authorize_url} =~ /response_type=code/ ) {
        my $authorize_url = Mojo::URL->new($provider_config->{authorize_url});
        $authorize_url->query->append(response_type => 'code');
        $provider_config->{authorize_url} = $authorize_url->to_string;
    }

    # Determine if it is a callback request, or the initial
    my $is_callback = $c->param('error_description') || $c->param('error') || $c->param('code');

    my $state;

    if ($is_callback) {
        # callback, check CSRF token
        unless (
            Koha::Token->new->check_csrf(
                {
                    session_id => $c->req->cookie('CGISESSID')->value,
                    token      => $c->param('state'),
                }
            )
          )
        {
            my $error = "wrong_csrf_token";
            return $c->redirect_to( $uri . "?auth_error=$error" );
        }
    }
    else {
        # initial request, generate CSRF token
        $state = Koha::Token->new->generate_csrf( { session_id => $c->req->cookie('CGISESSID')->value } );
    }

    return $c->oauth2->get_token_p( $provider => { ( !$is_callback ? ( state => $state ) : () ), redirect_uri => $redirect_url . $provider . "/" . $interface } )->then(
        sub {
            return unless my $response = shift;

            try {
                my ( $patron, $mapped_data, $domain ) = Koha::Auth::Client::OAuth->new->get_user(
                    {   provider  => $provider,
                        data      => $response,
                        interface => $interface,
                        config    => $c->oauth2->providers->{$provider}
                    }
                );

                if ( !$patron ) {
                    $patron = $c->auth->register(
                        {
                            data      => $mapped_data,
                            domain    => $domain,
                            interface => $interface
                        }
                    );
                }

                my $session_id = $c->auth->session({ patron => $patron, interface => $interface, provider => $provider });

                $c->cookie( CGISESSID => $session_id, { path => "/" } );

                $c->redirect_to($uri);
            } catch {
                my $error = $_;
                $logger->error($error);
                # TODO: Review behavior
                if ( blessed $error ) {
                    if ( $error->isa('Koha::Exceptions::Auth::Unauthorized') ) {
                        $error = "User cannot access this resource";
                    }
                    if ( $error->isa('Koha::Exceptions::Auth::NoValidDomain') ) {
                        $error = "No configuration found for your email domain";
                    }
                }

                $error = uri_escape_utf8($error);

                $c->redirect_to($uri."?auth_error=$error");
            };
        }
    )->catch(
        sub {
            my $error = shift;
            $logger->error($error);
            $error = uri_escape_utf8($error);
            $c->redirect_to($uri."?auth_error=$error");
        }
    )->wait;
}

1;
