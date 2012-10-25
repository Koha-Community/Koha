#!/usr/bin/perl

# Copyright 2009-2010 Kyle Hall
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
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

GetOptions(
    'h|help'    => \$help,
    'c|confirm' => \$confirm,
);
my $usage = << 'ENDUSAGE';

This script remove confirmed OPAC based patron registrations
that have not been changed from the patron category specified
in the system preference PatronSelfRegistrationDefaultCategory
within the required time period.

This script has the following parameters :
    -h --help:    This message

    -c --confirm: Without this flag set, this script will do nothing.
ENDUSAGE

if ( $help || !$confirm ) {
    print $usage;
    exit;
}

## Delete accounts that haven't been upgraded from the 'temporary' category code'
my $delay =
  C4::Context->preference('PatronSelfRegistrationExpireTemporaryAccountsDelay');
my $category_code =
  C4::Context->preference('PatronSelfRegistrationDefaultCategory');

my $query = "
    SELECT borrowernumber
    FROM borrowers
    WHERE
        categorycode = ?
      AND
        DATEDIFF( DATE( NOW() ), DATE(dateenrolled) ) = ? )
";

my $dbh = C4::Context->dbh;
my $sth = $dbh->prepare($query);
$sth->execute( $category_code, $delay );

while ( my ($borrowernumber) = $sth->fetchrow_array() ) {
    DelMember($borrowernumber);
}
