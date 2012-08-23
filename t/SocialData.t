#!/usr/bin/perl
#
#Testing C4 SocialData

use strict;
use warnings;
use Test::More tests => 5;
use Test::MockModule;

BEGIN {
    use_ok('C4::SocialData');
}

my $module = new Test::MockModule('C4::Context');
$module->mock(
    '_new_dbh',
    sub {
        my $dbh = DBI->connect( 'DBI:Mock:', '', '' )
          || die "Cannot create handle: $DBI::errstr\n";
        return $dbh;
    }
);
my $socialdata = [
    [
        'isbn',            'num_critics',
        'num_critics_pro', 'num_quotations',
        'num_videos',      'score_avg',
        'num_scores'
    ],
    [ '0-596-52674-1', 1, 2, 3, 4, 5.2, 6 ],
    [ '0-596-00289-0', 2, 3, 4, 5, 6.2, 7 ]
];
my $dbh = C4::Context->dbh();

$dbh->{mock_add_resultset} = $socialdata;

my $data = C4::SocialData::get_data();

is( $data->{'isbn'}, '0-596-52674-1', 'First isbn is 0-596-52674-1' );

my $reportdata =
  [ [ 'biblionumber', 'isbn' ], [ 1, '0-596-52674-1' ],
    [ 2, '0-596-00289-0' ] ];

use Data::Dumper;

$dbh->{mock_add_resultset} = $reportdata;

ok( my $report = C4::SocialData::get_report() );

is( $report->{'without'}->[0]->{'original'},
    '0-596-52674-1', 'testing get_report gives isbn' );

is( $report->{'without'}->[0]->{'isbn'}, '9780596526740',
    'testing get_report' );
