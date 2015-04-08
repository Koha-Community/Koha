package Koha::RecordProcessor;

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

Koha::RecordProcessor - Dispatcher class for record normalization

=head1 SYNOPSIS

  use Koha::RecordProcessor;
  my $normalizer = Koha::RecordProcessor(%params);
  $normalizer->process($record)

=head1 DESCRIPTION

Dispatcher class for record normalization. RecordProcessors must
extend Koha::RecordProcessor::Base, be in the Koha::Filter namespace,
and provide the following methods:

B<filter ($record)> - apply the filter and return the result. $record
may be either a scalar or an arrayref, and the return result will be
the same type.

These methods may be overriden:

B<initialize (%params)> - initialize the filter

B<destroy ()> - destroy the filter

These methods should not be overridden unless you are very sure of what
you are doing:

B<new ()> - create a new filter object

Note that the RecordProcessor will not clone the record that is
passed in. If you do not want to change the original MARC::Record
object (or whatever type of object you are passing in), you must
clone it I<prior> to passing it off to the RecordProcessor.

=head1 FUNCTIONS

=cut

use strict;
use warnings;
use Module::Load::Conditional qw(can_load);
use Module::Pluggable::Object;

use base qw(Class::Accessor);

__PACKAGE__->mk_accessors(qw( schema filters options record ));

=head2 new

    my $normalizer = Koha::RecordProcessor->new(%params);

Create a new normalizer. Available parameters are:

=over 8

=item B<schema>

Which metadata schema is in use. At the moment the only supported schema
is 'MARC'.

=item B<filters>

What filter(s) to use. This must be an arrayref to a list of filters. Filters
can be specified either with a complete class path, or, if they are in the
Koha::Filter::${schema} namespace, as only the filter name, and
"Koha::Filter::${schema}" will be prepended to it before the filter is loaded.

=back

=cut
sub new {
    my $class = shift;
    my $param = shift;


    my $schema = $param->{schema} || 'MARC';
    my $options = $param->{options} || '';
    my @filters = ( );

    foreach my $filter ($param->{filters}) {
        next unless $filter;
        my $filter_module = $filter =~ m/:/ ? $filter : "Koha::Filter::${schema}::${filter}";
        if (can_load( modules => { $filter_module => undef } )) {
            my $object = $filter_module->new();
            $filter_module->initialize($param);
            push @filters, $object;
        }
    }

    my $self = $class->SUPER::new( { schema => $schema,
                                     filters => \@filters,
                                     options => $options });
    bless $self, $class;
    return $self;
}

=head2 bind

    $normalizer->bind($record)

Bind a normalizer to a particular record.

=cut
sub bind {
    my $self = shift;
    my $record = shift;

    $self->{record} = $record;
    return;
}

=head2 process

    my $newrecord = $normalizer->process([$record])

Run the record(s) through the normalization pipeline. If $record is
not specified, process the record the normalizer is bound to.
Note that $record may be either a scalar or an arrayref, and the
return value will be of the same type.

=cut
sub process {
    my $self = shift;
    my $record = shift || $self->record;

    return unless defined $record;

    my $newrecord = $record;

    foreach my $filterobj (@{$self->filters}) {
        next unless $filterobj;
        $newrecord = $filterobj->filter($newrecord);
    }

    return $newrecord;
}

sub DESTROY {
    my $self = shift;

    foreach my $filterobj (@{$self->filters}) {
        $filterobj->destroy();
    }
}

=head2 AvailableFilters

    my @available_filters = Koha::RecordProcessor::AvailableFilters([$schema]);

Get a list of available filters. Optionally specify the metadata schema.
At present only MARC is supported as a schema.

=cut
sub AvailableFilters {
    my $schema = pop || '';
    my $path = 'Koha::Filter';
    $path .= "::$schema" if ($schema eq 'MARC');
    my $finder = Module::Pluggable::Object->new(search_path => $path);
    return $finder->plugins;
}

1;
