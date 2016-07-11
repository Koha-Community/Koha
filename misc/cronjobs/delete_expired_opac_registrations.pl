#!/usr/bin/perl

# Copyright 2009-2010 Kyle Hall
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
use Getopt::Long;

BEGIN {

    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { my $lib = "$FindBin::Bin/../kohalib.pl"; require $lib };
}

use C4::Context;

my $help;
my $confirm;
my $verbose;

GetOptions(
    'h|help'    => \$help,
    'c|confirm' => \$confirm,
    'v|verbose' => \$verbose,
);
my $usage = << 'ENDUSAGE';

IMPORTANT: You should no longer call this script. Please use
cleanup_database.pl with parameter --del-exp-selfreg.

This script removes confirmed OPAC based patron registrations
that have not been changed from the patron category specified
in the system preference PatronSelfRegistrationDefaultCategory
within the required time period.

NOTE: If you do not use self registration, do NOT run this script.
If you use self registration, but you do not use a temporary
category for new registrations, do NOT run this script too.

This script has the following parameters :
    -c --confirm: Without this flag set, this script will do nothing.
    -h --help:    Print this message.
    -v --verbose: Print number of removed patrons.

ENDUSAGE

if ( $help || !$confirm ) {
    print $usage;
    exit;
}

my $c= "$FindBin::Bin/cleanup_database.pl --del-exp-selfreg";
$c.= " -v" if $verbose;
system($c);
