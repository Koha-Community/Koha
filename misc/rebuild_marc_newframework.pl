#!/usr/bin/perl 
#-----------------------------------
# Script Name: rebuild_marc_newframework.pl
# Script Version: 0.1.0
# Date:  20/04/2006
##If you change your framework for marc mapping use this script to recreate marc records in your db
## Then drop the old framework and install the new one.New frameworks are being introduced with Koha3.0
##Re-export all your marc and recreate Zebra db.
##Writen by Tumer Garip tgarip@neu.edu.tr



use strict;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/kohalib.pl" };
}

use C4::Context;
use C4::Biblio;
use MARC::Record;
use MARC::File::USMARC;
use MARC::File::XML;

my $dbh=C4::Context->dbh;
use Time::HiRes qw(gettimeofday);

##Write the corresponding new mappings below. this one maps old 090$c$d to new 09o$c$d and  952 holdings of NEU to 95k values
##Adjust this mapping list to your own needs
my %mapping_list = (
	'090cd' =>'09ocd',
	'952abcdefpruvxyz'=>'95kkbcfazpw9d4ye',
	);

my $starttime = gettimeofday;
my $sth=$dbh->prepare("SELECT biblionumber,marc FROM biblioitems ");
$sth->execute;

my $update=$dbh->prepare("update biblioitems set marc=?,marcxml=? where biblionumber=?");

my $b=0;
my $timeneeded;
while (my ($biblionumber, $marc) = $sth->fetchrow) {
	 
my $record=MARC::File::USMARC::decode($marc);

foreach my $key (keys %mapping_list){
my $tag=substr($key,0,3);
my $newtag=substr($mapping_list{$key},0,3);
my @subf;
my @newsub;
	for (my $i=3; $i<length($key); $i++){
	push @subf,substr($key,$i,1);
	push @newsub,substr($mapping_list{$key},$i,1);
	}##

foreach my $field ($record->field($tag)){
my $notnew=1;
my $addedfield;
	for  (my $r=0; $r<@subf; $r++){
		if ($field->subfield($subf[$r]) && $notnew){
		$addedfield=MARC::Field->new($newtag,$field->indicator(1),$field->indicator(2),$newsub[$r]=>$field->subfield($subf[$r]));
		$notnew=0;
		}elsif ($field->subfield($subf[$r])){
		$addedfield->update($newsub[$r]=>$field->subfield($subf[$r]));
		}## a subfield exists
	}## all subfields added
$record->delete_field($field);	
$record->add_fields($addedfield);
}##foreach field found	
##Now update-db
$update->execute($record->as_usmarc,$record->as_xml_record,$biblionumber);
	
}##foreach $key
	$timeneeded = gettimeofday - $starttime unless ($b % 10000);
	print "$b in $timeneeded s\n" unless ($b % 10000);
	print "." unless ($b % 500);
	$b++;
}##while biblionumber

##Dont forget to export all new marc records and build your zebra db

	
#	$timeneeded = gettimeofday - $starttime unless ($i % 30000);
#	print "$i in $timeneeded s\n" unless ($i % 30000);
#	print "." unless ($i % 500);
#	$i++;


$dbh->disconnect();
