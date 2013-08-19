#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use Modern::Perl;

use Test::More tests => 7;

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
my $count = scalar( keys get_saved_reports() );
is( $count, 0, "There is no report" );
my $sample_report1 = {
    borrowernumber => 1,
    savedsql       => 'SQL1',
    name           => 'Name1',
    area           => 'area1',
    group          => 'group1',
    subgroup       => 'subgroup1',
    type           => 'type1',
    notes          => 'note1',
    cache_expiry   => 'null',
    public         => 'null'
};
my $sample_report2 = {
    borrowernumber => 2,
    savedsql       => 'SQL2',
    name           => 'Name2',
    area           => 'area2',
    group          => 'group2',
    subgroup       => 'subgroup2',
    type           => 'type2',
    notes          => 'note2',
    cache_expiry   => 'null',
    public         => 'null'
};
my $report_id1 = save_report($sample_report1);
my $report_id2 = save_report($sample_report2);
like( $report_id1, '/^\d+$/', "Save_report returns an id" );
like( $report_id2, '/^\d+$/', "Save_report returns an id" );
is( scalar( keys get_saved_reports() ),
    $count + 2, "Report1 and report2 have been added" );

#Test delete_report
#It would be better if delete_report has return values
delete_report( $report_id1, $report_id2 );
is( scalar( keys get_saved_reports() ),
    $count, "Report1 and report2 have been deleted" );

#FIX ME: Currently, this test doesn't pass because delete_report doesn't test if one or more parameters are given
#is (deleted_report(),undef, "Without id deleted_report returns undef");

#End transaction
$dbh->rollback;

