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
my $query="Select * from borrowers where borrowernumber=$data{'borrowernumber'}";
my $sth=$dbh->prepare($query);
$sth->execute;
if (my $data2=$sth->fetchrow_hashref){
	$query="update borrowers set title='$data{'title'}',expiry='$data{'expiry'}',
	cardnumber='$data{'cardnumber_institution'}',sex='$data{'sex'}',ethnotes='$data{'ethnicnotes'}',
	streetaddress='$data{'address'}',faxnumber='$data{'faxnumber'}',firstname='$data{'firstname'}',
	altnotes='$data{'altnotes'}',dateofbirth='$data{'dateofbirth'}',contactname='$data{'contactname'}',
	emailaddress='$data{'emailaddress'}',dateenrolled='$data{'joining'}',streetcity='$data{'streetcity'}',
	altrelationship='$data{'altrelationship'}',othernames='$data{'othernames'}',phoneday='$data{'phoneday'}',
	city='$data{'city'}',area='$data{'area'}',phone='$data{'phone'}',
	borrowernotes='$data{'borrowernotes'}',altphone='$data{'altphone'}',surname='$data{'institution_name'}',
	initials='$data{'initials'}',physstreet='$data{'streetaddress'}',ethnicity='$data{'ethnicity'}',
	gonenoaddress='$data{'gna'}',lost='$data{'lost'}',debarred='$data{'debarred'}',
	textmessaging='$data{'textmessaging'}', branchcode = '$data{'branchcode'}',
	zipcode = '$data{'zipcode'}',homezipcode='$data{'homezipcode'}'
	where borrowernumber=$data{'borrowernumber'}";
} else {
	my $surname=$data{'institution_name'};
	$query="insert into borrowers (title,expiry,cardnumber,sex,ethnotes,streetaddress,faxnumber,
	firstname,altnotes,dateofbirth,contactname,emailaddress,dateenrolled,streetcity,
	altrelationship,othernames,phoneday,categorycode,city,area,phone,borrowernotes,altphone,surname,
	initials,ethnicity,borrowernumber,guarantor,school,branchcode,zipcode,homezipcode)
	values ('','$data{'expiry'}','$data{'cardnumber_institution'}',
	'','$data{'ethnotes'}','$data{'address'}','$data{'faxnumber'}',
	'$data{'firstname'}','$data{'altnotes'}','','$data{'contactname'}',
	'$data{'emailaddress'}',
	now(),'$data{'streetcity'}','$data{'altrelationship'}','$data{'othernames'}',
	'$data{'phoneday'}','I','$data{'city'}','$data{'area'}','$data{'phone'}',
	'$data{'borrowernotes'}','$data{'altphone'}','$surname','$data{'initials'}',
	'$data{'ethnicity'}','$data{'borrowernumber'}','','','$data{'branchcode'}','$data{'zipcode'}','$data{'homezipcode'}')";
}

#print $query;
my $sth2=$dbh->prepare($query);
warn "==> $query";
$sth2->execute;
$sth2->finish;
#$sth->finish;

print $input->redirect("/cgi-bin/koha/moremember.pl?bornum=$data{'borrowernumber'}");
