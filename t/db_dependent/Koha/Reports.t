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
use Test::More tests => 25;

use C4::Context;
use Koha::BackgroundJob;
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
    plan tests => 8;

    t::lib::Mocks::mock_config( 'total_running_reports_per_instance_limit', 0 );

    my $report = Koha::Report->new(
        {
            report_name => 'report_name_for_test_1',
            savedsql    => 'SELECT * FROM items WHERE itemnumber IN <<Test|list>>',
            run_type    => 'any',
        }
    )->store;
    my $id = $report->id;

    my $user_id = C4::Context->userenv ? C4::Context->userenv->{number} : 0;

    my $fg = { run_type => 'foreground' };

    my ( $sql, undef ) = $report->prep_report( ['Test|list'], ["1\n12\n\r243"], $fg );
    is(
        $sql,
        qq{SELECT * FROM items WHERE itemnumber IN ('1','12','243') /* { saved_sql.id: $id } { user_id: $user_id } { run_type: foreground } */},
        'Expected sql generated correctly with single param and name'
    );

    $report->savedsql('SELECT * FROM items WHERE itemnumber IN <<Test|list>> AND <<Another>> AND <<Test|list>>')->store;

    ( $sql, undef ) = $report->prep_report( [ 'Test|list', 'Another' ], [ "1\n12\n\r243", 'the other' ], $fg );
    is(
        $sql,
        qq{SELECT * FROM items WHERE itemnumber IN ('1','12','243') AND 'the other' AND ('1','12','243') /* { saved_sql.id: $id } { user_id: $user_id } { run_type: foreground } */},
        'Expected sql generated correctly with multiple params and names'
    );

    ( $sql, undef ) = $report->prep_report( [], [ "1\n12\n\r243", 'the other' ], $fg );
    is(
        $sql,
        qq{SELECT * FROM items WHERE itemnumber IN ('1','12','243') AND 'the other' AND ('1','12','243') /* { saved_sql.id: $id } { user_id: $user_id } { run_type: foreground } */},
        'Expected sql generated correctly with multiple params and no names'
    );

    $report->savedsql(
        q{SELECT  i.itemnumber, i.itemnumber as Exemplarnummber, [[i.itemnumber| itemnumber for batch]] FROM items})
        ->store;
    my $headers;
    ( $sql, $headers ) = $report->prep_report( [], [], $fg );
    is_deeply( $headers, { 'itemnumber for batch' => 'itemnumber' } );

    # run_type marker
    $report->savedsql('SELECT 1')->store;

    ( $sql, undef ) = $report->prep_report( [], [], { run_type => 'foreground' } );
    is(
        $sql,
        qq{SELECT 1 /* { saved_sql.id: $id } { user_id: $user_id } { run_type: foreground } */},
        'run_type=foreground is appended to the marker'
    );

    ( $sql, undef ) = $report->prep_report( [], [], { run_type => 'background' } );
    is(
        $sql,
        qq{SELECT 1 /* { saved_sql.id: $id } { user_id: $user_id } { run_type: background } */},
        'run_type=background is appended to the marker'
    );

    throws_ok { $report->prep_report( [], [], {} ) }
    'Koha::Exceptions::MissingParameter',
        'missing run_type throws MissingParameter';

    throws_ok { $report->prep_report( [], [], { run_type => 'bogus' } ) }
    'Koha::Exceptions::BadParameter',
        'invalid run_type throws BadParameter';
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

