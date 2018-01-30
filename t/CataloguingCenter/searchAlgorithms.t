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
use Try::Tiny;
use Scalar::Util qw(blessed);

use C4::BatchOverlay::SearchAlgorithms;
use C4::BatchOverlay;

use Koha::Z3950Servers;

use t::CataloguingCenter::localMARCRecords;
use t::CataloguingCenter::z3950Params;
use t::lib::TestObjects::ObjectFactory;

my $testContext = {};

my $cataloguingCenterZ3950 = t::CataloguingCenter::z3950Params::getCataloguingCenterZ3950params();
unless ($cataloguingCenterZ3950 = Koha::Z3950Servers->search($cataloguingCenterZ3950)->next) {
    $cataloguingCenterZ3950 = Koha::Z3950Server->new($cataloguingCenterZ3950)->store;
}
$cataloguingCenterZ3950 = $cataloguingCenterZ3950->unblessed;

subtest "SearchAlgorithms->_validateReturnValue", \&searchAlgorithmValidateReturnValue;
sub searchAlgorithmValidateReturnValue {
    my ($breeding, $validBreed);
    eval {
        $breeding = [
            { breedingid => 12 },
            { breedingid => 13 },
        ];
        $validBreed = C4::BatchOverlay::SearchAlgorithms::_validateReturnValue($breeding);
        is($breeding, $validBreed, "Breeding ARRAY of objects validated");

        $breeding = { breedingid => 12 };
        $validBreed = C4::BatchOverlay::SearchAlgorithms::_validateReturnValue($breeding);
        is($breeding, $validBreed, "Breeding object validated");

        try {
            $breeding = 13;
            $validBreed = C4::BatchOverlay::SearchAlgorithms::_validateReturnValue($breeding);
        } catch {
            die $_ unless(blessed($_) && $_->can('rethrow'));
            $_->rethrow unless $_->isa('Koha::Exception::UnknownProgramState');
            is(ref($_), 'Koha::Exception::UnknownProgramState', "Breeding scalar invalid");
        };

        try {
            $breeding = [{name => 'fail'}, 13];
            $validBreed = C4::BatchOverlay::SearchAlgorithms::_validateReturnValue($breeding);
        } catch {
            die $_ unless(blessed($_) && $_->can('rethrow'));
            $_->rethrow unless $_->isa('Koha::Exception::UnknownProgramState');
            is(ref($_), 'Koha::Exception::UnknownProgramState', "Breeding arrayhashmonster invalid");
        };
    };
    if ($@) {
        ok(0, $@);
    }
}



