#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 10;
use Test::MockModule;

BEGIN {
    use_ok('C4::Barcodes::ValueBuilder');
}

use Test::DBIx::Class {
    schema_class => 'Koha::Schema',
    connect_info => ['dbi:SQLite:dbname=:memory:','',''],
    connect_opts => { name_sep => '.', quote_char => '`', },
    fixture_class => '::Populate',
}, 'Biblio' ;

sub fixtures {
    my ( $data ) = @_;
    fixtures_ok [
        Item => [
            @$data
        ],
    ], 'add fixtures';
}

my $db = Test::MockModule->new('Koha::Database');
$db->mock(
    _new_schema => sub { return Schema(); }
);


my %args = (
    year        => '2012',
    mon         => '07',
    day         => '30',
    tag         => '952',
    subfield    => 'p',
    loctag      => '952',
    locsubfield => 'a'
);

fixtures([
    [ qw/ itemnumber barcode / ],
    [ 1, 33333074344563 ]
]);
my ($nextnum, $scr) = C4::Barcodes::ValueBuilder::incremental::get_barcode(\%args);
is($nextnum, 33333074344564, 'incremental barcode');
is($scr, undef, 'incremental javascript');

fixtures([
    ['barcode'],
    ['890'],
]);

($nextnum, $scr) = C4::Barcodes::ValueBuilder::hbyymmincr::get_barcode(\%args);
is($nextnum, '12070891', 'hbyymmincr barcode');
ok(length($scr) > 0, 'hbyymmincr javascript');

fixtures([
    ['barcode'],
    #max(cast( substring_index(barcode, \'-\',-1) as signed))'],
    ['34'],
]);

($nextnum, $scr) = C4::Barcodes::ValueBuilder::annual::get_barcode(\%args);
is($nextnum, '2012-0035', 'annual barcode');
is($scr, undef, 'annual javascript');
