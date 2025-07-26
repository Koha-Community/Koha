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
    plan tests => 4;

    my $report = Koha::Report->new( { report_name => 'duplicate_running_test', savedsql => 'SELECT 1' } )->store;

    # Pretend a real user is logged in so prep_report's user_id check fires.
    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    t::lib::Mocks::mock_userenv( { patron => $patron } );

    # Pretend two copies of this report are already in flight.
    my $reports_mock = Test::MockModule->new('Koha::Reports');
    $reports_mock->mock(
        'running',
        sub {
            my ( $class, $params ) = @_;
            return $class->search( { id => $report->id } ) if $params->{report_id};
            return $class->search( { id => undef } );
        }
    );

    t::lib::Mocks::mock_config( 'duplicate_running_reports_per_user_limit', 0 );
    lives_ok { $report->prep_report( [], [] ) } 'limit=0 disables the guard';

    t::lib::Mocks::mock_config( 'duplicate_running_reports_per_user_limit', 5 );
    lives_ok { $report->prep_report( [], [] ) } 'limit not yet reached, prep_report returns normally';

    t::lib::Mocks::mock_config( 'duplicate_running_reports_per_user_limit', 1 );
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
subtest 'reports_branches are added and removed from report_branches table' => sub {
    plan tests => 4;

    my $updated_nb_of_reports = Koha::Reports->search->count;
    my $report                = Koha::Report->new(
        {
            report_name => 'report_name_for_test_1',
            savedsql    => 'SELECT * FROM items WHERE itemnumber IN <<Test|list>>',
        }
    )->store;

    my $id       = $report->id;
    my $library1 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library2 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library3 = $builder->build_object( { class => 'Koha::Libraries' } );
    my @branches = ( $library1->branchcode, $library2->branchcode, $library3->branchcode );

    $report->replace_library_limits( \@branches );

    my @branches_loop = $report->get_library_limits->as_list;
    is( scalar @branches_loop, 3, '3 branches added to report_branches table' );

    $report->replace_library_limits( [ $library1->branchcode, $library2->branchcode ] );

    @branches_loop = $report->get_library_limits->as_list;
    is( scalar @branches_loop, 2, '1 branch removed from report_branches table' );

    $report->delete;
    is( Koha::Reports->search->count, $updated_nb_of_reports, 'Report deleted, count is back to original' );
    is(
        $schema->resultset('ReportsBranch')->search( { report_id => $id } )->count,
        0,
        'No branches left in reports_branches table after report deletion'
    );
};

subtest 'can_manage_limits and can_access' => sub {
    plan tests => 21;

    my $libraryA = $builder->build_object( { class => 'Koha::Libraries' } );
    my $libraryB = $builder->build_object( { class => 'Koha::Libraries' } );
    my $branchA  = $libraryA->branchcode;
    my $branchB  = $libraryB->branchcode;

    my $super_patron =
        $builder->build_object( { class => 'Koha::Patrons', value => { flags => 1, branchcode => $branchA } } );
    my $mgr_patron   = $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $branchA } } );
    my $basic_patron = $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $branchA } } );

    # Grant reports => manage_report_limits to manager patron (create permission if missing)
    my $perm = $schema->resultset('Permission')->find( { module_bit => 16, code => 'manage_report_limits' } )
        // $schema->resultset('Permission')
        ->create( { module_bit => 16, code => 'manage_report_limits', description => 'Manage report limits' } );
    $schema->resultset('UserPermission')
        ->create( { borrowernumber => $mgr_patron->borrowernumber, module_bit => 16, code => 'manage_report_limits' } );

    # Helper to create reports
    my $r_no = Koha::Report->new( { report_name => 'No limits', savedsql => 'SELECT 1' } )->store;
    my $r_A  = Koha::Report->new( { report_name => 'Limit A',   savedsql => 'SELECT 1' } )->store;
    my $r_B  = Koha::Report->new( { report_name => 'Limit B',   savedsql => 'SELECT 1' } )->store;
    my $r_AB = Koha::Report->new( { report_name => 'Limit AB',  savedsql => 'SELECT 1' } )->store;

    $r_A->replace_library_limits( [$branchA] );
    $r_B->replace_library_limits( [$branchB] );
    $r_AB->replace_library_limits( [ $branchA, $branchB ] );

    # Preference ON, branch A
    t::lib::Mocks::mock_preference( 'LimitReportsByLibrary', 1 );
    t::lib::Mocks::mock_userenv( { branchcode => $branchA } );

    ok( Koha::Report->can_manage_limits($super_patron),  'pref ON: super manages limits' );
    ok( Koha::Report->can_manage_limits($mgr_patron),    'pref ON: manager manages limits' );
    ok( !Koha::Report->can_manage_limits($basic_patron), 'pref ON: basic cannot manage limits' );

    # Basic patron (branch A)
    ok( $r_no->can_access($basic_patron), 'pref ON: no limits accessible' );
    ok( $r_A->can_access($basic_patron),  'pref ON: limited includes branch accessible' );
    ok( !$r_B->can_access($basic_patron), 'pref ON: limited excludes branch denied' );
    ok( $r_AB->can_access($basic_patron), 'pref ON: multi includes branch accessible' );

    # Manager bypass (branch A)
    ok( $r_A->can_access($mgr_patron),  'pref ON: manager sees limited A' );
    ok( $r_B->can_access($mgr_patron),  'pref ON: manager sees limited B' );
    ok( $r_AB->can_access($mgr_patron), 'pref ON: manager sees multi AB' );
    ok( $r_no->can_access($mgr_patron), 'pref ON: manager sees no limits' );

    # Superlibrarian bypass (branch A)
    ok( $r_A->can_access($super_patron),  'pref ON: super sees limited A' );
    ok( $r_B->can_access($super_patron),  'pref ON: super sees limited B' );
    ok( $r_AB->can_access($super_patron), 'pref ON: super sees multi AB' );

    # Preference OFF (everything accessible, manage disabled)
    t::lib::Mocks::mock_preference( 'LimitReportsByLibrary', 0 );
    ok( !Koha::Report->can_manage_limits($super_patron), 'pref OFF: super cannot manage limits' );
    ok( !Koha::Report->can_manage_limits($mgr_patron),   'pref OFF: manager cannot manage limits' );
    ok( !Koha::Report->can_manage_limits($basic_patron), 'pref OFF: basic cannot manage limits' );
    ok( $r_B->can_access($basic_patron),                 'pref OFF: limited excludes branch still accessible' );
    ok( $r_A->can_access($basic_patron),                 'pref OFF: limited includes branch accessible' );
    ok( $r_AB->can_access($basic_patron),                'pref OFF: multi-limit accessible' );
    ok( $r_no->can_access($basic_patron),                'pref OFF: no limits accessible' );
};

