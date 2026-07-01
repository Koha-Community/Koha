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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Array::Utils qw( array_minus );
use Class::Inspector;
use List::MoreUtils           qw( any none );
use Module::Load::Conditional qw( can_load );
use Module::Load;
use Module::Pluggable search_path => ['Koha::Plugin'],
    except                        => qr/::Edifact(|::Line|::Message|::Order|::Segment|::Transport)$/;
use Try::Tiny;
use POSIX qw(getpid);

use C4::Context;
use C4::Output;

use Koha::Cache::Memory::Lite;
use Koha::Exceptions;
use Koha::Exceptions::Plugin;
use Koha::Plugins::Datas;
use Koha::Plugins::Methods;

use constant ENABLED_PLUGINS_CACHE_KEY => 'enabled_plugins';

BEGIN {
    my $pluginsdir = C4::Context->config("pluginsdir");
    my @pluginsdir = ref($pluginsdir) eq 'ARRAY' ? @$pluginsdir : $pluginsdir;
    push @INC, array_minus( @pluginsdir, @INC );
    pop @INC if $INC[-1] eq '.';

    # Load plugins early to ensure they're available before any transactions begin
    # Skip under "perl -c" to avoid C3 error when syntax checking plugins
    my $enable_plugins = C4::Context->config("enable_plugins") // 0;

    if ( $enable_plugins && !$^C ) {
        require Koha::Plugins::Loader;
        Koha::Plugins::Loader->get_enabled_plugins();
    }

}

=head1 NAME

Koha::Plugins - Module for loading and managing plugins.

=head2 new

Constructor

=cut

sub new {
    my ( $class, $args ) = @_;

    return unless ( C4::Context->config("enable_plugins") || $args->{'enable_plugins'} );

    $args->{'pluginsdir'} = C4::Context->config("pluginsdir");

    return bless( $args, $class );
}

=head2 call

Calls a plugin method for all enabled plugins

    @responses = Koha::Plugins->call($method, @args)

Note: Pass your arguments as refs, when you want subsequent plugins to use the value
updated by preceding plugins, provided that these plugins support that.

=cut

sub call {
    my ( $class, $method, @args ) = @_;

    return unless C4::Context->config('enable_plugins');

    my @responses;
    my @plugins = $class->get_enabled_plugins( { verbose => 0 } );
    @plugins = grep { $_->can($method) } @plugins;

    # TODO: Remove warn when after_hold_create is removed from the codebase
    warn "after_hold_create is deprecated and will be removed soon. Contact the following plugin's authors: "
        . join( ', ', map { $_->{metadata}->{name} } @plugins )
        if $method eq 'after_hold_create' and @plugins;

    foreach my $plugin (@plugins) {
        my $response = eval { $plugin->$method(@args) };
        if ($@) {
            warn sprintf( "Plugin error (%s): %s", $plugin->get_metadata->{name}, $@ );
            next;
        }

        push @responses, $response;
    }

    return @responses;
}

=head2 get_enabled_plugins

Returns a list of enabled plugins.

    @plugins = Koha::Plugins->get_enabled_plugins( [ verbose => 1 ] );

=cut

sub get_enabled_plugins {
    my ( $class, $params ) = @_;

    return unless C4::Context->config('enable_plugins');

    # Delegate to Koha::Plugins::Loader which handles caching and loading
    require Koha::Plugins::Loader;
    return Koha::Plugins::Loader->get_enabled_plugins();
}

=head3 _verbose

Helper function to reduce verbosity in tests

=cut

sub _verbose {
    my $class = shift;

    # Return false when running unit tests
    return exists $ENV{_} && $ENV{_} =~ /\/prove(\s|$)|\/koha-qa\.pl$|\.t$/ ? 0 : 1;
}

=head2 feature_enabled

Returns a boolean denoting whether a plugin based feature is enabled or not.

    $enabled = Koha::Plugins->feature_enabled('method_name');

=cut

sub feature_enabled {
    my ( $class, $method ) = @_;

    return 0 unless C4::Context->config('enable_plugins');

    my $key     = "ENABLED_PLUGIN_FEATURE_" . $method;
    my $feature = Koha::Cache::Memory::Lite->get_from_cache($key);
    unless ( defined($feature) ) {
        my @plugins = $class->get_enabled_plugins( { verbose => 0 } );
        my $enabled = any { $_->can($method) } @plugins;
        Koha::Cache::Memory::Lite->set_in_cache( $key, $enabled );
    }
    return $feature;
}

=head2 GetPlugins

This will return a list of all available plugins, optionally limited by
method or metadata value.

    my @plugins = Koha::Plugins::GetPlugins({
        method => 'some_method',
        metadata => { some_key => 'some_value' },
        [ all => 1, errors => 1, verbose => 1 ],
    });

The method and metadata parameters are optional.
If you pass multiple keys in the metadata hash, all keys must match.

