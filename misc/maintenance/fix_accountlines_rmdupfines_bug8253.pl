#!/usr/bin/perl
#
# Copyright (C) 2012 ByWater Solutions
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

use strict;
use warnings;

BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

use C4::Context;
use C4::Installer;
use C4::Dates;

use Getopt::Long;
use Data::Dumper;

sub print_usage {
    print <<_USAGE_
$0: Remove duplicate fines

Due to bug 8253, upgrading from Koha 3.6 to 3.8 may introduce duplicate fines.
This script will remove these duplicate fines. To use, repeatably run this
script until there are no more duplicates in the database.

Parameters:
  --confirm or -c     Confirm you want to run the script.
  --help or -h        Print out this help message.
_USAGE_
}

my $help;
my $confirm;
my $result = GetOptions(
    'confirm|c' => \$confirm,
    'help|h'   => \$help,
);
if ( $help || !$confirm ) {
    print_usage();
    exit 0;
}


my $dbh = C4::Context->dbh;

my $query = "
    SELECT * FROM accountlines
    WHERE ( accounttype =  'FU' OR accounttype =  'F' )
    AND description like '%23:59%'
    ORDER BY borrowernumber, itemnumber, accountno, description
";
my $sth = $dbh->prepare($query);
$sth->execute();
my $results = $sth->fetchall_arrayref( {} );

$query =
"SELECT * FROM accountlines WHERE description LIKE ? AND description NOT LIKE ?";
$sth = $dbh->prepare($query);

my @fines;
foreach my $keeper (@$results) {

    warn "WORKING ON KEEPER: " . Data::Dumper::Dumper( $keeper );
    my ($description_to_match) = split( / 23:59/, $keeper->{'description'} );
    $description_to_match .= '%';

    warn "DESCRIPTION TO MATCH: " . $description_to_match;

    $sth->execute( $description_to_match, $keeper->{'description'} );

    my $has_changed = 0;

    while ( my $f = $sth->fetchrow_hashref() ) {

        warn "DELETING: " . Data::Dumper::Dumper( $f );

        if ( $f->{'amountoutstanding'} < $keeper->{'amountoutstanding'} ) {
            $keeper->{'amountoutstanding'} = $f->{'amountoutstanding'};
            $has_changed = 1;
        }

        my $sql =
            "DELETE FROM accountlines WHERE borrowernumber = ? AND accountno = ? AND itemnumber = ? AND date = ? AND description = ? LIMIT 1";
        $dbh->do( $sql, undef, $f->{'borrowernumber'},
            $f->{'accountno'}, $f->{'itemnumber'}, $f->{'date'},
            $f->{'description'} );
    }

    if ($has_changed) {
        my $sql =
            "UPDATE accountlines SET amountoutstanding = ? WHERE borrowernumber = ? AND accountno = ? AND itemnumber = ? AND date = ? AND description = ? LIMIT 1";
        $dbh->do(
            $sql,                           undef,
            $keeper->{'amountoutstanding'}, $keeper->{'borrowernumber'},
            $keeper->{'accountno'},         $keeper->{'itemnumber'},
            $keeper->{'date'},              $keeper->{'description'}
        );
    }
}

exit;
