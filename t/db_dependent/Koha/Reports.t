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
use Test::More tests => 21;

use C4::Context;
use Koha::Library::Group;
use Koha::Report;
use Koha::Reports;
use Koha::Patrons;
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

    t::lib::Mocks::mock_config( 'total_running_reports_per_instance_limit', 0 );

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
    plan tests => 7;

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
    my $running_query    = sprintf( 'SELECT 1 /* { saved_sql.id: %d } { user_id: %d } */', $report->id, $patron->id );
    my $processlist_rows = [ { info => $running_query } ];
    my $reports_mock     = Test::MockModule->new('Koha::Reports');
    $reports_mock->mock( '_processlist_rows', sub { return $processlist_rows } );

    my $exception;
    eval { $report->prep_report( [], [] ); };
    $exception = $@;
    isa_ok(
        $exception, 'Koha::Exceptions::Report::DuplicateRunning',
        'limit reached -> DuplicateRunning exception'
    );
    is( $exception->limit, 1, 'exception carries the configured limit' );

    t::lib::Mocks::mock_config( 'duplicate_running_reports_per_user_limit', 2 );
    lives_ok { $report->prep_report( [], [] ) } 'one copy running, limit of 2 not yet reached';

    # Pretend a second copy of this report is in flight.
    push @$processlist_rows, { info => $running_query };
    throws_ok { $report->prep_report( [], [] ) }
    'Koha::Exceptions::Report::DuplicateRunning',
        'two copies running, limit of 2 reached -> DuplicateRunning exception';
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
    # running_count() is called without a report_id filter (ie. the "total" check).
    my $reports_mock = Test::MockModule->new('Koha::Reports');
    $reports_mock->mock(
        'running_count',
        sub {
            my ( $class, $params ) = @_;
            return $params->{report_id} ? 0 : 1;
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

subtest 'prep_report() total_running_reports_per_instance_limit' => sub {

    plan tests => 3;

    my $report = Koha::Report->new( { report_name => 'total_running_test', savedsql => 'SELECT 1' } )->store;

    # Pretend two reports belonging to other users are in flight whenever
    # running_count() is called without any filter
    my $reports_mock = Test::MockModule->new('Koha::Reports');
    $reports_mock->mock(
        'running_count',
        sub {
            my ( $class, $params ) = @_;
            return 0 if $params && ( $params->{report_id} || $params->{user_id} );
            return 2;
        }
    );

    # Turn the other 2 off
    t::lib::Mocks::mock_config( 'duplicate_running_reports_per_user_limit', 0 );
    t::lib::Mocks::mock_config( 'total_running_reports_per_user_limit',     0 );

    # Test no limit
    t::lib::Mocks::mock_config( 'total_running_reports_per_instance_limit', 0 );
    lives_ok { $report->prep_report( [], [] ) }
    'no limit enforced when total_running_reports_per_instance_limit is disabled, AKA 0';

    # Test running while staying under the limit
    t::lib::Mocks::mock_config( 'total_running_reports_per_instance_limit', 5 );
    lives_ok { $report->prep_report( [], [] ) }
    'report runs while under the total_running_reports_per_instance_limit';

    # Test going over the limit
    t::lib::Mocks::mock_config( 'total_running_reports_per_instance_limit', 2 );
    throws_ok { $report->prep_report( [], [] ) }
    'Koha::Exceptions::Report::InstanceTotalRunning',
        'exception thrown if total_running_reports_per_instance_limit is reached';

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
    my $mgr_patron =
        $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0, branchcode => $branchA } } );
    my $basic_patron =
        $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0, branchcode => $branchA } } );

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
    t::lib::Mocks::mock_preference( 'LimitReportsBy', 'library' );
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
    t::lib::Mocks::mock_preference( 'LimitReportsBy', 'none' );
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

    my $basic_patron =
        $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0, branchcode => $branchA } } );

    # Ensure manage_report_limits permission exists and is NOT granted to basic_patron
    my $perm = $schema->resultset('Permission')->find( { module_bit => 16, code => 'manage_report_limits' } )
        // $schema->resultset('Permission')
        ->create( { module_bit => 16, code => 'manage_report_limits', description => 'Manage report limits' } );

    # Create report path

    # pref ON, no permission: creator branch auto-assigned
    t::lib::Mocks::mock_preference( 'LimitReportsBy', 'library' );
    my $report_create = Koha::Report->new( { report_name => 'limit test create', savedsql => 'SELECT 1' } )->store;
    my $can_manage    = Koha::Report->can_manage_limits($basic_patron);
    my @branches      = $can_manage ? () : ( $basic_patron->branchcode );
    $report_create->replace_library_limits( \@branches );
    my @limits = $report_create->get_library_limits->as_list;
    is( scalar @limits,         1,        'pref ON, no perm: create assigns exactly one branch limit' );
    is( $limits[0]->branchcode, $branchA, 'pref ON, no perm: create limit is the creator branchcode' );

    # pref OFF: no branches from form, no limits stored
    t::lib::Mocks::mock_preference( 'LimitReportsBy', 'none' );
    my $report_off = Koha::Report->new( { report_name => 'limit test pref off', savedsql => 'SELECT 1' } )->store;
    $report_off->replace_library_limits( [] );
    is( $report_off->get_library_limits, undef, 'pref OFF: no limits stored on create' );

    # Update report path
    t::lib::Mocks::mock_preference( 'LimitReportsBy', 'library' );

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

