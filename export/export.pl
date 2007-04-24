#!/usr/bin/perl

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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

## This script allows you to export a rel_2_2 bibliographic db in
#MARC21 format from the command line.
#

use strict;
require Exporter;
use C4::Auth;
use C4::Output;    # contains gettemplate
use C4::Biblio;
use CGI;
use C4::Auth;

my $outfile = $ARGV[0];
open( OUT, ">$outfile" ) or die $!;
my $query                = new CGI;
my $StartingBiblionumber = $query->param("StartingBiblionumber");
my $EndingBiblionumber   = $query->param("EndingBiblionumber");
my $dbh                  = C4::Context->dbh;
my $sth;

if ( $StartingBiblionumber && $EndingBiblionumber ) {
    my $query =
        "SELECT biblionumber
         FROM   biblioitems
         WHERE  biblionumber >=?
          AND   biblionumber <=? 
         ORDER BY biblionumber
        ";
    $sth = $dbh->prepare($query);
    $sth->execute( $StartingBiblionumber, $EndingBiblionumber );
} else {
    my $query = "
        SELECT biblionumber
        FROM   biblioitems
        ORDER BY biblionumber
    ";
    $sth = $dbh->prepare($query);
    $sth->execute;
}
binmode(OUT, 'utf8');
my $i = 0;
while ( my ($biblionumber) = $sth->fetchrow ) {
    my $record = GetMarcBiblio($biblionumber);
    print $i++ . "\n";

    print OUT $record->as_usmarc();
}

close(OUT);
