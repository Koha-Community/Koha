#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 73;
use Test::Warn;

$| = 1;

BEGIN {
    use FindBin;
    use lib $FindBin::Bin;
    use_ok('C4::Barcodes');
}

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
        warning_like { $obj1 = C4::Barcodes->new($_); }
                     [ qr/No existing hbyymmincr barcodes found\.  Reverting to initial value\./ ],
                     "$pre Expected complaint regarding no hbyymmincr barcodes found";
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
        ok($initial= $obj1->initial(),              "$pre initial()        : " . ($initial|| 'FAILED') );
        if ($_ eq 'hbyymmincr') {
            warning_like { $temp = $obj1->db_max(); }
                         [ qr/No existing hbyymmincr barcodes found\.  Reverting to initial value\./ ],
                         "$pre Expected complaint regarding no hbyymmincr barcodes found";
        }
        else {
            $temp = $obj1->db_max();
        }
        ok($temp   = $obj1->max(),                  "$pre max()            : " . ($temp   || 'FAILED') );
        ok($value  = $obj1->value(),                "$pre value()          : " . ($value  || 'FAILED') );
        ok($serial = $obj1->serial(),               "$pre serial()         : " . ($serial || 'FAILED') );
        ok($temp   = $obj1->is_max(),               "$pre obj1->is_max() [obj1 should currently be max]");
        ok($obj2   = $obj1->new(),                  "$pre Barcode Creation : obj2 = obj1->new()");
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