subtest 'library_parameter_branchcodes' => sub {
    plan tests => 6;

    my $library_a = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_b = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_c = $builder->build_object( { class => 'Koha::Libraries' } );

    my $root_group = Koha::Library::Group->new( { title => 'param branchcodes root', ft_reports => 1 } )->store;
    my $group_ab =
        Koha::Library::Group->new( { parent_id => $root_group->id, title => 'param branchcodes group ab' } )->store;
    Koha::Library::Group->new( { parent_id => $group_ab->id, branchcode => $library_a->branchcode } )->store;
    Koha::Library::Group->new( { parent_id => $group_ab->id, branchcode => $library_b->branchcode } )->store;

    my $report_no_limit = $builder->build_object( { class => 'Koha::Reports' } );
    my $report_ab       = $builder->build_object( { class => 'Koha::Reports' } );
    my $report_a        = $builder->build_object( { class => 'Koha::Reports' } );
    my $report_c        = $builder->build_object( { class => 'Koha::Reports' } );
    $report_ab->replace_library_limits( [ $library_a->branchcode, $library_b->branchcode ] );
    $report_a->replace_library_limits( [ $library_a->branchcode ] );
    $report_c->replace_library_limits( [ $library_c->branchcode ] );

    t::lib::Mocks::mock_preference( 'LimitReportsBy', 'none' );
    is( $report_ab->library_parameter_branchcodes, undef, 'pref none: unrestricted' );

    t::lib::Mocks::mock_preference( 'LimitReportsBy', 'library' );
    is( $report_no_limit->library_parameter_branchcodes, undef, 'pref library: report with no limits is unrestricted' );
    is_deeply(
        [ sort @{ $report_ab->library_parameter_branchcodes } ],
        [ sort ( $library_a->branchcode, $library_b->branchcode ) ],
        'pref library: limited report resolves to its library limits only'
    );

    t::lib::Mocks::mock_preference( 'LimitReportsBy', 'library_group' );
    is(
        $report_no_limit->library_parameter_branchcodes, undef,
        'pref library_group: report with no limits is unrestricted'
    );
    is_deeply(
        [ sort @{ $report_a->library_parameter_branchcodes } ],
        [ sort ( $library_a->branchcode, $library_b->branchcode ) ],
        'pref library_group: limited report resolves to the whole reports group'
    );
    is_deeply(
        $report_c->library_parameter_branchcodes, [ $library_c->branchcode ],
        'pref library_group: ungrouped limit resolves to itself only'
    );
};

subtest '_confirm_branch_param_allowed' => sub {
    plan tests => 10;

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
    my $report_c        = $builder->build_object( { class => 'Koha::Reports' } );
    $report_ab->replace_library_limits( [ $library_a->branchcode ] );
    $report_c->replace_library_limits( [ $library_c->branchcode ] );

    my $exception = 'Koha::Exceptions::Report::UnauthorizedBranchParameter';

    # pref = none: any branch allowed regardless of report limits
    t::lib::Mocks::mock_preference( 'LimitReportsBy', 'none' );
    t::lib::Mocks::mock_userenv( { branchcode => $library_a->branchcode } );
    lives_ok { $report_ab->_confirm_branch_param_allowed( $library_c->branchcode ) }
    'pref none: any branchcode passes';

    # pref = library: a report with no limits allows any branch
    t::lib::Mocks::mock_preference( 'LimitReportsBy', 'library' );
    lives_ok { $report_no_limit->_confirm_branch_param_allowed( $library_c->branchcode ) }
    'pref library: report with no limits passes any branchcode';

    # pref = library: a limited report allows only its limited libraries
    lives_ok { $report_ab->_confirm_branch_param_allowed( $library_a->branchcode ) }
    'pref library: branchcode within the report limits passes';
    throws_ok { $report_ab->_confirm_branch_param_allowed( $library_b->branchcode ) }
    $exception, 'pref library: branchcode outside the report limits throws';

    # pref = library: the check does not depend on the logged-in branch
    C4::Context->unset_userenv;
    lives_ok { $report_ab->_confirm_branch_param_allowed( $library_a->branchcode ) }
    'pref library: no user branch still passes a branchcode within the report limits';

    # pref = library_group: a report with no limits allows any branch
    t::lib::Mocks::mock_preference( 'LimitReportsBy', 'library_group' );
    t::lib::Mocks::mock_userenv( { branchcode => $library_a->branchcode } );
    lives_ok { $report_no_limit->_confirm_branch_param_allowed( $library_c->branchcode ) }
    'pref library_group: report with no limits passes any branchcode';

    # pref = library_group: a limited report allows the whole reports group
    lives_ok { $report_ab->_confirm_branch_param_allowed( $library_b->branchcode ) }
    'pref library_group: branchcode within the report group passes';
    throws_ok { $report_ab->_confirm_branch_param_allowed( $library_c->branchcode ) }
    $exception, 'pref library_group: branchcode outside the report group throws';

    # pref = library_group: a report limited to an ungrouped library is enforced as a group of one
    lives_ok { $report_c->_confirm_branch_param_allowed( $library_c->branchcode ) }
    'pref library_group: ungrouped limit passes its own branchcode';
    throws_ok { $report_c->_confirm_branch_param_allowed( $library_a->branchcode ) }
    $exception, 'pref library_group: ungrouped limit throws for another branchcode';
};

