#!/bin/perl

use Test::More tests => 82;
BEGIN {
		use_ok('C4::Dates');
}

my %thash = (
	  iso  => ['2001-01-01','1989-09-21'],
	metric => ["01-01-2001",'21-09-1989'],
	   us  => ["01-01-2001",'09-21-1989'],
	  sql  => ['20010101    010101',
	  		   '19890921    143907'     ],
);

my @formats = sort keys %thash;
diag "\nNote: CGI::Carp may throw an initial error here.  Ignore that.\n";
diag "Testing " . scalar(@formats) . " formats.\nTesting no input:\n";
my ($today, $today0, $val, $re);
ok($today0 = C4::Dates->today(),                "(default) CLASS ->today : $today0" );
foreach (@formats) {
	my $pre = sprintf '(%-6s)', $_;
	ok($date = C4::Dates->new(),                "$pre Date Creation   : new()");
	ok($_ eq ($format = $date->format($_)),     "$pre format($_)      : $format" );
	ok($today  = $date->output(),               "$pre output()        : $today" );
	ok($today  = $date->today(),                "$pre object->today   : $today" );
	print "\n";
}

foreach my $format (@formats) {
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