subtest 'library_group_limits' => sub {
    plan tests => 25;

    my $library_a = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_b = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_c = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_d = $builder->build_object( { class => 'Koha::Libraries' } );

    # root (ft_reports)
    #   group_a: library_a, library_b
    #     group_d: library_d
    # library_c is not in any group
    my $root_group = Koha::Library::Group->new( { title     => 'test root group', ft_reports => 1 } )->store;
    my $group_a    = Koha::Library::Group->new( { parent_id => $root_group->id, title => 'test group a' } )->store;
    my $group_d    = Koha::Library::Group->new( { parent_id => $group_a->id,    title => 'test group d' } )->store;
    Koha::Library::Group->new( { parent_id => $group_a->id, branchcode => $library_a->branchcode } )->store;
    Koha::Library::Group->new( { parent_id => $group_a->id, branchcode => $library_b->branchcode } )->store;
    Koha::Library::Group->new( { parent_id => $group_d->id, branchcode => $library_d->branchcode } )->store;

    my $report_no_limit  = $builder->build_object( { class => 'Koha::Reports' } );
    my $report_library_a = $builder->build_object( { class => 'Koha::Reports' } );

    # No limit
    my $limits = $report_no_limit->library_group_limits;
    is( scalar @$limits, 0, 'report with no limits returns empty arrayref' );

    # Limited to library_a - returns the root group, not the immediate parent
    $report_library_a->replace_library_limits( [ $library_a->branchcode ] );
    $limits = $report_library_a->library_group_limits;
    is( scalar @$limits,  1,               'report limited to library_a returns one group' );
    is( $limits->[0]->id, $root_group->id, 'returned group is the root group' );

    # Limited to library_a and library_b (same tree) - deduplicated to one group
    $report_library_a->replace_library_limits( [ $library_a->branchcode, $library_b->branchcode ] );
    $limits = $report_library_a->library_group_limits;
    is( scalar @$limits, 1, 'limits for two libraries sharing a root deduplicates to one group' );

    # Limited to library_d (nested sub-group) - still returns the root group
    my $report_library_d = $builder->build_object( { class => 'Koha::Reports' } );
    $report_library_d->replace_library_limits( [ $library_d->branchcode ] );
    $limits = $report_library_d->library_group_limits;
    is( scalar @$limits,  1,               'report limited to a library in a sub-group returns one group' );
    is( $limits->[0]->id, $root_group->id, 'nested library: returned group is the root group' );
    is( scalar @{ $report_library_d->ungrouped_library_limits }, 0, 'nested library: not ungrouped' );
    is_deeply(
        [ sort @{ $report_library_d->library_group_limit_branchcodes } ],
        [ sort ( $library_a->branchcode, $library_b->branchcode, $library_d->branchcode ) ],
        'nested library: resolves to every library in the tree under the root'
    );

    # Limited to library_a and library_d (different depths, same tree) - one group
    $report_library_d->replace_library_limits( [ $library_a->branchcode, $library_d->branchcode ] );
    $limits = $report_library_d->library_group_limits;
    is( scalar @$limits, 1, 'limits for libraries at different depths of one tree deduplicate to one group' );

    # ft_reports disabled on root - group excluded by filter
    $root_group->ft_reports(0)->store;
    $limits = $report_library_a->library_group_limits;
    is( scalar @$limits, 0, 'returns empty arrayref when root group has ft_reports disabled' );

    # Re-enable and verify
    $root_group->ft_reports(1)->store;
    $limits = $report_library_a->library_group_limits;
    is( scalar @$limits, 1, 'returns group again after ft_reports re-enabled on root' );

    # No limit - helper methods return empty arrayrefs
    is( scalar @{ $report_no_limit->ungrouped_library_limits },        0, 'no limits: no ungrouped libraries' );
    is( scalar @{ $report_no_limit->library_group_limit_branchcodes }, 0, 'no limits: no resolved branchcodes' );

    # Limited to library_a (grouped) and library_c (not in any group)
    my $report_a_c = $builder->build_object( { class => 'Koha::Reports' } );
    $report_a_c->replace_library_limits( [ $library_a->branchcode, $library_c->branchcode ] );

    $limits = $report_a_c->library_group_limits;
    is( scalar @$limits,  1,               'grouped + ungrouped: only the qualifying group is returned' );
    is( $limits->[0]->id, $root_group->id, 'grouped + ungrouped: returned group is the root group' );

    my $ungrouped = $report_a_c->ungrouped_library_limits;
    is( scalar @$ungrouped,          1,                      'grouped + ungrouped: one ungrouped library' );
    is( $ungrouped->[0]->branchcode, $library_c->branchcode, 'grouped + ungrouped: ungrouped library is library_c' );

    my $branchcodes = $report_a_c->library_group_limit_branchcodes;
    is( scalar @$branchcodes, 4, 'grouped + ungrouped: resolves to the whole tree plus the ungrouped library' );
    is_deeply(
        [ sort @$branchcodes ],
        [ sort ( $library_a->branchcode, $library_b->branchcode, $library_c->branchcode, $library_d->branchcode ) ],
        'grouped + ungrouped: resolved branchcodes are a, b, c and d'
    );

    # Limited to library_c only - enforced as a group of one
    my $report_c = $builder->build_object( { class => 'Koha::Reports' } );
    $report_c->replace_library_limits( [ $library_c->branchcode ] );

    is( scalar @{ $report_c->library_group_limits }, 0, 'ungrouped only: no groups returned' );
    $ungrouped = $report_c->ungrouped_library_limits;
    is( scalar @$ungrouped,          1,                      'ungrouped only: one ungrouped library' );
    is( $ungrouped->[0]->branchcode, $library_c->branchcode, 'ungrouped only: ungrouped library is library_c' );
    is_deeply(
        $report_c->library_group_limit_branchcodes, [ $library_c->branchcode ],
        'ungrouped only: resolves to library_c alone'
    );

    # ft_reports disabled on root - grouped libraries become ungrouped
    $root_group->ft_reports(0)->store;
    $ungrouped = $report_a_c->ungrouped_library_limits;
    is( scalar @$ungrouped, 2, 'ft_reports disabled: both limited libraries are ungrouped' );
    is_deeply(
        [ sort @{ $report_a_c->library_group_limit_branchcodes } ],
        [ sort ( $library_a->branchcode, $library_c->branchcode ) ],
        'ft_reports disabled: resolves to the stored branchcodes only'
    );
};

