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

use Test::More tests => 3;
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

subtest 'get_record() tests' => sub {
    plan tests => 2;

    my $path = '/api/v1/records/';

    subtest 'test authentication & authorization' => sub {
        plan tests => 4;

        $schema->storage->txn_begin;

        my ($patron, $session) = create_user_and_session();

        my $tx = $t->ua->build_tx(GET => $path.'-999999999999' => {
            Accept => 'text/json'
        });
        $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
        $t->request_ok($tx)
          ->status_is(401);

        $tx = $t->ua->build_tx(GET => $path.'-999999999999' => {
            Accept => 'text/json'
        });
        $tx->req->cookies({name => 'CGISESSID', value => $session->id});
        $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
        $t->request_ok($tx)
          ->status_is(403);

        $schema->storage->txn_rollback;
    };

    subtest 'test getting a record' => sub {
        plan tests => 7;

        $schema->storage->txn_begin;

        my $testContext = {};
        my ($patron, $session) = create_user_and_session({
                editcatalogue => "*"
        });

        my $tx = $t->ua->build_tx(GET => $path.'999999999999' => {
            Accept => 'text/json'
        });
        $tx->req->cookies({name => 'CGISESSID', value => $session->id});
        $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
        $t->request_ok($tx)
          ->status_is(404)
          ->json_is('/biblionumber' => undef);

        my $biblio = t::lib::TestObjects::BiblioFactory->createTestGroup(
                        {'biblio.title' => 'The significant chore of building test faculties',
                         'biblio.author'   => 'Programmer, Broken',
                         'biblio.copyrightdate' => '2015',
                         'biblioitems.isbn'     => '951967151337',
                         'biblioitems.itemtype' => 'BK',
                        }, undef, $testContext);
        my $biblionumber = $biblio->{biblionumber};
        $tx = $t->ua->build_tx(GET => $path.$biblionumber => {
            Accept => 'text/json'
        });
        $tx->req->cookies({name => 'CGISESSID', value => $session->id});
        $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
        $t->request_ok($tx)
          ->status_is(200)
          ->json_is('/biblionumber' => $biblionumber)
          ->json_like('/marcxml' => qr(Programmer, Broken));

        t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);

        $schema->storage->txn_rollback;
    };
};

