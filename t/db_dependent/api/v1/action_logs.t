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
use Test::More tests => 2;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Log qw( logaction );
use Koha::ActionLogs;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'list() tests' => sub {

    plan tests => 24;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**13 }    # tools flag = 13
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    # Delete all logs after patron creation (building patrons can generate log entries)
    Koha::ActionLogs->search->delete;

    ## Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/action_logs")->status_is(403);

    # Delete again after auth attempts (login can generate AUTH logs)
    Koha::ActionLogs->search->delete;

    ## Authorized user tests
    # No logs, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/action_logs")->status_is(200)->json_is( [] );

    # Delete any logs created by the successful auth above
    Koha::ActionLogs->search->delete;

    # Create some log entries using a test-specific module to avoid collisions
    t::lib::Mocks::mock_userenv( { borrowernumber => $librarian->borrowernumber } );
    logaction( 'MEMBERS',     'MODIFY', $patron->borrowernumber, 'test info',    'INTRANET' );
    logaction( 'CIRCULATION', 'ISSUE',  $patron->borrowernumber, 'circ info',    'INTRANET' );
    logaction( 'CATALOGUING', 'ADD',    42,                      'biblio added', 'COMMANDLINE' );

    # Should return all three logs
    $t->get_ok("//$userid:$password@/api/v1/action_logs")->status_is(200);
    my $logs = $t->tx->res->json;
    is( scalar @$logs, 3, 'Three log entries returned' );

    # Filter by module
    $t->get_ok("//$userid:$password@/api/v1/action_logs?module=MEMBERS")->status_is(200);
    $logs = $t->tx->res->json;
    is( scalar @$logs,        1,           'One MEMBERS log entry returned' );
    is( $logs->[0]->{module}, 'MEMBERS',   'Correct module returned' );
    is( $logs->[0]->{info},   'test info', 'Correct info returned' );

    # Filter by action
    $t->get_ok("//$userid:$password@/api/v1/action_logs?action=ADD")->status_is(200);
    $logs = $t->tx->res->json;
    is( scalar @$logs,        1,     'One ADD action log entry returned' );
    is( $logs->[0]->{action}, 'ADD', 'Correct action returned' );

    # Filter by interface
    $t->get_ok("//$userid:$password@/api/v1/action_logs?interface=COMMANDLINE")->status_is(200);
    $logs = $t->tx->res->json;
    is( scalar @$logs,           1,             'One COMMANDLINE log entry returned' );
    is( $logs->[0]->{interface}, 'COMMANDLINE', 'Correct interface returned' );

    # Warn on unsupported query parameter
    $t->get_ok("//$userid:$password@/api/v1/action_logs?bork=borkbork")
        ->status_is(400)
        ->json_is( [ { path => '/query/bork', message => 'Malformed query string' } ] );

    $schema->storage->txn_rollback;
};
