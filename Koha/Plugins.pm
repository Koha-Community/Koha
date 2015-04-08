package Koha::Plugins;

# Copyright 2012 Kyle Hall
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

use Module::Load::Conditional qw(can_load);
use Module::Pluggable search_path => ['Koha::Plugin'];

use C4::Context;
use C4::Output;

BEGIN {
    push @INC, C4::Context->config("pluginsdir");
}

=head1 NAME

Koha::Plugins - Module for loading and managing plugins.

=cut

sub new {
    my ( $class, $args ) = @_;

    return unless ( C4::Context->config("enable_plugins") || $args->{'enable_plugins'} );

    $args->{'pluginsdir'} = C4::Context->config("pluginsdir");

    return bless( $args, $class );
}

=head2 GetPlugins()

This will return a list of all the available plugins of the passed type.

Usage: my @plugins = C4::Plugins::GetPlugins( $method );

At the moment, the available types are 'report' and 'tool'.
=cut

sub GetPlugins {
    my $self   = shift;
    my $method = shift;

    my @plugin_classes = $self->plugins();
    my @plugins;

    foreach my $plugin_class (@plugin_classes) {
        if ( can_load( modules => { $plugin_class => undef } ) ) {
            my $plugin = $plugin_class->new({ enable_plugins => $self->{'enable_plugins'} });

            if ($method) {
                if ( $plugin->can($method) ) {
                    push( @plugins, $plugin );
                }
            } else {
                push( @plugins, $plugin );
            }
        }
    }
    return @plugins;
}

1;
__END__

=head1 AUTHOR

Kyle M Hall <kyle.m.hall@gmail.com>

=cut
