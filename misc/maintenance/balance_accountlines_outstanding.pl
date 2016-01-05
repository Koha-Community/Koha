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

use Modern::Perl;

use open qw( :std :encoding(UTF-8) );
binmode( STDOUT, ":encoding(UTF-8)" );

use C4::Accounts;

use Getopt::Long qw(:config no_ignore_case);

my ($help, $verbose, $borrowernumber, $rtfm, $dryRun);

GetOptions(
    'h|help'             => \$help,
    'v|verbose'          => \$verbose,
    'b|borrowernumber:i' => \$borrowernumber,
    'd|dry'              => \$dryRun,
    'rtfm'               => \$rtfm,
);

my $usage = << 'ENDUSAGE';

This script finds all negative outstanding payments (debit), and encumbers the
"positive" debit to close the outstanding payments.
this is to fix a bug in Koha where deposits don't auto-encumber existing payments
and vice versa.

This script has the following parameters :
    -h --help         This help.

    -v --verbose      More verbose output

    -b --borrowernumber Only fix the accountlines of this borrower.
                      Useful for testing.

    -d --dry          Dry-run, report results but write nothing to DB.

    --rtfm            Acknowledge that you have read this manual description and
                      understand what you are doing (and have read the code)!
                      This script can potentially screw up your borrowers
                      accountlines information in a very nasty way, so test beforehand
                      with the --borrowernumber -flag to see that this script still works!

Examples:

perl balance_accountlines_outstanding.pl --verbose --borrowernumber 12123
perl balance_accountlines_outstanding.pl --dry

ENDUSAGE

if ($help) {
    print $usage;
    exit;
}
if (not($rtfm)) {
    print $usage;
    print "\nRTFM!\n";
    exit 1;
}

C4::Accounts::depleteDebits($borrowernumber, $verbose, $dryRun);