subtest 'prep_report enforces library parameter limits' => sub {
    plan tests => 10;

    t::lib::Mocks::mock_config( 'total_running_reports_per_instance_limit', 0 );

    my $library_a = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_b = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_c = $builder->build_object( { class => 'Koha::Libraries' } );
    my ( $code_a, $code_b, $code_c ) = map { $_->branchcode } ( $library_a, $library_b, $library_c );

    my $report_no_limit = $builder->build_object( { class => 'Koha::Reports' } );
    my $report_ab       = $builder->build_object( { class => 'Koha::Reports' } );
    $report_ab->replace_library_limits( [ $code_a, $code_b ] );

    my $exception = 'Koha::Exceptions::Report::UnauthorizedBranchParameter';

    t::lib::Mocks::mock_preference( 'LimitReportsBy', 'library' );
    t::lib::Mocks::mock_userenv( { branchcode => $code_a } );

    # The label is free text, the authorised value selects the check
    $report_ab->savedsql('SELECT branchcode FROM branches WHERE branchcode = <<Branch|branches>>');
    lives_ok { $report_ab->prep_report( ['Branch|branches'], [$code_a], { run_type => 'foreground' } ) }
    'label Branch: branchcode within the report limits passes';
    throws_ok { $report_ab->prep_report( ['Branch|branches'], [$code_c], { run_type => 'foreground' } ) }
    $exception, 'label Branch: branchcode outside the report limits throws';

    # A multi-select value is joined by newlines, each code is checked
    $report_ab->savedsql('SELECT branchcode FROM branches WHERE branchcode IN <<Library|branches:in>>');
    my $sql;
    lives_ok {
        ($sql) = $report_ab->prep_report( ['Library|branches:in'], ["$code_a\n$code_b"], { run_type => 'foreground' } )
    }
    'multi-select: two branchcodes within the report limits pass';
    like( $sql, qr/IN \('\Q$code_a\E','\Q$code_b\E'\)/, 'multi-select: both branchcodes are in the SQL' );
    throws_ok {
        $report_ab->prep_report( ['Library|branches:in'], ["$code_a\r\n$code_c"], { run_type => 'foreground' } )
    }
    $exception, 'multi-select: a branchcode outside the report limits throws';

    # The "All" value is never allowed on a limited report
    $report_ab->savedsql('SELECT branchcode FROM branches WHERE branchcode LIKE <<Library|branches:all>>');
    throws_ok { $report_ab->prep_report( ['Library|branches:all'], ['%'], { run_type => 'foreground' } ) }
    $exception, 'all option: % throws on a limited report';
    t::lib::Mocks::mock_preference( 'LimitReportsBy', 'none' );
    lives_ok { $report_ab->prep_report( ['Library|branches:all'], ['%'], { run_type => 'foreground' } ) }
    'all option: % passes when LimitReportsBy is none';
    t::lib::Mocks::mock_preference( 'LimitReportsBy', 'library' );

    # A parameter is only checked when its authorised value is branches
    $report_ab->savedsql('SELECT itype FROM items WHERE itype = <<Library|itemtypes>>');
    lives_ok { $report_ab->prep_report( ['Library|itemtypes'], [$code_c], { run_type => 'foreground' } ) }
    'label Library with another authorised value: not checked';
    $report_ab->savedsql('SELECT branchcode FROM branches WHERE branchcode = <<Library>>');
    lives_ok { $report_ab->prep_report( ['Library'], [$code_c], { run_type => 'foreground' } ) }
    'label Library with no authorised value: not checked';

    # A report with no limits is unrestricted
    $report_no_limit->savedsql('SELECT branchcode FROM branches WHERE branchcode = <<Branch|branches>>');
    lives_ok { $report_no_limit->prep_report( ['Branch|branches'], [$code_c], { run_type => 'foreground' } ) }
    'report with no limits: any branchcode passes';
};

