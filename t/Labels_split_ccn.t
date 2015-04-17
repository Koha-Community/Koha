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
    our $ccns = {};
    if ($ARGV[0]) {
        BAIL_OUT("USAGE: perl Labels_split_ccn.t 'BIO JP2 R5c.1' 'BIO,JP2,R5c.1'") unless $ARGV[1];
        $ccns = {$ARGV[0] => [split (/,/,$ARGV[1])],};
    }
    else {
        $ccns = {
            'BIO JP2 R5c.1'         => [qw(BIO JP2 R5 c.1)],
            'FIC GIR J5c.1'         => [qw(FIC GIR J5 c.1)],
            'J DAR G7c.11'          => [qw( J  DAR G7 c.11)],
            'MP3-CD F PARKER'       => [qw(MP3-CD F PARKER)],
        };
    }
    my $test_num = 1;
    foreach (keys(%$ccns)) {
        my $split_num += scalar(@{$ccns->{$_}});
        $test_num += 2 * $split_num;
        $test_num += 4;
    }
    plan tests => $test_num;
    use_ok('C4::Labels::Label');
    use vars qw($ccns);
}

foreach my $ccn (sort keys %$ccns) {
    my (@parts, @expected);
    ok($ccn, "ddcn: $ccn");
    ok(@expected = @{$ccns->{$ccn}}, "split expected to produce " . scalar(@expected) . " pieces");
    ok(@parts = C4::Labels::Label::_split_ccn($ccn), "C4::Labels::Label::_split_ccn($ccn)");
    ok(scalar(@expected) == scalar(@parts), sprintf("%d of %d pieces produced", scalar(@parts), scalar(@expected)));
    my $i = 0;
    foreach my $unit (@expected) {
        my $part;
        ok($part = $parts[$i], "($ccn)[$i] populated: " . (defined($part) ? $part : 'UNDEF'));
        ok((defined($part) and $part eq $unit),     "($ccn)[$i]   matches: $unit");
        $i++;
    }
}
