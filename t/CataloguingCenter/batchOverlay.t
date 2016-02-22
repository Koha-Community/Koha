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

=head TEST PLAN BatchOverlay

#Verify remote is working properly
-2. Make sure that the remote Z39.50 target is listening for connections, if not print info on how to enable it.
-2.1. Verify by making a search with an expected result. Test here that the biblios that overlay the test data are
      present. Verify remote test context integrity. If somebody altered necessary remote records, print help on how
      to recover.

#Verify local indexing works
-1. Verify that the local search index is working. If not, print info on how to enable it.
-1.1. Add a Biblio to indexing queue
-1.2. Index the search index
-1.3. Search for the indexed biblio.
-1.4. Verify match.

#Manual batch overlay testing
1. Create and index local records with a low cataloguing-level.
2. Make a local search with unique identifiers to collect the overwritable local records.
3. BatchOverlay local manually selected records from remote.
4. Confirm that we get expected results. Local 001 && 003 is overwritten by remote to mark the remote origin.
4.1. Expect not all records to be overwritten, because the fully catalogued records might not be available yet.

#Manual batch overlay with exceptions
-Unidentifiable local search terms. More than one hit, no hits.
-Remote search. More than one hit, no hits.
-Network fails abruptly?

#Automatic low-cataloguing level record overlay from complete
1. Create and index local records with a low cataloguing-level.
2. Make a cataloguing-level search to get partially catalogued records needing BatchOverlay.
3. BatchOverlay local automatically selected records from remote. Also expect not all records to be overwritten.
4. Confirm that we get expected results. Local 001 && 003 is overwritten by remote to mark the remote origin.
4.1. Expect not all records to be overwritten, because the fully catalogued records might not be available yet.

=cut

use Modern::Perl;
use Test::More;
use MARC::Record;
use MARC::File::XML;

use C4::Biblio;
use C4::Context;
use C4::Matcher;
use C4::Breeding;
use C4::Search;
use C4::BatchOverlay;

use Koha::Z3950Servers;

use t::CataloguingCenter::localMARCRecords;
use t::CataloguingCenter::matchers;
use t::CataloguingCenter::ContextSysprefs;
use t::CataloguingCenter::z3950Params;
use t::lib::TestObjects::ObjectFactory;
use t::lib::TestContext;

my $testContext = {};

t::lib::TestContext::setUserenv({cardnumber => '1AbatchOverlay'}, $testContext);
my $cataloguingCenterZ3950 = t::CataloguingCenter::z3950Params::getCataloguingCenterZ3950params();
$cataloguingCenterZ3950 = Koha::Z3950Server->new($cataloguingCenterZ3950)->store->unblessed;
my $mergeMatcher = t::CataloguingCenter::matchers::create($testContext)->{MERGE_MATCHER};
t::CataloguingCenter::ContextSysprefs::create($testContext);



subtest "Verify remote BatchOverlay target is available", \&verifyRemoteBatchOverlayTarget;
sub verifyRemoteBatchOverlayTarget {
    eval {
    my $z3950results = {};
    C4::Breeding::Z3950Search({id => [$cataloguingCenterZ3950->{id}],
                               title => 'Tuhat sanaa ruotsiksi',
                               }, $z3950results, 'getAll');
    my $searchResults = $z3950results->{breeding_loop};
    ok(ref($searchResults) eq 'ARRAY' && scalar(@$searchResults) == 1,
       'Search succesfull');
    my $breedingResult = $searchResults->[0];
    my ($newRecord, $newRecordEncoding) = C4::BatchOverlay::MARCfindbreeding( $breedingResult->{breedingid} );
    is($newRecord->subfield('245','a'),
       'Tuhat sanaa ruotsiksi /',
       "Title matches");
    is($newRecord->field('003')->data(),
       'VAARA',
       "003 matches");
    };
    if ($@) {
        ok(0, $@);
    }

    #TEAR DOWN CHANGES
    C4::ImportBatch::DeleteImportBatch('CATALOGUING_CENTER');
}



