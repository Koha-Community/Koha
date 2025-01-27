package Koha::REST::Plugin::PluginRoutes;

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

use Mojo::Base 'Mojolicious::Plugin';

use Koha::Exceptions::Plugin;
use Koha::Plugins;

use Clone qw( clone );
use JSON::Validator::Schema::OpenAPIv2;
use Try::Tiny qw( catch try );

=head1 NAME

Koha::REST::Plugin::PluginRoutes

=head1 API

=head2 Helper methods

=head3 register

=cut

sub register {
    my ( $self, $app, $config ) = @_;

    my $spec     = $config->{spec};
    my $validate = $config->{validate};

    my @plugins;

    if ( C4::Context->config("enable_plugins") ) {

        # plugin needs to define a namespace
        @plugins = Koha::Plugins->new()->GetPlugins(
            {
                method => 'api_namespace',
            }
        );

        foreach my $plugin (@plugins) {
            $spec = $self->inject_routes( $spec, $plugin, $validate, $app->log );
        }

    }

    return $spec;
}

=head3 inject_routes

=cut

sub inject_routes {
    my ( $self, $spec, $plugin, $validate, $logger ) = @_;

    return merge_spec( $spec, $plugin ) unless $validate;

    return try {

        my $backup_spec = merge_spec( clone($spec), $plugin );
        if ( $self->spec_ok($backup_spec) ) {
            $spec = merge_spec( $spec, $plugin );
        } else {
            Koha::Exceptions::Plugin->throw(
                "The resulting spec is invalid. Skipping " . $plugin->get_metadata->{name} );
        }

        return $spec;
    } catch {
        my $error = $_;
        my $class = ref $plugin;
        $logger->error("Plugin $class route injection failed: $error");
        return $spec;
    };
}

=head3 merge_spec

=cut

sub merge_spec {
    my ( $spec, $plugin ) = @_;

    if ( $plugin->can('api_routes') ) {
        my $plugin_spec = $plugin->api_routes;

        foreach my $route ( keys %{$plugin_spec} ) {
            my $THE_route = '/contrib/' . $plugin->api_namespace . $route;
            if ( exists $spec->{$THE_route} ) {

                # Route exists, overwriting is forbidden
                Koha::Exceptions::Plugin::ForbiddenAction->throw("Attempted to overwrite $THE_route");
            }

            $spec->{'paths'}->{$THE_route} = $plugin_spec->{$route};
        }
    }

    if ( $plugin->can('static_routes') ) {
        my $plugin_spec = $plugin->static_routes;

        foreach my $route ( keys %{$plugin_spec} ) {

            my $THE_route = '/contrib/' . $plugin->api_namespace . '/static' . $route;
            if ( exists $spec->{$THE_route} ) {

                # Route exists, overwriting is forbidden
                Koha::Exceptions::Plugin::ForbiddenAction->throw("Attempted to overwrite $THE_route");
            }

            $spec->{'paths'}->{$THE_route} = $plugin_spec->{$route};
        }
    }
    return $spec;
}

=head3 spec_ok

=cut

sub spec_ok {
    my ( $self, $spec ) = @_;

    my $schema = JSON::Validator::Schema::OpenAPIv2->new($spec);

    if ( $schema->is_invalid ) {
        warn $schema->errors->[0];
    }

    return !$schema->is_invalid;
}

1;
