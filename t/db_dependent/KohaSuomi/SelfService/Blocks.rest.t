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

BEGIN {
    #$ENV{LOG4PERL_VERBOSITY_CHANGE} = 6;
    #$ENV{MOJO_OPENAPI_DEBUG} = 1;
    $ENV{MOJO_LOG_LEVEL} = 'debug';
    $ENV{VERBOSE} = 1;
}

use Modern::Perl;
use utf8;

use Test::Most tests => 5;
use Test::Mojo;
use Data::Printer;

use t::lib::TestBuilder;
use t::lib::Mocks;
use Mojo::Cookie::Request;

use Koha::Database;
use C4::SelfService::Block;

my $schema = Koha::Database->schema;
#$schema->storage->txn_begin;
# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling, this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $builder = t::lib::TestBuilder->new;

my $apiUser = $builder->build({
    source => 'Borrower',
    value => {
        gonenoaddress   => 0,
        lost            => 0,
        debarred        => undef,
        debarredcomment => undef,
        branchcode => 'FPL',
    }
});

my @blockedUsers = (
    $builder->build({
        source => 'Borrower',
        value => {
            branchcode => 'CPL',
        }
    }),
    $builder->build({
        source => 'Borrower',
        value => {
            branchcode => 'IPT',
        }
    }),
);
my @blocks; #Global context to store created blocks and refer to them on later tests

$ENV{REMOTE_ADDR} = '127.0.0.1';
my $t = Test::Mojo->new('Koha::REST::V1');
authenticateToRESTAPI($apiUser, $t->ua, $ENV{REMOTE_ADDR});

subtest "List/GET blocks when there are no blocks to list" => sub {
    plan tests => 12;

    $t->get_ok('/api/v1/borrowers/'.$blockedUsers[0]->{borrowernumber}.'/ssblocks');
    p($t->tx->res->body) if ($ENV{VERBOSE});
    $t->status_is('403');
    $t->json_like('/error', qr/Missing required permission/, 'List: No permission');

    Koha::Auth::PermissionManager->grantPermission(
        $apiUser->{borrowernumber}, 'borrowers', 'ss_blocks_list'
    );

    $t->get_ok('/api/v1/borrowers/'.$blockedUsers[0]->{borrowernumber}.'/ssblocks');
    p($t->tx->res->body) if ($ENV{VERBOSE});
    $t->status_is('404');
    $t->json_like('/error', qr/No self-service blocks/,
        "No self-service blocks");


    my $borrower_ss_block_id = 0;
    $t->get_ok('/api/v1/borrowers/'.$blockedUsers[0]->{borrowernumber}.'/ssblocks/'.$borrower_ss_block_id);
    p($t->tx->res->body) if ($ENV{VERBOSE});
    $t->status_is('403');
    $t->json_like('/error', qr/Missing required permission/, 'GET: No permission');

    Koha::Auth::PermissionManager->grantPermission(
        scalar Koha::Patrons->find($apiUser->{borrowernumber}),
            'borrowers', 'ss_blocks_get'
    );

    $t->get_ok('/api/v1/borrowers/'.$blockedUsers[0]->{borrowernumber}.'/ssblocks/'.$borrower_ss_block_id);
    p($t->tx->res->body) if ($ENV{VERBOSE});
    $t->status_is('404');
    $t->json_like('/error', qr/No such self-service block/,
        "No such self-service block");
};

