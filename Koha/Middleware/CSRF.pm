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

    my ($error);
    if ( $stateless_methods{$request_method} && defined $original_op && $original_op =~ m{^cud-} ) {
        $error = sprintf "Programming error - op '%s' must not start with 'cud-' for %s %s (referer: %s)", $original_op,
            $request_method, $uri, $referer;
    } elsif ( $stateful_methods{$request_method} ) {

        # Get the CSRF token from the param list or the header
        my $csrf_token = $req->param('csrf_token') || $req->header('CSRF_TOKEN');

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
    }

    #NOTE: It is essential to check for this environmental variable.
    #NOTE: If we don't check for it, then we'll also throw an error for the "subrequest" that ErrorDocument uses to
    #fetch the error page document. Then we'll wind up with a very ugly error page and not our pretty one.
    if ( $error && !$env->{'plack.middleware.Koha.CSRF'} ) {

        #NOTE: Other Middleware will take care of logging to correct place, as Koha::Logger doesn't know where to go here
        warn $error;
        $env->{'plack.middleware.Koha.CSRF'} = $error;
        my $res = Plack::Response->new( 403, [ 'Content-Type' => 'text/plain' ], ["Wrong CSRF token"] );
        return $res->finalize;
    }

    return $self->app->($env);
}

1;
