#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use Test::More tests => 10;
use Test::MockModule;

BEGIN {
    use_ok('C4::Barcodes::ValueBuilder');
}


my $module = new Test::MockModule('C4::Context');
$module->mock('_new_dbh', sub {
                             my $dbh = DBI->connect( 'DBI:Mock:', '', '' )
                             || die "Cannot create handle: $DBI::errstr\n";
                             return $dbh });

# Mock data
my $incrementaldata = [
    ['max(abs(barcode))'],
    ['33333074344563'],
];


my $dbh = C4::Context->dbh();

my %args = (
    year        => '2012',
    mon         => '07',
    day         => '30',
    tag         => '952',
    subfield    => 'p',
    loctag      => '952',
    locsubfield => 'a'
);

$dbh->{mock_add_resultset} = $incrementaldata;
my ($nextnum, $scr, $history);

($nextnum, $scr) = C4::Barcodes::ValueBuilder::incremental::get_barcode(\%args);
is($nextnum, 33333074344564, 'incremental barcode');
is($scr, undef, 'incremental javascript');

# This should run exactly one query so we can test
$history = $dbh->{mock_all_history};
is(scalar(@{$history}), 1, 'Correct number of statements executed for incremental barcode') ;

my $hbyymmincrdata = [
    ['number'],
    ['890'],
];

$dbh->{mock_add_resultset} = $hbyymmincrdata;
$dbh->{mock_clear_history} = 1;
($nextnum, $scr) = C4::Barcodes::ValueBuilder::hbyymmincr::get_barcode(\%args);
is($nextnum, '12070891', 'hbyymmincr barcode');
ok(length($scr) > 0, 'hbyymmincr javascript');

# This should run exactly one query so we can test
$history = $dbh->{mock_all_history};
is(scalar(@{$history}), 1, 'Correct number of statements executed for hbyymmincr barcode') ;

my $annualdata = [
    ['max(cast( substring_index(barcode, \'-\',-1) as signed))'],
    ['34'],
];

$dbh->{mock_add_resultset} = $annualdata;
$dbh->{mock_clear_history} = 1;
($nextnum, $scr) = C4::Barcodes::ValueBuilder::annual::get_barcode(\%args);
is($nextnum, '2012-0035', 'annual barcode');
is($scr, undef, 'annual javascript');

# This should run exactly one query so we can test
$history = $dbh->{mock_all_history};
is(scalar(@{$history}), 1, 'Correct number of statements executed for hbyymmincr barcode') ;
