#!/usr/bin/perl

# This file is part of Koha.
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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 75;
use Test::Warn;
use Test::MockModule;
use t::lib::TestBuilder;

use Koha::Database;

$| = 1;

BEGIN {
    use FindBin;
    use lib $FindBin::Bin;
    use_ok('C4::Barcodes');
}

my $builder = t::lib::TestBuilder->new;

my $schema  = Koha::Database->new->schema;

subtest 'Test generation of annual barcodes from DB values' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;
    $builder->schema->resultset( 'Issue' )->delete_all;
    $builder->schema->resultset( 'Item' )->delete_all;

    my $barcodeobj;

    warning_like { $barcodeobj = C4::Barcodes->new('annual'); } [ qr/No max barcode (.*) found\.  Using initial value\./ ], "(annual) Expected complaint regarding no max barcode found";

    my $barcodevalue = $barcodeobj->value();

    my $item_1 = $builder->build({
        source => 'Item',
        value => {
            barcode => $barcodevalue
        }
    });

    is($barcodevalue,$barcodeobj->db_max(), "(annual) First barcode saved to db is equal to db_max" );

    #This is just setting the value ahead an arbitrary amount before adding a second barcode to db
    $barcodevalue = $barcodeobj->next_value();
    $barcodevalue = $barcodeobj->next_value($barcodevalue);
    $barcodevalue = $barcodeobj->next_value($barcodevalue);
    $barcodevalue = $barcodeobj->next_value($barcodevalue);
    $barcodevalue = $barcodeobj->next_value($barcodevalue);

    my $item_2 = $builder->build({
        source => 'Item',
        value => {
            barcode => $barcodevalue
        }
    });

    $barcodeobj = C4::Barcodes->new('annual');

    is($barcodevalue,$barcodeobj->db_max(), '(annual) db_max should equal the greatest barcode in the db when more than 1 present');
    ok($barcodeobj->value() gt $barcodevalue, '(annual) new barcode object should be created with value greater and last value inserted into db');

    $schema->storage->txn_rollback;
};

subtest 'Test generation of hbyymmincr barcodes from DB values' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;
    $builder->schema->resultset( 'Issue' )->delete_all;
    $builder->schema->resultset( 'Item' )->delete_all;

    my $branchcode_1 = "LETTERS"; #NOTE: This barcode type supports only letters in the branchcode
    my $barcodeobj;

    warnings_are { $barcodeobj = C4::Barcodes->new('hbyymmincr'); }
        [  "HBYYMM Barcode created with no branchcode, default is blank",
          "No existing hbyymmincr barcodes found.  Reverting to initial value.",
          "HBYYMM Barcode was not passed a branch, default is blank"]
        , "(hbyymmincr) Expected complaint regarding no max barcode found";


    warning_like { $barcodeobj = C4::Barcodes->new('hbyymmincr',$branchcode_1); }
    [ qr/No existing hbyymmincr barcodes found\.  Reverting to initial value\./],
        "(hbyymmincr) Expected complaint regarding no max barcode found";

    my $barcodevalue = $barcodeobj->value();

    my $item_1 = $builder->build({
        source => 'Item',
        value => {
            barcode => $barcodevalue
        }
    });

    is($barcodevalue,$barcodeobj->db_max(), "(hbyymmincr) First barcode saved to db is equal to db_max" );

    #This is just setting the value ahead an arbitrary amount before adding a second barcode to db
    $barcodevalue = $barcodeobj->next_value();
    $barcodevalue = $barcodeobj->next_value($barcodevalue);
    $barcodevalue = $barcodeobj->next_value($barcodevalue);
    $barcodevalue = $barcodeobj->next_value($barcodevalue);
    $barcodevalue = $barcodeobj->next_value($barcodevalue);

    my $item_2 = $builder->build({
        source => 'Item',
        value => {
            barcode => $barcodevalue
        }
    });

    $barcodeobj = C4::Barcodes->new('hbyymmincr',$branchcode_1);

    is($barcodevalue,$barcodeobj->db_max(), '(hbyymmincr) db_max should equal the greatest barcode in the db when more than 1 present');
    ok($barcodeobj->value() gt $barcodevalue, '(hbyymmincr) new barcode object should be created with value greater and last value inserted into db');

    $schema->storage->txn_rollback;
};


$schema->storage->txn_begin;

$builder->schema->resultset( 'Issue' )->delete_all;
$builder->schema->resultset( 'Item' )->delete_all;

my %thash = (
    incremental => [],
    annual => [],
    hbyymmincr => ['MAIN'],
    EAN13 => ['0000000695152','892685001928'],
);

