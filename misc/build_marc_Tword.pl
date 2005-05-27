#!/usr/bin/perl -w
#-----------------------------------
# Script Name: build_marc_Tword.pl
# Script Version: 0.1.0
# Date:  2004/06/05

# script to build a marc_Tword table.
# create the table :
# CREATE TABLE `marc_Tword` (
#  `word` varchar(80) NOT NULL default '',
#  `usedin` text NOT NULL,
#  `tagsubfield` varchar(4) NOT NULL default '',
#  PRIMARY KEY  (`word`,`tagsubfield`)
#) TYPE=MyISAM;
# just to test the idea of a reversed index searching.
# reversed index for searchs on Title.
# the marc_Tword table contains for each word & marc field/subfield, the list of biblios using it, with the title
# reminder : the inverted index is only done to search on a "contain". For a "=" or "start by", the marc_subfield_table is perfect & correctly indexed.
# if this POC becomes more than a POC, then I think we will have to build 1 table for each sorting (marc_Tword for title, Aword for author, Cword for callnumber...)

# FIXME :
# * indexes empty words too (it's just a proof of concept)
# * maybe it would be OK to store only 20 char of the title.

use strict;
use locale;
use C4::Context;
use C4::Biblio;
my $dbh=C4::Context->dbh;
use Time::HiRes qw(gettimeofday);

# fields & subfields to ignore
# in real situation, we should add a marc constraint on this.
# ideally, we should not inde isbn, as every would be different, so it makes the table very big.
# but in this case we have to find a way to automatically search "isbn = XXX" in marc_subfield_table

my %ignore_list = (
	'001' =>1,
	'010b'=>1,
	'0909' => 1,
	'090a' => 1,
	'100' => 1,
	'105' => 1,
	'6069' => 1,
	'7009' => 1,
	'7019' => 1,
	'7109' => 1,
	'7129' => 1,
	'9959' => 1,
);

my $starttime = gettimeofday;

$dbh->do("delete from marc_Tword");

# parse every line
my $query="SELECT biblio.biblionumber,tag,subfieldcode,subfieldvalue,biblio.title FROM marc_subfield_table left join marc_biblio on marc_biblio.bibid=marc_subfield_table.bibid left join biblio on marc_biblio.biblionumber=biblio.biblionumber";
my $sth=$dbh->prepare($query);

print "******** SELECTING \n";
$sth->execute;
print "******** DONE \n";
$|=1; # flushes output

my $sthT=$dbh->prepare("select usedin from marc_Tword where tagsubfield=? and word=?");
my $updateT=$dbh->prepare("update marc_Tword set usedin=? where tagsubfield=? and word=?");
my $insertT=$dbh->prepare("insert into marc_Tword (tagsubfield,word,usedin) values (?,?,?)");
my $i=0;
my $timeneeded;
# 1st version, slower, but less RAM consumming
# while (my ($biblionumber, $tag, $subfieldcode, $subfieldvalue, $title) = $sth->fetchrow) {
# 	next if $ignore_list{"$tag.$subfieldcode"};
#     $subfieldvalue =~ s/(\.|\?|\:|\!|\'|,|\-|\"|\(|\)|\[|\]|\{|\}|\/)/ /g;
# 	# remove useless chars in the title.
#     $title =~ s/(\.|\?|\:|\!|\'|,|\-|\"|\(|\)|\[|\]|\{|\}|\/)/ /g;
#     my @words = split / /, $subfieldvalue;
# 	# and retrieve the reversed entry
# 	foreach my $word (@words) {
# 		$sthT->execute($tag.$subfieldcode,$word);
# 		if (my ($usedin) = $sthT->fetchrow) {
# 			# add the field & save it once again.
# 			$usedin.=",$biblionumber-$title";
# 			$updateT->execute($usedin,$tag.$subfieldcode,$word);
# 		} else {
# 			$insertT->execute($tag.$subfieldcode,$word,",$title-$biblionumber");
# 		}
# 	}
# 	$timeneeded = gettimeofday - $starttime unless ($i % 100);
# 	print "$i in $timeneeded s\n" unless ($i % 100);
# 	print ".";
# 	$i++;
# }

# 2nd version : faster (about 100 times !), bug maybe too much RAM consumming...
my %largehash;
print "READING\n";
while (my ($biblionumber, $tag, $subfieldcode, $subfieldvalue, $title) = $sth->fetchrow) {
	next unless $subfieldvalue;
	next if $ignore_list{$tag.$subfieldcode};
    $subfieldvalue =~ s/(\.|\?|\:|\!|\'|,|\-|\"|\(|\)|\[|\]|\{|\}|\/)/ /g;
	# remove useless chars in the title.
    $title =~ s/(\.|\?|\:|\!|\'|,|\-|\"|\(|\)|\[|\]|\{|\}|\/)/ /g;
    my @words = split / /, $subfieldvalue;
	# and retrieve the reversed entry
	foreach my $word (@words) {
		my $localkey = $tag.$subfieldcode.'|'.uc($word);
		$largehash{$localkey}.=",$title-$biblionumber";
	}
	$timeneeded = gettimeofday - $starttime unless ($i % 30000);
	print "$i in $timeneeded s\n" unless ($i % 30000);
	print "." unless ($i % 500);
	$i++;
}
$i=0;
print "WRITING\n";
foreach my $k (keys %largehash) {
	$k =~ /(.*)\|(.*)/;
	$insertT->execute($1,$2,$largehash{$k});
	$timeneeded = gettimeofday - $starttime unless ($i % 30000);
	print "$i in $timeneeded s\n" unless ($i % 30000);
	print "." unless ($i % 500);
	$i++;
}

$dbh->disconnect();