subtest '/borrowers/{borrowernumber}/ssblocks POST' => sub {
    plan tests => 13;
    @blocks = (
        { borrowernumber => $blockedUsers[0]->{borrowernumber}, branchcode => 'CPL', notes => 'asd', expirationdate => DateTime->now(time_zone => C4::Context->tz())->add(days => 1)->datetime(' ') },
        { borrowernumber => $blockedUsers[0]->{borrowernumber}, branchcode => 'FPL', notes => undef, },
        { borrowernumber => $blockedUsers[1]->{borrowernumber}, branchcode => 'IPT', notes => '', },
    );

    $t->post_ok('/api/v1/borrowers/'.$blockedUsers[0]->{borrowernumber}.'/ssblocks' => {Accept => '*/*'} => json => $blocks[0]);
    p($t->tx->res->body) if ($ENV{VERBOSE});
    $t->status_is('403');
    $t->json_like('/error', qr/Missing required permission/, 'No permission');

    Koha::Auth::PermissionManager->grantPermission(
        $apiUser->{borrowernumber}, 'borrowers', 'ss_blocks_create'
    );

    for my $i (0..$#blocks) {
        $t->post_ok('/api/v1/borrowers/'.$blocks[$i]->{borrowernumber}.'/ssblocks' => {Accept => '*/*'} => json => $blocks[$i]);
        p($t->tx->res->body) if ($ENV{VERBOSE});
        $t->status_is('200');
        cmp_deeply($t->tx->res->json, noclass(C4::SelfService::Block::get_deeply_testable($blocks[$i])),
            "Block ".($i+1)." created as expected");
        $blocks[$i]->{borrower_ss_block_id} = $t->tx->res->json->{borrower_ss_block_id};
    }

    subtest("Scenario: Sanitate XSS", sub {
        plan tests => 3;

        push(@blocks, { borrowernumber => $blockedUsers[1]->{borrowernumber}, branchcode => 'CPL', notes => '<<script></script>script>...</script>'});
        $t->post_ok('/api/v1/borrowers/'.$blocks[3]->{borrowernumber}.'/ssblocks' => {Accept => '*/*'} => json => $blocks[3]);
        p($t->tx->res->body) if ($ENV{VERBOSE});
        $t->status_is('200');
        $t->json_is('/notes', '😄😄script😆😄/script😆script😆...😄/script😆',
            "notes-field sanitated against xss");
        $blocks[3]->{borrower_ss_block_id} = $t->tx->res->json->{borrower_ss_block_id};
    });
};

subtest "List/GET blocks when there is something to list/GET" => sub {
    plan tests => 10;

    $t->get_ok('/api/v1/borrowers/'.$blockedUsers[0]->{borrowernumber}.'/ssblocks');
    p($t->tx->res->body) if ($ENV{VERBOSE});
    $t->status_is('200');
    cmp_deeply(
        $t->tx->res->json,
        [
            noclass(C4::SelfService::Block::get_deeply_testable($blocks[0])),
            noclass(C4::SelfService::Block::get_deeply_testable($blocks[1]))
        ],
        "Blocked Borrower 1 has two blocks");

    $t->get_ok('/api/v1/borrowers/'.$blockedUsers[1]->{borrowernumber}.'/ssblocks');
    p($t->tx->res->body) if ($ENV{VERBOSE});
    $t->status_is('200');
    cmp_deeply(
        $t->tx->res->json,
        [
            noclass(C4::SelfService::Block::get_deeply_testable($blocks[2])),
            bool(1),
        ],
        "Blocked Borrower 2 has two blocks");

    $t->get_ok('/api/v1/borrowers/'.$blockedUsers[1]->{borrowernumber}.'/ssblocks/'.$blocks[2]->{borrower_ss_block_id});
    p($t->tx->res->body) if ($ENV{VERBOSE});
    $t->status_is('200');
    cmp_deeply($t->tx->res->json, noclass(C4::SelfService::Block::get_deeply_testable($blocks[2])),
        "Get Block");


    subtest("Scenario: Expired blocks are not returned by default", sub {
        plan tests => 4;

        ok(my $block = C4::SelfService::BlockManager::storeBlock( C4::SelfService::BlockManager::createBlock({
            borrower       => $blockedUsers[0],
            branchcode     => 'IPT',
            expirationdate => '2010-01-01',
        })),
            "Blocked Borrower 1 is given an expired block");

        $t->get_ok('/api/v1/borrowers/'.$blockedUsers[0]->{borrowernumber}.'/ssblocks');
        p($t->tx->res->body) if ($ENV{VERBOSE});
        $t->status_is('200');
        cmp_deeply(
            $t->tx->res->json,
            [
                noclass(C4::SelfService::Block::get_deeply_testable($blocks[0])),
                noclass(C4::SelfService::Block::get_deeply_testable($blocks[1]))
            ],
            "Blocked Borrower 1 still has two blocks");
    });
};