subtest 'add_record() tests' => sub {
    plan tests => 4;

    my $path = '/api/v1/records';

    subtest 'test authentication & authorization' => sub {
        plan tests => 4;

        $schema->storage->txn_begin;

        my ($patron, $session) = create_user_and_session();

        my $testMarcxml = <<MARCXML;
<record>
  <leader>00510cam a22002054a 4500</leader>
  <controlfield tag="008">       1988    xxk|||||||||| ||||1|eng|c</controlfield>
  <datafield tag="245" ind1="1" ind2="4">
    <subfield code="a">Missing 001 and 003m which is bad!</subfield>
  </datafield>
</record>
MARCXML

        my $tx = $t->ua->build_tx(POST => $path => {Accept => '*/*'});
        $tx->req->body( Mojo::Parameters->new("marcxml=$testMarcxml")->to_string);
        $tx->req->headers->remove('Content-Type');
        $tx->req->headers->add('Content-Type' => 'application/x-www-form-urlencoded');
        $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
        $t->request_ok($tx)
          ->status_is(401);

        $tx = $t->ua->build_tx(POST => $path => {Accept => '*/*'});
        $tx->req->body( Mojo::Parameters->new("marcxml=$testMarcxml")->to_string);
        $tx->req->headers->remove('Content-Type');
        $tx->req->headers->add('Content-Type' => 'application/x-www-form-urlencoded');
        $tx->req->cookies({name => 'CGISESSID', value => $session->id});
        $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
        $t->request_ok($tx)
          ->status_is(403);

        $schema->storage->txn_rollback;
    };

    subtest 'test missing mandatory fields' => sub {
        plan tests => 3;

        $schema->storage->txn_begin;

        my $testContext = {};
        my ($patron, $session) = create_user_and_session({
            editcatalogue => "add_catalogue"
        });

        my $testMarcxml = <<MARCXML;
<record>
  <leader>00510cam a22002054a 4500</leader>
  <controlfield tag="008">       1988    xxk|||||||||| ||||1|eng|c</controlfield>
  <datafield tag="245" ind1="1" ind2="4">
    <subfield code="a">Missing 001 and 003m which is bad!</subfield>
  </datafield>
</record>
MARCXML

        my $tx = $t->ua->build_tx(POST => $path => {Accept => '*/*'});
        $tx->req->body( Mojo::Parameters->new("marcxml=$testMarcxml")->to_string);
        $tx->req->headers->remove('Content-Type');
        $tx->req->headers->add('Content-Type' => 'application/x-www-form-urlencoded');
        $tx->req->cookies({name => 'CGISESSID', value => $session->id});
        $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
        $t->request_ok($tx)
          ->status_is(400)
          ->json_like('/error' => qr/One of mandatory fields '.*?' missing/);

        t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);

        $schema->storage->txn_rollback;
    };

    subtest 'test duplicate record' => sub {
        plan tests => 3;

        my $testContext = {};

        my $testMarcxml = <<MARCXML;
<record>
  <leader>00510cam a22002054a 4500</leader>
  <controlfield tag="001">rest-test-record</controlfield>
  <controlfield tag="003">REST-TEST</controlfield>
  <controlfield tag="008">       1988    xxk|||||||||| ||||1|eng|c</controlfield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">rest-test-isbn-duplicated</subfield>
  </datafield>
  <datafield tag="245" ind1="1" ind2="4">
    <subfield code="a">REST recordzzz</subfield>
  </datafield>
</record>
MARCXML

        my $biblio = t::lib::TestObjects::BiblioFactory->createTestGroup(
            {record => $testMarcxml}, undef, $testContext
        );

        my $matcher = Test::MockModule->new('C4::Matcher');
        $matcher->mock( get_matches => sub {
            my ($self, $match_record) = @_;

            my @matches;
            if ($match_record->field('020')->subfield('a') eq 'rest-test-isbn-duplicated') {
                push @matches, { 'record_id' => $biblio->{'biblionumber'}, 'score' => 100 };
            };
            return @matches;
        } );

        $schema->storage->txn_begin;

        my ($patron, $session) = create_user_and_session({
            editcatalogue => "add_catalogue"
        });

        my $tx = $t->ua->build_tx(POST => $path => {Accept => '*/*'});
        $tx->req->body( Mojo::Parameters->new("marcxml=$testMarcxml")->to_string);
        $tx->req->headers->remove('Content-Type');
        $tx->req->headers->add('Content-Type' => 'application/x-www-form-urlencoded');
        $tx->req->cookies({name => 'CGISESSID', value => $session->id});
        $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
        $t->request_ok($tx)
          ->status_is(400)
          ->json_like('/error' => qr/duplicate/);

        $schema->storage->txn_rollback;

        t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);
    };

    subtest 'test adding a record' => sub {
        plan tests => 6;

        $schema->storage->txn_begin;

        my $testContext = {};
        my ($patron, $session) = create_user_and_session({
            editcatalogue => "add_catalogue"
        });

        my $testMarcxml = <<MARCXML;
<record>
  <leader>00510cam a22002054a 4500</leader>
  <controlfield tag="001">rest-test-record</controlfield>
  <controlfield tag="003">REST-TEST</controlfield>
  <controlfield tag="008">       1988    xxk|||||||||| ||||1|eng|c</controlfield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">rest-test-isbn</subfield>
  </datafield>
  <datafield tag="245" ind1="1" ind2="4">
    <subfield code="a">REST recordzzz</subfield>
  </datafield>
</record>
MARCXML

        my $tx = $t->ua->build_tx(POST => $path => {Accept => '*/*'});
        $tx->req->body( Mojo::Parameters->new("marcxml=$testMarcxml")->to_string);
        $tx->req->headers->remove('Content-Type');
        $tx->req->headers->add('Content-Type' => 'application/x-www-form-urlencoded');
        $tx->req->cookies({name => 'CGISESSID', value => $session->id});
        $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
        $t->request_ok($tx)
          ->status_is(200)
          ->json_like('/biblionumber' => qr/\d+/);

        my $json = $tx->res->json;
        my $biblionumber = $json->{biblionumber};
        my $record = MARC::Record->new_from_xml(
            $json->{marcxml}, 'utf8', C4::Context->preference("marcflavour")
        );
        is($record->subfield('020', 'a'), 'rest-test-isbn', 'Got the ISBN!');

        is($json->{links}->[0]->{ref}, 'self.nativeView',
           'Received HATEOAS link reference');
        ok($json->{links}->[0]->{href} =~
           m!/cgi-bin/koha/catalogue/detail\.pl\?biblionumber=$biblionumber!,
           'Received HATEOAS link to home'
        );

        #Finally tear down changes
        C4::Biblio::DelBiblio($biblionumber);

        t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);
        $schema->storage->txn_rollback;
    };
};

subtest 'delete_record() tests' => sub {
    plan tests => 2;

    my $path = '/api/v1/records/';

    subtest 'test authentication & authorization' => sub {
        plan tests => 4;

        $schema->storage->txn_begin;

        my ($patron, $session) = create_user_and_session();

        my $tx = $t->ua->build_tx(DELETE => $path.'-999999999999' => {
            Accept => 'text/json'
        });
        $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
        $t->request_ok($tx)
          ->status_is(401);

        $tx = $t->ua->build_tx(DELETE => $path.'-999999999999' => {
            Accept => 'text/json'
        });
        $tx->req->cookies({name => 'CGISESSID', value => $session->id});
        $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
        $t->request_ok($tx)
          ->status_is(403);

        $schema->storage->txn_rollback;
    };

    subtest 'test deleting a record' => sub {
        plan tests => 2;

        $schema->storage->txn_begin;

        my $testContext = {};
        my ($patron, $session) = create_user_and_session({
            editcatalogue => "delete_catalogue"
        });

        my $biblio = t::lib::TestObjects::BiblioFactory->createTestGroup(
            {'biblio.title' => 'The significant chore of building test faculties',
             'biblio.author'   => 'Programmer, Broken',
             'biblio.copyrightdate' => '2015',
             'biblioitems.isbn'     => '951967151337',
             'biblioitems.itemtype' => 'BK',
            }, undef, $testContext);
        my $biblionumber = $biblio->{biblionumber};

        my $tx = $t->ua->build_tx(DELETE => $path.$biblionumber => {
            Accept => 'text/json'
        });
        $tx->req->cookies({name => 'CGISESSID', value => $session->id});
        $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
        $t->request_ok($tx)
          ->status_is(200);

        $schema->storage->txn_rollback;
    };
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
        foreach my $flag (keys %$flags) {
            if ($flags->{$flag} eq '*') {
                Koha::Auth::PermissionManager->grantAllSubpermissions(
                    $patron, $flag
                );
                delete $flags->{$flag};
            }
        }
        Koha::Auth::PermissionManager->grantPermissions($patron, $flags) if $flags;
    }

    return ($patron, $session);
}