my ($obj1,$obj2,$format,$value,$initial,$serial,$re,$next,$previous,$temp);
my @formats = sort keys %thash;
foreach (@formats) {
    my $pre = sprintf '(%-12s)', $_;
    if ($_ eq 'EAN13') {
        warning_like { $obj1 = C4::Barcodes->new($_); }
                     [ qr/not valid EAN-13 barcode/ ],
                     "$pre Expected complaint regarding $_ not being a valid EAN-13 barcode";
    }
    elsif ($_ eq 'annual') {
        warning_like { $obj1 = C4::Barcodes->new($_); }
                     [ qr/No max barcode (.*) found\.  Using initial value\./ ],
                     "$pre Expected complaint regarding no max barcode found";
    }
    elsif ($_ eq 'hbyymmincr') {
        warnings_are { $obj1 = C4::Barcodes->new($_); }
        [  "HBYYMM Barcode created with no branchcode, default is blank",
          "No existing hbyymmincr barcodes found.  Reverting to initial value.",
          "HBYYMM Barcode was not passed a branch, default is blank"]
        , "$pre Expected complaint regarding no max barcode found";
    }
    elsif ($_ eq 'incremental') {
        $obj1 = C4::Barcodes->new($_);
    }
    else {
        die "This should not happen! ($_)\n";
    }
    ok($obj1,           "$pre Barcode Creation : new($_)");
    SKIP: {
        skip "No Object Returned by new($_)", 17 unless $obj1;
        ok($_ eq ($format = $obj1->autoBarcode()),  "$pre autoBarcode()    : " . ($format || 'FAILED') );
        if ($_ eq 'hbyymmincr') {
            warning_like { $initial= $obj1->initial(); }
            [ qr/HBYYMM Barcode was not passed a branch, default is blank/ ]
           ,"$pre Expected complaint regarding no branch passed when getting initial\n      $pre initial()        : " . $initial ;
            warnings_are { $temp = $obj1->db_max(); }
       [   "No existing hbyymmincr barcodes found.  Reverting to initial value.",
           "HBYYMM Barcode was not passed a branch, default is blank"]
           ,"$pre Expected complaint regarding no hbyymmincr barcodes found";
        }
        else {
            ok($initial= $obj1->initial(),              "$pre initial()        : " . ($initial|| 'FAILED') );
            $temp = $obj1->db_max();
        }
        ok($temp   = $obj1->max(),                  "$pre max()            : " . ($temp   || 'FAILED') );
        ok($value  = $obj1->value(),                "$pre value()          : " . ($value  || 'FAILED') );
        ok($serial = $obj1->serial(),               "$pre serial()         : " . ($serial || 'FAILED') );
        ok($temp   = $obj1->is_max(),               "$pre obj1->is_max() [obj1 should currently be max]");
        if ($_ eq 'hbyymmincr') {
            warning_like { $obj2   = $obj1->new(); }
            [ qr/HBYYMM Barcode created with no branchcode, default is blank/ ]
           ,"$pre Expected complaint regarding no branch passed when getting initial\n      $pre Barcode Creation : obj2 = obj1->new()" ;
        } else {
            ok($obj2   = $obj1->new(),                  "$pre Barcode Creation : obj2 = obj1->new()");
        }
        ok(not($obj1->is_max()),                    "$pre obj1->is_max() [obj1 should no longer be max]");
        ok(    $obj2->is_max(),                     "$pre obj2->is_max() [obj2 should currently be max]");
        ok($obj2->serial == $obj1->serial + 1,      "$pre obj2->serial()   : " . ($obj2->serial || 'FAILED'));
        ok($previous = $obj2->previous(),           "$pre obj2->previous() : " . ($previous     || 'FAILED'));
        ok($next     = $obj1->next(),               "$pre obj1->next()     : " . ($next         || 'FAILED'));
        ok($next->previous()->value() eq $obj1->value(),  "$pre Roundtrip, value : " . ($obj1->value || 'FAILED'));
        ok($previous->next()->value() eq $obj2->value(),  "$pre Roundtrip, value : " . ($obj2->value || 'FAILED'));
    }
}

foreach $format (@formats) {
    my $pre = sprintf '(%-12s)', $format;
    foreach my $testval (@{$thash{ $format }}) {
        if ($format eq 'hbyymmincr') {
            warning_like { $obj1 = C4::Barcodes->new($format,$testval); }
                         [ qr/No existing hbyymmincr barcodes found\.  Reverting to initial value\./ ],
                         "$pre Expected complaint regarding no hbyymmincr barcodes found";
            ok($obj1,    "$pre Barcode Creation : new('$format','$testval')");
            $obj2 = $obj1->new();
            my $branch;
            ok($branch = $obj1->branch(),   "$pre branch() : " . ($branch || 'FAILED') );
            ok($branch eq $obj2->branch(),  "$pre branch extended to derived object : " . ($obj2->branch || 'FAILED'));
        }
        elsif ($format eq 'EAN13') {
            warning_like { $obj1 = C4::Barcodes->new($format,$testval) }
                         [ qr/not valid EAN-13 barcode/ ],
                         "$pre Expected complaint regarding $testval not being a valid EAN-13 barcode";
            ok($obj1,    "$pre Barcode Creation : new('$format','$testval')");
        }
        else {
            ok($obj1 = C4::Barcodes->new($format,$testval),    "$pre Barcode Creation : new('$format','$testval')");
        }
    }
}

$schema->storage->txn_rollback;
