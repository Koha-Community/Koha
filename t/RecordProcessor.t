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

use Modern::Perl;

use File::Spec;
use MARC::Record;
use English qw( -no_match_vars );
use Test::More;

BEGIN {
    use_ok('Koha::RecordProcessor');
}

my $isbn        = '0590353403';
my $title       = 'Foundation';
my $marc_record = MARC::Record->new;
my $field       = MARC::Field->new( '020', q{}, q{}, 'a' => $isbn );
$marc_record->append_fields($field);
$field = MARC::Field->new( '245', q{}, q{}, 'a' => $title );
$marc_record->append_fields($field);

my $filterdir = File::Spec->rel2abs('Koha/Filter') . '/MARC';

my $dh;
opendir $dh, $filterdir;
my @installed_filters;
my @directory_entries = readdir $dh;
foreach my $entry (@directory_entries) {
    if ( $entry =~ /[.]pm$/xsm && -f "$filterdir/$entry" ) {
        my $filter_name = $entry;
        $filter_name =~ s/[.]pm$//xsm;
        push @installed_filters, $filter_name;
    }
}
closedir $dh;
my @available_filters = Koha::RecordProcessor::AvailableFilters();

foreach my $filter (@installed_filters) {
    ok( grep { /${filter}/xsm } @available_filters, "Found filter $filter" );
}

my $marc_filters = grep { /MARC/sm } @available_filters;
is( scalar Koha::RecordProcessor::AvailableFilters('MARC'),
    $marc_filters, 'Retrieved list of MARC filters' );

my $processor =
  Koha::RecordProcessor->new( { filters => ('ABCD::EFGH::IJKL') } );

is( ref($processor), 'Koha::RecordProcessor',
    'Created record processor with invalid filter' );

is( $processor->process($marc_record),
    $marc_record, 'Process record with empty processor' );

$processor = Koha::RecordProcessor->new( { filters => ('Null') } );
is( ref( $processor->filters->[0] ),
    'Koha::Filter::MARC::Null',
    'Created record processor with implicitly scoped Null filter' );

$processor =
  Koha::RecordProcessor->new( { filters => ('Koha::Filter::MARC::Null') } );
is( ref( $processor->filters->[0] ),
    'Koha::Filter::MARC::Null',
    'Created record processor with explicitly scoped Null filter' );

is( $processor->process($marc_record), $marc_record, 'Process record' );

$processor->bind($marc_record);

is( $processor->record, $marc_record, 'Bound record to processor' );

is( $processor->process(), $marc_record, 'Filter bound record' );

my $destroy_test = eval {
    $processor =
      Koha::RecordProcessor->new( { filters => ('Koha::Filter::MARC::Null') } );
    undef $processor;
    return 1;
};

ok( !$EVAL_ERROR && $destroy_test == 1, 'Destroyed processor successfully' );

subtest 'new() tests' => sub {

    plan tests => 14;

    my $record_processor;

    # Create a processor with a valid filter
    $record_processor = Koha::RecordProcessor->new( { filters => 'Null' } );
    is( ref($record_processor), 'Koha::RecordProcessor', 'Processor created' );
    is( scalar @{ $record_processor->filters }, 1, 'One filter initialized' );
    is( ref( $record_processor->filters->[0] ),
        'Koha::Filter::MARC::Null', 'Correct filter initialized' );

    # Create a processor with an invalid filter
    $record_processor = Koha::RecordProcessor->new( { filters => 'Dummy' } );
    is( ref($record_processor), 'Koha::RecordProcessor', 'Processor created' );
    is( scalar @{ $record_processor->filters }, 0, 'No filter initialized' );
    is( ref( $record_processor->filters->[0] ),
        q{}, 'Make sure no filter initialized' );

    # Create a processor with two valid filters
    $record_processor = Koha::RecordProcessor->new(
        { filters => [ 'Null', 'EmbedSeeFromHeadings' ] } );
    is( ref($record_processor), 'Koha::RecordProcessor', 'Processor created' );
    is( scalar @{ $record_processor->filters }, 2, 'Two filters initialized' );
    is(
        ref( $record_processor->filters->[0] ),
        'Koha::Filter::MARC::Null',
        'Correct first filter initialized'
    );
    is(
        ref( $record_processor->filters->[1] ),
        'Koha::Filter::MARC::EmbedSeeFromHeadings',
        'Correct second filter initialized'
    );

    # Create a processor with both valid and invalid filters.
    # use hash reference for regression testing
    my $parameters = {
        filters => [ 'Null', 'Dummy' ],
        options => { 'test' => 'true' }
    };
    $record_processor = Koha::RecordProcessor->new($parameters);
    is( ref($record_processor), 'Koha::RecordProcessor', 'Processor created' );
    is( scalar @{ $record_processor->filters }, 1, 'Invalid filter skipped' );
    is( ref( $record_processor->filters->[0] ),
        'Koha::Filter::MARC::Null', 'Correct filter initialized' );

    my $filter_params = $record_processor->filters->[0]->params;
    is_deeply( $filter_params, $parameters, 'Initialization parameters' );
};

done_testing();
