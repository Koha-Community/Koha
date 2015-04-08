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
use Encode qw( encode );

use base qw( Template::Plugin );

use C4::Context;

=pod

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

sub Preference {
    my ( $self, $pref ) = @_;
    return encode('UTF-8', C4::Context->preference( $pref ) );
}

1;
