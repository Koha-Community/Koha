#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 126;
BEGIN {
	use FindBin;
	use lib $FindBin::Bin;
	use_ok('C4::Barcodes');
}

my %thash = (
	incremental => [],
	annual => [],
	hbyymmincr => ['MAIN'],
);

print "\n";
my ($obj1,$obj2,$format,$value,$initial,$serial,$re,$next,$previous,$temp);
my @formats = sort keys %thash;
foreach (@formats) {
	my $pre = sprintf '(%-12s)', $_;
	ok($obj1 = C4::Barcodes->new($_),           "$pre Barcode Creation : new($_)");
	ok($_ eq ($format = $obj1->autoBarcode()),  "$pre autoBarcode()    : " . ($format || 'FAILED') );
	ok($initial= $obj1->initial(),              "$pre initial()        : " . ($initial|| 'FAILED') );
	ok($temp   = $obj1->db_max(),               "$pre db_max()         : " . ($temp   || 'Database Empty or No Matches') );
	ok($temp   = $obj1->max(),                  "$pre max()            : " . ($temp   || 'FAILED') );
	ok($value  = $obj1->value(),                "$pre value()          : " . ($value  || 'FAILED') );
	ok($serial = $obj1->serial(),               "$pre serial()         : " . ($serial || 'FAILED') );
	ok($temp   = $obj1->is_max(),               "$pre obj1->is_max() [obj1 should currently be max]");
	diag "Creating new Barcodes object (obj2) based on the old one (obj1)\n";
	ok($obj2   = $obj1->new(),                  "$pre Barcode Creation : obj2 = obj1->new()");
	diag "$pre obj2->value: " . $obj2->value . "\n";
	ok(not($obj1->is_max()),                    "$pre obj1->is_max() [obj1 should no longer be max]");
	ok(    $obj2->is_max(),                     "$pre obj2->is_max() [obj2 should currently be max]");
	ok($obj2->serial == $obj1->serial + 1,      "$pre obj2->serial()   : " . ($obj2->serial || 'FAILED'));
	ok($previous = $obj2->previous(),           "$pre obj2->previous() : " . ($previous     || 'FAILED'));
	ok($next     = $obj1->next(),               "$pre obj1->next()     : " . ($next         || 'FAILED'));
	ok($next->previous()->value() eq $obj1->value(),  "$pre Roundtrip, value : " . ($obj1->value || 'FAILED'));
	ok($previous->next()->value() eq $obj2->value(),  "$pre Roundtrip, value : " . ($obj2->value || 'FAILED'));
	print "\n";
}

diag "\nTesting with valid inputs:\n";
foreach $format (@formats) {
	my $pre = sprintf '(%-12s)', $format;
  foreach my $testval (@{$thash{ $format }}) {
	ok($obj1 = C4::Barcodes->new($format,$testval),    "$pre Barcode Creation : new('$format','$testval')");
	if ($format eq 'hbyymmincr') {
		diag "\nExtra tests for hbyymmincr\n";
		$obj2 = $obj1->new();
		my $branch;
		ok($branch = $obj1->branch(),   "$pre branch() : " . ($branch || 'FAILED') );
		ok($branch eq $obj2->branch(),  "$pre branch extended to derived object : " . ($obj2->branch || 'FAILED'));
	}
	print "\n";
  }
}

diag "done.\n";
