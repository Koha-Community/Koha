#!/usr/bin/perl
# script that populates the authorities table with marc  
#  Written by TG on 10/04/2006
use strict;

# Koha modules used

use C4::Context;
use MARC::Record;
use MARC::File::USMARC;
use MARC::File::XML;
use C4::AuthoritiesMarc;
use Time::HiRes qw(gettimeofday);
my $timeneeded;
my $starttime = gettimeofday;


my $dbh = C4::Context->dbh;
my $sthcols=$dbh->prepare("show columns from auth_header");
$sthcols->execute();
my %columns;
while (( my $cols)=$sthcols->fetchrow){
$columns{$cols}=1;
}

##Update the database if missing fields;
 $dbh->do("LOCK TABLES auth_header WRITE, auth_subfield_structure WRITE , auth_subfield_table READ");
unless ($columns{'linkid'}){
my $sth=$dbh->prepare("ALTER TABLE auth_header  ADD COLUMN `linkid` BIGINT(20) UNSIGNED NOT NULL DEFAULT 0 ");
$sth->execute();
}
unless ($columns{'marc'}){
my $sth=$dbh->prepare("ALTER TABLE auth_header  ADD COLUMN `marc` BLOB  NOT NULL DEFAULT 0 ");
$sth->execute();
}
###Chechk auth_subfield_structure as well. User may have forgotten to update database
my $sthcols=$dbh->prepare("show columns from auth_subfield_structure");
$sthcols->execute();
my %columns;
while (( my $cols)=$sthcols->fetchrow){
$columns{$cols}=1;
}
##Update the database if missing fields;
unless ($columns{'link'}){
my $sth=$dbh->prepare("ALTER TABLE auth_subfield_structure ADD COLUMN `link` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 ");
$sth->execute();
}
unless ($columns{'isurl'}){
my $sth=$dbh->prepare("ALTER TABLE auth_subfield_structure ADD COLUMN `isurl` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 ");
$sth->execute();
}
unless ($columns{'hidden'}){
my $sth=$dbh->prepare("ALTER TABLE auth_subfield_structure ADD COLUMN `hidden` TINYINT(3) UNSIGNED NOT NULL ZEROFILL DEFAULT 000 ");
$sth->execute();
}
unless ($columns{'kohafield'}){
my $sth=$dbh->prepare("ALTER TABLE auth_subfield_structure  ADD COLUMN `kohafield` VARCHAR(45)  NOT NULL  ");
$sth->execute();
}
$dbh->do("UNLOCK TABLES ");
my $sth=$dbh->prepare("select authid,authtypecode from auth_header  ");
	$sth->execute();
 
my $i=0;
my $sth2 = $dbh->prepare("UPDATE auth_header  set marc=? where authid=?" );
   

while (my ($authid,$authtypecode)=$sth->fetchrow ){
 my $record = AUTHgetauthorityold($dbh,$authid);
##Add authid and authtypecode to record. Old records did not have these fields
my ($authidfield,$authidsubfield)=AUTHfind_marc_from_kohafield("auth_header.authid",$authtypecode);
my ($authidfield,$authtypesubfield)=AUTHfind_marc_from_kohafield("auth_header.authtypecode",$authtypecode);
##Both authid and authtypecode is expected to be in the same field. Modify if other requirements arise
	$record->add_fields($authidfield,'','',$authidsubfield=>$authid,$authtypesubfield=>$authtypecode);
$sth2->execute($record->as_usmarc,$authid);
$timeneeded = gettimeofday - $starttime unless ($i % 1000);
	print "$i in $timeneeded s\n" unless ($i % 1000);
	print "." unless ($i % 500);
	$i++;
}


sub AUTHgetauthorityold {
# Returns MARC::Record of the biblio passed in parameter.
    my ($dbh,$authid)=@_;
    my $record = MARC::Record->new();
#---- TODO : the leader is missing
	$record->leader('                        ');
    my $sth3=$dbh->prepare("select authid,subfieldid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,subfieldvalue
		 		 from auth_subfield_table
		 		 where authid=? order by tag,tagorder,subfieldorder
		 	 ");
	$sth3->execute($authid);
	my $prevtagorder=1;
	my $prevtag='XXX';
	my $previndicator;
	my $field; # for >=10 tags
	my $prevvalue; # for <10 tags
	while (my $row=$sth3->fetchrow_hashref) {
		if ($row->{tagorder} ne $prevtagorder || $row->{tag} ne $prevtag) {
			$previndicator.="  ";
			if ($prevtag <10) {
 			$record->add_fields((sprintf "%03s",$prevtag),$prevvalue) unless $prevtag eq "XXX"; # ignore the 1st loop
			} else {
				$record->add_fields($field) unless $prevtag eq "XXX";
			}
			undef $field;
			$prevtagorder=$row->{tagorder};
			$prevtag = $row->{tag};
			$previndicator=$row->{tag_indicator};
			if ($row->{tag}<10) {
				$prevvalue = $row->{subfieldvalue};
			} else {
				$field = MARC::Field->new((sprintf "%03s",$prevtag), substr($row->{tag_indicator}.'  ',0,1), substr($row->{tag_indicator}.'  ',1,1), $row->{'subfieldcode'}, $row->{'subfieldvalue'} );
			}
		} else {
			if ($row->{tag} <10) {
 				$record->add_fields((sprintf "%03s",$row->{tag}), $row->{'subfieldvalue'});
 			} else {
				$field->add_subfields($row->{'subfieldcode'}, $row->{'subfieldvalue'} );
 			}
 			$prevtag= $row->{tag};
			$previndicator=$row->{tag_indicator};
		}
	}
	# the last has not been included inside the loop... do it now !
	if ($prevtag ne "XXX") { # check that we have found something. Otherwise, prevtag is still XXX and we
						# must return an empty record, not make MARC::Record fail because we try to
						# create a record with XXX as field :-(
		if ($prevtag <10) {
			$record->add_fields($prevtag,$prevvalue);
		} else {
	#  		my $field = MARC::Field->new( $prevtag, "", "", %subfieldlist);
			$record->add_fields($field);
		}
	}
	return $record;
}

END;