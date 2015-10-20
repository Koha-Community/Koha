#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 7;
use Test::MockModule;
use t::lib::TestBuilder;

BEGIN {
    use_ok('C4::Barcodes::ValueBuilder');
};

my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;
$dbh->do(q|DELETE FROM items|);
my $item_1 = $builder->build({
    source => 'Item',
    value => {
        barcode => '33333074344563'
    }
});
my $item_2 = $builder->build({
    source => 'Item',
    value => {
        barcode => 'hb12070890'
    }
});
my $item_3 = $builder->build({
    source => 'Item',
    value => {
        barcode => '2012-0034'
    }
});

my %args = (
    year        => '2012',
    mon         => '07',
    day         => '30',
    tag         => '952',
    subfield    => 'p',
    loctag      => '952',
    locsubfield => 'a'
);

my ($nextnum, $scr) = C4::Barcodes::ValueBuilder::incremental::get_barcode(\%args);
is($nextnum, 33333074344564, 'incremental barcode');
is($scr, undef, 'incremental javascript');

($nextnum, $scr) = C4::Barcodes::ValueBuilder::hbyymmincr::get_barcode(\%args);
is($nextnum, '12070891', 'hbyymmincr barcode');
ok(length($scr) > 0, 'hbyymmincr javascript');

($nextnum, $scr) = C4::Barcodes::ValueBuilder::annual::get_barcode(\%args);
is($nextnum, '2012-0035', 'annual barcode');
is($scr, undef, 'annual javascript');
