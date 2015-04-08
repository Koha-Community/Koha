package Koha::RecordProcessor::Base;

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

Koha::RecordProcessor::Base - Base class for RecordProcessor filters

=head1 SYNOPSIS

  use base qw(Koha::RecordProcessor::Base);

=head1 DESCRIPTION

Base class for record normalizer filters. RecordProcessors must
provide the following methods:

B<filter ($record)> - apply the filter and return the result. $record
may be either a scalar or an arrayref, and the return result will be
the same type.

The following variables must be defined in each filter:
  our $NAME ='Filter';
  our $VERSION = '1.0';

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

use base qw(Class::Accessor);

__PACKAGE__->mk_ro_accessors(qw( name version ));
__PACKAGE__->mk_accessors(qw( params ));
our $NAME = 'Base';
our $VERSION = '1.0';


=head2 new

    my $filter = Koha::RecordProcessor::Base->new;

Create a new filter;

=cut
sub new {
    my $class = shift;

    my $self = $class->SUPER::new( { });#name => $class->NAME,
                                     #version => $class->VERSION });

    bless $self, $class;
    return $self;
}


=head2 initialize

    $filter->initalize(%params);

Initialize a filter using the specified parameters.

=cut
sub initialize {
    my $self = shift;
    my $params = shift;

    #$self->params = $params;

    return $self;
}


=head2 destroy

    $filter->destroy();

Destroy the filter.

=cut
sub destroy {
    my $self = shift;
    return;
}

=head2 filter

    my $newrecord = $filter->filter($record);
    my $newrecords = $filter->filter(\@records);

Filter the specified record(s) and return the result.

=cut
sub filter {
    my $self = shift;
    my $record = shift;
    return $record;
}

1;