subtest "Verify remote BatchOverlay target is accepts Control-number-identifier searching", \&verifyRemoteBatchOverlayTargetCNISearch;
sub verifyRemoteBatchOverlayTargetCNISearch {
    eval {
    my $z3950results = {};
    C4::Breeding::Z3950Search({id => [$cataloguingCenterZ3950->{id}],
                               controlNumber => '13371337',
                               controlNumberIdentifier => 'CNI-TEST',
                               }, $z3950results, 'getAll');
    my $searchResults = $z3950results->{breeding_loop};
    ok(ref($searchResults) eq 'ARRAY' && scalar(@$searchResults) == 1,
       'Search succesfull');
    my $breedingResult = $searchResults->[0];
    my ($newRecord, $newRecordEncoding) = C4::BatchOverlay::MARCfindbreeding( $breedingResult->{breedingid} );
    is($newRecord->subfield('245','a'),
       'Control-number Z39.50 matching regression',
       "Title matches");
    is($newRecord->field('003')->data(),
       'CNI-TEST',
       "003 matches");
    };
    if ($@) {
        ok(0, $@);
    }

    #TEAR DOWN CHANGES
    C4::ImportBatch::DeleteImportBatch('CATALOGUING_CENTER');
}



subtest "Verify local search and indexing works", \&verifyLocalSearchAndIndexing;
sub verifyLocalSearchAndIndexing {
    my $subtestContext = {};
    my ( $error, $marcresults, $total_hits, $localRecords, $output );
    eval {
    $localRecords = t::CataloguingCenter::localMARCRecords::create($subtestContext);

    $output = C4::Search::reindexZebraChanges();

    ( $error, $marcresults, $total_hits ) = C4::Search::SimpleSearch("title='Tuhat sanaa ruotsiksi'");
    ok(ref($marcresults) eq 'ARRAY' && scalar(@$marcresults) == 1,
       'Search "Tuhat sanaa ruotsiksi"');
    ok($marcresults->[0] =~ /Tuhat sanaa ruotsiksi/,
       'Got the correct record');

    ( $error, $marcresults, $total_hits ) = C4::Search::SimpleSearch("title='THE WISHING TREE'");
    ok(ref($marcresults) eq 'ARRAY' && scalar(@$marcresults) == 1,
       'Search "THE WISHING TREE"');
    ok($marcresults->[0] =~ /THE WISHING TREE/,
       'Got the correct record');

    ( $error, $marcresults, $total_hits ) = C4::Search::SimpleSearch("title='TYRANNIT VOIVAT'"); #HYVIN and PAREMMIN
    ok(ref($marcresults) eq 'ARRAY' && scalar(@$marcresults) == 2,
       'Search "TYRANNIT VOIVAT" and got two results');
    ok($marcresults->[0] =~ /TYRANNIT VOIVAT HYVIN/,
       'Got the correct record');
    ok($marcresults->[1] =~ /TYRANNIT VOIVAT PAREMMIN/,
       'Got the correct record');

    ( $error, $marcresults, $total_hits ) = C4::Search::SimpleSearch("title='1212343'");
    ok(ref($marcresults) eq 'ARRAY' && scalar(@$marcresults) == 0,
       'Bad search failed');

    };
    if ($@) {
        ok(0, $@);
    }
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($subtestContext);
    C4::Context->flushZconns(); #ZOOM connection has cached the previous result, so flush all connections to drop all caches.
}



subtest "Manual BatchOverlay", \&manualBatchOverlay;
sub manualBatchOverlay {
    my $subtestContext = {};
    eval {

    my $localRecords = t::CataloguingCenter::localMARCRecords::create($subtestContext);
    my $output = C4::Search::reindexZebraChanges();

    my $batchOverlayer = C4::BatchOverlay->new();
    $batchOverlayer->overlay(['9510108340', '9510108340', 'this-doesnt-exist'], undef);
    my $reports = $batchOverlayer->getReports();
    is(scalar(@$reports), 3,
       "Overlaid three records, got three operation reports");
    is($reports->[0]->getDiff()->{class},
       'Koha::Exception::BatchOverlay::DuplicateSearchTerm',
       'First report is a DuplicateSearchTerm-exception');
    is($reports->[0]->{operation},
       'error sanitate search terms',
       'First report has operation tagged with error and attempted operation');
    is($reports->[1]->getDiff()->{100}->[0]->{a}->[0]->[0],
       undef,
       'Old record is missing field 100$a');
    is($reports->[1]->getDiff()->{100}->[0]->{a}->[0]->[2],
       'LUOSTARINEN, AKI.',
       'Missing field 100$a overlayed from remote, yay!');
    is($reports->[2]->getDiff()->{class},
       'Koha::Exception::BatchOverlay::LocalSearchNoResults',
       'third report is a LocalSearchNoResults-exception');

    #Get the original local record from the search index to verify it has changed.
    C4::Context->flushZconns(); #ZOOM connection has cached the previous result, so flush all connections to drop all caches.
    $output = C4::Search::reindexZebraChanges();
    my ( $error, $marcresults, $total_hits ) = C4::Search::SimpleSearch("9510108340");
    my $overlayedRecord = MARC::Record::new_from_xml( $marcresults->[0], "utf8", 'marc21' );
    is($overlayedRecord->subfield('100','a'),
       'LUOSTARINEN, AKI.',
       'From search index: Overlayed subfield 100$a is present in search index');

    #Get the biblionumber of the original local biblio and refresh reference from DB
    my $overlayedBiblio = C4::Biblio::GetBiblio( $localRecords->{'9510108340'}->{biblionumber} );
    is($overlayedBiblio->{author},
       'LUOSTARINEN, AKI.',
       'From DB: Overlayed subfield 100$a is present in DB');

    };
    if ($@) {
        ok(0, $@);
    }

    C4::BatchOverlay::ReportManager->removeReports({do => 1});
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($subtestContext);
    C4::ImportBatch::DeleteImportBatch('CATALOGUING_CENTER');
    C4::Context->flushZconns(); #ZOOM connection has cached the previous result, so flush all connections to drop all caches.
}



