#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 91;
BEGIN {
	use_ok('C4::Dates', qw(format_date format_date_in_iso));
}

my %thash = (
	  iso  => ['2001-01-01','1989-09-21'],
	metric => ["01-01-2001",'21-09-1989'],
	   us  => ["01-01-2001",'09-21-1989'],
	  sql  => ['20010101    010101',
	  		   '19890921    143907'     ],
);

my ($date, $format, $today, $today0, $val, $re, $syspref);
my @formats = sort keys %thash;
diag "\n Testing Legacy Functions: format_date and format_date_in_iso";
ok($syspref = C4::Dates->new->format(),         "Your system preference is: $syspref");
print "\n";
foreach (@{$thash{'iso'}}) {
	ok($val = format_date($_),                  "format_date('$_'): $val"            );
}
foreach (@{$thash{$syspref}}) {
	ok($val = format_date_in_iso($_),           "format_date_in_iso('$_'): $val"     );
}
ok($today0 = C4::Dates->today(),                "(default) CLASS ->today : $today0" );
diag "\nTesting " . scalar(@formats) . " formats.\nTesting no input (defaults):\n";
print "\n";
foreach (@formats) {
	my $pre = sprintf '(%-6s)', $_;
	ok($date = C4::Dates->new(),                "$pre Date Creation   : new()");
	ok($_ eq ($format = $date->format($_)),     "$pre format($_)      : $format" );
	ok($format = $date->visual(),  				"$pre visual()        : $format" );
	ok($today  = $date->output(),               "$pre output()        : $today" );
	ok($today  = $date->today(),                "$pre object->today   : $today" );
	print "\n";
}

diag "\nTesting with inputs:\n";
foreach $format (@formats) {
	my $pre = sprintf '(%-6s)', $format;
  foreach my $testval (@{$thash{ $format }}) {
	ok($date = C4::Dates->new($testval,$format),      "$pre Date Creation   : new('$testval','$format')");
	ok($re   = $date->regexp,                   "$pre has regexp()" );
	ok($val  = $date->output(),                 "$pre output()        : $val" );
	foreach (grep {!/$format/} @formats) {
		ok($today = $date->output($_),          "$pre output(" . sprintf("%8s","'$_'") . "): $today");
	}
	ok($today  = $date->today(),                "$pre object->today   : $today" );
	# ok($today == ($today = C4::Dates->today()), "$pre CLASS ->today   : $today" );
	ok($val  = $date->output(),                 "$pre output()        : $val" );
	# ok($format eq ($format = $date->format()),  "$pre format()        : $format" );
	print "\n";
  }
}

diag "done.\n";
