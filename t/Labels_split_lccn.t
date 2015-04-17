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
    our $lccns = {};
    if ($ARGV[0]) {
        BAIL_OUT("USAGE: perl Labels_split_lccn.t 'HE 8700.7 .P6 T44 1983' 'HE,8700.7,.P6,T44,1983'") unless $ARGV[1];
        $lccns = {$ARGV[0] => [split (/,/,$ARGV[1])],};
    }
    else {
        $lccns = {
            'HE8700.7 .P6T44 1983' => [qw(HE 8700.7 .P6 T44 1983)],
            'BS2545.E8 H39 1996'   => [qw(BS 2545 .E8 H39 1996)],
            'NX512.S85 A4 2006'    => [qw(NX 512 .S85 A4 2006)],
            'QH541.15.C6 C25 2012' => [qw(QH 541.15 .C6 C25 2012)],
            '123 ABC FOO BAR'      => [qw(123 ABC FOO BAR)],
        };
    }
    my $test_num = 1;
    foreach (keys(%$lccns)) {
        my $split_num += scalar(@{$lccns->{$_}});
        $test_num += 2 * $split_num;
        $test_num += 4;
    }
    plan tests => $test_num;
    use_ok('C4::Labels::Label');
    use vars qw($lccns);
}

foreach my $lccn (sort keys %$lccns) {
    my (@parts, @expected);
    ok($lccn, "lccn: $lccn");
    ok(@expected = @{$lccns->{$lccn}}, "split expected to produce " . scalar(@expected) . " pieces");
    ok(@parts = C4::Labels::Label::_split_lccn($lccn), "C4::Labels::Label::_split_lccn($lccn)");
    ok(scalar(@expected) == scalar(@parts), sprintf("%d of %d pieces produced", scalar(@parts), scalar(@expected)));
    my $i = 0;
    foreach my $unit (@expected) {
        my $part;
        ok($part = $parts[$i], "($lccn)[$i] populated: " . (defined($part) ? $part : 'UNDEF'));
        ok((defined($part) and $part eq $unit),     "($lccn)[$i]   matches: $unit");
        $i++;
    }
}

