#!/usr/bin/perl

# This file is part of Koha
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

use Test::Exception;
use Test::MockModule;
use Test::NoWarnings;
use Test::More tests => 13;

use Koha::Report;
use Koha::Reports;
use Koha::Database;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder       = t::lib::TestBuilder->new;
my $nb_of_reports = Koha::Reports->search->count;
my $new_report_1  = Koha::Report->new(
    {
        report_name => 'report_name_for_test_1',
        savedsql    => 'SELECT "I wrote a report"',
    }
)->store;
my $new_report_2 = Koha::Report->new(
    {
        report_name => 'report_name_for_test_1',
        savedsql    => 'SELECT "Oops, I did it again"',
    }
)->store;

like( $new_report_1->id, qr|^\d+$|, 'Adding a new report should have set the id' );
is( Koha::Reports->search->count, $nb_of_reports + 2, 'The 2 reports should have been added' );

my $retrieved_report_1 = Koha::Reports->find( $new_report_1->id );
is(
    $retrieved_report_1->report_name, $new_report_1->report_name,
    'Find a report by id should return the correct report'
);

$retrieved_report_1->delete;
is( Koha::Reports->search->count, $nb_of_reports + 1, 'Delete should have deleted the report' );

subtest 'prep_report' => sub {
    plan tests => 4;

    my $report = Koha::Report->new(
        {
            report_name => 'report_name_for_test_1',
            savedsql    => 'SELECT * FROM items WHERE itemnumber IN <<Test|list>>',
        }
    )->store;
    my $id = $report->id;

    my $user_id = C4::Context->userenv ? C4::Context->userenv->{number} : 0;

    my ( $sql, undef ) = $report->prep_report( ['Test|list'], ["1\n12\n\r243"] );
    is(
        $sql,
        qq{SELECT * FROM items WHERE itemnumber IN ('1','12','243') /* { saved_sql.id: $id } { user_id: $user_id } */},
        'Expected sql generated correctly with single param and name'
    );

    $report->savedsql('SELECT * FROM items WHERE itemnumber IN <<Test|list>> AND <<Another>> AND <<Test|list>>')->store;

    ( $sql, undef ) = $report->prep_report( [ 'Test|list', 'Another' ], [ "1\n12\n\r243", 'the other' ] );
    is(
        $sql,
        qq{SELECT * FROM items WHERE itemnumber IN ('1','12','243') AND 'the other' AND ('1','12','243') /* { saved_sql.id: $id } { user_id: $user_id } */},
        'Expected sql generated correctly with multiple params and names'
    );

    ( $sql, undef ) = $report->prep_report( [], [ "1\n12\n\r243", 'the other' ] );
    is(
        $sql,
        qq{SELECT * FROM items WHERE itemnumber IN ('1','12','243') AND 'the other' AND ('1','12','243') /* { saved_sql.id: $id } { user_id: $user_id } */},
        'Expected sql generated correctly with multiple params and no names'
    );

    $report->savedsql(
        q{SELECT  i.itemnumber, i.itemnumber as Exemplarnummber, [[i.itemnumber| itemnumber for batch]] FROM items})
        ->store;
    my $headers;
    ( $sql, $headers ) = $report->prep_report( [], [] );
    is_deeply( $headers, { 'itemnumber for batch' => 'itemnumber' } );
};

subtest 'prep_report throws when duplicate-running limit is exceeded' => sub {
    plan tests => 5;

    my $report = Koha::Report->new( { report_name => 'duplicate_running_test', savedsql => 'SELECT 1' } )->store;

    # Pretend a real user is logged in so prep_report's user_id check fires.
    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    t::lib::Mocks::mock_userenv( { patron => $patron } );

    t::lib::Mocks::mock_config( 'duplicate_running_reports_per_user_limit', 0 );
    lives_ok { $report->prep_report( [], [] ) } 'limit=0 disables the guard';

    t::lib::Mocks::mock_config( 'duplicate_running_reports_per_user_limit', 5 );
    lives_ok { $report->prep_report( [], [] ) } 'limit not yet reached, prep_report returns normally';

    t::lib::Mocks::mock_config( 'duplicate_running_reports_per_user_limit', 1 );
    lives_ok { $report->prep_report( [], [] ) } 'limit not yet reached, prep_report returns normally';

    # Pretend a copy of this report is already in flight.
    my $reports_mock = Test::MockModule->new('Koha::Reports');
    $reports_mock->mock(
        'running',
        sub {
            my ( $class, $params ) = @_;
            return $class->search( { id => $report->id } ) if $params->{report_id};
            return $class->search( { id => undef } );
        }
    );

    my $exception;
    eval { $report->prep_report( [], [] ); };
    $exception = $@;
    isa_ok(
        $exception, 'Koha::Exceptions::Report::DuplicateRunning',
        'limit reached -> DuplicateRunning exception'
    );
    is( $exception->limit, 1, 'exception carries the configured limit' );

};

