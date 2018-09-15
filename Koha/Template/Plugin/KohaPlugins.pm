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

=head1 NAME

Koha::Template::Plugin::KohaPlugins - A module for adding hooks into Koha for plugins

=head1 DESCRIPTION

This plugin contains functions related to adding plugin hooks into various parts
of Koha.

To use, include the line '[% USE KohaPlugins %]' at the top of the template
to enable the plugin

=head2 Methods

=head3 get_plugins_opac_head

[% KohaPlugins.get_plugins_opac_head %]

This method collects the output of all plugins with an opac_head method
to output to the head section of opac pages.

=cut

sub get_plugins_opac_head {
    return q{}
      unless C4::Context->preference('UseKohaPlugins');

    my $p = Koha::Plugins->new();

    return q{} unless $p;

    my @plugins = $p->GetPlugins(
        {
            method => 'opac_head',
        }
    );

    my @data = map { $_->opac_head || q{} } @plugins;

    return join( "\n", @data );
}

=head3 get_plugins_opac_js

[% KohaPlugins.get_plugins_opac_js %]

This method collects the output of all plugins with an opac_js method
to output to the javascript section of at the bottom of opac pages.

=cut

sub get_plugins_opac_js {
    return q{}
      unless C4::Context->preference('UseKohaPlugins');

    my $p = Koha::Plugins->new();

    return q{} unless $p;

    my @plugins = $p->GetPlugins(
        {
            method => 'opac_js',
        }
    );

    my @data = map { $_->opac_js || q{} } @plugins;

    return join( "\n", @data );
}

=head3 get_plugins_intranet_head

[% KohaPlugins.get_plugins_intranet_head %]

This method collects the output of all plugins with an intranet_head method
to output to the head section of intranet pages.

=cut

sub get_plugins_intranet_head {
    return q{}
      unless C4::Context->preference('UseKohaPlugins');

    my $p = Koha::Plugins->new();

    return q{} unless $p;

    my @plugins = $p->GetPlugins(
        {
            method => 'intranet_head',
        }
    );

    my @data = map { $_->intranet_head || q{} } @plugins;

    return join( "\n", @data );
}

=head3 get_plugins_intranet_js

[% KohaPlugins.get_plugins_intranet_js %]

This method collects the output of all plugins with an intranet_js method
to output to the javascript section of at the bottom of intranet pages.

=cut

sub get_plugins_intranet_js {
    return q{}
      unless C4::Context->preference('UseKohaPlugins');

    my $p = Koha::Plugins->new();

    return q{} unless $p;

    my @plugins = $p->GetPlugins(
        {
            method => 'intranet_js',
        }
    );

    my @data = map { $_->intranet_js || q{} } @plugins;

    return join( "\n", @data );
}

1;
