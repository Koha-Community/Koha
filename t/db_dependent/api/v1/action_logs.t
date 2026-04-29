#!/usr/bin/env perl

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 6;
use Test::Mojo;

use Mojo::JSON qw( encode_json );

use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Log qw( logaction );
use Koha::ActionLogs;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth',  1 );
t::lib::Mocks::mock_preference( 'AuthSuccessLog', 0 );
t::lib::Mocks::mock_preference( 'AuthFailureLog', 0 );
t::lib::Mocks::mock_preference( 'BorrowersLog',   0 );

my $t = Test::Mojo->new('Koha::REST::V1');

# Build credentials and an isolated set of seed log entries used by every
# subtest below.
sub build_fixtures {

    # Need both `tools` (view_system_logs) and `borrowers` so embedded patron
    # fields don't get redacted by Koha::Patron->is_accessible.
    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**13 + 2**4 }    # tools + borrowers
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    $patron->set_password( { password => $password, skip_validation => 1 } );

    Koha::ActionLogs->search->delete;
    t::lib::Mocks::mock_userenv( { borrowernumber => $librarian->borrowernumber } );

    return ( $librarian, $patron, $password );
}

subtest 'authorization' => sub {
    plan tests => 4;
    $schema->storage->txn_begin;

    my ( $librarian, $patron, $password ) = build_fixtures();
    my $userid        = $librarian->userid;
    my $unauth_userid = $patron->userid;

    $t->get_ok("//$unauth_userid:$password@/api/v1/action_logs")
        ->status_is( 403, 'forbidden without view_system_logs' );
    $t->get_ok("//$userid:$password@/api/v1/action_logs")->status_is( 200, 'allowed with tools/view_system_logs' );

    $schema->storage->txn_rollback;
};

subtest 'simple typed filters' => sub {
    plan tests => 13;
    $schema->storage->txn_begin;

    my ( $librarian, $patron, $password ) = build_fixtures();
    my $userid = $librarian->userid;

    logaction( 'MEMBERS',     'MODIFY', $patron->borrowernumber, 'test info',    'INTRANET' );
    logaction( 'CIRCULATION', 'ISSUE',  $patron->borrowernumber, 'circ info',    'INTRANET' );
    logaction( 'CATALOGUING', 'ADD',    42,                      'biblio added', 'COMMANDLINE' );

    $t->get_ok("//$userid:$password@/api/v1/action_logs?module=MEMBERS")->status_is(200);
    my $logs = $t->tx->res->json;
    is( scalar @$logs,        1,           'one MEMBERS row' );
    is( $logs->[0]->{module}, 'MEMBERS',   'correct module returned' );
    is( $logs->[0]->{info},   'test info', 'correct info returned' );

    $t->get_ok("//$userid:$password@/api/v1/action_logs?action=ADD")->status_is(200);
    is( $t->tx->res->json->[0]->{action}, 'ADD', 'action filter works' );

    $t->get_ok("//$userid:$password@/api/v1/action_logs?interface=COMMANDLINE")->status_is(200);
    is( $t->tx->res->json->[0]->{interface}, 'COMMANDLINE', 'interface filter works' );

    $t->get_ok("//$userid:$password@/api/v1/action_logs?bork=borkbork")
        ->status_is( 400, 'unsupported query param rejected' );

    $schema->storage->txn_rollback;
};