subtest 'library limits enforcement on save and update' => sub {
    plan tests => 5;

    my $libraryA = $builder->build_object( { class => 'Koha::Libraries' } );
    my $branchA  = $libraryA->branchcode;

    my $basic_patron = $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $branchA } } );

    # Ensure manage_report_limits permission exists and is NOT granted to basic_patron
    my $perm = $schema->resultset('Permission')->find( { module_bit => 16, code => 'manage_report_limits' } )
        // $schema->resultset('Permission')
        ->create( { module_bit => 16, code => 'manage_report_limits', description => 'Manage report limits' } );

    # Create report path

    # pref ON, no permission: creator branch auto-assigned
    t::lib::Mocks::mock_preference( 'LimitReportsByLibrary', 1 );
    my $report_create = Koha::Report->new( { report_name => 'limit test create', savedsql => 'SELECT 1' } )->store;
    my $can_manage    = Koha::Report->can_manage_limits($basic_patron);
    my @branches      = $can_manage ? () : ( $basic_patron->branchcode );
    $report_create->replace_library_limits( \@branches );
    my @limits = $report_create->get_library_limits->as_list;
    is( scalar @limits,         1,        'pref ON, no perm: create assigns exactly one branch limit' );
    is( $limits[0]->branchcode, $branchA, 'pref ON, no perm: create limit is the creator branchcode' );

    # pref OFF: no branches from form, no limits stored
    t::lib::Mocks::mock_preference( 'LimitReportsByLibrary', 0 );
    my $report_off = Koha::Report->new( { report_name => 'limit test pref off', savedsql => 'SELECT 1' } )->store;
    $report_off->replace_library_limits( [] );
    is( $report_off->get_library_limits, undef, 'pref OFF: no limits stored on create' );

    # Update report path
    t::lib::Mocks::mock_preference( 'LimitReportsByLibrary', 1 );

    # pref ON, no permission, report has existing limits: limits preserved unchanged
    my $report_update = Koha::Report->new( { report_name => 'limit test update', savedsql => 'SELECT 1' } )->store;
    $report_update->replace_library_limits( [$branchA] );
    my $existing_limits = $report_update->get_library_limits;
    my @preserved       = $existing_limits ? map { $_->branchcode } $existing_limits->as_list : ();
    $report_update->replace_library_limits( \@preserved );
    my @updated_limits = $report_update->get_library_limits->as_list;
    is( scalar @updated_limits, 1, 'pref ON, no perm: update preserves existing limits unchanged' );

    # pref ON, no permission, report has no existing limits: stays limit-free
    my $report_no_limits =
        Koha::Report->new( { report_name => 'limit test no limits', savedsql => 'SELECT 1' } )->store;
    my $existing_limits2 = $report_no_limits->get_library_limits;
    my @branches2        = $existing_limits2 ? map { $_->branchcode } $existing_limits2->as_list : ();
    $report_no_limits->replace_library_limits( \@branches2 );
    is(
        $report_no_limits->get_library_limits, undef,
        'pref ON, no perm: update with no existing limits stays limit-free'
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
