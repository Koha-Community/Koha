#!/usr/bin/perl

#script to delete items
#written 2/5/00
#by chris@katipo.co.nz

use strict;

use C4::Search;
use CGI;
use C4::Output;
use C4::Database;
use C4::Circulation::Circ2;
#use C4::Acquisitions;

my $input = new CGI;
#print $input->header;
my $member=$input->param('member');
my %env;
$env{'nottodayissues'}=1;
my %member2;
$member2{'borrowernumber'}=$member;
my $issues=currentissues(\%env,\%member2);
my $i=0;
foreach (sort keys %$issues) {
  $i++;
}
if ($i > 0){ 
  print $input->header;
  print "error borrower has items on issue";
} else {
  delmember($member);
  print $input->redirect("/members/");
}

sub delmember{
  my ($member)=@_;
  my $dbh=C4Connect;
  my $query="Select * from borrowers where borrowernumber='$member'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @data=$sth->fetchrow_array;
  $sth->finish;
  $query="Insert into deletedborrowers values (";
  foreach my $temp (@data){
    $query=$query."'$temp',";
  }
  $query=~ s/\,$/\)/;
  #  print $query;
  $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $query = "Delete from borrowers where borrowernumber='$member'";
  $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}