subtest "Search algorithms complex case", \&searchAlgorithmsComplexCase;
sub searchAlgorithmsComplexCase {
    my $subtestContext = {};
    eval {
    my ($localRecords, $output, $breeding, $newRecord, $newRecordEncoding);
    $localRecords = t::CataloguingCenter::localMARCRecords::createCNI_and_isbn($subtestContext);
    $output = C4::Search::reindexZebraChanges();

    ### Test "Control-number-identifier"-algorithm produces one "no results" and one good match
    try {
        $breeding = undef;
        $breeding = C4::BatchOverlay::SearchAlgorithms::dispatch('Control_number_identifier', $cataloguingCenterZ3950, $localRecords->{'0233982213'});
        die 'Test "Control-number-identifier"-algorithm using "0233982213" failed to crash as expected';
    } catch {
        die $_ unless blessed($_) && $_->can('rethrow');
        unless ($_->isa('Koha::Exception::BatchOverlay::RemoteSearchNoResults')) {
            $_->rethrow();
        }
        is($breeding, undef,
            "CNI doesn't match ISBN");
        is(ref($_), 'Koha::Exception::BatchOverlay::RemoteSearchNoResults',
            "Got the expected exception.");
    };
    try {
        $breeding = undef;
        $breeding = C4::BatchOverlay::SearchAlgorithms::dispatch('Control_number_identifier', $cataloguingCenterZ3950, $localRecords->{'-just-a-unique-id- | thiz-isbn-doeznt-match'});
        ($newRecord, $newRecordEncoding) = C4::BatchOverlay::MARCfindbreeding( $breeding->{breedingid} );
        ok($breeding,
            "CNI Matches");
        is($newRecord->title(), 'Control-number Z39.50 matching regression', #Title of the remote record, from testCluster -> batchOverlayContext.pm
            "Got the expected record");
    } catch {
        die $_ unless blessed($_) && $_->can('rethrow');
        $_->rethrow();
    };
    ### EO Test "Control-number-identifier"

    ### Test "Standard-identifier"-algorithm produces one "no results" and one good match
    try {
        $breeding = undef;
        $breeding = C4::BatchOverlay::SearchAlgorithms::dispatch('Standard_identifier', $cataloguingCenterZ3950, $localRecords->{'-just-a-unique-id- | thiz-isbn-doeznt-match'});
        die 'Test "Standard-identifier"-algorithm using "-just-a-unique-id-" failed to crash as expected';
    } catch {
        die $_ unless blessed($_) && $_->can('rethrow');
        unless ($_->isa('Koha::Exception::BatchOverlay::RemoteSearchNoResults')) {
            $_->rethrow();
        }
        is($breeding, undef,
            "Stdid doesn't match CNI");
        is(ref($_), 'Koha::Exception::BatchOverlay::RemoteSearchNoResults',
            "Got the expected exception.");
        is($_->searchTerm, '-just-a-unique-id-, thiz-isbn-doeznt-match',
            "Expected exception has the used standard identifiers listed.");
    };
    try {
        $breeding = undef;
        $breeding = C4::BatchOverlay::SearchAlgorithms::dispatch('Standard_identifier', $cataloguingCenterZ3950, $localRecords->{'0233982213'});
        ($newRecord, $newRecordEncoding) = C4::BatchOverlay::MARCfindbreeding( $breeding->{breedingid} );
        ok($breeding,
            "Stdid Matches");
        is($newRecord->title(), 'THE WISHING TREE / USHA BAHL.', #Title of the remote record, from testCluster -> batchOverlayContext.pm
            "Got the expected record");
    } catch {
        die $_ unless blessed($_) && $_->can('rethrow');
        $_->rethrow();
    };
    ### EO Test "Standard-identifier"

    };
    if ($@) {
        ok(0, $@);
    }

    t::lib::TestObjects::ObjectFactory->tearDownTestContext($subtestContext);
    C4::ImportBatch::DeleteImportBatch('CATALOGUING_CENTER');
    C4::Context->flushZconns(); #ZOOM connection has cached the previous result, so flush all connections to drop all caches.
}



subtest "Search algorithms failed search", \&searchAlgorithmsFailedSearch;
sub searchAlgorithmsFailedSearch {
    my $subtestContext = {};
    eval {
    my ($localRecords, $output, $breeding, $exceptions, $record);
    $localRecords = t::CataloguingCenter::localMARCRecords::create_isbn_strangers($subtestContext);
    $output = C4::Search::reindexZebraChanges();

    ### Testing exceptions when nothing is found
    my $searchAlgorithms = ['Control_number_identifier', 'Standard_identifier'];
    my @exceptions; #Collect exceptions from multiple search attempts here and if no search produces results, throw them all

    $record = $localRecords->{'i-dont-exist-in-remote-1111'};
    ($breeding, $exceptions) = C4::BatchOverlay->_trySearchAlgorithms($searchAlgorithms, $cataloguingCenterZ3950, $record);
    is($breeding, undef,
       "1st search no breeding result");
    is(scalar(@$exceptions), 2,
       "1st search got 2 exceptions");
    is($exceptions->[0]->searchAlgorithm(), "Control_number_identifier",
       "1st search 1st exception property 'searchAlgorithm'");
    is($exceptions->[1]->searchAlgorithm(), "Standard_identifier",
       "1st search 2nd exception property 'searchAlgorithm'");

    $record = $localRecords->{'i-dont-exist-in-remote-2222'};
    ($breeding, $exceptions) = C4::BatchOverlay->_trySearchAlgorithms($searchAlgorithms, $cataloguingCenterZ3950, $record);
    is($breeding, undef,
       "2nd search no breeding result");
    is(scalar(@$exceptions), 2,
       "2nd search got 2 exceptions");
    is($exceptions->[0]->searchAlgorithm(), "Control_number_identifier",
       "2nd search 1st exception property 'searchAlgorithm'");
    is($exceptions->[1]->searchAlgorithm(), "Standard_identifier",
       "2nd search 2nd exception property 'searchAlgorithm'");

    };
    if ($@) {
        ok(0, $@);
    }

    t::lib::TestObjects::ObjectFactory->tearDownTestContext($subtestContext);
    C4::ImportBatch::DeleteImportBatch('CATALOGUING_CENTER');
    C4::Context->flushZconns(); #ZOOM connection has cached the previous result, so flush all connections to drop all caches.
}



t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);
done_testing();
