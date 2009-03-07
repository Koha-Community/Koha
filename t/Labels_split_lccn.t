#!/usr/bin/perl
#
# for context, see http://bugs.koha.org/cgi-bin/bugzilla/show_bug.cgi?id=2691

use strict;
use warnings;

use Test::More tests => 44;

BEGIN {
    use_ok('C4::Labels');
}
ok(defined C4::Labels::split_lccn, 'C4::Labels::split_lccn defined');

my $lccns = {
    'HE8700.7 .P6T44 1983' => [qw(HE 8700.7 .P6 T44 1983)],
    'BS2545.E8 H39 1996'   => [qw(BS 2545 .E8 H39 1996)],
    'NX512.S85 A4 2006'    => [qw(NX 512 .S85 A4 2006)],
};

foreach my $lccn (sort keys %$lccns) {
    my (@parts, @expected);
    ok($lccn, "lccn: $lccn");
    ok(@expected = @{$lccns->{$lccn}}, "split expected to produce " . scalar(@expected) . " pieces");
    ok(@parts = C4::Labels::split_lccn($lccn), "C4::Labels::split_lccn($lccn)");
    ok(scalar(@expected) == scalar(@parts), sprintf("%d of %d pieces produced", scalar(@parts), scalar(@expected)));
    my $i = 0;
    foreach my $unit (@expected) {
        my $part;
        ok($part = $parts[$i], "($lccn)[$i] populated: " . (defined($part) ? $part : 'UNDEF'));
        ok((defined($part) and $part eq $unit),     "($lccn)[$i]   matches: $unit");
        $i++;
    }
}

