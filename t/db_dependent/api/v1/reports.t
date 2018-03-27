#!/usr/bin/env perl

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

use Test::More tests => 2;
use Test::Mojo;

use t::lib::Mocks;
use t::lib::TestBuilder;
use t::CataloguingCenter::ContextSysprefs;
use t::db_dependent::Biblio::Diff::localRecords;
use t::lib::TestObjects::ObjectFactory;

use C4::Auth;
use C4::Context;
use C4::BatchOverlay::ErrorBuilder;
use C4::BatchOverlay::ReportContainer;
use C4::BatchOverlay::RuleManager;

use Koha::Database;

use Koha::Exception::BatchOverlay::UnknownMatcher;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $remote_address = '127.0.0.1';
my $t              = Test::Mojo->new('Koha::REST::V1');

subtest 'list_report_containers() tests' => sub {
    plan tests => 7;

    $schema->storage->txn_begin;

    my $testContext = {};
    my ($patron, $session) = create_user_and_session();

    my $dbh = C4::Context->dbh;
    $dbh->do("update marc_subfield_structure set kohafield='biblio.frameworkcode'"
             ."where tagfield='999' and tagsubfield='b'");
    C4::Context->_new_userenv('DUMMY SESSION');
    C4::Context->set_userenv(
        $patron->borrowernumber,
        $patron->userid,
        $patron->cardnumber,
        $patron->firstname,
        $patron->surname,
        $patron->branchcode,
        'Library 1',
        {},
        $patron->email,
        '',
        ''
    );

    my $tx = $t->ua->build_tx(GET => "/api/v1/reports/batchOverlays");
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(404)
      ->json_is('/0/borrowernumber' => undef, "No report containers");

    _setUpTestContext($testContext);

    $tx = $t->ua->build_tx(GET => "/api/v1/reports/batchOverlays");
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/0/borrowernumber' => $patron->borrowernumber, "Got borrowernumber")
      ->json_is('/1/borrowernumber' => undef, "No second report container");

    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);

    $schema->storage->txn_rollback;
};

subtest 'list_reports() tests' => sub {
    plan tests => 11;

    $schema->storage->txn_begin;

    my $testContext = {};

    my ($patron, $session) = create_user_and_session();

    my $dbh = C4::Context->dbh;
    $dbh->do("update marc_subfield_structure set kohafield='biblio.frameworkcode'"
             ."where tagfield='999' and tagsubfield='b'");
    C4::Context->_new_userenv('DUMMY SESSION');
    C4::Context->set_userenv(
        $patron->borrowernumber,
        $patron->userid,
        $patron->cardnumber,
        $patron->firstname,
        $patron->surname,
        $patron->branchcode,
        'Library 1',
        {},
        $patron->email,
        '',
        ''
    );
    my $reportContainer = _setUpTestContext($testContext);

    my $id = $reportContainer->getId();
    my $path = "/api/v1/reports/batchOverlays/$id/reports";
    my $tx = $t->ua->build_tx(GET => $path => {Accept => 'text/json'});
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/0/operation' => 'record merging', "Got report 1")
      ->json_is('/1/operation' => 'record merging', "Got report 2")
      ->json_is('/2/operation' => undef,            "No report 3");

    #Execute request with all exception classes
    $tx = $t->ua->build_tx(GET => $path.'?showAllExceptions=1' => {Accept => 'text/json'});
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/0/operation' => 'record merging', "Got report 1")
      ->json_is('/1/operation' => 'error',          "Got report 2 - excluded exception")
      ->json_is('/2/operation' => 'record merging', "Got report 3")
      ->json_is('/3/operation' => undef,            "No report 4");

    C4::BatchOverlay::ReportManager->removeReports({do => 1});

    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);

    $schema->storage->txn_rollback;
};

sub create_user_and_session {
    my ($flags) = @_;

    my $categorycode = $builder->build({ source => 'Category' })->{categorycode};
    my $branchcode = $builder->build({ source => 'Branch' })->{ branchcode };

    my $borrower = $builder->build({
        source => 'Borrower',
        value => {
            branchcode   => $branchcode,
            categorycode => $categorycode,
            lost         => 0,
        }
    });

    my $session = t::lib::Mocks::mock_session({borrower => $borrower});
    my $patron = Koha::Patrons->find($borrower->{borrowernumber});
    if ( $flags ) {
        Koha::Auth::PermissionManager->grantPermissions($patron, $flags);
    }

    return ($patron, $session);
}

sub _setUpTestContext {
    my ($testContext) = @_;

    t::CataloguingCenter::ContextSysprefs::createBatchOverlayRules($testContext);
    my $ruleManager = C4::BatchOverlay::RuleManager->new();
    my $records = t::db_dependent::Biblio::Diff::localRecords::create($testContext);
    my @recKeys = sort(keys(%$records));

    my $errorBuilder = C4::BatchOverlay::ErrorBuilder->new();
    my $errorReport = $errorBuilder->addError(
        Koha::Exception::BatchOverlay::UnknownMatcher->new(
            error => "errordescription"
        ),
        $records->{ $recKeys[0] },
        $ruleManager->getRuleFromRuleName('default')
    );
    my $reportContainer = C4::BatchOverlay::ReportContainer->new();
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
        $errorReport,
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
    return $reportContainer;
}
