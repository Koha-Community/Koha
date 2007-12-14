#!/usr/bin/perl 
#run nightly -- changes J to A on someone's 18th birthday
use strict;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

use C4::Context;
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)
                                            = localtime(time);
$year +=1900;
$mon +=1; if ($mon < 10) {$mon = "0".$mon;}
if ($mday < 10) {$mday = "0".$mday;}

$year -=18; #18 year olds here: if your J turns to A before this change here
my $dbh=C4::Context->dbh;

#get today's date, format it and subtract 18 yrs.
my $itsyourbirthday = "$year-$mon-$mday";

my $query=qq|UPDATE borrowers 
	   SET categorycode='A',
	    guarantorid ='0'	 
	   WHERE dateofbirth<=? 
	   AND dateofbirth!='0000-00-00' 
	   AND categorycode IN (select categorycode from categories where category_type='C')|;
my $sth=$dbh->prepare($query);
my $res = $sth->execute($itsyourbirthday) or die "can't execute";
print "$res\n"; #did it work?
$dbh->disconnect();