If you pass errors (only used in plugins-home), we return two arrayrefs:

    ( $good, $bad ) = Koha::Plugins::GetPlugins( { errors => 1 } );

If you pass verbose, you can enable or disable explicitly warnings
from Module::Load::Conditional. Disabled by default to not flood
the logs.

=cut

sub GetPlugins {
    my ( $self, $params ) = @_;

    my $method       = $params->{method};
    my $req_metadata = $params->{metadata} // {};
    my $errors       = $params->{errors};

    # By default dont warn here unless asked to do so.
    my $verbose = $params->{verbose} // 0;

    my $filter = ($method) ? { plugin_method => $method } : undef;

    my $plugin_classes = Koha::Plugins::Methods->search(
        $filter,
        {
            columns  => 'plugin_class',
            distinct => 1
        }
    )->_resultset->get_column('plugin_class');

    # Loop through all plugins that implement at least a method
    my ( @plugins, @failing );
    while ( my $plugin_class = $plugin_classes->next ) {
        if ( can_load( modules => { $plugin_class => undef }, verbose => $verbose, nocache => 1 ) ) {

            my $plugin;
            my $failed_instantiation;

            try {
                $plugin = $plugin_class->new(
                    {
                        enable_plugins => $self->{'enable_plugins'}

                        # loads even if plugins are disabled
                        # FIXME: is this for testing without bothering to mock config?
                    }
                );
            } catch {
                warn "$_";
                $failed_instantiation = 1;
            };

            next if $failed_instantiation;

            next
                unless $plugin->is_enabled
                or defined( $params->{all} ) && $params->{all};

            # filter the plugin out by metadata
            my $plugin_metadata = $plugin->get_metadata;
            next
                if $plugin_metadata
                and %$req_metadata
                and any { !$plugin_metadata->{$_} || $plugin_metadata->{$_} ne $req_metadata->{$_} }
                keys %$req_metadata;

            push @plugins, $plugin;
        } elsif ($errors) {
            push @failing, { error => 1, name => $plugin_class };
        }
    }

    return $errors ? ( \@plugins, \@failing ) : @plugins;
}

=head2 InstallPlugins

    my $plugins = Koha::Plugins->new();
    $plugins->InstallPlugins(
        {
          [ verbose => 1,
            include => ( 'Koha::Plugin::A', ... ),
            exclude => ( 'Koha::Plugin::X', ... ), ]
        }
    );

This method iterates through all plugins physically present on a system.
For each plugin module found, it will test that the plugin can be loaded,
and if it can, will store its available methods in the plugin_methods table.

Parameters:

=over 4

=item B<exclude>: A list of class names to exclude from the process.

=item B<include>: A list of class names to limit the process to.

=item B<verbose>: Print useful information.

=back

NOTE: We reload all plugins here as a protective measure in case someone
has removed a plugin directly from the system without using the UI

=cut

sub InstallPlugins {
    my ( $self, $params ) = @_;
    my $verbose = $params->{verbose} // $self->_verbose;

    my @plugin_classes = $self->plugins();
    my @plugins;

    Koha::Exceptions::BadParameter->throw("Only one of 'include' and 'exclude' can be passed")
        if ( $params->{exclude} && $params->{include} );

    if ( defined( $params->{include} ) || defined( $params->{exclude} ) ) {
        my @classes_filters =
            defined( $params->{include} )
            ? @{ $params->{include} }
            : @{ $params->{exclude} };

        # Warn user if the specified classes doesn't exist and return nothing
        foreach my $class_name (@classes_filters) {
            unless ( any { $class_name eq $_ } @plugin_classes ) {
                Koha::Exceptions::BadParameter->throw("$class_name has not been found, try a different name");
            }
        }

        # filter things
        if ( $params->{include} ) {
            @plugin_classes = grep {
                my $plugin_class = $_;
                any { $plugin_class eq $_ } @classes_filters
            } @plugin_classes;
        } else {    # exclude
            @plugin_classes = grep {
                my $plugin_class = $_;
                none { $plugin_class eq $_ } @classes_filters
            } @plugin_classes;
        }
    }

    foreach my $plugin_class (@plugin_classes) {

        # Force a fresh load from disk. Without this, a long-lived Plack
        # worker that already has the plugin loaded would rescan a stale
        # symbol table during an upgrade, so plugin_methods ends up out of
        # sync with the installed .pm (e.g. missing newly-added methods or
        # retaining methods that were renamed or removed).
        $self->_forget_plugin_class($plugin_class);

        if ( can_load( modules => { $plugin_class => undef }, verbose => $verbose, nocache => 1 ) ) {
            next unless $plugin_class->isa('Koha::Plugins::Base');

            my $plugin;
            my $failed_instantiation;

            try {
                $plugin = $plugin_class->new( { enable_plugins => $self->{'enable_plugins'} } );
            } catch {
                warn "$_";
                $failed_instantiation = 1;
            };

            next if $failed_instantiation;

            Koha::Plugins::Methods->search( { plugin_class => $plugin_class } )->delete();

            foreach my $method ( @{ Class::Inspector->methods( $plugin_class, 'public' ) } ) {
                Koha::Plugins::Method->new(
                    {
                        plugin_class  => $plugin_class,
                        plugin_method => $method,
                    }
                )->store();
            }

            push @plugins, $plugin;
        }
    }

    Koha::Cache::Memory::Lite->clear_from_cache(ENABLED_PLUGINS_CACHE_KEY);

    $self->_restart_after_change();

    return @plugins;
}

