#!/usr/bin/perl
# migrate koha-biblios to MARCbiblios

package C4::test;

# Copyright 2000-2002 Katipo Communications
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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
require Exporter;
use C4::Context("/etc/koha.conf.tmpXX");
use C4::Catalogue;
use C4::Biblio;
use MARC::Record;
use MARC::File::USMARC;

#die;
my $dbh = C4::Context->dbh;
my $sth = $dbh->prepare("select * from systempreferences");
$sth->execute;
print "connecté\n";
die;
$dbh->do("delete from marc_biblio");
$dbh->do("delete from marc_blob_subfield");
$dbh->do("delete from marc_subfield_table");
$dbh->do("delete from marc_word");
my $sth=$dbh->prepare("select * from biblio left join biblioitems on biblioitems.biblionumber=biblio.biblionumber order by biblio.biblionumber");
my ($row,$row2);
my $sth2 = $dbh->prepare("select count(*) from biblio");
$sth2->execute;
my ($total) = $sth2->fetchrow_array;
my $rest = $total;
$sth->execute;
my $i=0;
while ($row=$sth->fetchrow_hashref) {
    $i++;
    $rest--;
    if ($i>99) {
	$i=0;
	print "$rest / $total\n";
    }
    my $MARCbiblio = MARCkoha2marcBiblio($dbh,$row->{biblionumber},$row->{biblioitemnumber});
    &MARCaddbiblio($dbh,$MARCbiblio,$row->{biblionumber});
    my $sth_item = $dbh->prepare("select * from items where biblionumber=? and biblioitemnumber=?");
    $sth_item->execute($row->{biblionumber},$row->{biblioitemnumber});
    while ($row2=$sth_item->fetchrow_hashref) {
	my $MARCitem = &MARCkoha2marcItem($dbh,$row2->{biblionumber},$row2->{itemnumber});
	&MARCadditem($dbh,$MARCitem,$row2->{biblionumber});
    }
}


