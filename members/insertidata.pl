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
my $sth2;
foreach my $key (@names){
  $data{$key}=$input->param($key);
}
my $dbh = C4::Context->dbh;
my $sth=$dbh->prepare("Select * from borrowers where borrowernumber=?");
$sth->execute($data{'borrowernumber'});
if (my $data2=$sth->fetchrow_hashref){
	$sth2=$dbh->prepare("update borrowers set title=?,expiry=?,
	cardnumber=?,sex=?,ethnotes=?,
	streetaddress=?,faxnumber=?,firstname=?,
	altnotes=?,dateofbirth=?,contactname=?,
	emailaddress=?,dateenrolled=?,streetcity=?,
	altrelationship=?,othernames=?,phoneday=?,
	city=?,area=?,phone=?,
	borrowernotes=?,altphone=?,surname=?,
	initials=?,physstreet=?,ethnicity=?,
	gonenoaddress=?,lost=?,debarred=?,
	textmessaging=?, branchcode = ?,
	zipcode = ?,homezipcode=?
	where borrowernumber=?");
	$sth2->execute($data{'title'},$data{'expiry'},
	$data{'cardnumber_institution'},$data{'sex'},$data{'ethnicnotes'},
	$data{'address'},$data{'faxnumber'},$data{'firstname'},
	$data{'altnotes'},$data{'dateofbirth'},$data{'contactname'},
	$data{'emailaddress'},$data{'joining'},$data{'streetcity'},
	$data{'altrelationship'},$data{'othernames'},$data{'phoneday'},
	$data{'city'},$data{'area'},$data{'phone'},
	$data{'borrowernotes'},$data{'altphone'},$data{'institution_name'},
	$data{'initials'},$data{'streetaddress'},$data{'ethnicity'},
	$data{'gna'},$data{'lost'},$data{'debarred'},
	$data{'textmessaging'},$data{'branchcode'},
	$data{'zipcode'},$data{'homezipcode'},
	$data{'borrowernumber'});
} else {
	my $surname=$data{'institution_name'};
	# note for code reading : 5 on each line
	$sth2=$dbh->prepare("insert into borrowers (
			title,			expiry,		cardnumber,	sex,		ethnotes,
			streetaddress,	faxnumber,	firstname,		altnotes,	dateofbirth,
			contactname,	emailaddress,	dateenrolled,	streetcity,	altrelationship,
			othernames,	phoneday,		categorycode,	city,		area,
			phone,		borrowernotes,	altphone,		surname,	initials,
			ethnicity,		borrowernumber,guarantor,		school,	branchcode,
			zipcode,		homezipcode)
	values (	?,?,?,?,?,
			?,?,?,?,?,
			?,?,now(),?,?,
			?,?,?,?,?,
			?,?,?,?,?,
			?,?,?,?,?,
			?,?
			)");
	$sth2->execute('',				$data{'expiry'},			$data{'cardnumber_institution'},	'',				$data{'ethnotes'},
				$data{'address'},	$data{'faxnumber'},		$surname,					$data{'altnotes'},	'',
				$data{'contactname'},$data{'emailaddress'},	$data{'streetcity'},			$data{'altrelationship'}, # only 4 because of now()
				$data{'othernames'},	$data{'phoneday'},		'I',						$data{'city'},		$data{'area'},
				''.$data{'phone'},		$data{'borrowernotes'},	$data{'altphone'},			$surname,			''.$data{'initials'},
				$data{'ethnicity'},	$data{'borrowernumber'},	'',						'',				$data{'branchcode'},
				$data{'zipcode'},	$data{'homezipcode'});
}

$sth2->finish;
$sth->finish;

print $input->redirect("/cgi-bin/koha/members/moremember.pl?bornum=$data{'borrowernumber'}");
