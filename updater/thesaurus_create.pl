#!/usr/bin/perl


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
# This script generates and fill the thesaurus table
# with the data in bibliothesaurus

use C4::Context;
use C4::Catalogue;
use DBI;
use C4::Acquisitions;
use C4::Output;

my $dbh = C4::Context->dbh;

sub dosql {
	my ($dbh,$sql_cmd)=@_;
	my $sti=$dbh->prepare($sql_cmd);
	$sti->execute;
	if ($sti->err) {
		print "error : ".$sti->errstr." \n tried to execute : $sql_cmd\n";
		$sti->finish;
	}
}

my $sth=$dbh->prepare("show tables");
$sth->execute;
my %tables;
while (my ($table) = $sth->fetchrow) {
    $tables{$table}=1;
#    print "table $table\n";
}

print "creating thesaurus...\n";
dosql($dbh,"CREATE TABLE bibliothesaurus (code BIGINT not null AUTO_INCREMENT, freelib CHAR (255) not null , stdlib CHAR (255) not null , type CHAR (80) not null , PRIMARY KEY (code), INDEX (freelib),index(stdlib),index(type))");
	my $sti=$dbh->prepare("select count(*) as tot from bibliosubject");
	$sti->execute;
	my $total = $sti->fetchrow_hashref;
	# FIXME - There's already a $sti in this scope.
	my $sti=$dbh->prepare("select subject from bibliosubject");
	$sti->execute;
	my $i;
	while (my $line =$sti->fetchrow_hashref) {
		$i++;
		if ($i % 1000==0) {
			print "$i / $total->{'tot'}\n";
		}
#		print "$i $line->{'subject'}\n";
		my $sti2=$dbh->prepare("select count(*) as t from bibliothesaurus where freelib=".$dbh->quote($line->{'subject'}));
		$sti2->execute;
		if ($sti2->err) {
			print "error : ".$sti2->errstr."\n";
			die;
		}
		my $line2=$sti2->fetchrow_hashref;
		if ($line2->{'t'} ==0) {
			dosql($dbh,"insert into bibliothesaurus (freelib,stdlib) values (".$dbh->quote($line->{'subject'}).",".$dbh->quote($line->{'subject'}).")");
#		} else {
#			print "pas ecriture pour : $line->{'subject'}\n";
		}

	}