subtest "BatchOverlay Component parts", \&batchOverlayComponentParts;
sub batchOverlayComponentParts {
    my $subtestContext = {};
    eval {
    my ($localRecords, $output, $batchOverlayer, $reportContainer, $hostRecord, @comPartBiblionumbers);

    $localRecords = t::CataloguingCenter::localMARCRecords::create_host_record($subtestContext);
    $hostRecord = $localRecords->{'host-record-isbn'};
    $output = C4::Search::reindexZebraChanges();

    ################################################
    ### Batch Overlay component parts (for the first time)

    $batchOverlayer = C4::BatchOverlay->new();
    $reportContainer = $batchOverlayer->getReportContainer();
    $batchOverlayer->overlayComponentParts($hostRecord, '');

    is($reportContainer->getReportsCount(),
       3,
       "Got 3 component part overlaying reports");
    is($reportContainer->getErrorsCount(),
       0,
       "Got 0 component part overlaying errors");


    #Get the component parts from local search index
    C4::Context->flushZconns(); #ZOOM connection has cached the previous result, so flush all connections to drop all caches.
    $output = C4::Search::reindexZebraChanges();
    my ($parentsField001, $parentsField003, $parentrecord, $error, $componentPartRecordXMLs, $resultSetSize)
                    = C4::Biblio::_getComponentParts($hostRecord->field('001')->data(),
                                                     $hostRecord->field('003')->data());

    ok($componentPartRecordXMLs->[0] =~ /component-part-11/,
       "CP1 in local index");
    is(C4::Biblio::GetMarcTitle( $reportContainer->getReports()->[0]->{newRecord}),
       'Component part 11',
       'CP1 in ReportContainer with title');
    is(C4::Biblio::GetMarcKohaDefaultItemType( $reportContainer->getReports()->[0]->{newRecord}),
       'BK',
       'CP1 in ReportContainer with Koha default item type from parent');
    ok(C4::Biblio::GetMarcControlnumber( $reportContainer->getReports()->[0]->{newRecord}, 'MARC21'),
       'CP1 in ReportContainer with biblionumber');
    is($reportContainer->getReports()->[0]->{operation},
       'new component part',
       'CP1 in ReportContainer with proper operation');
    ok($reportContainer->getReports()->[0]->getHeaders()->[0]->getBiblionumber,
       'CP1 in ReportContainer with a header biblionumber');
    ok(not(  $reportContainer->getReports()->[0]->getHeaders()->[1]  ),
       'CP1 in ReportContainer with only one header');
    ok($componentPartRecordXMLs->[1] =~ /component-part-22/,
       "CP2 in local index");
    is(C4::Biblio::GetMarcTitle( $reportContainer->getReports()->[1]->{newRecord}),
       'Component part 22',
       'CP2 in ReportContainer with title');
    is(C4::Biblio::GetMarcKohaDefaultItemType( $reportContainer->getReports()->[1]->{newRecord}),
       'BK',
       'CP2 in ReportContainer with Koha default item type from parent');
    ok(C4::Biblio::GetMarcControlnumber( $reportContainer->getReports()->[1]->{newRecord}, 'MARC21'),
       'CP2 in ReportContainer with biblionumber');
    is($reportContainer->getReports()->[1]->{operation},
       'new component part',
       'CP2 in ReportContainer with proper operation');
    ok($reportContainer->getReports()->[1]->getHeaders()->[0]->getBiblionumber,
       'CP2 in ReportContainer with a header biblionumber');
    ok(not(  $reportContainer->getReports()->[1]->getHeaders()->[1]  ),
       'CP2 in ReportContainer with only one header');
    ok($componentPartRecordXMLs->[2] =~ /component-part-33/,
       "CP3 in local index");
    ok(not( $componentPartRecordXMLs->[3] ),
       "Only 3 CP's found in local index");
    ok(not( $reportContainer->getReports()->[3] ),
       "Only 3 CP's found in ReportContainer");
    #Store the biblionumbers of recently added component parts so we can make sure that the following component parts overlay them, not add new ones.
    $comPartBiblionumbers[0] = C4::Biblio::GetMarcControlnumber( $reportContainer->getReports()->[0]->{newRecord}, 'MARC21');
    $comPartBiblionumbers[1] = C4::Biblio::GetMarcControlnumber( $reportContainer->getReports()->[1]->{newRecord}, 'MARC21');
    $comPartBiblionumbers[2] = C4::Biblio::GetMarcControlnumber( $reportContainer->getReports()->[2]->{newRecord}, 'MARC21');

    ################################
    ### Modify a component part and overlay it from remote again to confirm that local changes have been overwritten ###

    #mod component part
    my $cp1 = MARC::Record::new_from_xml( $componentPartRecordXMLs->[0], "utf8", 'marc21' );
    my ( $tag, $code ) = C4::Biblio::GetMarcFromKohaField( "biblio.biblionumber" );
    my $cp1biblionumber = $cp1->subfield( $tag, $code );
    $cp1->insert_fields_ordered(  MARC::Field->new( '510', ' ', ' ',
                                                    'a' => 'Indexed by Google.' )  );
    C4::Biblio::ModBiblio($cp1, $cp1biblionumber, '');
    C4::Context->flushZconns(); #ZOOM connection has cached the previous result, so flush all connections to drop all caches.
    $output = C4::Search::reindexZebraChanges();

    #Verify that the mod is persisted
    ($parentsField001, $parentsField003, $parentrecord, $error, $componentPartRecordXMLs, $resultSetSize)
                    = C4::Biblio::_getComponentParts($hostRecord->field('001')->data(),
                                                     $hostRecord->field('003')->data());
    ok($componentPartRecordXMLs->[0] =~ /component-part-11/ && $componentPartRecordXMLs->[0] =~ /Indexed by Google\./,
       "Component part 1 modification persisted");

    #Start a new batch overlay operation, this time we already have the component parts in the DB
    $batchOverlayer = C4::BatchOverlay->new();
    $reportContainer = $batchOverlayer->getReportContainer();
    $batchOverlayer->overlayComponentParts($hostRecord, '');

    is($batchOverlayer->getReportContainer->getReportsCount(),
       3,
       "Got 3 component part overlaying reports");
    is($batchOverlayer->getReportContainer->getErrorsCount(),
       0,
       "Got 0 component part overlaying errors");

    #Get the component parts from local search index
    C4::Context->flushZconns(); #ZOOM connection has cached the previous result, so flush all connections to drop all caches.
    $output = C4::Search::reindexZebraChanges();
    ($parentsField001, $parentsField003, $parentrecord, $error, $componentPartRecordXMLs, $resultSetSize)
                    = C4::Biblio::_getComponentParts($hostRecord->field('001')->data(),
                                                     $hostRecord->field('003')->data());

    is($reportContainer->getReports()->[0]->getHeaders()->[2]->getTitle(),
       'Component part 11',
       'CP1 in ReportContainer with headers');
    ok(not( $reportContainer->getReports()->[0]->getHeaders()->[3] ),
       'CP1 in ReportContainer with three headers');
    ok($componentPartRecordXMLs->[0] =~ /component-part-11/,
       "Component part 1 found again from local index");
    is(C4::Biblio::GetMarcControlnumber( $reportContainer->getReports()->[0]->{newRecord}, 'MARC21'),
       $comPartBiblionumbers[0],
       "CP1 in ReportContainer matches previously added CP1");
    ok($componentPartRecordXMLs->[1] =~ /component-part-22/,
       "Component part 2 found again from local index");
    is(C4::Biblio::GetMarcControlnumber( $reportContainer->getReports()->[1]->{newRecord}, 'MARC21'),
       $comPartBiblionumbers[1],
       "CP2 in ReportContainer matches previously added CP2");
    is(C4::Biblio::GetMarcTitle( $reportContainer->getReports()->[1]->{newRecord}),
       'Component part 22',
       'CP2 in ReportContainer with title');
    ok(C4::Biblio::GetMarcControlnumber( $reportContainer->getReports()->[1]->{newRecord}, 'MARC21'),
       'CP2 in ReportContainer with biblionumber');
    is($reportContainer->getReports()->[1]->{operation},
       'overlaying component part',
       'CP2 in ReportContainer with proper operation');
    ok($reportContainer->getReports()->[1]->getHeaders()->[0]->getBiblionumber,
       'CP2 in ReportContainer with a header biblionumber');
    is($reportContainer->getReports()->[1]->getHeaders()->[2]->getTitle(),
       'Component part 22',
       'CP2 in ReportContainer with headers');
    ok(not( $reportContainer->getReports()->[1]->getHeaders()->[3] ),
       'CP2 in ReportContainer with three headers');
    ok($componentPartRecordXMLs->[2] =~ /component-part-33/,
       "Component part 3 found again from local index");
    is(C4::Biblio::GetMarcControlnumber( $reportContainer->getReports()->[2]->{newRecord}, 'MARC21'),
       $comPartBiblionumbers[2],
       "CP3 in ReportContainer matches previously added CP3");
    is($reportContainer->getReports()->[2]->getHeaders()->[2]->getTitle(),
       'Component part 33',
       'CP3 in ReportContainer with headers');
    ok(not( $reportContainer->getReports()->[2]->getHeaders()->[3] ),
       'CP3 in ReportContainer with three headers');

    $cp1 = MARC::Record::new_from_xml( $componentPartRecordXMLs->[0], "utf8", 'marc21' );
    is($cp1->subfield('510'), undef,
       "Component part 1 modification overwritten from remote.");
    is(C4::Biblio::GetMarcKohaDefaultItemType( $cp1 ),
       'BK',
       'Component part 1 Koha default item type from parent preserved');

    };
    if ($@) {
        ok(0, $@);
    }

    C4::BatchOverlay::ReportManager->removeReports({do => 1});
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($subtestContext);
    C4::ImportBatch::DeleteImportBatch('CATALOGUING_CENTER');
    C4::Context->flushZconns(); #ZOOM connection has cached the previous result, so flush all connections to drop all caches.
}



