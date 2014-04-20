#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use Modern::Perl;

use Test::More tests => 14;

use C4::Context;

BEGIN {
    use_ok('C4::Reports::Guided');
}
can_ok(
    'C4::Reports::Guided',
    qw(save_report delete_report execute_query)
);

#Start transaction
my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;
$dbh->{AutoCommit} = 0;

$dbh->do(q|DELETE FROM saved_sql|);

#Start tests

#Test save_report
my $count = scalar( @{ get_saved_reports() } );
is( $count, 0, "There is no report" );

my @report_ids;
for my $id ( 1 .. 3 ) {
    push @report_ids, save_report({
        borrowernumber => $id,
        savedsql       => "SQL$id",
        name           => "Name$id",
        area           => "area$id",
        group          => "group$id",
        subgroup       => "subgroup$id",
        type           => "type$id",
        notes          => "note$id",
        cache_expiry   => "null",
        public         => "null"
    });
    $count++;
}
like( $report_ids[0], '/^\d+$/', "Save_report returns an id for first" );
like( $report_ids[1], '/^\d+$/', "Save_report returns an id for second" );
like( $report_ids[2], '/^\d+$/', "Save_report returns an id for third" );

is( scalar( @{ get_saved_reports() } ),
    $count, "$count reports have been added" );

#Test delete_report
is (delete_report(),undef, "Without id delete_report returns undef");

is( delete_report( $report_ids[0] ), 1, "report 1 is deleted" );
$count--;

is( scalar( @{ get_saved_reports() } ), $count, "Report1 has been deleted" );

is( delete_report( $report_ids[1], $report_ids[2] ), 2, "report 2 and 3 are deleted" );
$count -= 2;

is( scalar( @{ get_saved_reports() } ),
    $count, "Report2 and report3 have been deleted" );

my $sth = execute_query('SELECT COUNT(*) FROM systempreferences', 0, 10);
my $results = $sth->fetchall_arrayref;
is(scalar(@$results), 1, 'running a query returned a result');

my $version = C4::Context->preference('Version');
$sth = execute_query(
    'SELECT value FROM systempreferences WHERE variable = ?',
    0,
    10,
    [ 'Version' ],
);
$results = $sth->fetchall_arrayref;
is_deeply(
    $results,
    [ [ $version ] ],
    'running a query with a parameter returned the expected result'
);

#End transaction
$dbh->rollback;