subtest '/borrowers/{borrowernumber}/ssblocks DELETE' => sub {
    plan tests => 15;

    $t->delete_ok('/api/v1/borrowers/'.$blockedUsers[0]->{borrowernumber}.'/ssblocks');
    p($t->tx->res->body) if ($ENV{VERBOSE});
    $t->status_is('403');
    $t->json_like('/error', qr/Missing required permission/, 'No permission');

    Koha::Auth::PermissionManager->grantPermission(
        scalar Koha::Patrons->find($apiUser->{borrowernumber}),
        'borrowers', 'ss_blocks_delete'
    );

    $t->delete_ok('/api/v1/borrowers/'.$blockedUsers[0]->{borrowernumber}.'/ssblocks');
    p($t->tx->res->body) if ($ENV{VERBOSE});
    $t->status_is('200');
    cmp_deeply($t->tx->res->json, {deleted_count => 3},
        "Deleted all Blocks and deleted_count is as expected");

    $t->delete_ok('/api/v1/borrowers/'.$blockedUsers[0]->{borrowernumber}.'/ssblocks');
    p($t->tx->res->body) if ($ENV{VERBOSE});
    $t->status_is('200');
    cmp_deeply($t->tx->res->json, {deleted_count => 0},
        "Deleted all Blocks and deleted_count is zero");


    $t->delete_ok('/api/v1/borrowers/'.$blockedUsers[1]->{borrowernumber}.'/ssblocks/'.$blocks[2]->{borrower_ss_block_id});
    p($t->tx->res->body) if ($ENV{VERBOSE});
    $t->status_is('200');
    cmp_deeply($t->tx->res->json, {deleted_count => 1},
        "Deleted a single Block and deleted_count is 1");

    $t->delete_ok('/api/v1/borrowers/'.$blockedUsers[1]->{borrowernumber}.'/ssblocks/'.$blocks[2]->{borrower_ss_block_id});
    p($t->tx->res->body) if ($ENV{VERBOSE});
    $t->status_is('200');
    cmp_deeply($t->tx->res->json, {deleted_count => 0},
        "Trying to delete a single Block which doesn't exist and deleted_count is 0");
};

subtest "/borrowers/{borrowernumber}/ssblocks/hasblock/{branchcode}" => sub {
    plan tests => 7;

    ok(my $block = C4::SelfService::BlockManager::storeBlock( C4::SelfService::BlockManager::createBlock({
        borrowernumber => $blockedUsers[0]->{borrowernumber},
        branchcode     => 'CPL',
    })),
        "Given a simple block has been given");

    $t->get_ok('/api/v1/borrowers/'.$blockedUsers[0]->{borrowernumber}.'/ssblocks/hasblock/'.'CPL');
    p($t->tx->res->body) if ($ENV{VERBOSE});
    $t->status_is('200');
    cmp_deeply(
        $t->tx->res->json,
        noclass(C4::SelfService::Block::get_deeply_testable({
            borrowernumber => $blockedUsers[0]->{borrowernumber},
            branchcode => 'CPL',})),
        "Borrower is blocked to branch CPL");

    $t->get_ok('/api/v1/borrowers/'.$blockedUsers[1]->{borrowernumber}.'/ssblocks/hasblock/'.'IPT');
    p($t->tx->res->body) if ($ENV{VERBOSE});
    $t->status_is('204');
    cmp_deeply(
        $t->tx->res->json, undef,
        "Borrower is blocked to branch IPT");
};

sub authenticateToRESTAPI {
    my ($apiUser, $userAgent, $domain) = @_;
    my $session = t::lib::Mocks::mock_session({borrower => $apiUser});
    my $jar = Mojo::UserAgent::CookieJar->new;
    $jar->add(
        Mojo::Cookie::Response->new(
            name   => 'CGISESSID',
            value  => $session->id,
            domain => $domain,
            path   => '/',
        )
    );
    $userAgent->cookie_jar($jar);
}

1;
