#!/usr/bin/perl
# This script finds and fixes missing 090 fields in Koha for MARC21
#  Written by TG on 01/10/2005
#  Revised by Joshua Ferraro on 03/31/2006
use strict;
#use warnings; FIXME - Bug 2505
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../../kohalib.pl" };
}

# Koha modules used

use C4::Context;
use C4::Biblio;
use MARC::Record;
use MARC::File::USMARC;


my $dbh = C4::Context->dbh;

my $sth=$dbh->prepare("select biblionumber,timestamp from biblioitems");
	$sth->execute();

$|=1; # flushes output
print "Creating/updating field 100 if needed\n";
while (my ($biblionumber,$time)=$sth->fetchrow ){
#   my $record;
# print "record : $biblionumber \n";
    my $record = GetMarcBiblio($biblionumber);
# print "=> ".$record->as_formatted;
    MARCmodrecord($biblionumber,$record,$time) if ($record);
#
}

sub MARCmodrecord {
    my ($biblionumber,$record,$time)=@_;
#     warn "AVANT : ".$record->as_formatted;
        my $update=0;
        $record->leader('     nac  22     1u 4500');
        $update=1;
        my $string;
        if ($record->field(100)) {
            $string = substr($record->subfield(100,"a")."                                   ",0,35);
            my $f100 = $record->field(100);
            $record->delete_field($f100);
        } else {
            $string = POSIX::strftime("%Y%m%d", localtime);
            $string=~s/\-//g;
            $string = sprintf("%-*s",35, $string);
        }
        substr($string,22,6,"frey50");
        unless ($record->subfield(100,"a")){
            $record->insert_fields_ordered(MARC::Field->new(100,"","","a"=>"$string"));
        }
    if ($update){
        &ModBiblioMarc($record,$biblionumber,'');
        print "\r$biblionumber" unless ( $biblionumber % 100 );
    }

}
END;
