#!/usr/bin/perl

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

use Test::More tests => 2;

foreach my $record_type ( qw( biblios authorities ) ) {

    subtest "bib1.att tests for $record_type" => sub {

        my $bib1_att = "etc/zebradb/$record_type/etc/bib1.att";

        my $att_codes = {};

        open my $fh, '<', $bib1_att or die "Cannot open file $bib1_att: $!\n";

        while (<$fh>) {

            chomp;

            if ( $_ =~ m/^att\s(?<code>\d+)/ ) {
                $att_codes->{ $+{code} }++;
            }
        }

        foreach my $code (keys %{$att_codes}) {
            is( $att_codes->{$code}, 1, "Only one occurrence for code ($code)" );
        }
    };
}

1;
