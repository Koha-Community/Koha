# Copyright 2016 KohaSuomi
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use Test::More;
use Carp;

use DateTime;
use C4::Search;
use C4::BatchOverlay::LowlyFinder;

use Koha::Logger;
#Koha::Logger->setConsoleVerbosity('TRACE');

use t::CataloguingCenter::localMARCRecords;
use t::lib::TestContext;

my $testContext = {};

t::lib::TestContext::setUserenv({cardnumber => '1AbatchOverlay'}, $testContext);
my $lowlyRecords = t::CataloguingCenter::localMARCRecords::create_lowlyRecords($testContext);
C4::Context->flushZconns(); #ZOOM connection has cached the previous result, so flush all connections to drop all caches.
my $output = C4::Search::reindexZebraChanges();


subtest "_prepareMonthsSearchQuery", \&_prepareMonthsSearchQuery;
sub _prepareMonthsSearchQuery {
    eval {

    my $monthsPast = 30;
    my $now = DateTime->now(time_zone => C4::Context->tz());
    my @pastMonths;
    foreach my $i (0..$monthsPast) {
        my $before = $now->clone->subtract(months => $i);
        push(@pastMonths, $before->year().'-'.sprintf("%02d",$before->month())."'");
    }

    my $query = C4::BatchOverlay::LowlyFinder::_prepareMonthsSearchQuery($monthsPast);
    foreach my $test (@pastMonths) {
        ok($query =~ /$test/, "$test found");
    }

    };
    if ($@) {
        ok(0, $@);
    }
}


subtest "Test fetching a limited amount of chunks", \&testLimiter;
sub testLimiter {
    my ($lowlyFinder, $records);
    eval {

    ##Test getting only two chunks
    $lowlyFinder = C4::BatchOverlay::LowlyFinder->new({chunk => 2, chunks => 2});

    $records = sortRecordsNicely($lowlyFinder->nextLowlyCataloguedRecords());
    is scalar(@$records), 2,                '2 chunks only. Chunk has 2 records';
    $records = sortRecordsNicely($lowlyFinder->nextLowlyCataloguedRecords());
    is scalar(@$records), 2,                '2 chunks only. Chunk has 2 records';
    $records = sortRecordsNicely($lowlyFinder->nextLowlyCataloguedRecords());
    is $records, undef,                     '2 chunks only. Chunk is undef';

    ##Test getting one chunk, which is the default
    $lowlyFinder = C4::BatchOverlay::LowlyFinder->new({chunk => 2});

    $records = sortRecordsNicely($lowlyFinder->nextLowlyCataloguedRecords());
    is scalar(@$records), 2,                'Default chunks count. Chunk has 2 records';
    $records = sortRecordsNicely($lowlyFinder->nextLowlyCataloguedRecords());
    is $records, undef,                     'Default chunks count. Chunk is undef';

    };
    if ($@) {
        ok(0, $@);
    }
}



