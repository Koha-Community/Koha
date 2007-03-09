#!/usr/bin/perl
# This script finds and fixes missing 090 fields in Koha for MARC21
#  Written by TG on 01/10/2005
#  Revised by Joshua Ferraro on 03/31/2006
use strict;

# Koha modules used

use C4::Context;
use C4::Biblio;
use MARC::Record;
use MARC::File::USMARC;


my $dbh = C4::Context->dbh;

my $sth=$dbh->prepare("select biblionumber,timestamp from biblioitems");
	$sth->execute();

while (my ($biblionumber,$time)=$sth->fetchrow ){
#   my $record;
  my $record = GetMarcBiblio($biblionumber);
#print $record->as_marc;
		MARCmodrecord($biblionumber,$record,$time);
#
}

sub MARCmodrecord {
    my ($biblionumber,$record,$time)=@_;
#     warn "AVANT : ".$record->as_formatted;
    my $update=0;
        $record->leader('     nac  22     1u 4500');
        $update=1;
        my $string;
        if ($record->subfield(100,"a")) {
            $string = $record->subfield(100,"a");
            my $f100 = $record->field(100);
            $record->delete_field($f100);
        } else {
            $string = POSIX::strftime("%Y%m%d", localtime);
            $string=~s/\-//g;
            $string = sprintf("%-*s",35, $string);
        }
        substr($string,22,6,"frey50");
        unless ($record->subfield(100,"a")){
            $record->insert_fields_ordered(MARC::Field->new(100,"","","a"=>$string));
        }
#     warn "APRES : ".$record->as_formatted;
    # delete all items related fields
    foreach ($record->field('995')) {
        $record->delete_field($_);
    }
    if ($update){	
        &MARCmodbiblio($dbh,$biblionumber,$record,'',0);
        print "$biblionumber \n";	
    }

}
END;
