package Koha::Template::Plugin::KohaPlugins;

# This file is part of Koha.
#
# Copyright ByWater Solutions 2018
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

use base qw( Template::Plugin );

use Koha::Plugins;

sub get_plugins_opac_head {
    return q{}
      unless C4::Context->preference('UseKohaPlugins')
      && C4::Context->config("enable_plugins");

    my @plugins = Koha::Plugins->new()->GetPlugins(
        {
            method => 'opac_head',
        }
    );

    my @data = map { $_->opac_head || q{} } @plugins;

    return join( "\n", @data );
}

sub get_plugins_opac_js {
    return q{}
      unless C4::Context->preference('UseKohaPlugins')
      && C4::Context->config("enable_plugins");

    my @plugins = Koha::Plugins->new()->GetPlugins(
        {
            method => 'opac_js',
        }
    );

    my @data = map { $_->opac_js || q{} } @plugins;

    return join( "\n", @data );
}

1;
