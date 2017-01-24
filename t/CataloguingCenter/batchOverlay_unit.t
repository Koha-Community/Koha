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
use Scalar::Util qw(blessed);
use Try::Tiny;

use C4::BatchOverlay;
use C4::BatchOverlay::ErrorBuilder;
use C4::BatchOverlay::ReportContainer;
use C4::BatchOverlay::ReportManager;
use C4::BatchOverlay::RuleManager;

use t::lib::TestContext;
use t::CataloguingCenter::localMARCRecords;
use t::CataloguingCenter::ContextSysprefs;
use t::db_dependent::Biblio::Diff::localRecords;
use t::lib::TestObjects::ObjectFactory;
use t::lib::TestObjects::BiblioFactory;

use Koha::Exception::BatchOverlay::UnknownMatcher;
use Koha::Exception::BatchOverlay::DuplicateSearchTerm;

my $globalTestContext = {};
t::lib::TestContext::setUserenv({cardnumber => '1AbatchOverlay'}, $globalTestContext);
t::CataloguingCenter::ContextSysprefs::createBatchOverlayRules($globalTestContext);

subtest "BatchOverlay::Rule", \&batchOverlayRule;
sub batchOverlayRule {
    eval {
    my $ruleManager = C4::BatchOverlay::RuleManager->new();
    my $rule = $ruleManager->getRuleFromRuleName('default');
    my $def = $rule->getDiffExcludedFields();
    my $rfd = $rule->getRemoteFieldsDropped();

    is($def->[0], '999', "Koha control field excluded from diff");
    is($def->[1], '952', "Koha items field excluded from diff");
    is($rfd->[0], '999', "Koha control field dropped from remote records");
    is($rfd->[1], '952', "Koha items field dropped from remote records");
    };
    if ($@) {
        ok(0, $@);
    }
}

subtest "BatchOverlay->_sanitateSearchTermsArray", \&batchOverlay_sanitateSearchTermsArray;
sub batchOverlay_sanitateSearchTermsArray {
    eval {
    my $batchOverlayer = C4::BatchOverlay->new();

    my $searchTerms = $batchOverlayer->_sanitateSearchTermsArray(['isbn1','isbn2','isbn3','isbn1','isbn2']);
    is($searchTerms->[0], 'isbn1', "Search term deduplicated");
    is($searchTerms->[1], 'isbn2', "Search term deduplicated");
    is($searchTerms->[2], 'isbn3', "Search term present");
    my $errors = $batchOverlayer->getErrorBuilder()->getErrors();
    is($errors->[0]->getError()->{class}, 'Koha::Exception::BatchOverlay::DuplicateSearchTerm', 'Koha::Exception::BatchOverlay::DuplicateSearchTerm caught');
    is($errors->[1]->getError()->{error}, "Duplicate search term 'isbn2'", 'Koha::Exception::BatchOverlay::DuplicateSearchTerm has correct message');
    };
    if ($@) {
        ok(0, $@);
    }
}

subtest "BatchOverlay::ReportContainer->generateReport", \&batchOverlayGenerateReport;
sub batchOverlayGenerateReport {
    my $testContext = {};
    eval {
        my $ruleManager = C4::BatchOverlay::RuleManager->new();
        my $records = t::db_dependent::Biblio::Diff::localRecords::create($testContext);
        my @recKeys = sort(keys(%$records));

        #Remove 9** fields, including biblionumber-subfield, since they are hard to test but add no value to this subtest.
        foreach (keys(%$records)) {
            my $record = $records->{$_};
            my @delme = $record->field('9..');
            $record->delete_fields(@delme);
        }

        my $reportContainer = C4::BatchOverlay::ReportContainer->new();
        $reportContainer->addReport(
            {   localRecord =>    $records->{ $recKeys[0] },
                newRecord =>    $records->{ $recKeys[1] },
                mergedRecord => $records->{ $recKeys[2] },
                operation => 'record merging',
                timestamp => DateTime->now( time_zone => C4::Context->tz() ),
                overlayRule => $ruleManager->getRuleFromRuleName('default'),
            }
        );
        $reportContainer->addReport(
            {   localRecord =>    $records->{ $recKeys[1] },
                newRecord =>    $records->{ $recKeys[2] },
                mergedRecord => $records->{ $recKeys[0] },
                operation => 'record merging',
                timestamp => DateTime->now( time_zone => C4::Context->tz() ),
                overlayRule => $ruleManager->getRuleFromRuleName('default'),
            }
        );
        my $reports = $reportContainer->getReports();
        my $headers0 = $reports->[0]->{recordHeaders};
        is($headers0->[0]->{title},
           'THE WISHING TREE /',
           'Diff 0, record 0, header title');
        is($headers0->[1]->{title},
           'TYRANNIT VOIVAT PAREMMIN :',
           'Diff 0, record 1, header title');
        is($headers0->[2]->{title},
           'TYRANNIT VOIVAT PAREMMIN :',
           'Diff 0, record 2, header title');

        my $diff1 = $reports->[1]->{diff};
        is($diff1->{'003'}->[0],
           'OUTI',
           "Same diff, different order");
        is($diff1->{'003'}->[1],
           undef,
           "Same diff, different order");
        is($diff1->{'003'}->[2],
           'KYYTI',
           "Same diff, different order");
    };
    if ($@) {
        ok(0, $@);
    }
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);
}

