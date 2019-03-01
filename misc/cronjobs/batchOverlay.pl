#!/usr/bin/perl

# Copyright 2016 KohaSuomi
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

BEGIN { $ENV{KOHA_INTERFACE} = 'commandline'; };

use Modern::Perl;
use Carp;
use Getopt::Long qw(:config no_ignore_case);

my $help;
my $verbose;
my $rtfm = 'false';
my $chunk = 500;
my $chunks = 1;
my $monthsPast = undef;
my $biblionumbers;

GetOptions(
    'h|help'                      => \$help,
    'v|verbose:i'                 => \$verbose,
    'rtfm:s'                      => \$rtfm,
    'chunk:i'                     => \$chunk,
    'c|chunks:i'                  => \$chunks,
    'm:i'                         => \$monthsPast,
    'b|biblionumber:s@'           => \$biblionumbers,
);

my $usage = <<USAGE;

Automatically BatchOverlays records from configured remote cataloguing record
providers over local biblographic records using the system preference
'BatchOverlayRules'.
A report of the operation is saved in '/cgi-bin/koha/cataloguing/batchOverlay.pl'
More verbose help about the feature can be found from the aforementioned page's
help.

It is advised to test first with the syspref's "dry-run"-flag on.

  -h --help             This friendly help!

  -v --verbose          Set the log level to one of the Log4perl log levels
                            FATAL|ERROR|TRACE|...
                        or use a signed integer to adjust the verbosity
                            -1 decrease log verbosity by one level
                            +1 increase log verbosity by one level

  --chunk               Size of the single overlaying operation in bibliographic
                        records. This is essentially the size of the reports
                        container shown in the reports-page in the staff client.
                        So don't set this value too high or the browsers might
                        have trouble loading the reports.
                        Defaults to 1000

  -c --chunks           How many chunks to overlay?
                        Defaults to 1.
                        999999999 should be enough to cover the whole DB.

  --rtfm                Defaults to false. Set this to "true", to confirm that
                        you have read the manual and understand the consequences
                        of your actions. This feature, if misconfigured has the
                        potential to destroy your whole bibliographic records
                        database, so it is advised to test all configurations
                        first using the "dry-run"-flag in the syspref.

  -m                    How many months to look behind while looking for lowly
                        catalogued records? Defaults to finding all lowly
                        catalogued records.

  -b --biblionumber     Repeatable list of biblionumbers. If you want to
                        batchOverlay only the specific biblios for testing
                        purposes, use this.

EXAMPLE

    batchOverlay.pl -m 6 -c 1 --chunk 500 -v 4

    batchOverlay.pl -b 545433 -b 406554 -v TRACE

USAGE

if ($help || $rtfm ne "true") {
    print $usage;
    exit 0;
}


use C4::BatchOverlay;

use Koha::Logger;
Koha::Logger->setVerbosity($verbose);

my $batchOverlayer = C4::BatchOverlay->new();

if ($biblionumbers) {
    for (my $i=0 ; $i<@$biblionumbers ; $i++) {
        $biblionumbers->[$i] = 'biblionumber='.$biblionumbers->[$i];
    }
    $batchOverlayer->overlay($biblionumbers, undef);
}
else {
    $batchOverlayer->batchOverlay({chunk => $chunk, chunks => $chunks, monthsPast => $monthsPast});
}
