#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 7;
use Test::MockModule;
use t::lib::TestBuilder;

use Koha::Database;

BEGIN {
    use_ok('C4::Barcodes::ValueBuilder');
};

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

my $dbh = C4::Context->dbh;
$dbh->do(q|DELETE FROM issues|);
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

$schema->storage->txn_rollback;

1;
