package Koha::SuggestionEngine::Base;

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

Koha::SuggestionEngine::Base - Base class for SuggestionEngine plugins

=head1 SYNOPSIS

  use base qw(Koha::SuggestionEngine::Base);

=head1 DESCRIPTION

Base class for suggestion engine plugins. SuggestionEngines must
provide the following methods:

B<get_suggestions (\%param)> - get suggestions for the search described
in $param->{'search'}, and return them in a hashref with the suggestions
as keys and relevance as values.

B<NAME> - return a string with the name of the plugin.

B<VERSION> - return a string with the version of the plugin.

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

use base qw(Class::Accessor);

__PACKAGE__->mk_ro_accessors(qw( name version ));
__PACKAGE__->mk_accessors(qw( params ));

=head2 new

    my $plugin = Koha::SuggestionEngine::Base->new;

Create a new filter;

=cut

sub new {
    my $class = shift;

    my $self = $class->SUPER::new( {} );    #name => $class->NAME,
                                            #version => $class->VERSION });

    bless $self, $class;
    return $self;
}

=head2 initialize

    $plugin->initalize(%params);

Initialize a filter using the specified parameters.

=cut

sub initialize {
    my $self   = shift;
    my $params = shift;

    #$self->params = $params;

    return $self;
}

=head2 destroy

    $plugin->destroy();

Destroy the filter.

=cut

sub destroy {
    my $self = shift;
    return;
}

=head2 get_suggestions

    my $suggestions = $plugin->get_suggestions(\%param);

Return suggestions for the specified search.

=cut

sub get_suggestions {
    my $self  = shift;
    my $param = shift;
    return;
}

1;