subtest 'can_access with library_group' => sub {
    plan tests => 13;

    my $library_a = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_b = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_c = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_d = $builder->build_object( { class => 'Koha::Libraries' } );

    # root (ft_reports)
    #   group_ab: library_a, library_b
    #     group_d: library_d
    # library_c is not in any group
    my $root_group = Koha::Library::Group->new( { title => 'can_access root', ft_reports => 1 } )->store;
    my $group_ab = Koha::Library::Group->new( { parent_id => $root_group->id, title => 'can_access group ab' } )->store;
    my $group_d  = Koha::Library::Group->new( { parent_id => $group_ab->id,   title => 'can_access group d' } )->store;
    Koha::Library::Group->new( { parent_id => $group_ab->id, branchcode => $library_a->branchcode } )->store;
    Koha::Library::Group->new( { parent_id => $group_ab->id, branchcode => $library_b->branchcode } )->store;
    Koha::Library::Group->new( { parent_id => $group_d->id,  branchcode => $library_d->branchcode } )->store;

    my $basic_patron = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );
    my $super_patron = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 1 } } );

    my $report_no_limit = $builder->build_object( { class => 'Koha::Reports' } );
    my $report_a        = $builder->build_object( { class => 'Koha::Reports' } );
    my $report_c        = $builder->build_object( { class => 'Koha::Reports' } );
    my $report_d        = $builder->build_object( { class => 'Koha::Reports' } );
    $report_a->replace_library_limits( [ $library_a->branchcode ] );
    $report_c->replace_library_limits( [ $library_c->branchcode ] );
    $report_d->replace_library_limits( [ $library_d->branchcode ] );

    t::lib::Mocks::mock_preference( 'LimitReportsBy', 'library_group' );

    # User at library_a (grouped with library_b, library_d in a sub-group)
    t::lib::Mocks::mock_userenv( { branchcode => $library_a->branchcode } );
    ok( $report_no_limit->can_access($basic_patron), 'branch a: report with no limits accessible' );
    ok( $report_a->can_access($basic_patron),        'branch a: report limited to own branch accessible' );
    ok( !$report_c->can_access($basic_patron),       'branch a: report limited to ungrouped branch c denied' );
    ok( $report_d->can_access($basic_patron),        'branch a: report limited to a branch in a sub-group accessible' );

    # User at library_b (sibling of library_a)
    t::lib::Mocks::mock_userenv( { branchcode => $library_b->branchcode } );
    ok( $report_a->can_access($basic_patron),  'branch b: report limited to group sibling accessible' );
    ok( !$report_c->can_access($basic_patron), 'branch b: report limited to ungrouped branch c denied' );

    # User at library_d (sub-group) - the whole tree under the root is one group
    t::lib::Mocks::mock_userenv( { branchcode => $library_d->branchcode } );
    ok( $report_d->can_access($basic_patron),  'branch d: report limited to own branch accessible' );
    ok( $report_a->can_access($basic_patron),  'branch d: report limited to a branch higher in the tree accessible' );
    ok( !$report_c->can_access($basic_patron), 'branch d: report limited to ungrouped branch c denied' );

    # User at library_c (not in any group) - own branch is a group of one
    t::lib::Mocks::mock_userenv( { branchcode => $library_c->branchcode } );
    ok( $report_c->can_access($basic_patron),  'branch c: report limited to own ungrouped branch accessible' );
    ok( !$report_a->can_access($basic_patron), 'branch c: report limited to another group denied' );
    ok( $report_c->can_access($super_patron),  'branch c: superlibrarian bypasses limits' );

    # No logged-in branch
    C4::Context->unset_userenv;
    ok( !$report_c->can_access($basic_patron), 'no user branch: limited report denied' );
};

