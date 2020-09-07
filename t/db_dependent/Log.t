#!/usr/bin/perl
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
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use Test::More tests => 3;

use C4::Context;
use C4::Log;
use C4::Auth qw/checkpw/;
use Koha::Database;
use Koha::DateUtils;
use Koha::ActionLogs;

use t::lib::Mocks qw/mock_preference/; # to mock CronjobLog
use t::lib::TestBuilder;

# Make sure we can rollback.
our $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;
our $dbh = C4::Context->dbh;

subtest 'Existing tests' => sub {
    plan tests => 3;

    my $success;
    eval {
        # FIXME: are we sure there is an member number 1?
        logaction("MEMBERS","MODIFY",1,"test operation");
        $success = 1;
    } or do {
        diag($@);
        $success = 0;
    };
    ok($success, "logaction seemed to work");

    # We want numbers to be the same between runs.
    $dbh->do("DELETE FROM action_logs;");

    t::lib::Mocks::mock_preference('CronjobLog',0);
    cronlogaction();
    my $cronJobCount = $dbh->selectrow_array("SELECT COUNT(*) FROM action_logs WHERE module='CRONJOBS';",{});
    is($cronJobCount,0,"Cronjob not logged as expected.");

    t::lib::Mocks::mock_preference('CronjobLog',1);
    cronlogaction();
    $cronJobCount = $dbh->selectrow_array("SELECT COUNT(*) FROM action_logs WHERE module='CRONJOBS';",{});
    is($cronJobCount,1,"Cronjob logged as expected.");
};

subtest 'logaction(): interface is correctly logged' => sub {

    plan tests => 4;

    # No interface passed, using C4::Context->interface
    $dbh->do("DELETE FROM action_logs;");
    C4::Context->interface( 'commandline' );
    logaction( "MEMBERS", "MODIFY", 1, "test operation");
    my $log = Koha::ActionLogs->search->next;
    is( $log->interface, 'commandline', 'Interface correctly deduced (commandline)');

    # No interface passed, using C4::Context->interface
    $dbh->do("DELETE FROM action_logs;");
    C4::Context->interface( 'opac' );
    logaction( "MEMBERS", "MODIFY", 1, "test operation");
    $log = Koha::ActionLogs->search->next;
    is( $log->interface, 'opac', 'Interface correctly deduced (opac)');

    # Explicit interfaces
    $dbh->do("DELETE FROM action_logs;");
    C4::Context->interface( 'intranet' );
    logaction( "MEMBERS", "MODIFY", 1, 'test info', 'intranet');
    $log = Koha::ActionLogs->search->next;
    is( $log->interface, 'intranet', 'Passed interface is respected (intranet)');

    # Explicit interfaces
    $dbh->do("DELETE FROM action_logs;");
    C4::Context->interface( 'sip' );
    logaction( "MEMBERS", "MODIFY", 1, 'test info', 'sip');
    $log = Koha::ActionLogs->search->next;
    is( $log->interface, 'sip', 'Passed interface is respected (sip)');
};

subtest 'GDPR logging' => sub {
    plan tests => 6;

    my $builder = t::lib::TestBuilder->new;
    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    t::lib::Mocks::mock_userenv({ patron => $patron });
    logaction( 'AUTH', 'FAILURE', $patron->id, '', 'opac' );
    my $logs = Koha::ActionLogs->search(
        {
            user   => $patron->id,
            module => 'AUTH',
            action => 'FAILURE',
            object => $patron->id,
        }
    );
    is( $logs->count, 1, 'We should find one auth failure' );

    t::lib::Mocks::mock_preference('AuthFailureLog', 1);
    my $strong_password = 'N0tStr0ngAnyM0reN0w:)';
    $patron->set_password({ password => $strong_password });
    my @ret = checkpw( $dbh, $patron->userid, 'WrongPassword', undef, undef, 1);
    is( $ret[0], 0, 'Authentication failed' );
    # Look for auth failure but NOT on patron id, pass userid in info parameter
    $logs = Koha::ActionLogs->search(
        {
            module => 'AUTH',
            action => 'FAILURE',
            info   => { -like => '%'.$patron->userid.'%' },
        }
    );
    is( $logs->count, 1, 'We should find one auth failure with this userid' );
    t::lib::Mocks::mock_preference('AuthFailureLog', 0);
    @ret = checkpw( $dbh, $patron->userid, 'WrongPassword', undef, undef, 1);
    $logs = Koha::ActionLogs->search(
        {
            module => 'AUTH',
            action => 'FAILURE',
            info   => { -like => '%'.$patron->userid.'%' },
        }
    );
    is( $logs->count, 1, 'Still only one failure with this userid' );
    t::lib::Mocks::mock_preference('AuthSuccessLog', 1);
    @ret = checkpw( $dbh, $patron->userid, $strong_password, undef, undef, 1);
    is( $ret[0], 1, 'Authentication succeeded' );
    # Now we can look for patron id
    $logs = Koha::ActionLogs->search(
        {
            user   => $patron->id,
            module => 'AUTH',
            action => 'SUCCESS',
            object => $patron->id,
        }
    );

    is( $logs->count, 1, 'We expect only one auth success line for this patron' );
};

$schema->storage->txn_rollback;