subtest 'prep_report throws when total-running limit is exceeded' => sub {
    plan tests => 3;

    my $report = Koha::Report->new( { report_name => 'total_running_test', savedsql => 'SELECT 1' } )->store;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    t::lib::Mocks::mock_userenv( { patron => $patron } );

    # The duplicate-limit check runs first, so neutralise it for these
    # assertions and only exercise the total-limit branch.
    t::lib::Mocks::mock_config( 'duplicate_running_reports_per_user_limit', 0 );

    # Pretend the user has three reports of various ids in flight whenever
    # running() is called without a report_id filter (ie. the "total" check).
    my $reports_mock = Test::MockModule->new('Koha::Reports');
    $reports_mock->mock(
        'running',
        sub {
            my ( $class, $params ) = @_;
            return $class->search( { id => undef } ) if $params->{report_id};
            return $class->search( { id => $report->id } );
        }
    );

    t::lib::Mocks::mock_config( 'total_running_reports_per_user_limit', 5 );
    lives_ok { $report->prep_report( [], [] ) } 'total limit not yet reached, prep_report returns normally';

    t::lib::Mocks::mock_config( 'total_running_reports_per_user_limit', 1 );
    my $exception;
    eval { $report->prep_report( [], [] ); };
    $exception = $@;
    isa_ok(
        $exception, 'Koha::Exceptions::Report::TotalRunning',
        'total limit reached -> TotalRunning exception'
    );
    is( $exception->limit, 1, 'exception carries the configured total limit' );
};

subtest 'is_sql_valid' => sub {
    plan tests => 3 + 6 * 2;
    my @badwords = ( 'UPDATE', 'DELETE', 'DROP', 'INSERT', 'SHOW', 'CREATE' );
    is_deeply(
        [ Koha::Report->new( { savedsql => '' } )->is_sql_valid ],
        [ 0, [ { queryerr => 'Missing SELECT' } ] ],
        'Empty sql is missing SELECT'
    );
    is_deeply(
        [ Koha::Report->new( { savedsql => 'FOO' } )->is_sql_valid ],
        [ 0, [ { queryerr => 'Missing SELECT' } ] ],
        'Nonsense sql is missing SELECT'
    );
    is_deeply(
        [ Koha::Report->new( { savedsql => 'select FOO' } )->is_sql_valid ],
        [ 1, [] ],
        'select FOO is good'
    );
    foreach my $word (@badwords) {
        is_deeply(
            [ Koha::Report->new( { savedsql => 'select FOO;' . $word . ' BAR' } )->is_sql_valid ],
            [ 0, [ { sqlerr => $word } ] ],
            'select FOO with ' . $word . ' BAR'
        );
        is_deeply(
            [ Koha::Report->new( { savedsql => $word . ' qux' } )->is_sql_valid ],
            [ 0, [ { sqlerr => $word } ] ],
            $word . ' qux'
        );
    }
};

subtest 'check_columns' => sub {
    plan tests => 3;

    my $report = Koha::Report->new;
    is_deeply( [ $report->check_columns('SELECT passWorD from borrowers') ], ['passWorD'], 'Bad column found in SQL' );
    is( scalar $report->check_columns('SELECT reset_passWorD from borrowers'), 0, 'No bad column found in SQL' );

    is_deeply(
        [
            $report->check_columns(
                undef,
                [
                    qw(change_password hash secret test place mytoken hersecret password_expiry_days password_expiry_days2)
                ]
            )
        ],
        [qw(secret mytoken hersecret password_expiry_days2)],
        'Check column_names parameter'
    );
};

subtest '_might_add_limit' => sub {
    plan tests => 10;

    my $sql;

    t::lib::Mocks::mock_preference( 'ReportsExportLimit', undef );    # i.e. no limit
    $sql = "SELECT * FROM biblio WHERE 1";
    is( Koha::Report->_might_add_limit($sql), $sql, 'Pref is undefined, no changes' );
    t::lib::Mocks::mock_preference( 'ReportsExportLimit', 0 );        # i.e. no limit
    is( Koha::Report->_might_add_limit($sql), $sql, 'Pref is zero, no changes' );
    t::lib::Mocks::mock_preference( 'ReportsExportLimit', q{} );      # i.e. no limit
    is( Koha::Report->_might_add_limit($sql), $sql, 'Pref is empty, no changes' );
    t::lib::Mocks::mock_preference( 'ReportsExportLimit', 10 );
    like( Koha::Report->_might_add_limit($sql), qr/ LIMIT 10$/, 'Limit 10 found at the end' );
    $sql = "SELECT * FROM biblio WHERE 1 LIMIT 1000 ";
    is( Koha::Report->_might_add_limit($sql), $sql, 'Already contains a limit' );
    $sql = "SELECT * FROM biblio WHERE 1 LIMIT 1000,2000";
    is( Koha::Report->_might_add_limit($sql), $sql, 'Variation, also contains a limit' );

    # trying a subquery having a limit (testing the lookahead in regex)
    $sql = "SELECT * FROM biblio WHERE biblionumber IN (SELECT biblionumber FROM reserves LIMIT 2)";
    like( Koha::Report->_might_add_limit($sql), qr/ LIMIT 10$/, 'Subquery, limit 10 found at the end' );
    $sql = "SELECT * FROM biblio WHERE biblionumber IN (SELECT biblionumber FROM reserves LIMIT 2, 3 ) AND 1";
    like( Koha::Report->_might_add_limit($sql), qr/ LIMIT 10$/, 'Subquery variation, limit 10 found at the end' );
    $sql = "select * from biblio where biblionumber in (select biblionumber from reserves limiT 3,4) and 1";
    like( Koha::Report->_might_add_limit($sql), qr/ LIMIT 10$/, 'Subquery lc variation, limit 10 found at the end' );

    $sql = "select limit, 22 from mylimits where limit between 1 and 3";
    like(
        Koha::Report->_might_add_limit($sql), qr/ LIMIT 10$/,
        'Query refers to limit field, limit 10 found at the end'
    );
};

