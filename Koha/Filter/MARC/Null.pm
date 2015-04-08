package Koha::Filter::MARC::Null;

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

Koha::Filter::MARC::Null - an example filter that does nothing but allow us to run tests

=head1 SYNOPSIS


=head1 DESCRIPTION

Filter to allow us to run unit tests and regression tests against the
RecordProcessor.

=cut

use strict;
use warnings;
use Carp;

use base qw(Koha::RecordProcessor::Base);
our $NAME = 'Null';
our $VERSION = '1.0';

=head2 filter

    my $newrecord = $filter->filter($record);
    my $newrecords = $filter->filter(\@records);

Return the original record.

=cut
sub filter {
    my $self = shift;
    my $record = shift;

    return $record;
}
