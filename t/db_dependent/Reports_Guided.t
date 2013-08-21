#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use Modern::Perl;

use Test::More tests => 12;

use C4::Context;

BEGIN {
    use_ok('C4::Reports::Guided');
}
can_ok(
    'C4::Reports::Guided',
    qw(save_report
      delete_report)
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

#End transaction
$dbh->rollback;

