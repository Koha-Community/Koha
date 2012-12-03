#!/usr/bin/perl

use Modern::Perl;
use Test::More;
use Test::MockModule;
use C4::Context;
use Data::Dumper;

BEGIN {
    use_ok('C4::Update::Database');
}

clean_db();

my $already_applied_before = C4::Update::Database::list_versions_already_applied;
my $nb_applied_before = scalar @$already_applied_before;
my $nb_status_ok_before = grep {$_->{status}} @$already_applied_before;

my $updatedatabasemodule = new Test::MockModule('C4::Update::Database');
$updatedatabasemodule->mock('get_versions_path', sub {C4::Context->config('intranetdir') . '/t/db_dependent/data/update_database/versions'});

my $availables = C4::Update::Database::list_versions_available;
my $already_applied = C4::Update::Database::list_versions_already_applied;

my $report;

is ( scalar @$availables, 4, "There are 4 new available updates" );

$report = C4::Update::Database::execute_version( "3.99.01.001" );
is ( $report->{'3.99.01.001'}, 'OK', "There is no error for the 1st version" );

$already_applied = C4::Update::Database::list_versions_already_applied;
is ( scalar @$already_applied, $nb_applied_before + 1, "There is 1 already applied version" );

$report = C4::Update::Database::execute_version( "3.99.01.001" );
is ( $report->{"3.99.01.001"}{error}, 'ALREADY_EXISTS', "There is an 'already exist' error" );
is ( $report->{"3.99.01.001"}{old_version}, '3.99.01.001', "This version had already executed in version 3.99.01.001" );


my $queries = C4::Update::Database::get_queries( C4::Update::Database::get_filepath( "3.99.01.002" ) );
my $expected = {
    queries => [
        'CREATE TABLE UpdateDatabase_testFOOBIS ( `version` varchar(32) DEFAULT NULL)'
    ],
    'comments' => [
        'This is a comment',
        'This is aanother comment'
    ]
};
is_deeply ( $queries, $expected, "The version 002 contains 1 query and 2 comments" );

$report = C4::Update::Database::execute_version( "3.99.01.002" );
is ( $report->{'3.99.01.002'}, 'OK', "There is no error for the 2nd version" );

$report = C4::Update::Database::execute_version( "3.99.01.003" );
$expected = {
    '3.99.01.003' => [
        q{Error : 1050 => Table 'UpdateDatabase_testFOO' already exists}
    ]
};
is_deeply ( $report, $expected, "There is an error for the 3rd version" );

$report = C4::Update::Database::execute_version( "3.99.01.004" );
is ( $report->{'3.99.01.004'}, 'OK', "There is no error for the 4th version" );


$already_applied = C4::Update::Database::list_versions_already_applied;
is ( grep( {$_->{status}} @$already_applied ), $nb_status_ok_before + 3, "There are 3 new versions with a status OK" );

C4::Update::Database::mark_as_ok( "3.99.01.003" );
$already_applied = C4::Update::Database::list_versions_already_applied;
is ( grep( {$_->{status}} @$already_applied ), $nb_status_ok_before + 4, "There are 4 new versions with a status OK" );


clean_db();

sub clean_db {
    my $dbh = C4::Context->dbh;
    local $dbh->{PrintError} = 0;
    local $dbh->{RaiseError} = 0;
    $dbh->do( q{
        DELETE FROM updatedb_error WHERE version LIKE "3.99.01.%";
    });
    $dbh->do( q{
        DELETE FROM updatedb_query WHERE version LIKE "3.99.01.%";
    });
    $dbh->do( q{
        DELETE FROM updatedb_report WHERE version LIKE "3.99.01.%";
    });
    $dbh->do( q{
        DROP TABLE UpdateDatabase_testFOO;
    });
    $dbh->do( q{
        DROP TABLE UpdateDatabase_testFOOBIS;
    });
    $dbh->do( q{
        DELETE FROM systempreferences WHERE variable = "UpdateDatabase::testsyspref1" OR variable = "UpdateDatabase::testsyspref2"
    });
}

done_testing;
