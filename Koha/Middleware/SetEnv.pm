package Koha::Middleware::SetEnv;

# Copyright 2016 ByWater Solutions and the Koha Dev Team
#
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

use Plack::Request;

=head1 NAME

Koha::Middleware::SetEnv - Plack middleware to allow SetEnv through proxied headers

=head1 SYNOPSIS

  builder {
      ...
      enable "Koha::Middleware::SetEnv";
      ...
  }



=head1 DESCRIPTION

This module adds a Plack middleware to convert C<X-Koha-SetEnv> request headers to actual
environment variables.

This is needed because Plackified Koha is currently connected to Apache via an HTTP proxy, and
C<SetEnv>s are not passed through. Koha uses SetEnvs to pass memcached settings and per-virtualhost
styles, search limits and syspref overrides.

=head1 CAVEATS

Due to how HTTP headers are combined, if you want to set a value with an embedded comma, it must be
escaped:

  SetEnv OVERRIDE_SYSPREF_LibraryName "The Best, Truly the Best, Koha Library"
  RequestHeader add X-Koha-SetEnv "OVERRIDE_SYSPREF_LibraryName The Best\, Truly the Best\, Koha Library"

=head1 NOTES

This system was designed to use a single header for reasons of security. We have no way of knowing
whether a given request header was set by Apache or the original client, so we have to clear any
relevant headers before Apache starts adding them. This is only really practical for a single header
name.

=cut

my $allowed_setenvs = qr/^(
    OVERRIDE_SYSPREF_(\w+) |
    OVERRIDE_SYSPREF_NAMES |
    OPAC_BRANCH_DEFAULT |
    OPAC_CSS_OVERRIDE |
    OPAC_SEARCH_LIMIT |
    OPAC_LIMIT_OVERRIDE |
    TZ
)\ /x;

sub call {
    my ( $self, $env ) = @_;
    my $req = Plack::Request->new($env);

    # First, we split the result only on unescaped commas.
    my @setenv_headers = split /(?<!\\),\s*/, $req->header('X-Koha-SetEnv') || '';

    # Then, these need to be mapped to key-value pairs, and commas removed.
    my %setenvs = map {
        # The syntax of this is a bit awkward because you can't use return inside a map (it
        # returns from the enclosing function).
        if (!/$allowed_setenvs/) {
            warn "Forbidden/incorrect X-Koha-SetEnv: $_";

            ();
        } else {
            my ( $key, $value ) = /(\w+) (.*)/;
            $value =~ s/\\,/,/g;

            ( $key, $value );
        }
    } @setenv_headers;

    #Add the environmental variables to the $env hashref which travels between middlewares
    #NOTE: It's very important that this $env keeps the same reference address so that
    #all middlewares act correctly
    foreach my $key ( keys %setenvs ) {
        $env->{$key} = $setenvs{$key};
    }

    return $self->app->($env);
}

=head1 AUTHOR

Jesse Weaver, E<lt>jweaver@bywatersolutions.comE<gt>

=cut

1;