subtest 'q DSL: multi-value, like, range' => sub {
    plan tests => 13;
    $schema->storage->txn_begin;

    my ( $librarian, $patron, $password ) = build_fixtures();
    my $userid = $librarian->userid;

    logaction( 'MEMBERS',     'MODIFY', $patron->borrowernumber, 'flag toggled',  'INTRANET' );
    logaction( 'CIRCULATION', 'ISSUE',  $patron->borrowernumber, 'item issued',   'INTRANET' );
    logaction( 'CATALOGUING', 'ADD',    42,                      'biblio added',  'COMMANDLINE' );
    logaction( 'CATALOGUING', 'MODIFY', 42,                      'biblio edited', 'COMMANDLINE' );

    # Multi-value module via q
    my $q_multi = encode_json( { module => [ 'MEMBERS', 'CIRCULATION' ] } );
    $t->get_ok("//$userid:$password@/api/v1/action_logs?q=$q_multi")->status_is(200);
    is( scalar @{ $t->tx->res->json }, 2, 'multi-value module filter returns union' );

    # Substring (LIKE) on info
    my $q_like = encode_json( { info => { -like => '%biblio%' } } );
    $t->get_ok("//$userid:$password@/api/v1/action_logs?q=$q_like")->status_is(200);
    is( scalar @{ $t->tx->res->json }, 2, 'like operator on info matches both biblio rows' );

    # Object filter via typed param
    $t->get_ok("//$userid:$password@/api/v1/action_logs?object=42")->status_is(200);
    is( scalar @{ $t->tx->res->json }, 2, 'object filter returns rows for object 42' );

    # Combined filter
    my $q_combo = encode_json(
        {
            module => 'CATALOGUING',
            action => 'MODIFY'
        }
    );
    $t->get_ok("//$userid:$password@/api/v1/action_logs?q=$q_combo")->status_is(200);
    my $combo = $t->tx->res->json;
    is( scalar @$combo,        1,        'combined filter narrows to one row' );
    is( $combo->[0]->{action}, 'MODIFY', 'combined filter returned MODIFY' );

    $schema->storage->txn_rollback;
};

subtest 'embeds' => sub {
    plan tests => 10;
    $schema->storage->txn_begin;

    my ( $librarian, $patron, $password ) = build_fixtures();
    my $userid = $librarian->userid;

    logaction( 'MEMBERS',     'MODIFY', $patron->borrowernumber, 'embed test', 'INTRANET' );
    logaction( 'CATALOGUING', 'ADD',    42,                      'biblio',     'COMMANDLINE' );

    # Without embed, no librarian/patron objects in payload
    $t->get_ok("//$userid:$password@/api/v1/action_logs?module=MEMBERS")->status_is(200);
    my $bare = $t->tx->res->json->[0];
    ok( !exists $bare->{librarian}, 'no librarian key without embed' );
    ok( !exists $bare->{patron},    'no patron key without embed' );

    # With embed=librarian, librarian object populated
    $t->get_ok( "/api/v1/action_logs?module=MEMBERS" =>
            { 'x-koha-embed' => 'librarian', Authorization => _basic( $userid, $password ) } )->status_is(200);
    my $embed_lib = $t->tx->res->json->[0];
    is(
        $embed_lib->{librarian}->{patron_id},
        $librarian->borrowernumber,
        'embedded librarian.patron_id matches the actor'
    );

    # With embed=patron, patron object populated for MEMBERS row
    $t->get_ok( "/api/v1/action_logs?module=MEMBERS" =>
            { 'x-koha-embed' => 'patron', Authorization => _basic( $userid, $password ) } )->status_is(200);
    my $embed_pat = $t->tx->res->json->[0];
    is(
        $embed_pat->{patron}->{patron_id},
        $patron->borrowernumber,
        'embedded patron.patron_id matches the row object'
    );

    $schema->storage->txn_rollback;
};

subtest 'pagination and sorting' => sub {
    plan tests => 6;
    $schema->storage->txn_begin;

    my ( $librarian, $patron, $password ) = build_fixtures();
    my $userid = $librarian->userid;

    logaction( 'MEMBERS', 'MODIFY', $patron->borrowernumber, "row $_", 'INTRANET' ) for 1 .. 5;

    $t->get_ok("//$userid:$password@/api/v1/action_logs?_per_page=2&_page=1&module=MEMBERS")->status_is(200);
    is( scalar @{ $t->tx->res->json },                 2, 'pagination limits results' );
    is( $t->tx->res->headers->header('x-total-count'), 5, 'X-Total-Count reflects unfiltered total' );

    $t->get_ok("//$userid:$password@/api/v1/action_logs?_order_by=-action_id&module=MEMBERS")->status_is(200);

    $schema->storage->txn_rollback;
};

sub _basic {
    my ( $u, $p ) = @_;
    require MIME::Base64;
    return 'Basic ' . MIME::Base64::encode_base64( "$u:$p", '' );
}
