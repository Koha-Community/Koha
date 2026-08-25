package Koha::Template::Plugin::LinkPref;

# Copyright Athens County Public Libraries 2026
# Author: Owen Leonard <oleonard@myacpl.org>

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

use Template::Plugin::Filter;
use base qw( Template::Plugin::Filter );
our $DYNAMIC = 1;

sub filter {
    my ( $self, $text ) = @_;
    return "" unless $text;
    my $span;

    if ( $self->{_CONTEXT}->stash->{'CAN_user_parameters_manage_sysprefs'} ) {
        $span .= '<a class="link_preference" href="/cgi-bin/koha/admin/preferences.pl?op=search&ok=Search&searchfield=';
        $span .= $text;
        $span .= '">';
        $span .= $text;
        $span .= '</a>';
    } else {
        $span .= '<span class="link_preference">';
        $span .= $text;
        $span .= '</span>';
    }

    return $span;
}

1;

=head1 NAME

Koha::Template::Plugin::LinkPref - TT plugin for wrapping a system preference name in a link to that preference if the user has permission

=head1 SYNOPSIS

[% USE LinkPref %]

[% "SYSTEM_PREFERENCE_NAME" | html | $LinkPref %]

This filter wraps a system preference name in a link to that preference if the user has permission.

=head1 METHODS

=head2 filter

Returns the system preference variable name as an HTML link or plain text based on the logged-in user's permissions

=cut
