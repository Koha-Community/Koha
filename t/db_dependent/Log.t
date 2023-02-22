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
use Data::Dumper qw( Dumper );
use Test::More tests => 5;

use C4::Context;
use C4::Log qw( logaction cronlogaction );
use C4::Auth qw( checkpw );
use Koha::Database;
use Koha::ActionLogs;

use t::lib::Mocks qw/mock_preference/; # to mock CronjobLog
use t::lib::TestBuilder;

# Make sure we can rollback.
our $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;

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
    Koha::ActionLogs->search->delete;

    t::lib::Mocks::mock_preference('CronjobLog',0);
    cronlogaction();
    is(Koha::ActionLogs->search({ module => 'CRONJOBS' })->count,0,"Cronjob not logged as expected.");

    t::lib::Mocks::mock_preference('CronjobLog',1);
    cronlogaction();
    is(Koha::ActionLogs->search({ module => 'CRONJOBS' })->count,1,"Cronjob logged as expected.");
};

subtest 'logaction(): interface is correctly logged' => sub {

    plan tests => 4;

    # No interface passed, using C4::Context->interface
    Koha::ActionLogs->search->delete;
    C4::Context->interface( 'commandline' );
    logaction( "MEMBERS", "MODIFY", 1, "test operation");
    my $log = Koha::ActionLogs->search->next;
    is( $log->interface, 'commandline', 'Interface correctly deduced (commandline)');

    # No interface passed, using C4::Context->interface
    Koha::ActionLogs->search->delete;
    C4::Context->interface( 'opac' );
    logaction( "MEMBERS", "MODIFY", 1, "test operation");
    $log = Koha::ActionLogs->search->next;
    is( $log->interface, 'opac', 'Interface correctly deduced (opac)');

    # Explicit interfaces
    Koha::ActionLogs->search->delete;
    C4::Context->interface( 'intranet' );
    logaction( "MEMBERS", "MODIFY", 1, 'test info', 'intranet');
    $log = Koha::ActionLogs->search->next;
    is( $log->interface, 'intranet', 'Passed interface is respected (intranet)');

    # Explicit interfaces
    Koha::ActionLogs->search->delete;
    C4::Context->interface( 'sip' );
    logaction( "MEMBERS", "MODIFY", 1, 'test info', 'sip');
    $log = Koha::ActionLogs->search->next;
    is( $log->interface, 'sip', 'Passed interface is respected (sip)');
};

subtest 'logaction / trace' => sub {
    plan tests => 2;

    C4::Context->interface( 'intranet' );
    t::lib::Mocks::mock_preference('ActionLogsTraceDepth',0);

    logaction( "MEMBERS", "MODIFY", 1, "test1");
    is( Koha::ActionLogs->search({ info => 'test1' })->last->trace, undef, 'No trace at level 0' );
    t::lib::Mocks::mock_preference('ActionLogsTraceDepth',2);
    logaction( "MEMBERS", "MODIFY", 1, "test2");
    like( Koha::ActionLogs->search({ info => 'test2' })->last->trace, qr/("line":.*){2}/, 'Found two trace levels' );

    t::lib::Mocks::mock_preference('ActionLogsTraceDepth',0);
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
    my @ret = checkpw( $patron->userid, 'WrongPassword', undef, undef, 1);
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
    @ret = checkpw( $patron->userid, 'WrongPassword', undef, undef, 1);
    $logs = Koha::ActionLogs->search(
        {
            module => 'AUTH',
            action => 'FAILURE',
            info   => { -like => '%'.$patron->userid.'%' },
        }
    );
    is( $logs->count, 1, 'Still only one failure with this userid' );
    t::lib::Mocks::mock_preference('AuthSuccessLog', 1);
    @ret = checkpw( $patron->userid, $strong_password, undef, undef, 1);
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

subtest 'Reduce log size by unblessing Koha objects' => sub {
    plan tests => 7;

    my $builder = t::lib::TestBuilder->new;
    my $item = $builder->build_sample_item;

    logaction( 'MY_MODULE', 'TEST01', $item->itemnumber, $item, 'opac' );
    my $str = Dumper($item->unblessed);
    my $logs = Koha::ActionLogs->search({ module => 'MY_MODULE', action => 'TEST01', object => $item->itemnumber });
    is( $logs->count, 1, 'Action found' );
    is( length($logs->next->info), length($str), 'Length exactly identical' );

    logaction( 'CATALOGUING', 'MODIFY', $item->itemnumber, $item, 'opac' );
    $logs = Koha::ActionLogs->search({ module => 'CATALOGUING', action => 'MODIFY', object => $item->itemnumber });
    is( substr($logs->next->info, 0, 5), 'item ', 'Prefix item' );
    is( length($logs->reset->next->info), 5+length($str), 'Length + 5' );

    my $hold = $builder->build_object({ class => 'Koha::Holds' });
    logaction( 'MY_CIRC_MODULE', 'TEST', $item->itemnumber, $hold, 'opac' );
    $logs = Koha::ActionLogs->search({ module => 'MY_CIRC_MODULE', action => 'TEST', object => $item->itemnumber });
    is( length($logs->next->info), length( Dumper($hold->unblessed)), 'Length of dumped unblessed hold' );

    logaction( 'MY_MODULE', 'TEST02', $item->itemnumber, [], 'opac' );
    $logs = Koha::ActionLogs->search({ module => 'MY_MODULE', action => 'TEST02', object => $item->itemnumber });
    like( $logs->next->info, qr/^ARRAY\(/, 'Dumped arrayref' );

    logaction( 'MY_MODULE', 'TEST03', $item->itemnumber, $builder, 'opac' );
    $logs = Koha::ActionLogs->search({ module => 'MY_MODULE', action => 'TEST03', object => $item->itemnumber });
    like( $logs->next->info, qr/^t::lib::TestBuilder/, 'Dumped TestBuilder object' );
};

$schema->storage->txn_rollback;