subtest 'check_limits() tests' => sub {
    plan tests => 11;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    my $report = $builder->build_object( { class => 'Koha::Reports' } );

    t::lib::Mocks::mock_userenv( { patron => $patron } );
    t::lib::Mocks::mock_config( 'duplicate_running_reports_per_user_limit', 0 );
    t::lib::Mocks::mock_config( 'total_running_reports_per_user_limit',     0 );
    t::lib::Mocks::mock_config( 'total_running_reports_per_instance_limit', 0 );

    my $borrowernumber  = $patron->borrowernumber;
    my $borrowernumber2 = $builder->build_object( { class => 'Koha::Patrons' } )->borrowernumber;
    my $report_id       = $report->id;
    my $report_id2      = $builder->build_object( { class => 'Koha::Reports' } )->id;

    my $reports_mock = Test::MockModule->new('Koha::Reports');
    $reports_mock->mock(
        '_processlist_rows',
        sub {
            return [
                {
                    info =>
                        "SELECT 1 /* { saved_sql.id: $report_id } { user_id: $borrowernumber } { run_type: foreground } */"
                },
                {
                    info =>
                        "SELECT 1 /* { saved_sql.id: $report_id } { user_id: $borrowernumber } { run_type: background } */"
                },
                {
                    info =>
                        "SELECT 1 /* { saved_sql.id: $report_id2 } { user_id: $borrowernumber2 } { run_type: foreground } */"
                },
            ];
        }
    );

    # Required-param tests
    throws_ok { Koha::Reports->check_limits( {} ) } 'Koha::Exceptions::MissingParameter',
        'missing run_type => MissingParameter';
    throws_ok { Koha::Reports->check_limits( { run_type => 'bogus' } ) } 'Koha::Exceptions::BadParameter',
        'invalid run_type => BadParameter';

    # No limits test
    my $r = Koha::Reports->check_limits(
        { report_id => $report_id, borrowernumber => $borrowernumber, run_type => 'foreground' } );
    is( $r->{any_exceeded}, 0, 'no limits configured => not exceeded' );

    # duplicate_running_reports_per_user
    t::lib::Mocks::mock_config( 'duplicate_running_reports_per_user_limit', 2 );
    $r = Koha::Reports->check_limits(
        { report_id => $report_id, borrowernumber => $borrowernumber, run_type => 'foreground' } );
    is( $r->{any_exceeded}, 1, 'duplicate limit met by 2 queries' );
    is(
        ( keys %{ $r->{errors}[0] } )[0],
        'duplicate_running_reports_per_user_limit_exceeded',
        'duplicate error key emitted'
    );

    # total_running_reports_per_user
    t::lib::Mocks::mock_config( 'duplicate_running_reports_per_user_limit', 0 );
    t::lib::Mocks::mock_config( 'total_running_reports_per_user_limit',     2 );
    $r = Koha::Reports->check_limits( { borrowernumber => $borrowernumber, run_type => 'foreground' } );
    is(
        ( keys %{ $r->{errors}[0] } )[0],
        'total_running_reports_per_user_limit_exceeded',
        'per-user total error key emitted'
    );

    # total_running_reports_per_instance
    t::lib::Mocks::mock_config( 'total_running_reports_per_user_limit',     0 );
    t::lib::Mocks::mock_config( 'total_running_reports_per_instance_limit', 3 );
    $r = Koha::Reports->check_limits( { run_type => 'foreground' } );
    is(
        ( keys %{ $r->{errors}[0] } )[0],
        'total_running_reports_per_instance_limit_exceeded',
        'per-instance total error key emitted'
    );

    # Queued background jobs add to the count
    Koha::BackgroundJob->new(
        {
            type           => 'run_report',
            status         => 'new',
            borrowernumber => $borrowernumber,
            report_id      => $report_id,
            data           => qq({"report_id":$report_id}),
        }
    )->store;

    t::lib::Mocks::mock_config( 'total_running_reports_per_instance_limit', 4 );
    $r = Koha::Reports->check_limits( { run_type => 'foreground' } );
    is( $r->{any_exceeded}, 1, 'queued run_report job counts toward per-instance' );

    t::lib::Mocks::mock_config( 'total_running_reports_per_instance_limit', 0 );
    t::lib::Mocks::mock_config( 'total_running_reports_per_user_limit',     3 );
    $r = Koha::Reports->check_limits( { borrowernumber => $borrowernumber, run_type => 'foreground' } );
    is( $r->{any_exceeded}, 1, 'queued run_report job counts toward per-user' );

    t::lib::Mocks::mock_config( 'total_running_reports_per_user_limit',     0 );
    t::lib::Mocks::mock_config( 'duplicate_running_reports_per_user_limit', 3 );
    $r = Koha::Reports->check_limits(
        { report_id => $report_id, borrowernumber => $borrowernumber, run_type => 'foreground' } );
    is( $r->{any_exceeded}, 1, 'queued run_report job counts toward duplicate-per-user' );

    # Processlist read failure is fatal. Limit checks cannot run without it.
    $reports_mock->mock( '_processlist_rows', sub { die "Access denied\n"; } );
    t::lib::Mocks::mock_config( 'duplicate_running_reports_per_user_limit', 0 );
    t::lib::Mocks::mock_config( 'total_running_reports_per_instance_limit', 1 );
    throws_ok { Koha::Reports->check_limits( { run_type => 'foreground' } ) } qr/Access denied/,
        'processlist read failure propagates';
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

subtest 'check_limits() per-run-type override tests' => sub {
    plan tests => 7;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    my $report = $builder->build_object( { class => 'Koha::Reports' } );

    t::lib::Mocks::mock_userenv( { patron => $patron } );
    for my $key (
        qw(
        duplicate_running_reports_per_user_limit
        total_running_reports_per_user_limit
        total_running_reports_per_instance_limit
        foreground_duplicate_running_reports_per_user_limit
        background_duplicate_running_reports_per_user_limit
        foreground_total_running_reports_per_user_limit
        background_total_running_reports_per_user_limit
        foreground_total_running_reports_per_instance_limit
        background_total_running_reports_per_instance_limit
        )
        )
    {
        t::lib::Mocks::mock_config( $key, 0 );
    }

    my $borrowernumber = $patron->borrowernumber;
    my $report_id      = $report->id;

    # 2 foreground queries + 1 background query for this user/report
    my $reports_mock = Test::MockModule->new('Koha::Reports');
    $reports_mock->mock(
        '_processlist_rows',
        sub {
            return [
                {
                    info =>
                        "SELECT 1 /* { saved_sql.id: $report_id } { user_id: $borrowernumber } { run_type: foreground } */"
                },
                {
                    info =>
                        "SELECT 1 /* { saved_sql.id: $report_id } { user_id: $borrowernumber } { run_type: foreground } */"
                },
                {
                    info =>
                        "SELECT 1 /* { saved_sql.id: $report_id } { user_id: $borrowernumber } { run_type: background } */"
                },
            ];
        }
    );

    # Foreground override counts only foreground queries
    t::lib::Mocks::mock_config( 'foreground_total_running_reports_per_instance_limit', 2 );
    my $r = Koha::Reports->check_limits( { run_type => 'foreground' } );
    is( $r->{any_exceeded}, 1, 'fg override exceeded by 2 fg queries at fg cap 2' );
    $r = Koha::Reports->check_limits( { run_type => 'background' } );
    is( $r->{any_exceeded}, 0, 'fg override does not affect background run_type' );
    t::lib::Mocks::mock_config( 'foreground_total_running_reports_per_instance_limit', 0 );

    # Background override counts only background queries plus queued jobs
    Koha::BackgroundJob->new(
        {
            type           => 'run_report',
            status         => 'new',
            borrowernumber => $borrowernumber,
            report_id      => $report_id,
            data           => qq({"report_id":$report_id}),
        }
    )->store;
    t::lib::Mocks::mock_config( 'background_total_running_reports_per_instance_limit', 2 );
    $r = Koha::Reports->check_limits( { run_type => 'background' } );
    is( $r->{any_exceeded}, 1, 'bg override exceeded by 1 bg query + 1 queued at bg cap 2' );
    $r = Koha::Reports->check_limits( { run_type => 'foreground' } );
    is( $r->{any_exceeded}, 0, 'bg override does not affect foreground run_type' );
    t::lib::Mocks::mock_config( 'background_total_running_reports_per_instance_limit', 0 );

    # When the override is set, the combined key is ignored for that run_type.
    # Combined cap of 1 would normally trigger. fg override of 99 lets fg through.
    t::lib::Mocks::mock_config( 'total_running_reports_per_instance_limit',            1 );
    t::lib::Mocks::mock_config( 'foreground_total_running_reports_per_instance_limit', 99 );
    $r = Koha::Reports->check_limits( { run_type => 'foreground' } );
    is( $r->{any_exceeded}, 0, 'fg override replaces (not stacks with) the combined cap' );

    # Background still hits the combined cap when no bg override is set.
    $r = Koha::Reports->check_limits( { run_type => 'background' } );
    is( $r->{any_exceeded}, 1, 'background falls back to the combined cap when no bg override' );
    t::lib::Mocks::mock_config( 'total_running_reports_per_instance_limit',            0 );
    t::lib::Mocks::mock_config( 'foreground_total_running_reports_per_instance_limit', 0 );

    # Per-user duplicate override works the same way.
    t::lib::Mocks::mock_config( 'foreground_duplicate_running_reports_per_user_limit', 2 );
    $r = Koha::Reports->check_limits(
        { report_id => $report_id, borrowernumber => $borrowernumber, run_type => 'foreground' } );
    is(
        ( keys %{ $r->{errors}[0] } )[0],
        'duplicate_running_reports_per_user_limit_exceeded',
        'override hits emit the canonical (un-prefixed) error key'
    );
};

subtest 'can_run_foreground_background' => sub {
    plan tests => 15;

    $schema->storage->txn_begin;

    #build some patrons to test with
    my $superlibrarian             = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 1 } } );
    my $foreground_dude            = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );
    my $background_dude            = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );
    my $foreground_background_dude = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );
    my $you_get_nothing_dude       = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );

    #foreground_dude gets execute_reports_foreground permission
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $foreground_dude->borrowernumber, module_bit => 16,
                code           => 'execute_reports_foreground'
            }
        }
    );

    #background dude gets execute_reports_background
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $background_dude->borrowernumber, module_bit => 16,
                code           => 'execute_reports_background'
            }
        }
    );

    #foreground_background_dude gets both execute_reports_foreground and execute_reports_background
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $foreground_background_dude->borrowernumber, module_bit => 16,
                code           => 'execute_reports_foreground'
            }
        }
    );

    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $foreground_background_dude->borrowernumber, module_bit => 16,
                code           => 'execute_reports_background'
            }
        }
    );

    # ReportsRunInBackground set to user_choice
    t::lib::Mocks::mock_preference( 'ReportsRunInBackground', 'user_choice' );
    is_deeply(
        Koha::Report->can_run_foreground_background($superlibrarian),
        { foreground => 1, background => 1 }, 'superlibrarian can run foreground and background'
    );
    is_deeply(
        Koha::Report->can_run_foreground_background($foreground_dude),
        { foreground => 1, background => 0 }, 'foreground permission can run foreground only'
    );
    is_deeply(
        Koha::Report->can_run_foreground_background($background_dude),
        { foreground => 0, background => 1 }, 'background permission can run background only'
    );
    is_deeply(
        Koha::Report->can_run_foreground_background($foreground_background_dude),
        { foreground => 1, background => 1 }, 'both permissions can run foreground and background'
    );
    is_deeply(
        Koha::Report->can_run_foreground_background($you_get_nothing_dude),
        { foreground => 0, background => 0 }, 'no permissions cannot run either'
    );

    # ReportsRunInBackground set to only run in background
    t::lib::Mocks::mock_preference( 'ReportsRunInBackground', 'always' );
    is_deeply(
        Koha::Report->can_run_foreground_background($superlibrarian),
        { foreground => 0, background => 1 }, 'superlibrarian can run background'
    );
    is_deeply(
        Koha::Report->can_run_foreground_background($foreground_dude),
        { foreground => 0, background => 0 }, 'foreground permission cannot run report in background'
    );
    is_deeply(
        Koha::Report->can_run_foreground_background($background_dude),
        { foreground => 0, background => 1 }, 'background permission can run background'
    );
    is_deeply(
        Koha::Report->can_run_foreground_background($foreground_background_dude),
        { foreground => 0, background => 1 }, 'both permissions can run background'
    );
    is_deeply(
        Koha::Report->can_run_foreground_background($you_get_nothing_dude),
        { foreground => 0, background => 0 }, 'no permissions cannot run'
    );

    # ReportsRunInBackground set to only run in foreground
    t::lib::Mocks::mock_preference( 'ReportsRunInBackground', 'never' );
    is_deeply(
        Koha::Report->can_run_foreground_background($superlibrarian),
        { foreground => 1, background => 0 }, 'superlibrarian can run foreground'
    );
    is_deeply(
        Koha::Report->can_run_foreground_background($foreground_dude),
        { foreground => 1, background => 0 }, 'foreground permission can run foreground'
    );
    is_deeply(
        Koha::Report->can_run_foreground_background($background_dude),
        { foreground => 0, background => 0 }, 'background permission cannot foreground'
    );
    is_deeply(
        Koha::Report->can_run_foreground_background($foreground_background_dude),
        { foreground => 1, background => 0 }, 'both permissions can run foreground'
    );
    is_deeply(
        Koha::Report->can_run_foreground_background($you_get_nothing_dude),
        { foreground => 0, background => 0 }, 'no permissions cannot run'
    );
};

