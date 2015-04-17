#!/usr/bin/perl
#
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
#
# for context, see http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=2691

use strict;
use warnings;

use Test::More;

BEGIN {
    our $ddcns = {};
    if ($ARGV[0]) {
        BAIL_OUT("USAGE: perl Labels_split_ddcn.t '621.3828 J28l' '621.3828,J28l'") unless $ARGV[1];
        $ddcns = {$ARGV[0] => [split (/,/,$ARGV[1])],};
    }
    else {
        $ddcns = {
            'R220.3 H2793Z H32 c.2' => [qw(R 220.3 H2793Z H32 c.2)],
            'CD-ROM 787.87 EAS'     => [qw(CD-ROM 787.87 EAS)],
            '252.051 T147 v.1-2'    => [qw(252.051 T147 v.1-2)],
        };
    }
    my $test_num = 1;
    foreach (keys(%$ddcns)) {
        my $split_num += scalar(@{$ddcns->{$_}});
        $test_num += 2 * $split_num;
        $test_num += 4;
    }
    plan tests => $test_num;
    use_ok('C4::Labels::Label');
    use vars qw($ddcns);
}

foreach my $ddcn (sort keys %$ddcns) {
    my (@parts, @expected);
    ok($ddcn, "ddcn: $ddcn");
    ok(@expected = @{$ddcns->{$ddcn}}, "split expected to produce " . scalar(@expected) . " pieces");
    ok(@parts = C4::Labels::Label::_split_ddcn($ddcn), "C4::Labels::Label::_split_ddcn($ddcn)");
    ok(scalar(@expected) == scalar(@parts), sprintf("%d of %d pieces produced", scalar(@parts), scalar(@expected)));
    my $i = 0;
    foreach my $unit (@expected) {
        my $part;
        ok($part = $parts[$i], "($ddcn)[$i] populated: " . (defined($part) ? $part : 'UNDEF'));
        ok((defined($part) and $part eq $unit),     "($ddcn)[$i]   matches: $unit");
        $i++;
    }
}
