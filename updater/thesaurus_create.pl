#!/usr/bin/perl

use strict;
# This script generates and fill the thesaurus table
# with the data in bibliothesaurus

use C4::Database;
use C4::Catalogue;
use DBI;
use C4::Acquisitions;
use C4::Output;

my $dbh=C4Connect;

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