subtest 'prep_report() honors saved_sql.run_type setting' => sub {
    plan tests => 6;

    t::lib::Mocks::mock_preference( 'ReportsRunInBackground', 'user_choice' );

    my $fg_report =
        Koha::Report->new( { report_name => 'fg_only', savedsql => 'SELECT 1', run_type => 'foreground' } )->store;
    my $bg_report =
        Koha::Report->new( { report_name => 'bg_only', savedsql => 'SELECT 1', run_type => 'background' } )->store;
    my $any_report =
        Koha::Report->new( { report_name => 'any_runtype', savedsql => 'SELECT 1', run_type => 'any' } )->store;

    throws_ok { $fg_report->prep_report( [], [], { run_type => 'background' } ) }
    'Koha::Exceptions::Report::RunTypeNotAllowed',
        'foreground-only report rejects a background request';

    throws_ok { $bg_report->prep_report( [], [], { run_type => 'foreground' } ) }
    'Koha::Exceptions::Report::RunTypeNotAllowed',
        'background-only report rejects a foreground request';

    lives_ok { $fg_report->prep_report( [], [], { run_type => 'foreground' } ) }
    'foreground-only report accepts a foreground request';

    lives_ok { $bg_report->prep_report( [], [], { run_type => 'background' } ) }
    'background-only report accepts a background request';

    lives_ok { $any_report->prep_report( [], [], { run_type => 'background' } ) }
    'any-runtype report accepts either request';

    t::lib::Mocks::mock_preference( 'ReportsRunInBackground', 'never' );
    lives_ok { $bg_report->prep_report( [], [], { run_type => 'foreground' } ) }
    'background-only report accepts a foreground request when ReportsRunInBackground is never';
};

subtest 'effective_run_type() tests' => sub {
    plan tests => 6;

    my $fg_report = $builder->build_object( { class => 'Koha::Reports', value => { run_type => 'foreground' } } );
    my $bg_report = $builder->build_object( { class => 'Koha::Reports', value => { run_type => 'background' } } );

    t::lib::Mocks::mock_preference( 'ReportsRunInBackground', 'user_choice' );
    is( $fg_report->effective_run_type, 'foreground', 'user_choice: foreground-only report is enforced' );
    is( $bg_report->effective_run_type, 'background', 'user_choice: background-only report is enforced' );

    t::lib::Mocks::mock_preference( 'ReportsRunInBackground', 'always' );
    is( $fg_report->effective_run_type, 'any', 'always: foreground-only report is ignored' );
    is( $bg_report->effective_run_type, 'any', 'always: background-only report is ignored' );

    t::lib::Mocks::mock_preference( 'ReportsRunInBackground', 'never' );
    is( $fg_report->effective_run_type, 'any', 'never: foreground-only report is ignored' );
    is( $bg_report->effective_run_type, 'any', 'never: background-only report is ignored' );
};

$schema->storage->txn_rollback;
