#!/usr/bin/perl
# NOTE: Use standard 8-space tabs for this file (indents are 4 spaces)

# $Id$

# Copyright 2000-2003 Katipo Communications
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
require Exporter;
use C4::Koha;
use CGI;
use C4::Search;
use C4::Acquisition;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Date;
use C4::Context;
use C4::Biblio;
use C4::Accounts2;
use C4::Circulation::Circ2;

my $dbh=C4::Context->dbh;
my $query=new CGI;


my ($template, $loggedinuser, $cookie) = get_template_and_user({
	template_name   => ( 'catalogue/moredetail.tmpl'),
	query           => $query,
	type            => "intranet",
	authnotrequired => 0,
	flagsrequired   => {catalogue => 1},
    });

# get variables
my $op=$query->param('op');
my $lost=$query->param('lost');
my $withdrawn=$query->param('withdrawn');
my $override=$query->param('override');
my $itemnumber=$query->param('itemnumber');
my $barcode=$query->param('barcode');

my $title=$query->param('title');
my $biblionumber=$query->param('biblionumber');
my ($record)=XMLgetbibliohash($dbh,$biblionumber);
my $data=XMLmarc2koha_onerecord($dbh,$record,"biblios");
my $dewey = $data->{'dewey'};
# FIXME Dewey is a string, not a number, & we should use a function
$dewey =~ s/0+$//;
if ($dewey eq "000.") { $dewey = "";};
if ($dewey < 10){$dewey='00'.$dewey;}
if ($dewey < 100 && $dewey > 10){$dewey='0'.$dewey;}
if ($dewey <= 0){
      $dewey='';
}
$dewey=~ s/\.$//;
$data->{'dewey'}=$dewey;

my @results;

my @items;
if ($op eq "update"){
my $env;
##Do Lost or Withdraw here
my $flag=0;
  my ($resbor,$resrec)=C4::Reserves2::CheckReserves($env,$dbh,$itemnumber);
if ($override ne "yes"){
  if ($resbor){
#    print $query->header;
    $template->param(error => "This item   has a reserve on it");
 $template->param(biblionumber =>$biblionumber);
 $template->param(itemnumber =>$itemnumber);
 $template->param(lost =>$lost);
 $template->param(withdrawn =>$withdrawn);
    $flag=1;
  }
  my $sth=$dbh->prepare("Select * from issues where (itemnumber=?) and (returndate is null)");
  $sth->execute($itemnumber);
 
  if (my $data=$sth->fetchrow_hashref) {
   $template->param(biblionumber =>$biblionumber);
 $template->param(itemnumber =>$itemnumber);
 $template->param(error => "This item   is On Loan to a member");
 $template->param(lost =>$lost);
 $template->param(withdrawn =>$withdrawn);
    $flag=2;
  }
}
if ($flag != 0 && $override ne "yes"){

  }else {
   ##UPDATE here

XMLmoditemonefield($dbh,$biblionumber,$itemnumber,'wthdrawn',$withdrawn,1);
XMLmoditemonefield($dbh,$biblionumber,$itemnumber,'itemlost',$lost);

     if ($lost ==1 && $flag ==2){
    my $sth=$dbh->prepare("Select * from issues where (itemnumber=?) and (returndate is null)");
    $sth->execute($itemnumber);
    my $data=$sth->fetchrow_hashref;
    if ($data->{'borrowernumber'} ne '') {
      #item on issue add replacement cost to borrowers record
      my $accountno=getnextacctno($env,$data->{'borrowernumber'},$dbh);
      my $item=getiteminformation($env, $itemnumber);
      my $sth2=$dbh->prepare("Insert into accountlines
      (borrowernumber,accountno,date,amount,description,accounttype,amountoutstanding,itemnumber)
      values
      (?,?,now(),?,?,'L',?,?)");
      $sth2->execute($data->{'borrowernumber'},$accountno,$item->{'replacementprice'},
      "Lost Item $item->{'title'} $item->{'barcode'}",
      $item->{'replacementprice'},$itemnumber);
      $sth2->finish;
    }
    }
	if ($flag==1){
	foreach my $res ($resrec){
	C4::Reserves2::CancelReseve(undef,$res->{itemnumber},$res->{borrowernumber});
	}
	}
    
  }
}
my @itemrecords=XMLgetallitems($dbh,$biblionumber);
foreach my $itemrecord (@itemrecords){
$itemrecord=XML_xml2hash_onerecord($itemrecord);
my $items = XMLmarc2koha_onerecord($dbh,$itemrecord,"holdings");
$items->{itemtype}=$data->{itemtype};
$items->{biblionumber}=$biblionumber;
$items=itemissues($dbh,$items,$items->{'itemnumber'});
push @items,$items;
}
my $count=@items;
$data->{'count'}=$count;
my ($order,$ordernum)=GetOrder($biblionumber,$barcode);

my $env;
$env->{itemcount}=1;

$results[0]=$data;

foreach my $item (@items){
    $item->{'replacementprice'}=sprintf("%.2f", $item->{'replacementprice'});
    $item->{'datelastborrowed'}= format_date($item->{'datelastborrowed'});
    $item->{'dateaccessioned'} = format_date($item->{'dateaccessioned'});
    $item->{'datelastseen'} = format_date($item->{'datelastseen'});
    $item->{'ordernumber'} = $ordernum;
    $item->{'booksellerinvoicenumber'} = $order->{'booksellerinvoicenumber'};

    if ($item->{'date_due'} gt '0000-00-00'){
	$item->{'date_due'} = format_date($item->{'date_due'});		
$item->{'issue'}= 1;
		$item->{'borrowernumber'} = $item->{'borrower'};
		$item->{'cardnumber'} = $item->{'card'};
			
    } else {
	$item->{'issue'}= 0;
    }
}

$template->param(BIBITEM_DATA => \@results);
$template->param(ITEM_DATA => \@items);
$template->param(loggedinuser => $loggedinuser);

output_html_with_http_headers $query, $cookie, $template->output;


# Local Variables:
# tab-width: 8
# End:
