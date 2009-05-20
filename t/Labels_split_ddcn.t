#!/usr/bin/perl
#
# for context, see http://bugs.koha.org

use strict;
use warnings;

use Test::More tests => 72;

BEGIN {
    use_ok('C4::Labels');
}
ok(defined C4::Labels::split_ddcn, 'C4::Labels::split_ddcn defined');

my $ddcns = {
    'BIO JP2 R5c.1'         => [qw(BIO JP2 R5 c.1 )],
    'FIC GIR J5c.1'         => [qw(FIC GIR J5 c.1 )],
    'J DAR G7c.11'          => [qw( J  DAR G7 c.11)],
    'R220.3 H2793Z H32 c.2' => [qw(R 220.3 H2793Z H32 c.2)],
    'CD-ROM 787.87 EAS'     => [qw(CD-ROM 787.87 EAS)],
    'MP3-CD F PARKER'       => [qw(MP3-CD F PARKER)],
};

foreach my $ddcn (sort keys %$ddcns) {
    my (@parts, @expected);
    ok($ddcn, "ddcn: $ddcn");
    ok(@expected = @{$ddcns->{$ddcn}}, "split expected to produce " . scalar(@expected) . " pieces");
    ok(@parts = C4::Labels::split_ddcn($ddcn), "C4::Labels::split_ddcn($ddcn)");
    ok(scalar(@expected) == scalar(@parts), sprintf("%d of %d pieces produced", scalar(@parts), scalar(@expected)));
    my $i = 0;
    foreach my $unit (@expected) {
        my $part;
        ok($part = $parts[$i], "($ddcn)[$i] populated: " . (defined($part) ? $part : 'UNDEF'));
        ok((defined($part) and $part eq $unit),     "($ddcn)[$i]   matches: $unit");
        $i++;
    }
}

