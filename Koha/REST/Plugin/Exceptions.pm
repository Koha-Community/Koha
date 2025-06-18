package Koha::REST::Plugin::Exceptions;

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

use Scalar::Util qw( blessed );

use Mojo::Base 'Mojolicious::Plugin';

=head1 NAME

Koha::REST::Plugin::Exceptions

=head1 API

=head2 Helper methods

=head3 unhandled_exception

    try {
        ...
    }
    catch {
        if ( know_exception ) {
            handle_known_exception($_);
        }

        $c->unhandled_exception($_);
    }

Provides a generic and reusable way to throw unhandled exceptions. This way we
can centralize the behaviour control (e.g. production vs. development environment)

=cut

=head2 register

Missing POD for register.

=cut

sub register {
    my ( $self, $app ) = @_;

    $app->helper(
        'unhandled_exception' => sub {
            my ( $c, $exception ) = @_;

            my $req    = $c->req;
            my $method = $req->method;
            my $path   = $req->url->to_abs->path;
            my $type   = "";

            if ( blessed $exception && ref($exception) eq 'Koha::Exceptions::REST::Query::InvalidOperator' ) {
                return $c->render(
                    status => 400,
                    json   => {
                        error      => printf( "Invalid operator in query: %s", $exception->operator ),
                        error_code => 'invalid_query',
                    }
                );
            } elsif ( blessed $exception
                && ref($exception) eq 'Koha::Exceptions::REST::Public::Authentication::Required' )
            {
                return $c->render(
                    status => 401,
                    json   => {
                        error => $exception->error,
                    }
                );
            } elsif ( blessed $exception && ref($exception) eq 'Koha::Exceptions::REST::Public::Unauthorized' ) {
                return $c->render(
                    status => 403,
                    json   => {
                        error => $exception->error,
                    }
                );
            }

            if ( blessed $exception ) {
                $type = "(" . ref($exception) . ")";
            }

            my $exception_string = "$exception";
            chomp($exception_string);

            my $message = "$method $path: unhandled exception $type\<\<$exception_string\>\>";

            $c->app->log->error("$message");

            $c->render(
                status => 500,
                json   => {
                    error      => "Something went wrong, check Koha logs for details.",
                    error_code => 'internal_server_error',
                }
            );
        }
    );
}

1;
