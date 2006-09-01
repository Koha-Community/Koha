#!/usr/bin/perl


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
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Auth;
use CGI;
use C4::Search;
use C4::Context;
use C4::Biblio;

my $input = new CGI;

my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "admin/checkmarc.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });

my $dbh = C4::Context->dbh;
my $total;
# checks itemnumber field
my $sth = $dbh->prepare("select tagfield from koha_attr where marctokoha=\"itemnumber\"");
$sth->execute;
my ($res) = $sth->fetchrow;
unless ($res) {
	$template->param(itemnumber => 1);
	$total++;
}
#check biblionumber
my $sth = $dbh->prepare("select tagfield from koha_attr where marctokoha=\"biblionumber\"");
$sth->execute;
my ($res) = $sth->fetchrow;
if ($res ){
	($res) = $sth->fetchrow;
	unless ($res){
	$template->param(biblionumber => 1);
	$total++;
	}
}
#check barcode
my $sth = $dbh->prepare("select tagfield from koha_attr where marctokoha=\"barcode\"");
$sth->execute;
my ($res) = $sth->fetchrow;
unless ($res){
	$template->param(barcode=> 1);
	$total++;
}
#check isbn
my $sth = $dbh->prepare("select tagfield from koha_attr where marctokoha=\"isbn\"");
$sth->execute;
my ($res) = $sth->fetchrow;
unless ($res){
	$template->param(isbn => 1);
	$total++;
}
## Check for itemtype
my $sth = $dbh->prepare("select tagfield,tagsubfield from koha_attr where marctokoha=\"itemtype\"");
$sth->execute;
my ($res,$res2) = $sth->fetchrow;
if ($res) {
$sth = $dbh->prepare("select authorised_value from biblios_subfield_structure where tagfield=? and tagsubfield=?");
$sth->execute($res,$res2);
 my ($item)=$sth->fetchrow;
    unless ($item eq "itemtypes"){
	$template->param(itemtype => 1);
	$total++;
    }
}

## Check for homebranch
my $sth = $dbh->prepare("select tagfield from koha_attr where marctokoha=\"homebranch\"");
$sth->execute;
my ($res) = $sth->fetchrow;
unless  ($res) {
	$template->param(branch => 1);
	$total++;
    
}

## Check for holdingbranch
my $sth = $dbh->prepare("select tagfield,tagsubfield from koha_attr where marctokoha=\"holdingbranch\"");
$sth->execute;
my ($res,$res2) = $sth->fetchrow;
if ($res) {
$sth = $dbh->prepare("select authorised_value from biblios_subfield_structure where tagfield=? and tagsubfield=?");
$sth->execute($res,$res2);
 my ($item)=$sth->fetchrow;
    unless ($item eq "branches"){
	$template->param(holdingbranch => 1);
	$total++;
    }
}



# checks that itemtypes & branches tables are not empty
$sth = $dbh->prepare("select count(*) from itemtypes");
$sth->execute;
($res) = $sth->fetchrow;
unless ($res) {
	$template->param(itemtypes_empty =>1);
	$total++;
}

$sth = $dbh->prepare("select count(*) from branches");
$sth->execute;
($res) = $sth->fetchrow;
unless ($res) {
	$template->param(branches_empty =>1);
	$total++;
}

$template->param(total => $total);
output_html_with_http_headers $input, $cookie, $template->output;
