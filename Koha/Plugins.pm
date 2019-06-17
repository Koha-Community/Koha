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

use Class::Inspector;
use List::MoreUtils qw(any);
use Module::Load::Conditional qw(can_load);
use Module::Load qw(load);
use Module::Pluggable search_path => ['Koha::Plugin'], except => qr/::Edifact(|::Line|::Message|::Order|::Segment|::Transport)$/;

use C4::Context;
use C4::Output;
use Koha::Plugins::Methods;

BEGIN {
    my $pluginsdir = C4::Context->config("pluginsdir");
    my @pluginsdir = ref($pluginsdir) eq 'ARRAY' ? @$pluginsdir : $pluginsdir;
    push( @INC, @pluginsdir );
    pop @INC if $INC[-1] eq '.';
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

=head2 GetPlugins

This will return a list of all available plugins, optionally limited by
method or metadata value.

    my @plugins = Koha::Plugins::GetPlugins({
        method => 'some_method',
        metadata => { some_key => 'some_value' },
    });

The method and metadata parameters are optional.
Available methods currently are: 'report', 'tool', 'to_marc', 'edifact'.
If you pass multiple keys in the metadata hash, all keys must match.

=cut

sub GetPlugins {
    my ( $self, $params ) = @_;

    my $method       = $params->{method};
    my $req_metadata = $params->{metadata} // {};

    my $filter = ( $method ) ? { plugin_method => $method } : undef;

    my $plugin_classes = Koha::Plugins::Methods->search(
        $filter,
        {   columns  => 'plugin_class',
            distinct => 1
        }
    )->_resultset->get_column('plugin_class');

    my @plugins;

    # Loop through all plugins that implement at least a method
    while ( my $plugin_class = $plugin_classes->next ) {

        load $plugin_class;
        my $plugin = $plugin_class->new({
            enable_plugins => $self->{'enable_plugins'}
                # loads even if plugins are disabled
                # FIXME: is this for testing without bothering to mock config?
        });

        next unless $plugin->is_enabled or
                    defined($params->{all}) && $params->{all};

        # filter the plugin out by metadata
        my $plugin_metadata = $plugin->get_metadata;
        next
            if $plugin_metadata
            and %$req_metadata
            and any { !$plugin_metadata->{$_} || $plugin_metadata->{$_} ne $req_metadata->{$_} } keys %$req_metadata;

        push @plugins, $plugin;

    }

    return @plugins;
}

=head2 InstallPlugins

Koha::Plugins::InstallPlugins()

This method iterates through all plugins physically present on a system.
For each plugin module found, it will test that the plugin can be loaded,
and if it can, will store its available methods in the plugin_methods table.

NOTE: We re-load all plugins here as a protective measure in case someone
has removed a plugin directly from the system without using the UI

=cut

sub InstallPlugins {
    my ( $self, $params ) = @_;

    my @plugin_classes = $self->plugins();
    my @plugins;

    foreach my $plugin_class (@plugin_classes) {
        if ( can_load( modules => { $plugin_class => undef }, nocache => 1 ) ) {
            next unless $plugin_class->isa('Koha::Plugins::Base');

            my $plugin = $plugin_class->new({ enable_plugins => $self->{'enable_plugins'} });

            Koha::Plugins::Methods->search({ plugin_class => $plugin_class })->delete();

            foreach my $method ( @{ Class::Inspector->methods( $plugin_class, 'public' ) } ) {
                Koha::Plugins::Method->new(
                    {
                        plugin_class  => $plugin_class,
                        plugin_method => $method,
                    }
                )->store();
            }

            push @plugins, $plugin;
        } else {
            my $error = $Module::Load::Conditional::ERROR;
            # Do not warn the error if the plugin has been uninstalled
            warn $error unless $error =~ m|^Could not find or check module '$plugin_class'|;
        }
    }
    return @plugins;
}

1;
__END__

=head1 AUTHOR

Kyle M Hall <kyle.m.hall@gmail.com>

=cut
