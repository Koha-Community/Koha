#!/usr/bin/perl

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

use strict;
use warnings;
use File::Spec;
use MARC::Record;

use Test::More;

BEGIN {
        use_ok('Koha::RecordProcessor');
}

my $isbn = '0590353403';
my $title = 'Foundation';
my $marc_record=MARC::Record->new;
my $field = MARC::Field->new('020','','','a' => $isbn);
$marc_record->append_fields($field);
$field = MARC::Field->new('245','','','a' => $title);
$marc_record->append_fields($field);


my $filterdir = File::Spec->rel2abs('Koha/Filter') . '/MARC';

opendir(my $dh, $filterdir);
my @installed_filters = map { ( /\.pm$/ && -f "$filterdir/$_" && s/\.pm$// ) ? "Koha::Filters::MARC::$_" : () } readdir($dh);
my @available_filters = Koha::RecordProcessor::AvailableFilters();

foreach my $filter (@installed_filters) {
    ok(grep($filter, @available_filters), "Found filter $filter");
}

my $marc_filters = grep (/MARC/, @available_filters);
is(scalar Koha::RecordProcessor::AvailableFilters('MARC'), $marc_filters, 'Retrieved list of MARC filters');

my $processor = Koha::RecordProcessor->new( { filters => ( 'ABCD::EFGH::IJKL' ) } );

is(ref($processor), 'Koha::RecordProcessor', 'Created record processor with invalid filter');

is($processor->process($marc_record), $marc_record, 'Process record with empty processor');

$processor = Koha::RecordProcessor->new( { filters => ( 'Null' ) } );
is(ref($processor->filters->[0]), 'Koha::Filter::MARC::Null', 'Created record processor with implicitly scoped Null filter');

$processor = Koha::RecordProcessor->new( { filters => ( 'Koha::Filter::MARC::Null' ) } );
is(ref($processor->filters->[0]), 'Koha::Filter::MARC::Null', 'Created record processor with explicitly scoped Null filter');

is($processor->process($marc_record), $marc_record, 'Process record');

$processor->bind($marc_record);

is($processor->record, $marc_record, 'Bound record to processor');

is($processor->process(), $marc_record, 'Filter bound record');

eval {
    $processor = Koha::RecordProcessor->new( { filters => ( 'Koha::Filter::MARC::Null' ) } );
    undef $processor;
};

ok(!$@, 'Destroyed processor successfully');

done_testing();