=head3 _forget_plugin_class

Force Perl to forget an in-memory plugin class, so a subsequent re-require
picks up the .pm file as it currently exists on disk, rather than whatever
was loaded into this worker previously.

We deliberately do not use Symbol::delete_package here: it clears the
whole symbol table, including any already-loaded packages nested under
it (e.g. Koha::Plugin::Foo::Controller, bundled by the plugin in its own
Koha/Plugin/Foo/Controller.pm). Since those keep their own %INC entry,
they are never re-required afterwards and are left permanently blanked
out. Module::Pluggable discovers them as their own entries in the plugin
list regardless, so they get reloaded on their own turn; this helper
only ever clears the target class's own symbols, leaving any nested
packages alone.

=cut

sub _forget_plugin_class {
    my ( $self, $plugin_class ) = @_;

    return unless Class::Inspector->loaded($plugin_class);

    no strict 'refs';    ## no critic (ProhibitNoStrict)
    @{"${plugin_class}::ISA"} = ();
    my $stash = \%{"${plugin_class}::"};
    for my $symbol ( keys %$stash ) {
        next if $symbol =~ /::\z/;    # leave nested packages alone
        delete $stash->{$symbol};
    }

    ( my $plugin_inc_key = $plugin_class ) =~ s{::}{/}g;
    delete $INC{"$plugin_inc_key.pm"};

    return;
}

=head2 RemovePlugins

    Koha::Plugins->RemovePlugins( {
        [ plugin_class => MODULE_NAME, destructive => 1, disable => 1 ],
    } );

    This is primarily for unit testing. Take care when you pass the
    destructive flag (know what you are doing)!

    The method removes records from plugin_methods for one or all plugins.

    If you pass the destructive flag, it will remove records too from
    plugin_data for one or all plugins. Destructive overrules disable.

    If you pass disable, it will disable one or all plugins (in plugin_data).

    If you do not pass destructive or disable, this method does not touch
    records in plugin_data. The cache key for enabled plugins will be cleared
    only if you pass disabled or destructive.

=cut

sub RemovePlugins {
    my ( $class, $params ) = @_;

    my $cond = {
        $params->{plugin_class}
        ? ( plugin_class => $params->{plugin_class} )
        : ()
    };
    Koha::Plugins::Methods->search($cond)->delete;
    if ( $params->{destructive} ) {
        Koha::Plugins::Datas->search($cond)->delete;
        Koha::Cache::Memory::Lite->clear_from_cache( Koha::Plugins->ENABLED_PLUGINS_CACHE_KEY );
    } elsif ( $params->{disable} ) {
        $cond->{plugin_key} = '__ENABLED__';
        Koha::Plugins::Datas->search($cond)->update( { plugin_value => 0 } );
        Koha::Cache::Memory::Lite->clear_from_cache( Koha::Plugins->ENABLED_PLUGINS_CACHE_KEY );
    }

    $class->_restart_after_change();
}

=head3 _restart_after_change

Helper function to reload plack after a plugin change if the
'plugins_restart' flag is enabled in the koha-conf.xml

=cut

sub _restart_after_change {
    my ( $class, $params ) = @_;

    return unless ( C4::Context->config('plugins_restart') && C4::Context->psgi_env );

    my $parent_pid = getppid();

    # Send HUP signal to Plack parent process for graceful restart
    kill 'HUP', $parent_pid;
}

=head2 get_valuebuilders_installed

    my @valuebuilders = Koha::Plugins->new->get_valuebuilders_installed();

Returns a list of all valuebuilder plugins provided by plugins.

=cut

sub get_valuebuilders_installed {
    my ($self) = @_;

    # Get ENABLED plugins
    my @plugins = $self->get_enabled_plugins();

    my @valuebuilders;

    foreach my $plugin (@plugins) {

        # Check if plugin implements get_valuebuilder method
        if ( $plugin->can('get_valuebuilder') ) {

            # Get the value builder from the plugin
            my $valuebuilder = $plugin->get_valuebuilder();

            if ($valuebuilder) {
                push @valuebuilders, {
                    name   => $valuebuilder,
                    plugin => $plugin,
                };
            }
        }
    }

    return @valuebuilders;
}

1;
__END__

=head1 AUTHOR

Kyle M Hall <kyle.m.hall@gmail.com>

=cut
