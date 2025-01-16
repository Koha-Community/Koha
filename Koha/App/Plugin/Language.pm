package Koha::App::Plugin::Language;

# Copyright 2025 Koha development team
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

=head1 NAME

Koha::App::Plugin::Language

=head1 SYNOPSIS

    $app->plugin('Language');

=head1 DESCRIPTION

Sets the current language based on request (cookies, headers, ...)

=cut

use Modern::Perl;

use Mojo::Base 'Mojolicious::Plugin';

use Koha::Language;

=head1 METHODS

=head2 register

Called by Mojolicious when the plugin is loaded.

Defines an `around_action` hook that will sets the current language based on
the current request.

=cut

sub register {
    my ( $self, $app, $conf ) = @_;

    $app->hook(
        around_action => sub {
            my ( $next, $c, $action, $last ) = @_;

            # Make the value of Accept-Language header and KohaOpacLanguage
            # cookie accessible to C4::Languages::getlanguage when not in a CGI
            # context

            if ( my $accept_language = $c->req->headers->accept_language ) {
                $ENV{HTTP_ACCEPT_LANGUAGE} = $accept_language;
            }
            if ( my $KohaOpacLanguage = $c->cookie('KohaOpacLanguage') ) {
                Koha::Language->set_requested_language($KohaOpacLanguage);
            }

            return $next->();
        }
    );
}

1;
