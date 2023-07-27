package Koha::Template::Plugin::Koha;

# Copyright ByWater Solutions 2013

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

use base qw( Template::Plugin );

use C4::Context;
use Koha::Token;
use Koha;

=head1 NAME

Koha::Template::Plugin::Koha - General Koha Template Toolkit plugin

=head1 SYNOPSIS

This plugin contains various Koha replated Template Toolkit functions
to help streamline Koha and to move logic from the Perl code into the
Templates when it makes sense to do so.

To use, first, include the line '[% USE Koha %]' at the top
of the template to enable the plugin.

For example: [% IF Koha.Preference( 'MyPreference ) == 'SettingA' %]
removes the necessity of setting a template variable in Perl code for
each and every system preference, even if no evaluation of the setting
is necessary.

=cut

=head1 API

=head2 Class Methods

=head3 new

This new method allows us to store the context which gives us
access to the template vars already set. In particular this gives
us access to the template vars set by C4::Auth::get_template_and_user

=cut

sub new {
    my ( $class, $context ) = @_;
    bless {
        _CONTEXT => $context,
    }, $class;
}


sub Preference {
    my ( $self, $pref ) = @_;
    return C4::Context->preference( $pref );
}

=head3 CSVDelimiter

The delimiter option 'tabs' is stored in the DB as 'tabulation' to avoid issues
storing special characters in the DB. This helper function translates the value
to the correct character when used in templates.

You can, optionally, pass a value parameter to this routine in the case of delimiter
being fetched in the scripts and still needing to be translated

=cut

sub CSVDelimiter {
    my ( $self, $val ) = @_;
    return C4::Context->csv_delimiter($val);
}

sub Version {
    my $version_string = Koha::version();
    my ( $major, $minor, $maintenance, $development ) = split( '\.', $version_string );

    return {
        major       => $major,
        minor       => $minor,
        release     => $major . "." . $minor,
        maintenance => $major . "." . $minor . "." . $maintenance,
        development => ( $development ne '000' ) ? $development : undef,
    };
}

=head3 GenerateCSRF

Generate a new CSRF token.

=cut

sub GenerateCSRF {
    my ($self) = @_;
    my $session_id = $self->{_CONTEXT}->stash->{sessionID};
    return Koha::Token->new->generate_csrf( { session_id => scalar $session_id } );
}

1;
