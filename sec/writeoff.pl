#!/usr/bin/perl

#written 11/1/2000 by chris@katipo.co.nz
#script to write off accounts

use strict;
use CGI;
use C4::Database;
my $input=new CGI;

#print $input->header;
#print $input->dump;

my%inp;

my @name=$input->param;
for (my $i=0;$i<@name;$i++){
  my $test=$input->param($name[$i]);
  if ($test eq 'wo'){
    my $temp=$name[$i];
    $temp=~ s/payfine//;
    $inp{$name[$i]}=$temp;
  }
}
my $bornum;
while ( my ($key, $value) = each %inp){
#  print $key,$value;
  my $accounttype=$input->param("accounttype$value");
  $bornum=$input->param("bornum$value");
  my $itemno=$input->param("itemnumber$value");
  my $amount=$input->param("amount$value");
  if ($accounttype eq 'Res'){
    my $accountno=$input->param("accountno$value");
    writeoff($bornum,$accountno,$itemno,$accounttype,$amount);
  } else {
    writeoff($bornum,'',$itemno,$accounttype,$amount);
  }
}
#print $input->header;
$bornum=$input->param('bornum');
print $input->redirect("/cgi-bin/koha/pay.pl?bornum=$bornum");

#needs to be shifted to a module when time permits
sub writeoff{
  my ($bornum,$accountnum,$itemnum,$accounttype,$amount)=@_;
  my $dbh=C4Connect;
  my $query="Update accountlines set amountoutstanding=0 where ";
  if ($accounttype eq 'Res'){
    $query.="accounttype='Res' and accountno='$accountnum' and borrowernumber='$bornum'";
  } else {
    $query.="accounttype='$accounttype' and itemnumber='$itemnum' and borrowernumber='$bornum'";
  }
  my $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;
  $query="select max(accountno) from accountlines";
  $sth=$dbh->prepare($query);
  $sth->execute;
  my $account=$sth->fetchrow_hashref;
  $sth->finish;
  $account->{'max(accountno)'}++;
  $query="insert into accountlines (borrowernumber,accountno,itemnumber,date,amount,description,accounttype)
  values ('$bornum','$account->{'max(accountno)'}','$itemnum',now(),'$amount','Writeoff','W')";
  $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish; 
#  print $query;
  $dbh->disconnect;
}
