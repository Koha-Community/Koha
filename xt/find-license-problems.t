#!/usr/bin/perl
#
# Find copyright and license problems in Koha source files. At this
# time it only looks for references to the old FSF address in GPLv2
# license notices, but it might in the future be extended to look for
# other things, too.
#
# Copyright 2010 Catalyst IT Ltd
# Copyright 2020 Koha Development Team
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use Test::More;
use Test::NoWarnings;

my @files = map {
    chomp;
    my $name = $_;
    !(     $name =~ m{^koha-tmpl/}
        || $name =~ m{\.(gif|jpg|odt|ogg|pdf|png|po|psd|svg|swf|zip)$}
        || $name =~ m{xt/find-license-problems|xt/fix-old-fsf-address|misc/translator/po2json}
        || $name =~ m[t/mock_templates/intranet-tmpl/prog]
        || !-f $name )
    ? $_
        : ()
} `git ls-tree -r HEAD --name-only`;    # only files part of git

plan tests => scalar(@files) + 1;

foreach my $name (@files) {
    open( my $fh, '<', $name ) || die "cannot open file $name $!";
    my (
        $hasgpl,        $hasv3, $hasorlater, $haslinktolicense,
        $hasfranklinst, $is_not_us
    ) = (0) x 7;
    while ( my $line = <$fh> ) {
        $hasgpl     = 1 if ( $line =~ /GNU General Public License/ );
        $hasv3      = 1 if ( $line =~ /either version 3/ );
        $hasorlater = 1
            if ( $line =~ /any later version/
            || $line =~ /at your option/ );
        $haslinktolicense = 1 if $line =~ m|https://www\.gnu\.org/licenses|;
        $hasfranklinst    = 1 if ( $line =~ /51 Franklin Street/ );
        $is_not_us        = 1 if $line =~ m|This file is part of the Zebra server|;
    }
    close $fh;

    if ( $is_not_us || !$hasgpl ) {
        pass();
        next;
    }

    ok( $hasgpl && $hasv3 && $hasorlater && $haslinktolicense && !$hasfranklinst )
        or diag(
        sprintf
            "File %s has wrong copyright: hasgpl=%s, hasv3=%s, hasorlater=%s, haslinktolicense=%s, hasfranklinst=%s",
        $name, $hasgpl, $hasv3, $hasorlater, $haslinktolicense, $hasfranklinst
        );
}
