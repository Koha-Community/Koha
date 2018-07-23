package Koha::REST::Plugin::PluginRoutes;

# This file is part of Koha.
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

use Mojo::Base 'Mojolicious::Plugin';

use Koha::Exceptions::Plugin;
use Koha::Plugins;

use Clone qw(clone);
use Try::Tiny;

=head1 NAME

Koha::REST::Plugin::PluginRoutes

=head1 API

=head2 Helper methods

=head3 register

=cut

sub register {
    my ( $self, $app, $config ) = @_;

    my $spec      = $config->{spec};
    my $validator = $config->{validator};

    my @plugins;

    if (   C4::Context->preference('UseKohaPlugins')
        && C4::Context->config("enable_plugins") )
    {
        @plugins = Koha::Plugins->new()->GetPlugins(
            {
                method => 'api_routes',
            }
        );
        # plugin needs to define a namespace
        @plugins = grep { $_->api_namespace } @plugins;
    }

    foreach my $plugin ( @plugins ) {
        $spec = inject_routes( $spec, $plugin, $validator );
    }

    return $spec;
}

=head3 inject_routes

=cut

sub inject_routes {
    my ( $spec, $plugin, $validator ) = @_;

    return try {

        my $backup_spec = merge_spec( clone($spec), $plugin );
        if ( spec_ok( $backup_spec, $validator ) ) {
            $spec = merge_spec( $spec, $plugin );
        }
        else {
            Koha::Exceptions::Plugin->throw(
                "The resulting spec is invalid. Skipping " . $plugin->get_metadata->{name}
            );
        }

        return $spec;
    }
    catch {
        warn "$_";
        return $spec;
    };
}

=head3 merge_spec

=cut

sub merge_spec {
    my ( $spec, $plugin ) = @_;

    my $plugin_spec = $plugin->api_routes;

    foreach my $route ( keys %{ $plugin_spec } ) {

        my $THE_route = '/contrib/' . $plugin->api_namespace . $route;
        if ( exists $spec->{ $THE_route } ) {
            # Route exists, overwriting is forbidden
            Koha::Exceptions::Plugin::ForbiddenAction->throw(
                "Attempted to overwrite $THE_route"
            );
        }

        $spec->{'paths'}->{ $THE_route } = $plugin_spec->{ $route };
    }

    return $spec;
}

=head3 spec_ok

=cut

sub spec_ok {
    my ( $spec, $validator ) = @_;

    return try {
        $validator->load_and_validate_schema(
            $spec,
            {
                allow_invalid_ref => 1,
            }
        );
        return 1;
    }
    catch {
        return 0;
    }
}

1;
