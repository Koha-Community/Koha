#!/usr/bin/perl

#script to enter borrower data into the data base
#needs to be moved into a perl module
# written 9/11/99 by chris@katipo.co.nz


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

use CGI;
use C4::Context;
use C4::Input;
use Date::Manip;
use strict;

my $input= new CGI;
#print $input->header;
#print $input->Dump;

#get all the data into a hash
my @names=$input->param;
my %data;
my $keyfld;
my $keyval;
my $problems;
my $env;
foreach my $key (@names){
  $data{$key}=$input->param($key);
}
my $dbh = C4::Context->dbh;
my $surname=$data{'institution_name'};
my $query="insert into borrowers (title,expiry,cardnumber,sex,ethnotes,streetaddress,faxnumber,
firstname,altnotes,dateofbirth,contactname,emailaddress,dateenrolled,streetcity,
altrelationship,othernames,phoneday,categorycode,city,area,phone,borrowernotes,altphone,surname,
initials,ethnicity,borrowernumber,guarantor,school) 
values ('','$data{'expiry'}','$data{'cardnumber_institution'}',
'','$data{'ethnotes'}','$data{'address'}','$data{'faxnumber'}',
'$data{'firstname'}','$data{'altnotes'}','','$data{'contactname'}',
'$data{'emailaddress'}',
now(),'$data{'streetcity'}','$data{'altrelationship'}','$data{'othernames'}',
'$data{'phoneday'}','I','$data{'city'}','$data{'area'}','$data{'phone'}',
'$data{'borrowernotes'}','$data{'altphone'}','$surname','$data{'initials'}',
'$data{'ethnicity'}','$data{'borrowernumber'}','','')";


#print $query;
  my $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;
#$sth->finish;

print $input->redirect("/cgi-bin/koha/moremember.pl?bornum=$data{'borrowernumber'}");