subtest 'search_with_library_group_limits' => sub {
    plan tests => 6;

    C4::Context->unset_userenv;

    my $library_a = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_b = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_c = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_d = $builder->build_object( { class => 'Koha::Libraries' } );

    # root (ft_reports)
    #   group_a: library_a, library_b
    #     group_d: library_d
    # library_c is not in any group
    my $root_group = Koha::Library::Group->new( { title => 'search test root', ft_reports => 1 } )->store;
    my $group_a = Koha::Library::Group->new( { parent_id => $root_group->id, title => 'search test group a' } )->store;
    my $group_d = Koha::Library::Group->new( { parent_id => $group_a->id,    title => 'search test group d' } )->store;
    Koha::Library::Group->new( { parent_id => $group_a->id, branchcode => $library_a->branchcode } )->store;
    Koha::Library::Group->new( { parent_id => $group_a->id, branchcode => $library_b->branchcode } )->store;
    Koha::Library::Group->new( { parent_id => $group_d->id, branchcode => $library_d->branchcode } )->store;

    my $report_no_limit  = $builder->build_object( { class => 'Koha::Reports' } );
    my $report_library_a = $builder->build_object( { class => 'Koha::Reports' } );
    my $report_library_b = $builder->build_object( { class => 'Koha::Reports' } );
    my $report_library_d = $builder->build_object( { class => 'Koha::Reports' } );
    $report_library_a->replace_library_limits( [ $library_a->branchcode ] );
    $report_library_b->replace_library_limits( [ $library_b->branchcode ] );
    $report_library_d->replace_library_limits( [ $library_d->branchcode ] );

    my @ids       = ( $report_no_limit->id, $report_library_a->id, $report_library_b->id, $report_library_d->id );
    my $id_filter = { 'me.id' => { '-in' => \@ids } };

    # No library_id - unrestricted search
    my @results = Koha::Reports->search_with_library_group_limits( $id_filter, {}, undef, 'ft_reports' )->as_list;
    is( scalar @results, 4, 'no library_id returns all reports unrestricted' );

    # library_c not in any group - only own-branch and unlimited reports accessible
    @results = Koha::Reports->search_with_library_group_limits( $id_filter, {}, $library_c->branchcode, 'ft_reports' )
        ->as_list;
    is( scalar @results, 1, 'library not in any group sees only reports with no limit' );

    # library_a in group_a (ft_reports=1) - whole tree is accessible, sees library_b and library_d limited reports too
    @results = Koha::Reports->search_with_library_group_limits( $id_filter, {}, $library_a->branchcode, 'ft_reports' )
        ->as_list;
    is( scalar @results, 4, 'library in ft_reports group sees all reports limited to libraries in the tree' );

    # library_b (sibling of library_a) - same result
    @results = Koha::Reports->search_with_library_group_limits( $id_filter, {}, $library_b->branchcode, 'ft_reports' )
        ->as_list;
    is( scalar @results, 4, 'sibling library in the same group also sees all group-limited reports' );

    # library_d (sub-group) - sees reports limited to libraries higher in the tree
    @results = Koha::Reports->search_with_library_group_limits( $id_filter, {}, $library_d->branchcode, 'ft_reports' )
        ->as_list;
    is( scalar @results, 4, 'library in a sub-group sees all reports limited to libraries in the tree' );

    # ft_reports disabled on root - library_a falls back to own-branch only
    $root_group->ft_reports(0)->store;
    @results = Koha::Reports->search_with_library_group_limits( $id_filter, {}, $library_a->branchcode, 'ft_reports' )
        ->as_list;
    is( scalar @results, 2, 'ft_reports disabled on root limits access to own branch only' );
};