subtest "Automatic BatchOverlay", \&automaticBatchOverlay;
sub automaticBatchOverlay {
    my $subtestContext = {};
    eval {

    my $localRecords = t::CataloguingCenter::localMARCRecords::create($subtestContext);
    my @localRecords = map {$localRecords->{$_}} keys %$localRecords;
    @localRecords = sort { $a->{biblionumber} <=> $b->{biblionumber} } @localRecords;
    my $output = C4::Search::reindexZebraChanges();

    my $batchOverlayer = C4::BatchOverlay->new();
    $batchOverlayer->overlay(undef, \@localRecords); #overlay from MARC::Records instead of search keywords
    my $reports = $batchOverlayer->getReports();
    is(scalar(@$reports), 5,
       "Overlaid five records, got five operation reports");
    is($reports->[0]->getDiff()->{'000'}->[0],
       '00494cam a22001694a 4500',
       'First overlay - almost unchanged');
    is(scalar(keys %{$reports->[0]->getDiff()}),
       2,
       'First overlay - two changed fields');
    is($reports->[0]->{operation},
       'overlay record',
       'First overlay - operation ok');
    is($reports->[3]->getDiff()->{100}->[0]->{a}->[0]->[0],
       undef,
       'Fourth overlay - Old record is missing field 100$a');
    is($reports->[3]->getDiff()->{100}->[0]->{a}->[0]->[1],
       'LUOSTARINEN, AKI.',
       'Fourth overlay - New record has field 100$a');
    is($reports->[3]->getDiff()->{100}->[0]->{a}->[0]->[2],
       'LUOSTARINEN, AKI.',
       'Fourth overlay - Merged record has field 100$a');
    is(scalar(keys %{$reports->[3]->getDiff()}),
       8,
       'Fourth overlay - six changed fields');
    is($reports->[3]->{operation},
       'overlay record',
       'Fourth overlay - operation ok');

    };
    if ($@) {
        ok(0, $@);
    }

    C4::BatchOverlay::ReportManager->removeReports({do => 1});
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($subtestContext);
    C4::ImportBatch::DeleteImportBatch('CATALOGUING_CENTER');
    C4::Context->flushZconns(); #ZOOM connection has cached the previous result, so flush all connections to drop all caches.
}



t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);
done_testing();