subtest "BatchOverlay->_sanitateRemoteRecord", \&batchOverlaySanitateRemoteRecord;
sub batchOverlaySanitateRemoteRecord {
    my $testContext = {};
    eval {
        my $ruleManager = C4::BatchOverlay::RuleManager->new();
        my $records = t::db_dependent::Biblio::Diff::localRecords::create($testContext);
        my $dirtyRecord = $records->{'9510108305'};

        #Find the fields we expect to be sanitated
        my ( $systemControlField, $systemControlSf ) = C4::Biblio::GetMarcFromKohaField( "biblio.biblionumber", '' );
        my ( $holdingsField, $holdingsSf ) = C4::Biblio::GetMarcFromKohaField( "items.barcode", '' );

        my @fields = $dirtyRecord->field($systemControlField);
        is(scalar(@fields), 1,
           "Koha-specific control field found");
#        #Looks like the holdings field is not brought and is removed somewhere in the depths of Koha.
#        @fields = $dirtyRecord->field($holdingsField);
#        is(scalar(@fields), 1,
#           "Koha-specific holdings field found");

        C4::BatchOverlay->_sanitateRemoteRecord( $dirtyRecord, $ruleManager->getRuleFromRuleName('default') );

        @fields = $dirtyRecord->field($systemControlField);
        is(scalar(@fields), 0,
           "Koha-specific control field removed");
        @fields = $dirtyRecord->field($holdingsField);
        is(scalar(@fields), 0,
           "Koha-specific holdings field removed");
    };
    if ($@) {
        ok(0, $@);
    }
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);
}

