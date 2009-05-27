#!/usr/bin/perl
#
# for context, see http://bugs.koha.org

use strict;
use warnings;

<<<<<<< HEAD:t/Labels_split_ddcn.t
use Test::More tests => 62;
=======
use Test::More tests => 82;
>>>>>>> e72a02e... Bug 2500 Tweaking DDCN Split for Hyphenated Volumn Numbers:t/Labels_split_ddcn.t

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
    '252.051 T147 v.1-2'    => [qw(252.051 T147 v.1-2)],
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

