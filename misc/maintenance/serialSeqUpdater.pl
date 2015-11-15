#!/usr/bin/perl

# Copyright 2015 KohaSuomi
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use open qw( :std :encoding(UTF-8) );
binmode( STDOUT, ":encoding(UTF-8)" );

use Koha::Serials;

use Getopt::Long qw(:config no_ignore_case);

my $help = 0;
my $verbose = 0;
my $regexp;

GetOptions(
    'h|help'           => \$help,
    'v|verbose:i'      => \$verbose,
    's|splitter:s'     => \$regexp,
);

my $usage = << 'ENDUSAGE';

This script updates the koha.serial.pattern_[xyz] -columns by splitting the
koha.serial.serialseq-column using a regexp.
This is used to maintain tricky patterns and fix possible error caused by the Serials module.

This script has the following parameters :
    -h --help         This help.

    -v --verbose      Integer 1, prints warnings.
                              2, prints everything that happens.

    -s --splitter     Regexp This regexp is used to separate the patterns from the serialseq.
                             Is used with the Perl's split()-command.

Examples:

perl serialSeqUpdater.pl --verbose 2 -s ':'

ENDUSAGE

if ($help) {
    print $usage;
    exit;
}
unless ($regexp) {
    print $usage."\n";
    print "You must define a --splitter!\n";
    exit 1;
}

foreach my $serial (Koha::Serials->search->as_list) {
    $serial->update_patterns_xyz({
        verbose => $verbose,
        serialSequenceSplitterRegexp => $regexp
    });
}
