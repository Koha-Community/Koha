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
use C4::Members qw/ DelMember /;

my $help;
my $confirm;
my $hours = 24;

GetOptions(
    'h|help'    => \$help,
    'c|confirm' => \$confirm,
    't|time=i'  => \$hours,
);
my $usage = << 'ENDUSAGE';

This script removes unconfirmed OPAC based patron registrations
that have not been confirmed within the required time period.

This script has the following parameters :
    -h --help:    This message

    -t --time:    The length in hours to wait before removing an unconfirmed registration.
                  Defaults to 24 hours if not set.

    -c --confirm: Without this flag set, this script will do nothing.
ENDUSAGE

if ( $help || !$confirm ) {
    print $usage;
    exit;
}

my $dbh = C4::Context->dbh;

$dbh->do( "
         DELETE FROM borrower_modifications
         WHERE
             borrowernumber = 0
           AND
             TIME_TO_SEC( TIMEDIFF( NOW(), timestamp )) / 3600 > ?
", undef, $hours );
