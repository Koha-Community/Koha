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


use Test::More tests => 5;
use Test::Mojo;
use t::lib::Mocks;
use t::lib::TestBuilder;
use t::lib::TestObjects::Labels::SheetFactory;

use C4::Auth;
use C4::Context;
use C4::Labels::SheetManager;

use Koha::Database;
use Koha::Auth::PermissionManager;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $remote_address = '127.0.0.1';
my $t              = Test::Mojo->new('Koha::REST::V1');

subtest 'list() tests' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    my $testContext = {};
    my $sheet = t::lib::TestObjects::Labels::SheetFactory->createTestGroup(
                    {name => 'Sheetilian',
                    },
                    undef, $testContext);
    $sheet = C4::Labels::SheetManager::putNewSheetToDB($sheet);

    my ($borrowernumber, $sessionid) = create_user_and_session();
    my ($borrowernumber2, $sessionid2) = create_user_and_session();
    Koha::Auth::PermissionManager->new->grantPermission(
                            $borrowernumber, "labels", "sheets_get");

    my $tx = $t->ua->build_tx(GET => "/api/v1/labels/sheets");
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)->status_is(401);

    $tx = $t->ua->build_tx(GET => "/api/v1/labels/sheets");
    $tx->req->cookies({name => 'CGISESSID', value => $sessionid2});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)->status_is(403);

    # Test list.
    $tx = $t->ua->build_tx(GET => "/api/v1/labels/sheets");
    $tx->req->cookies({name => 'CGISESSID', value => $sessionid});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)->status_is(200);

    $schema->storage->txn_rollback;
};

subtest 'post() tests' => sub {
    plan tests => 8;

    $schema->storage->txn_begin;

    my $testContext = {};
    my $sheet = t::lib::TestObjects::Labels::SheetFactory->createTestGroup(
                    {name => 'Sheetilian',
                    },
                    undef, $testContext);
    my ($borrowernumber, $sessionid) = create_user_and_session();
    my ($borrowernumber2, $sessionid2) = create_user_and_session();
    Koha::Auth::PermissionManager->new->grantPermission(
                            $borrowernumber, "labels", "sheets_new");

    my $form = {
        sheet => $sheet->toJSON()
    };

    my $tx = $t->ua->build_tx(POST => "/api/v1/labels/sheets"
                                   => form => $form);
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)->status_is(401);

    $tx = $t->ua->build_tx(POST => "/api/v1/labels/sheets"
                                => form => $form);
    $tx->req->cookies({name => 'CGISESSID', value => $sessionid2});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)->status_is(403);

    my $nonsense = '{ "what": "is this?", "bad": "input" }';
    $tx = $t->ua->build_tx(POST => "/api/v1/labels/sheets"
                                => form => { sheet => $nonsense });
    $tx->req->cookies({name => 'CGISESSID', value => $sessionid});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)->status_is(400);

    $tx = $t->ua->build_tx(POST => "/api/v1/labels/sheets"
                                => form => $form);
    $tx->req->cookies({name => 'CGISESSID', value => $sessionid});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)->status_is(201);

    $schema->storage->txn_rollback;
};

subtest 'update() tests' => sub {
    plan tests => 12;

    $schema->storage->txn_begin;

    my $testContext = {};
    my $sheet = t::lib::TestObjects::Labels::SheetFactory->createTestGroup(
                    {name => 'Sheetilian',
                    },
                    undef, $testContext);
    $sheet = C4::Labels::SheetManager::putNewSheetToDB($sheet);
    my $simplex = t::lib::TestObjects::Labels::SheetFactory->createTestGroup(
                    {name => 'Simplex',
                    },
                    undef, $testContext);
    $simplex->{id} = $sheet->{id};

    my ($borrowernumber, $sessionid) = create_user_and_session();
    my ($borrowernumber2, $sessionid2) = create_user_and_session();
    Koha::Auth::PermissionManager->new->grantPermission(
                            $borrowernumber, "labels", "sheets_mod");

    my $form = {
        sheet => $simplex->toJSON()
    };

    my $tx = $t->ua->build_tx(PUT => "/api/v1/labels/sheets"
                                => form => $form);
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)->status_is(401);

    $tx = $t->ua->build_tx(PUT => "/api/v1/labels/sheets"
                                => form => $form);
    $tx->req->cookies({name => 'CGISESSID', value => $sessionid2});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)->status_is(403);

    my $nonsense = '{ "what": "is this?", "bad": "input" }';
    $tx = $t->ua->build_tx(PUT => "/api/v1/labels/sheets"
                                => form => { sheet => $nonsense });
    $tx->req->cookies({name => 'CGISESSID', value => $sessionid});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)->status_is(400);

    is(C4::Labels::SheetManager::getSheetByName('Sheetilian')->getName(),
       'Sheetilian', 'Found sheet Sheetilian');
    is(C4::Labels::SheetManager::getSheetByName('Simplex'),
       undef, 'Did not find Simplex');
    $tx = $t->ua->build_tx(PUT => "/api/v1/labels/sheets"
                                => form => $form);
    $tx->req->cookies({name => 'CGISESSID', value => $sessionid});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)->status_is(201);
    is(C4::Labels::SheetManager::getSheetByName('Sheetilian')->getName(),
       'Sheetilian', 'After updating Sheetilian to Simplex,'.
       'did not find Sheetilian');
    is(C4::Labels::SheetManager::getSheetByName('Simplex'),
       undef, 'After update, found sheet Simplex');

    $schema->storage->txn_rollback;
};

