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

use C4::Auth;
use C4::Context;

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
    plan tests => 2;

    $schema->storage->txn_begin;

    my ($borrowernumber, $sessionid) = create_user_and_session();
    Koha::Auth::PermissionManager->new->grantPermission(
                            $borrowernumber, "labels", "sheets_get");

    # Test list.
    my $tx = $t->ua->build_tx(GET => "/api/v1/labels/sheets");
    $tx->req->cookies({name => 'CGISESSID', value => $sessionid});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)->status_is(200);

    $schema->storage->txn_rollback;
};

subtest 'list_sheet_versions() tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my ($borrowernumber, $sessionid) = create_user_and_session();
    Koha::Auth::PermissionManager->new->grantPermission(
                            $borrowernumber, "labels", "sheets_get");

    # Test list.
    my $tx = $t->ua->build_tx(GET => "/api/v1/labels/sheets/version");
    $tx->req->cookies({name => 'CGISESSID', value => $sessionid});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)->status_is(200);

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

    my $borrowersession = C4::Auth::get_session('');
    $borrowersession->param('number', $borrower->{ borrowernumber });
    $borrowersession->param('id', $borrower->{ userid });
    $borrowersession->param('ip', '127.0.0.1');
    $borrowersession->param('lasttime', time());
    $borrowersession->flush;

    return ($borrower->{borrowernumber}, $borrowersession->id);
}
