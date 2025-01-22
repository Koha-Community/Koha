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

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 6;
use C4::ClassSplitRoutine::RegEx qw( split_callnumber );

my $callnumbers = {
    '830 Han'          => [qw{830 Han}],
    '159.9 (091) Gesh' => [qw{159.9 (091) Gesh}],
    'J 3 Kin =774'     => [ 'J 3', 'Kin', '=774' ],
    '830 Hil =774 4'   => [qw{830 Hil =774 4}],
    '830 Las=20 4'     => [qw{830 Las =20 4}],
};

# Split on spaces and before =
# If starts with J or K then do not split the first 2 groups
my @regexs = ( 's/\s/\n/g', 's/(\s?=)/\n=/g', 's/^(J|K)\n/$1 /' );
foreach my $cn ( sort keys %$callnumbers ) {
    my @parts    = C4::ClassSplitRoutine::RegEx::split_callnumber( $cn, \@regexs );
    my @expected = @{ $callnumbers->{$cn} };
    is_deeply( \@parts, \@expected );
}
