package Koha::Template::Plugin::KohaPlugins;

# This file is part of Koha.
#
# Copyright ByWater Solutions 2018
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

use Try::Tiny qw( catch try );

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
    return q{} unless C4::Context->config("enable_plugins");

    my $p = Koha::Plugins->new();

    return q{} unless $p;

    my @plugins = $p->GetPlugins(
        {
            method => 'opac_head',
        }
    );

    my @data = ();
    foreach my $plugin (@plugins){
        try {
            my $datum = $plugin->opac_head || q{};
            push(@data,$datum);
        }
        catch {
            warn "Error calling 'opac_head' on the " . $plugin->{class} . "plugin ($_)";
        };
    }

    return join( "\n", @data );
}

=head3 get_plugins_opac_js

[% KohaPlugins.get_plugins_opac_js %]

This method collects the output of all plugins with an opac_js method
to output to the javascript section of at the bottom of opac pages.

=cut

sub get_plugins_opac_js {
    return q{} unless C4::Context->config("enable_plugins");

    my $p = Koha::Plugins->new();

    return q{} unless $p;

    my @plugins = $p->GetPlugins(
        {
            method => 'opac_js',
        }
    );

    my @data = ();
    foreach my $plugin (@plugins){
        try {
            my $datum = $plugin->opac_js || q{};
            push(@data,$datum);
        }
        catch {
            warn "Error calling 'opac_js' on the " . $plugin->{class} . "plugin ($_)";
        };
    }

    return join( "\n", @data );
}

=head3 get_plugins_intranet_head

[% KohaPlugins.get_plugins_intranet_head %]

This method collects the output of all plugins with an intranet_head method
to output to the head section of intranet pages.

=cut

sub get_plugins_intranet_head {
    return q{} unless C4::Context->config("enable_plugins");

    my $p = Koha::Plugins->new();

    return q{} unless $p;

    my @plugins = $p->GetPlugins(
        {
            method => 'intranet_head',
        }
    );

    my @data = ();
    foreach my $plugin (@plugins){
        try {
            my $datum = $plugin->intranet_head || q{};
            push(@data,$datum);
        }
        catch {
            warn "Error calling 'intranet_head' on the " . $plugin->{class} . "plugin ($_)";
        };
    }

    return join( "\n", @data );
}

=head3 get_plugins_intranet_js

[% KohaPlugins.get_plugins_intranet_js %]

This method collects the output of all plugins with an intranet_js method
to output to the javascript section of at the bottom of intranet pages.

=cut

sub get_plugins_intranet_js {
    return q{} unless C4::Context->config("enable_plugins");

    my $p = Koha::Plugins->new();

    return q{} unless $p;

    my @plugins = $p->GetPlugins(
        {
            method => 'intranet_js',
        }
    );

    my @data = ();
    foreach my $plugin (@plugins){
        try {
            my $datum = $plugin->intranet_js || q{};
            push(@data,$datum);
        }
        catch {
            warn "Error calling 'intranet_js' on the " . $plugin->{class} . "plugin ($_)";
        };
    }

    return join( "\n", @data );
}

=head3 get_plugins_intranet_catalog_biblio_tab

  [% SET plugins_intranet_catalog_biblio_tabs = KohaPlugins.get_plugins_intranet_catalog_biblio_tab %]
  [% FOREACH plugins_intranet_catalog_biblio_tab IN plugins_intranet_catalog_biblio_tabs %]
    <li><a href="#[% plugins_intranet_catalog_biblio_tab.id | uri %]">[% plugins_intranet_catalog_biblio_tab.title | html %]</a></li>
  [% END %]

This method collects the output of all plugins with a intranet_catalog_biblio_tab
method to output to the list of extra cataloguing tabs on intranet pages.

=cut

sub get_plugins_intranet_catalog_biblio_tab {
    my ( $self, $params ) = @_;
    my $tabs = [];

    return $tabs unless C4::Context->config("enable_plugins");

    my $p = Koha::Plugins->new();
    return $tabs unless $p;

    my @plugins = $p->GetPlugins(
        {
            method => 'intranet_catalog_biblio_tab',
        }
    );

    foreach my $plugin (@plugins) {
        try {
            my @newtabs = $plugin->intranet_catalog_biblio_tab($params);
            foreach my $newtab (@newtabs) {
                # Add a unique HTML id
                my $html_id = 'tab-'. $plugin->{class} . '-' . $newtab->title;
                # Using characters except ASCII letters, digits, '_', '-' and '.' may cause compatibility problems
                $html_id =~ s/[^0-9A-Za-z]+/-/g;
                $newtab->id($html_id);
            }
            push @$tabs, @newtabs;
        }
        catch {
            warn "Error calling 'intranet_catalog_biblio_tab' on the " . $plugin->{class} . "plugin ($_)";
        };
    }

    return $tabs;
}

=head3 get_plugins_intranet_cover_images

[% KohaPlugins. get_plugins_intranet_cover_images %]

This method collects the output of all plugins for injecting cover images into the intranet template and appends it to the javascript at the bottom of the page.

=cut

sub get_plugins_intranet_cover_images {
    return q{} unless C4::Context->config("enable_plugins");

    my $p = Koha::Plugins->new();

    return q{} unless $p;

    my @plugins = $p->GetPlugins(
        {
            method => 'intranet_cover_images',
        }
    );

    my @data = map { $_->intranet_cover_images || q{} } @plugins;

    return join( "\n", @data );
}

=head3 get_plugins_opac_cover_images

[% KohaPlugins. get_plugins_opac_cover_images %]

This method collects the output of all plugins for injecting cover images into the opac template and appends it to the javascript at the bottom of the page.

=cut

sub get_plugins_opac_cover_images {
    return q{} unless C4::Context->config("enable_plugins");

    my $p = Koha::Plugins->new();

    return q{} unless $p;

    my @plugins = $p->GetPlugins(
        {
            method => 'opac_cover_images',
        }
    );

    my @data = map { $_->opac_cover_images || q{} } @plugins;

    return join( "\n", @data );
}

1;
