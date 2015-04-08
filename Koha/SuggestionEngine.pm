package Koha::SuggestionEngine;

# Copyright 2012 C & P Bibliography Services
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

=head1 NAME

Koha::SuggestionEngine - Dispatcher class for suggestion engines

=head1 SYNOPSIS

  use Koha::SuggestionEngine;
  my $suggestor = Koha::SuggestionEngine->new(%params);
  $suggestor->get_suggestions($search)

=head1 DESCRIPTION

Dispatcher class for retrieving suggestions. SuggestionEngines must
extend Koha::SuggestionEngine::Base, be in the Koha::SuggestionEngine::Plugin
namespace, and provide the following methods:

B<get_suggestions ($search)> - get suggestions from the plugin for the
specified search.

These methods may be overriden:

B<initialize (%params)> - initialize the plugin

B<destroy ()> - destroy the plugin

These methods should not be overridden unless you are very sure of what
you are doing:

B<new ()> - create a new plugin object

=head1 FUNCTIONS

=cut

use strict;
use warnings;
use Module::Load::Conditional qw(can_load);
use Module::Pluggable::Object;

use base qw(Class::Accessor);

__PACKAGE__->mk_accessors(qw( schema plugins options record ));

=head2 new

    my $suggestor = Koha::SuggestionEngine->new(%params);

Create a new suggestor class. Available parameters are:

=over 8

=item B<plugins>

What plugin(s) to use. This must be an arrayref to a list of plugins. Plugins
can be specified either with a complete class path, or, if they are in the
Koha::SuggestionEngine::Plugin namespace, as only the plugin name, and
"Koha::SuggestionEngine::Plugin" will be prepended to it before the plugin
is loaded.

=back

=cut

sub new {
    my $class = shift;
    my $param = shift;

    my $options = $param->{options} || '';
    my @plugins = ();

    foreach my $plugin ( @{$param->{plugins}} ) {
        next unless $plugin;
        my $plugin_module =
            $plugin =~ m/:/
          ? $plugin
          : "Koha::SuggestionEngine::Plugin::${plugin}";
        if ( can_load( modules => { $plugin_module => undef } ) ) {
            my $object = $plugin_module->new();
            $plugin_module->initialize($param);
            push @plugins, $object;
        }
    }

    my $self = $class->SUPER::new(
        {
            plugins => \@plugins,
            options => $options
        }
    );
    bless $self, $class;
    return $self;
}

=head2 get_suggestions

    my $suggestions = $suggester->get_suggestions(\%params)

Get a list of suggestions based on the search passed in. Available parameters
are:

=over 8

=item B<search>

Required. The search for which suggestions are desired.

=item B<count>

Optional. The number of suggestions to retrieve. Defaults to 10.

=back

=cut

sub get_suggestions {
    my $self  = shift;
    my $param = shift;

    return unless $param->{'search'};

    my $number = $param->{'count'} || 10;

    my %suggestions;

    my $index = scalar @{ $self->plugins };

    foreach my $pluginobj ( @{ $self->plugins } ) {
        next unless $pluginobj;
        my $pluginres = $pluginobj->get_suggestions($param);
        foreach my $suggestion (@$pluginres) {
            $suggestions{ $suggestion->{'search'} }->{'relevance'} +=
              $suggestion->{'relevance'} * $index;
            $suggestions{ $suggestion->{'search'} }->{'label'} |=
              $suggestion->{'label'};
        }
        $index--;
    }

    my @results = ();
    for (
        sort {
            $suggestions{$b}->{'relevance'} <=> $suggestions{$a}->{'relevance'}
        } keys %suggestions
      )
    {
        last if ( $#results == $number - 1 );
        push @results,
          {
            'search'  => $_,
            relevance => $suggestions{$_}->{'relevance'},
            label     => $suggestions{$_}->{'label'}
          };
    }

    return \@results;
}

sub DESTROY {
    my $self = shift;

    foreach my $pluginobj ( @{ $self->plugins } ) {
        $pluginobj->destroy();
    }
}

=head2 AvailablePlugins

    my @available_plugins = Koha::SuggestionEngine::AvailablePlugins();

Get a list of available plugins.

=cut

sub AvailablePlugins {
    my $path = 'Koha::SuggestionEngine::Plugin';
    my $finder = Module::Pluggable::Object->new( search_path => $path );
    return $finder->plugins;
}

1;
