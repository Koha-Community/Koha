#!/usr/bin/perl

#written 11/1/2000 by chris@katipo.co.nz
#script to write off accounts


# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
use CGI;
use C4::Context;
use C4::Stats;
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
  my $user=$input->remote_user;
  $user=~ s/Levin/C/;
  $user=~ s/Foxton/F/;
  $user=~ s/Shannon/S/;
  my $dbh = C4::Context->dbh;
  my $env;
  my $sth;
  if ($accounttype eq 'Res'){
    $sth=$dbh->prepare("Update accountlines set amountoutstanding=0 where accounttype='Res' and accountno=? and borrowernumber=?");
    $sth->execute($accountnum,$bornum);
  } else {
    $sth=$dbh->prepare("Update accountlines set amountoutstanding=0 where accounttype=? and itemnumber=? and borrowernumber=?");
    $sth->execute($accounttype,$itemnum,$bornum);
  }
  $sth->finish;
  $sth=$dbh->prepare("select max(accountno) from accountlines");
  $sth->execute;
  my $account=$sth->fetchrow_hashref;
  $sth->finish;
  $account->{'max(accountno)'}++;
  $sth=$dbh->prepare("insert into accountlines (borrowernumber,accountno,itemnumber,date,amount,description,accounttype)
  values (?,?,?,now(),?,'Writeoff','W')");
  $sth->execute($bornum,$account->{'max(accountno)'},$itemnum,$amount);
  $sth->finish;
#  print $query;
  UpdateStats($env,$user,'writeoff',$amount,'','','',$bornum);
}