subtest 'apply_execution_time_limit' => sub {
    plan tests => 3;

    my $sql = "SELECT * FROM biblio";

    t::lib::Mocks::mock_config( 'report_sql_max_statement_time_seconds', 0 );
    is( Koha::Report->apply_execution_time_limit($sql), $sql, 'No execution time limit configured' );

    t::lib::Mocks::mock_config( 'report_sql_max_statement_time_seconds', 1.5 );
    my $context = Test::MockModule->new('C4::Context');
    $context->mock( 'get_versions', sub { return ( mysqlVersion => '10.6.0-MariaDB' ); } );
    is(
        Koha::Report->apply_execution_time_limit($sql),
        'SET STATEMENT max_statement_time=1.500000 FOR SELECT * FROM biblio',
        'MariaDB max statement time applied'
    );

    $context->mock( 'get_versions', sub { return ( mysqlVersion => '8.0.36' ); } );
    like(
        Koha::Report->apply_execution_time_limit($sql),
        qr!^(?i:select) /\*\+ MAX_EXECUTION_TIME\(1500\) \*/ \* FROM biblio$!,
        'MySQL max execution time hint applied'
    );
};

subtest 'running' => sub {
    plan tests => 8;

    my $running = Koha::Reports->running;
    isa_ok( $running, 'Koha::Reports', 'running() returns a Koha::Reports resultset' );

    # No saved-report SQL is in flight in the test process; processlist may show
    # this very test connection but its current statement carries no saved_sql.id
    # marker, so the result must be empty.
    is( Koha::Reports->running->count, 0, 'no running reports => empty resultset' );

    is(
        Koha::Reports->running( { user_id => 999_999_999 } )->count, 0,
        'unknown user_id => empty resultset'
    );
    is(
        Koha::Reports->running( { report_id => 999_999_999 } )->count, 0,
        'unknown report_id => empty resultset'
    );

    # Capture the SQL bindings and feed synthetic rows back; this exercises the
    # WHERE-clause assembly and the saved_sql.id parser without relying on a
    # real long-running query in the database.
    my $reports_mock = Test::MockModule->new('Koha::Reports');
    my @captured_binds;
    my $captured_sql;
    my $synthetic_rows = [];
    $reports_mock->mock(
        '_processlist_rows',
        sub {
            my ( $class, $sql, @binds ) = @_;
            $captured_sql = $sql;
            push @captured_binds, [@binds];
            return $synthetic_rows;
        }
    );

    my $report_a = $builder->build_object( { class => 'Koha::Reports' } );
    my $report_b = $builder->build_object( { class => 'Koha::Reports' } );
    my ( $a_id, $b_id ) = ( $report_a->id, $report_b->id );

    $synthetic_rows = [
        { info => "SELECT 1 /* { saved_sql.id: $a_id } { user_id: 17 } */" },
        { info => "SELECT 1 /* { saved_sql.id: $b_id } { user_id: 18 } */" },
        { info => "SELECT 1 /* no marker, should be ignored */" },
    ];
    is( Koha::Reports->running->count, 2, 'parses saved_sql.id markers and returns matching reports' );

    @captured_binds = ();
    Koha::Reports->running( { user_id => 17 } );
    is_deeply(
        $captured_binds[0],
        [ 'Sleep', '%saved_sql.id:%', '%{ user_id: 17 }%' ],
        'user_id contributes a parameterised LIKE bind'
    );

    like(
        $captured_sql,
        qr/user\s*=\s*SUBSTRING_INDEX\(CURRENT_USER\(\),\s*'\@',\s*1\)/,
        'query is scoped to the current connection user'
    );

    # Graceful degradation when the underlying DB call dies (eg. PROCESS denied).
    $reports_mock->mock( '_processlist_rows', sub { die "Access denied for user\n"; } );
    is(
        Koha::Reports->running->count, 0,
        'DB failure => empty resultset (caller is not aborted)'
    );
};

$schema->storage->txn_rollback;