subtest '_confirm_branch_param_allowed' => sub {
    plan tests => 7;

    my $library_a = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_b = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_c = $builder->build_object( { class => 'Koha::Libraries' } );

    my $root_group = Koha::Library::Group->new( { title => 'confirm branch root', ft_reports => 1 } )->store;
    my $group_ab =
        Koha::Library::Group->new( { parent_id => $root_group->id, title => 'confirm branch group ab' } )->store;
    Koha::Library::Group->new( { parent_id => $group_ab->id, branchcode => $library_a->branchcode } )->store;
    Koha::Library::Group->new( { parent_id => $group_ab->id, branchcode => $library_b->branchcode } )->store;

    my $report_no_limit = $builder->build_object( { class => 'Koha::Reports' } );
    my $report_ab       = $builder->build_object( { class => 'Koha::Reports' } );
    $report_ab->replace_library_limits( [ $library_a->branchcode ] );

    # pref = none: any branch allowed regardless of user branch or report limits
    t::lib::Mocks::mock_preference( 'LimitReportsBy', 'none' );
    t::lib::Mocks::mock_userenv( { branchcode => $library_a->branchcode } );
    lives_ok { $report_ab->_confirm_branch_param_allowed( $library_c->branchcode ) }
    'pref none: any branchcode passes';

    # pref = library: branch matching user branch passes
    t::lib::Mocks::mock_preference( 'LimitReportsBy', 'library' );
    lives_ok { $report_ab->_confirm_branch_param_allowed( $library_a->branchcode ) }
    'pref library: matching branch passes';

    # pref = library: branch not matching user branch throws
    throws_ok { $report_ab->_confirm_branch_param_allowed( $library_b->branchcode ) }
    'Koha::Exception', 'pref library: non-matching branch throws';

    # pref = library: no logged-in branch throws
    C4::Context->unset_userenv;
    throws_ok { $report_ab->_confirm_branch_param_allowed( $library_a->branchcode ) }
    'Koha::Exception', 'pref library: no user branch throws';

    # pref = library_group: report with no group limits passes any branch
    t::lib::Mocks::mock_preference( 'LimitReportsBy', 'library_group' );
    t::lib::Mocks::mock_userenv( { branchcode => $library_a->branchcode } );
    lives_ok { $report_no_limit->_confirm_branch_param_allowed( $library_c->branchcode ) }
    'pref library_group: report with no group limits passes any branchcode';

    # pref = library_group: branchcode within the report group passes
    lives_ok { $report_ab->_confirm_branch_param_allowed( $library_b->branchcode ) }
    'pref library_group: branchcode within report group passes';

    # pref = library_group: branchcode outside the report group throws
    throws_ok { $report_ab->_confirm_branch_param_allowed( $library_c->branchcode ) }
    'Koha::Exception', 'pref library_group: branchcode outside report group throws';
};

