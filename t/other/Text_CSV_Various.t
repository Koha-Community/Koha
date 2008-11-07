#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 25;
BEGIN {
    diag "
This test demonstrates why Koha uses the CSV parser and configration it does.
Specifically, the test is for Unicode compliance in text parsing and data.
This test requires other modules that Koha doesn't actually use, in order to compare.
Therefore, running this test is not necessary to test your Koha installation.

";
	use FindBin;
	use lib $FindBin::Bin;
	use_ok('Text::CSV');
	use_ok('Text::CSV_XS');
	use_ok('Text::CSV::Unicode');
}

sub pretty_line {
	my $max = 54;
	(@_) or return "#" x $max . "\n";
	my $phrase = "  " . shift() . "  ";
	my $half = "#" x (($max - length($phrase))/2);
	return $half . $phrase . $half . "\n";
}

my ($csv, $bin, %parsers);

foreach(qw(Text::CSV Text::CSV_XS Text::CSV::Unicode)) {
    ok($csv = $_->new(),            $_ . '->new()');
    ok($bin = $_->new({binary=>1}), $_ . '->new({binary=>1})');
    $csv and $parsers{$_} = $csv;
    $bin and $parsers{$_ . " (binary)"} = $bin;
}

my $lines = [
    {description=>"010D: LATIN SMALL LETTER C WITH CARON",     character=>'č', line=>'field1,second field,field3,do_we_have_a_č_problem?, f!fth field ,lastfield'},
    {description=>"0117: LATIN SMALL LETTER E WITH DOT ABOVE", character=>'ė', line=>'field1,second field,field3,do_we_have_a_ė_problem?, f!fth field ,lastfield'},
];
# 010D: č LATIN SMALL LETTER C WITH CARON
# 0117: ė LATIN SMALL LETTER E WITH DOT ABOVE
diag sprintf "Testing %d lines with  %d parsers.", scalar(@$lines), scalar(keys %parsers);
foreach my $key (sort keys %parsers) {
    my $parser = $parsers{$key};
    print "Testing parser $key version " . ($parser->version||'?') . "\n";
}
my $i = 0;
LINE: foreach (@$lines) {
    print pretty_line("Line " . ++$i);
    print pretty_line($_->{description} . ': ' . $_->{character});
    foreach my $key (sort keys %parsers) {
        my $parser = $parsers{$key};
        my ($status,$count,@fields);
        ok($status = $parser->parse($_->{line}), "parse ($key)");
        if ($status) {
            @fields = $parser->fields;
            ok(($count = scalar(@fields)) == 6, "Number of fields ($count of 6)");
            my $j = 0;
            foreach my $f (@fields) {
                print "\t field " . ++$j . ": $f\n";
            }
        }
    }
}
diag "done.\n";
