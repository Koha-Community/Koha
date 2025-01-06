package Koha::Middleware::CSRF;

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

use parent qw(Plack::Middleware);
use Plack::Response;

# If you need to update the logic here, please also update Koha::App::Plugin::CSRF

sub call {
    my ( $self, $env ) = @_;
    my $req = Plack::Request->new($env);

    my %stateless_methods = (
        GET     => 1,
        HEAD    => 1,
        OPTIONS => 1,
        TRACE   => 1,
    );

    my %stateful_methods = (
        POST   => 1,
        PUT    => 1,
        DELETE => 1,
        PATCH  => 1,
    );

    my $original_op    = $req->param('op');
    my $request_method = $req->method  // q{};
    my $uri            = $req->uri     // q{};
    my $referer        = $req->referer // q{No referer};
    my $request_path   = $req->path    // q{};

    my %path_exceptions = (
        '/ilsdi.pl' => 1,
    );

    #NOTE: Ignore ErrorDocument requests for CSRF
    if ( $env->{'psgix.errordocument.SCRIPT_NAME'} ) {
        return $self->app->($env);
    } elsif ( $path_exceptions{$request_path} ) {

        #NOTE: Ignore path exceptions for CSRF
        return $self->app->($env);
    }

    my ($error);
    if ( $stateless_methods{$request_method} && defined $original_op && $original_op =~ m{^cud-} ) {
        $error = sprintf "Programming error - op '%s' must not start with 'cud-' for %s %s (referer: %s)", $original_op,
            $request_method, $uri, $referer;
    } elsif ( $stateful_methods{$request_method} ) {

        # Get the CSRF token from the param list or the header
        my $csrf_token = $req->param('csrf_token') || $req->header('CSRF-TOKEN');

        if ( defined $req->param('op') && $original_op !~ m{^cud-} ) {
            $error = sprintf "Programming error - op '%s' must start with 'cud-' for %s %s (referer: %s)", $original_op,
                $request_method, $uri, $referer;
        } elsif ( !$csrf_token ) {
            $error = sprintf "Programming error - No CSRF token passed for %s %s (referer: %s)", $request_method,
                $uri, $referer;
        } else {
            unless (
                Koha::Token->new->check_csrf(
                    {
                        session_id => scalar $req->cookies->{CGISESSID},
                        token      => $csrf_token,
                    }
                )
                )
            {
                $error = "wrong_csrf_token";
            }
        }
    } elsif ( !exists $stateless_methods{$request_method} && !exists $stateful_methods{$request_method} ) {
        $error = sprintf "unknown or unsupported method %s", $request_method;
    }

    if ($error) {

        #NOTE: Other Middleware will take care of logging to correct place, as Koha::Logger doesn't know where to go here
        warn $error;
        $env->{'plack.middleware.Koha.CSRF'} = $error if !$env->{'plack.middleware.Koha.CSRF'};
        my $res = Plack::Response->new( 403, [ 'Content-Type' => 'text/plain' ], ["Wrong CSRF token"] );
        return $res->finalize;
    }

    return $self->app->($env);
}

1;