subtest 'running' => sub {
    plan tests => 9;

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
        { info => "SELECT 1 /* { saved_sql.id: $a_id } { user_id: 17 } */" },
        { info => "SELECT 1 /* { saved_sql.id: $b_id } { user_id: 18 } */" },
        { info => "SELECT 1 /* no marker, should be ignored */" },
    ];
    is( Koha::Reports->running->count, 2, 'parses saved_sql.id markers and returns matching reports' );
    is( Koha::Reports->running_count,  3, 'running_count() counts each run of a report' );

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

subtest 'check_edit_permission() and store enforcement' => sub {
    plan tests => 8;

    my $owner  = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );
    my $editor = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );

    my $report = Koha::Report->new(
        {
            report_name    => 'permission_test',
            savedsql       => 'SELECT 1',
            borrowernumber => $owner->borrowernumber,
        }
    )->store;

    my $context = Test::MockModule->new('C4::Context');
    $context->mock( 'userenv', sub { undef } );
    lives_ok { $report->savedsql('SELECT 2')->store }
    'no logged-in user, store of an existing report is allowed';
    $context->unmock('userenv');

    t::lib::Mocks::mock_userenv( { patron => $owner } );
    lives_ok { $report->savedsql('SELECT 3')->store }
    'report creator can edit their own report';

    t::lib::Mocks::mock_userenv( { patron => $editor } );
    throws_ok { $report->savedsql('SELECT 4')->store }
    'Koha::Exceptions::Report::EditPermission',
        'a non-owner without edit_all_reports cannot edit the report';

    my $shared = Koha::Reports->find( $report->id );
    lives_ok { $shared->mana_id(12345)->store }
    'a mana_id-only change is exempt from the edit check';

    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $editor->borrowernumber,
                module_bit     => 16,
                code           => 'edit_all_reports',
            },
        }
    );
    lives_ok { $report->savedsql('SELECT 5')->store }
    'a non-owner with edit_all_reports can edit the report';

    lives_ok {
        Koha::Report->new(
            { report_name => 'new_one', savedsql => 'SELECT 1', borrowernumber => $owner->borrowernumber } )->store;
    }
    'creating a new report is not subject to the edit check';

    my $ownerless = Koha::Report->new( { report_name => 'ownerless_test', savedsql => 'SELECT 1' } )->store;

    t::lib::Mocks::mock_userenv( { patron => $owner } );
    throws_ok { $ownerless->savedsql('SELECT 2')->store }
    'Koha::Exceptions::Report::EditPermission',
        'a patron without edit_all_reports cannot edit an ownerless report';

    t::lib::Mocks::mock_userenv( { patron => $editor } );
    lives_ok { $ownerless->savedsql('SELECT 3')->store }
    'a patron with edit_all_reports can edit an ownerless report';
};

$schema->storage->txn_rollback;