subtest 'list_sheet_versions() tests' => sub {
    plan tests => 10;

    $schema->storage->txn_begin;

    my $testContext = {};
    my $sheetilian = t::lib::TestObjects::Labels::SheetFactory->createTestGroup(
                    {name => 'Sheetilian',
                    },
                    undef, $testContext);
    $sheetilian = C4::Labels::SheetManager::putNewSheetToDB($sheetilian);
    my $simplex = t::lib::TestObjects::Labels::SheetFactory->createTestGroup(
                    {name => 'Simplex',
                    },
                    undef, $testContext);
    $simplex = C4::Labels::SheetManager::putNewSheetToDB($simplex);

    my ($borrowernumber, $sessionid) = create_user_and_session();
    my ($borrowernumber2, $sessionid2) = create_user_and_session();
    Koha::Auth::PermissionManager->new->grantPermission(
                            $borrowernumber, "labels", "sheets_get");

    my $tx = $t->ua->build_tx(GET => "/api/v1/labels/sheets/version");
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)->status_is(401);

    $tx = $t->ua->build_tx(GET => "/api/v1/labels/sheets/version");
    $tx->req->cookies({name => 'CGISESSID', value => $sessionid2});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)->status_is(403);

    # Test list.
    $tx = $t->ua->build_tx(GET => "/api/v1/labels/sheets/version");
    $tx->req->cookies({name => 'CGISESSID', value => $sessionid});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/0/name' => $sheetilian->getName(),       "Name ok")
      ->json_is('/0/version' => $sheetilian->getVersion(), "Version ok")
      ->json_is('/1/name' => $simplex->getName(),       "Name ok")
      ->json_is('/1/version' => $simplex->getVersion(), "Version ok");

    $schema->storage->txn_rollback;
};

subtest 'delete() sheet version tests' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    my $testContext = {};
    my $sheet = t::lib::TestObjects::Labels::SheetFactory->createTestGroup(
                    {name => 'Sheetilian',
                    },
                    undef, $testContext);
    $sheet = C4::Labels::SheetManager::putNewSheetToDB($sheet);

    my ($borrowernumber, $sessionid) = create_user_and_session();
    my ($borrowernumber2, $sessionid2) = create_user_and_session();
    Koha::Auth::PermissionManager->new->grantPermission(
                            $borrowernumber, "labels", "sheets_del");

    my $tx = $t->ua->build_tx(DELETE => "/api/v1/labels/sheets/".
            $sheet->getId() . "/" . $sheet->getVersion());
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)->status_is(401);

    $tx = $t->ua->build_tx(DELETE => "/api/v1/labels/sheets/".
            $sheet->getId() . "/" . $sheet->getVersion());
    $tx->req->cookies({name => 'CGISESSID', value => $sessionid2});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)->status_is(403);

    # Test list.
    $tx = $t->ua->build_tx(DELETE => "/api/v1/labels/sheets/".
            $sheet->getId() . "/" . $sheet->getVersion());
    $tx->req->cookies({name => 'CGISESSID', value => $sessionid});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)->status_is(204);

    $schema->storage->txn_rollback;
};

sub create_user_and_session {
    my ($flags) = @_;

    my $categorycode = $builder->build({ source => 'Category' })->{ categorycode };
    my $branchcode = $builder->build({ source => 'Branch' })->{ branchcode };

    my $borrower = $builder->build({
        source => 'Borrower',
        value => {
            branchcode   => $branchcode,
            categorycode => $categorycode,
            flags        => $flags,
            lost         => 0,
        }
    });

    my $borrowersession = t::lib::Mocks::mock_session({borrower => $borrower});

    return ($borrower->{borrowernumber}, $borrowersession->id);
}
