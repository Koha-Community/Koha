#!/usr/bin/perl

# $Id$

#script to delete items
#written 2/5/00
#by chris@katipo.co.nz


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
use C4::Search;
use C4::Output;
use C4::Circulation::Circ2;
#use C4::Acquisitions;
use C4::Auth;


my $input = new CGI;

my $flagsrequired;
$flagsrequired->{borrower}=1;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0, $flagsrequired);



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
  my ($bor,$flags)=getpatroninformation(\%env, $member,'');
my $dbh = C4::Context->dbh;
my $sth=$dbh->prepare("Select * from borrowers where guarantor=?");
$sth->execute($member);
my $data=$sth->fetchrow_hashref;
$sth->finish;


if ($i > 0 || $flags->{'CHARGES'} ne '' || $data ne ''){
  print $input->header;
  print "<table border=1>";
  if ($i > 0){
      print "<TR><TD>Items on Issue</td><td align=right>$i</td></tr>";
  }
  if ($flags->{'CHARGES'} ne ''){
      print "<TR><TD>Charges</td><td>$flags->{'CHARGES'}->{'message'}</tr>";
  }
  if ($data ne ''){
      print "<TR><TD>Guarantees</td></tr>";
  }
  print "</table>";

} else {
         delmember($member);
         print $input->redirect("/cgi-bin/koha/members-home.pl");
}

sub delmember{
  my ($member)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select * from borrowers where borrowernumber=?");
  $sth->execute($member);
  my @data=$sth->fetchrow_array;
  $sth->finish;
  $sth=$dbh->prepare("Insert into deletedborrowers values (".("?,"x(scalar(@data)-1))."?)");
  $sth->execute(@data);
  $sth->finish;
  $sth=$dbh->prepare("Delete from borrowers where borrowernumber=?");
  $sth->execute($member);
  $sth->finish;
  $sth=$dbh->prepare("Delete from reserves where borrowernumber=?");
  $sth->execute($member);
  $sth->finish;
}
