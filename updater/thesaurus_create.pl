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

#print "creating thesaurus...\n";
#dosql($dbh,"CREATE TABLE bibliothesaurus (code BIGINT not null AUTO_INCREMENT, freelib CHAR (255) not null , stdlib CHAR (255) not null , type CHAR (80) not null , PRIMARY KEY (code), INDEX (freelib),index(stdlib),index(type))");
$dbh->do("delete from bibliothesaurus");
my $sti=$dbh->prepare("select count(*) from bibliosubject");
$sti->execute;
my ($total) = $sti->fetchrow_array;
$sti=$dbh->prepare("select subject from bibliosubject");
$sti->execute;
my $i;
my $search_sth = $dbh->prepare("select id,level,hierarchy from bibliothesaurus where stdlib=?");
my $insert_sth = $dbh->prepare("insert into bibliothesaurus (freelib,stdlib,category,level,hierarchy) values (?,?,?,?,?)");
while (my $line =$sti->fetchrow_hashref) {
	$i++;
	if ($i % 1000==0) {
		print "$i / $total\n";
	}
	my @hierarchy = split / - /,$line->{'subject'};
	my $rebuild = "";
	my $top_hierarchy = "";
	#---- if not a main authority field, search where to link
	for (my $hier=0; $hier<$#hierarchy+1 ; $hier++) {
		$rebuild .=$hierarchy[$hier];
		$search_sth->execute($rebuild);
		my ($id,$level,$hierarchy) = $search_sth->fetchrow_array;
#		warn "/($line->{'subject'}) : $rebuild/";
# if father not found, create father and son
		if (!$id) {
			$insert_sth->execute($rebuild,$rebuild,"",$hier,"$top_hierarchy");
			# search again, to find $id and buiild $top_hierarchy
			$search_sth->execute($rebuild);
			my ($id,$level,$hierarchy) = $search_sth->fetchrow_array;
			$top_hierarchy .="|" if ($top_hierarchy);
			$top_hierarchy .= "$id";
# else create only son
		} else {
			$top_hierarchy .="|" if ($top_hierarchy);
			$top_hierarchy .= "$id";
#			$insert_sth->execute($rebuild,$rebuild,"",$hier,"$top_hierarchy");
		}
		$rebuild .=" - ";
	}
#	my $sti2=$dbh->prepare("select count(*) as t from bibliothesaurus where freelib=".$dbh->quote($line->{'subject'}));
#	$sti2->execute;
#	if ($sti2->err) {
#		print "error : ".$sti2->errstr."\n";
#		die;
#	}
#	my $line2=$sti2->fetchrow_hashref;
#	if ($line2->{'t'} ==0) {
#		dosql($dbh,"insert into bibliothesaurus (freelib,stdlib,category) values (".$dbh->quote($line->{'subject'}).",".$dbh->quote($line->{'subject'}).")");
#	}
}