subtest "Find lowly catalogued Records", \&findLowlyCataloguedRecords;
sub findLowlyCataloguedRecords {
    my ($lowlyFinder, $records);
    eval {

    $lowlyFinder = C4::BatchOverlay::LowlyFinder->new({chunk => 2, chunks => 10});

    #Iterate chunk1, this should be the most lowest catalogued records.
    $records = sortRecordsNicely($lowlyFinder->nextLowlyCataloguedRecords());
    is $records->[0]->subfield('020','a'), 'lowly-z-22', 'lowly-z-22';
    is $records->[1]->subfield('020','a'), 'lowly-z-21', 'lowly-z-21';
    is scalar(@$records), 2,                'Chunk has 2 records';

    #Iterate chunk2, this is an intersection between two encoding level values # and z
    $records = sortRecordsNicely($lowlyFinder->nextLowlyCataloguedRecords());
    is $records->[0]->subfield('020','a'), 'lowly-z-20', 'lowly-z-20';
    is $records->[1]->subfield('020','a'), 'lowly-u-19', 'lowly-u-19';
    is scalar(@$records), 2,                'Chunk has 2 records';

    #Iterate chunk3, this is plain enc level u
    $records = sortRecordsNicely($lowlyFinder->nextLowlyCataloguedRecords());
    is $records->[0]->subfield('020','a'), 'lowly-u-18', 'lowly-u-18';
    is $records->[1]->subfield('020','a'), 'lowly-u-17', 'lowly-u-17';
    is scalar(@$records), 2,                'Chunk remains to contain 2 records';

    #Iterate chunk4, this is plain enc level 8
    $records = sortRecordsNicely($lowlyFinder->nextLowlyCataloguedRecords());
    is $records->[0]->subfield('020','a'), 'lowly-8-16', 'lowly-8-16';
    is $records->[1]->subfield('020','a'), 'lowly-8-15', 'lowly-8-15';

    #Iterate chunk5, this is an intersection between two encoding level values 8 and 7
    $records = sortRecordsNicely($lowlyFinder->nextLowlyCataloguedRecords());
    is $records->[0]->subfield('020','a'), 'lowly-8-14', 'lowly-8-14';
    is $records->[1]->subfield('020','a'), 'lowly-7-13', 'lowly-7-13';

    #Iterate chunk6, this is plain enc level 7
    $records = sortRecordsNicely($lowlyFinder->nextLowlyCataloguedRecords());
    is $records->[0]->subfield('020','a'), 'lowly-7-12', 'lowly-7-12';
    is $records->[1]->subfield('020','a'), 'lowly-7-11', 'lowly-7-11';

    #Iterate chunk7, this is plain enc level 6
    $records = sortRecordsNicely($lowlyFinder->nextLowlyCataloguedRecords());
    is $records->[0]->subfield('020','a'), 'lowly-6-10', 'lowly-6-10';
    is $records->[1]->subfield('020','a'), 'lowly-6-9',  'lowly-6-9';

    #Iterate chunk8, this is an intersection between two encoding level values 6 and 5
    $records = sortRecordsNicely($lowlyFinder->nextLowlyCataloguedRecords());
    is $records->[0]->subfield('020','a'), 'lowly-6-8', 'lowly-6-8';
    is $records->[1]->subfield('020','a'), 'lowly-5-7', 'lowly-5-7';

    #Iterate chunk9, this is plain enc level 5
    $records = sortRecordsNicely($lowlyFinder->nextLowlyCataloguedRecords());
    is $records->[0]->subfield('020','a'), 'lowly-5-6', 'lowly-5-6';
    is $records->[1]->subfield('020','a'), 'lowly-5-5', 'lowly-5-5';

    #Iterate chunk10, this is an empty ArrayRef
    $records = sortRecordsNicely($lowlyFinder->nextLowlyCataloguedRecords());
    is $records, undef,                    'Chunk is undef';

    };
    if ($@) {
        ok(0, $@);
    }
}



subtest "Test ending threshold", \&testEndingThreshold;
sub testEndingThreshold {
    my ($lowlyFinder, $records);
    eval {

    $lowlyFinder = C4::BatchOverlay::LowlyFinder->new({chunk => 5, chunks => 4});

    $records = sortRecordsNicely($lowlyFinder->nextLowlyCataloguedRecords());
    is scalar(@$records), 5,                'Chunk has 5 records';

    $records = sortRecordsNicely($lowlyFinder->nextLowlyCataloguedRecords());
    is scalar(@$records), 5,                'Chunk has 5 records';

    $records = sortRecordsNicely($lowlyFinder->nextLowlyCataloguedRecords());
    is scalar(@$records), 5,                'Chunk has 5 records';

    #Now we get the last lowly records
    $records = sortRecordsNicely($lowlyFinder->nextLowlyCataloguedRecords());
    is scalar(@$records), 3,                'Chunk has 3 records';
    is $records->[0]->subfield('020','a'), 'lowly-5-7', 'lowly-5-7';
    is $records->[1]->subfield('020','a'), 'lowly-5-6', 'lowly-5-6';
    is $records->[2]->subfield('020','a'), 'lowly-5-5', 'lowly-5-5';

    };
    if ($@) {
        ok(0, $@);
    }
}



sub sortRecordsNicely {
    my ($arr) = @_;
    return unless $arr;
    @$arr = sort { substr($b->subfield('020', 'a'), 8, 2) <=> substr($a->subfield('020', 'a'), 8, 2) } @$arr;
    return $arr;
}

t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);
C4::Context->flushZconns(); #ZOOM connection has cached the previous result, so flush all connections to drop all caches.
$output = C4::Search::reindexZebraChanges();
done_testing();