#!/usr/bin/perl

# Copyright 2011, ByWater Solutions.
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

BEGIN {

    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

use Koha::Script -cron;
use C4::Context;
use Koha::Patrons;
use Getopt::Long;

sub usage {
    print STDERR <<USAGE;
Usage: $0  [-h|--help]
   -c --confirm       required to actually perform the anonymization
   -v --verbose       gives a little more information
   -h --help          prints this help message, and exits, ignoring all
                      other options
USAGE
    exit $_[0];
}

my ( $help, $verbose, $confirm );

GetOptions(
    'h|help'    => \$help,
    'v|verbose' => \$verbose,
    'c|confirm' => \$confirm,
) || usage(1);

if ($help) {
    usage(0);
}

my $AnonymizeLastBorrower = C4::Context->preference("AnonymizeLastBorrower");
my $AnonymousPatron       = C4::Context->preference("AnonymousPatron");

unless ($AnonymizeLastBorrower) {
    print STDERR "Preference 'AnonymizeLastBorrower' must be enabled to anonymize item's last borrower\n\n";
    exit(1);
}

unless ($AnonymousPatron) {
    print STDERR "Preference 'AnonymousPatron' must be enabled to anonymize item's last borrower\n\n";
    exit(1);
}

unless ($confirm) {
    print STDERR "You must use the --confirm flag to run this script.\n";
    print STDERR "Add --confirm to actually perform the anonymization.\n";
    exit(1);
}

my $rows = Koha::Patrons->anonymize_last_borrowers();
$verbose and print int($rows) . " item's last borrowers anonymized.\n";

exit(0);
