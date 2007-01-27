#!/usr/bin/perl
use C4::Context;
use CGI;
use DBI;
#use strict;
use C4::Biblio;
use C4::Output;
use Getopt::Long;

my ( $confirm,$delete);
GetOptions(
	'c' => \$confirm,
	'd' => \$delete,
);
my $dbh = C4::Context->dbh;
if ($delete) {
	print "deleting MARC tables\n";
	$dbh->do("delete from marc_biblio");
	$dbh->do("alter table marc_biblio auto_increment=1");
	$dbh->do("delete from marc_subfield_table");
	$dbh->do("alter table marc_subfield_table auto_increment=1");
	$dbh->do("delete from marc_blob_subfield");
	$dbh->do("alter table marc_blob_subfield auto_increment=1");
	$dbh->do("delete from marc_word");
	$dbh->do("alter table marc_word auto_increment=1");
}

my $userid=$ENV{'REMOTE_USER'};
my $sthbiblioitem = $dbh->prepare("select biblioitemnumber from biblioitems where biblionumber=?");
my $sthitems = $dbh->prepare("select itemnumber from items where biblionumber=?");
my $sth=$dbh->prepare("select biblionumber from biblio");
$sth->execute;
my $env;
$env->{'marconly'}=1;
my ($MARC, $biblionumber,$biblioitemnumber,$bibid);
while (($biblionumber) = $sth->fetchrow) {
	print "Processing $biblionumber\n";
	$sthbiblioitem->execute($biblionumber);
	($biblioitemnumber) = $sthbiblioitem->fetchrow;
	$MARC =  &MARCkoha2marcBiblio($dbh,$biblionumber,$biblioitemnumber);
	$bibid = &MARCaddbiblio($dbh,$MARC,$biblionumber,'');
	# now, search items, and add them...
	$sthitems->execute($biblionumber);
	while (($itemnumber) = $sthitems->fetchrow) {
		$MARC = &MARCkoha2marcItem($dbh,$biblionumber,$itemnumber);
		&MARCadditem($dbh,$MARC,$biblionumber);
	}
}