subtest "BatchOverlay::ReportContainer->persist", \&batchOverlayReportPersist;
sub batchOverlayReportPersist {
    my $testContext = {};
    eval {
        my $ruleManager = C4::BatchOverlay::RuleManager->new();
        my $records = t::db_dependent::Biblio::Diff::localRecords::create($testContext);
        my @recKeys = sort(keys(%$records));

        my $errorBuilder = C4::BatchOverlay::ErrorBuilder->new();
        my $errorUnknownMatcher  = $errorBuilder->addError(  Koha::Exception::BatchOverlay::UnknownMatcher->new(
                                                                    error => "errordescription",
                                                                    records => [$records->{ $recKeys[0] }],
                                                                    overlayRule => $ruleManager->getRuleFromRuleName('default'))  );
        my $errorDuplicateSearchTerm = $errorBuilder->addError(Koha::Exception::BatchOverlay::DuplicateSearchTerm->new(error => "duplicatesearchterm"));
        my $reportContainer = C4::BatchOverlay::ReportContainer->new();
        $reportContainer->addReport(
            $errorDuplicateSearchTerm,
        );
        $reportContainer->addReport(
            {   localRecord  => $records->{ $recKeys[0] },
                newRecord    => $records->{ $recKeys[1] },
                mergedRecord => $records->{ $recKeys[2] },
                operation => 'record merging',
                timestamp => DateTime->now( time_zone => C4::Context->tz() ),
                overlayRule => $ruleManager->getRuleFromRuleName('default'),
            }
        );
        $reportContainer->addReport(
            $errorUnknownMatcher,
        );
        $reportContainer->addReport(
            {   localRecord =>    $records->{ $recKeys[1] },
                newRecord =>    $records->{ $recKeys[2] },
                mergedRecord => $records->{ $recKeys[0] },
                operation => 'record merging',
                timestamp => DateTime->now( time_zone => C4::Context->tz() ),
                overlayRule => $ruleManager->getRuleFromRuleName('default'),
            }
        );
        $reportContainer->persist();

        my $reportContainers = C4::BatchOverlay::ReportManager->getReportContainers();
        ok(ref($reportContainers) eq 'ARRAY' && scalar(@$reportContainers) == 1,
           "One batch overlay report container created");
        is($reportContainers->[0]->getReportsCount(),
           2,
           "batch_overlay_reports-row has 2 reports");
        is($reportContainers->[0]->getErrorsCount(),
           2,
           "batch_overlay_reports-row has 2 errors");

        my $partlyHiddenPersistedReports = C4::BatchOverlay::ReportManager->getReports($reportContainers->[0]->{id});
        ok(ref($partlyHiddenPersistedReports) eq 'ARRAY' && scalar(@$partlyHiddenPersistedReports) == 3,
           "Got 3 diffs from DB when hiding some exceptions");
        my $persistedReports = C4::BatchOverlay::ReportManager->getReports($reportContainers->[0]->{id}, 'showAllExceptions');
        my $headers;
        ok(ref($persistedReports) eq 'ARRAY' && scalar(@$persistedReports) == 4,
           "Got 4 diffs from DB when showing all exceptions");

        is_deeply($errorDuplicateSearchTerm->getError(),
                  $persistedReports->[0]->getDiff(),
                  'First report error diff persisted deeply');
        $headers = $persistedReports->[0]->getHeaders();
        ok(ref($headers) eq 'ARRAY' && scalar(@$headers) == 0,
           "First report error has 0 header");

        is(ref($persistedReports->[1]),
           'C4::BatchOverlay::Report::Report',
           "Second diff is a report");
        $headers = $persistedReports->[1]->getHeaders();
        ok(ref($headers) eq 'ARRAY' && scalar(@$headers) == 3,
           "Second diff has 3 headers");

        is(ref($persistedReports->[2]),
           'C4::BatchOverlay::Report::Error',
           "Thrid diff is an error");
        is($persistedReports->[2]->getError()->{class},
           'Koha::Exception::BatchOverlay::UnknownMatcher',
           "Exception class persisted");
        is($persistedReports->[2]->getBiblionumber(),
           $records->{ $recKeys[0] }->{biblionumber},
           "Error persisted the same record");
        is($persistedReports->[2]->getRuleName(),
           'default',
           "Error persisted the same ruleName");
        is_deeply($errorUnknownMatcher->getError(),
                  $persistedReports->[2]->getDiff(),
                  'Error diff persisted deeply');
        $headers = $persistedReports->[2]->getHeaders();
        ok(ref($headers) eq 'ARRAY' && scalar(@$headers) == 1,
           "Third diff has 1 header");

        is(ref($persistedReports->[3]),
           'C4::BatchOverlay::Report::Report',
           "Fourth diff is a report");
        is($persistedReports->[3]->getBiblionumber(),
           $records->{ $recKeys[1] }->{biblionumber},
           "Fourth diff persisted the same record");
        is($persistedReports->[3]->getRuleName(),
           'default',
           "Fourth diff persisted the same ruleName");
        $headers = $persistedReports->[3]->getHeaders();
        ok(ref($headers) eq 'ARRAY' && scalar(@$headers) == 3,
           "Fourth diff has 3 headers");
    };
    if ($@) {
        ok(0, $@);
    }
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);
    C4::BatchOverlay::ReportManager->removeReports({do => 1});
    my $reportContainers = C4::BatchOverlay::ReportManager->listReports();
    is(scalar(@$reportContainers), 0, "All reports deleted");
}

subtest "BatchOverlay::_populateComponentPartFieldsFromParent", \&_populateComponentPartFieldsFromParent;
sub _populateComponentPartFieldsFromParent {
    my $subtestContext = {};
    eval {
    my ($host, $child);

    $host  = t::CataloguingCenter::localMARCRecords::create_host_record($subtestContext)->{'host-record-isbn'};
    $child = t::lib::TestObjects::BiblioFactory->createTestGroup({'biblioitems.isbn' => '5432154321', 'biblio.title' => 'child preservative'}, undef, $subtestContext);
    C4::BatchOverlay::_populateComponentPartFieldsFromParent($child, $host);

    is($child->subfield('942', 'c'), 'BK', 'Koha default item type received from parent');
    is($child->subfield('999', 'b'), 'BKS', 'Koha biblio.frameworkcode received from parent');

    };
    if ($@) {
        ok(0, $@);
    }
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($subtestContext);
}

t::lib::TestObjects::ObjectFactory->tearDownTestContext($globalTestContext);
done_testing();