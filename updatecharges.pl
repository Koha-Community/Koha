#!/usr/bin/perl

#script to update charges for overdue in database
#updates categoryitem
# is called by charges.pl
# written 1/1/2000 by chris@katipo.co.nz

use strict;
use CGI;
use C4::Output;
use C4::Database;

my $input = new CGI;
#print $input->header;
#print startpage();
#print startmenu('issue');


my $dbh=C4Connect;
#print $input->dump;
my @names=$input->param();

foreach my $key (@names){
  
  my $bor=substr($key,0,1);
  my $cat=$key;
  $cat =~ s/[A-Z]//i;
  my $data=$input->param($key);
  my @dat=split(',',$data);
#  print "$bor $cat $dat[0] $dat[1] $dat[2] <br> ";
  my $sth=$dbh->prepare("Update categoryitem set fine=$dat[0],startcharge=$dat[1],chargeperiod=$dat[2] where 
  categorycode='$bor' and itemtype='$cat'");
  $sth->execute;
  $sth->finish;
}
$dbh->disconnect;
print $input->redirect("/cgi-bin/koha/charges.pl");
#print endmenu('issue');
#print endpage();
