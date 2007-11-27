#!/usr/bin/perl

# $Id: updateitem.pl,v 1.9.2.1.2.4 2006/10/05 18:36:50 kados Exp $
# Copyright 2006 LibLime
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
use strict; use warnings;
use CGI;
use C4::Context;
use C4::Biblio;
use C4::Output;
use C4::Circulation;
use C4::Accounts;
use C4::Reserves;

my $cgi= new CGI;

my $biblionumber=$cgi->param('biblionumber');
my $itemnumber=$cgi->param('itemnumber');
my $biblioitemnumber=$cgi->param('biblioitemnumber');
my $itemlost=$cgi->param('itemlost');
my $wthdrawn=$cgi->param('wthdrawn');
my $damaged=$cgi->param('damaged');

my $confirm=$cgi->param('confirm');
my $dbh = C4::Context->dbh;
# get the rest of this item's information
my $item_data_hashref = GetItem($itemnumber, undef);

# modify bib MARC
if ((not defined($item_data_hashref->{'itemlost'})) or ($itemlost ne $item_data_hashref->{'itemlost'})) {
    ModItemInMarconefield($biblionumber, $itemnumber, 'items.itemlost', $itemlost);
}
if ((not defined($item_data_hashref->{'wthdrawn'})) or ($wthdrawn ne $item_data_hashref->{'wthdrawn'})) {
    ModItemInMarconefield($biblionumber, $itemnumber, 'items.wthdrawn', $wthdrawn);
}
if ((not defined($item_data_hashref->{'damaged'})) or ($damaged ne $item_data_hashref->{'damaged'})) {
    ModItemInMarconefield($biblionumber, $itemnumber, 'items.damaged', $damaged);
}

# check reservations
my ($status, $reserve) = CheckReserves($itemnumber, $item_data_hashref->{'barcode'});
if ($reserve){
	#print $cgi->header;
	warn "Reservation found on item $itemnumber";
	#exit;
}
# check issues
my $sth=$dbh->prepare("SELECT * FROM issues WHERE (itemnumber=? AND returndate IS NULL)");
$sth->execute($itemnumber);
my $issues=$sth->fetchrow_hashref();

# if a borrower lost the item, add a replacement cost to the their record
if ( ($issues->{borrowernumber}) && ($itemlost==1) ){

		# first make sure the borrower hasn't already been charged for this item
		my $sth1=$dbh->prepare("SELECT * from accountlines
		WHERE borrowernumber=? AND itemnumber=?");
		$sth1->execute($issues->{'borrowernumber'},$itemnumber);
		my $existing_charge_hashref=$sth1->fetchrow_hashref();

		# OK, they haven't
		unless ($existing_charge_hashref) {
			# This item is on issue ... add replacement cost to the borrower's record and mark it returned
			my $accountno = getnextacctno('',$issues->{'borrowernumber'},$dbh);
			my $sth2=$dbh->prepare("INSERT INTO accountlines
			(borrowernumber,accountno,date,amount,description,accounttype,amountoutstanding,itemnumber)
			VALUES
			(?,?,now(),?,?,'L',?,?)");
			$sth2->execute($issues->{'borrowernumber'},$accountno,$item_data_hashref->{'replacementprice'},
			"Lost Item $item_data_hashref->{'title'} $item_data_hashref->{'barcode'}",
			$item_data_hashref->{'replacementprice'},$itemnumber);
			$sth2->finish;
		}
}
$sth->finish;

# FIXME: eventually we'll use Biblio.pm, but it's currently too buggy
#ModItem( $dbh,'',$biblionumber,$itemnumber,'',$item_hashref );
$sth = $dbh->prepare("UPDATE items SET wthdrawn=?,itemlost=?,damaged=? WHERE itemnumber=?");
$sth->execute($wthdrawn,$itemlost,$damaged,$itemnumber);

print $cgi->redirect("moredetail.pl?biblionumber=$biblionumber&itemnumber=$itemnumber");
