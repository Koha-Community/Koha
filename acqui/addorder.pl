#!/usr/bin/perl

#script to add an order into the system
#written 29/2/00 by chris@katipo.co.nz

use strict;
use CGI;
use C4::Output;
use C4::Acquisitions;

my $input = new CGI;
my $existing=$input->param('existing');
my $title=$input->param('title');
$title=~ s/\'/\\\'/g;
my $author=$input->param('author');
$author=~ s/\'/\\\'/g;
my $copyright=$input->param('copyright');
my $isbn=$input->param('ISBN');
my $itemtype=$input->param('format');
my $ordnum=$input->param('ordnum');
my $basketno=$input->param('basket');
my $quantity=$input->param('quantity');
my $listprice=$input->param('list_price');
my $series=$input->param('Series');
if ($listprice eq ''){
  $listprice=0;
}
my $supplier=$input->param('supplier');
my $notes=$input->param('notes');
my $bookfund=$input->param('bookfund');
my $who=$input->remote_user;
my $bibnum;
my $bibitemnum;
my $rrp=$input->param('rrp');
my $ecost=$input->param('ecost');
my $gst=$input->param('GST');
my $orderexists=$input->param('orderexists');

#check to see if biblio exists
if ($quantity ne '0'){

  if ($existing eq 'no'){
    #if it doesnt create it
    $bibnum = &newbiblio({ title     => $title?$title:"",
	                   author    => $author?$author:"",
	                   copyright => $copyright?$copyright:"" });
    $bibitemnum = &newbiblioitem({ biblionumber => $bibnum,
 	                           itemtype     => $itemtype?$itemtype:"",
	                           isben        => $isbn?$isbn:"" });
	if ($title) {
    		newsubtitle($bibnum,$title);
	}
    modbiblio({ biblionumber  => $bibnum,
	        title         => $title?$title:"",
	        author        => $author?$author:"",
	        copyrightdate => $copyright?$copyright:"",
	        series        => $series?$series:"" });
  } else {
    $bibnum=$input->param('biblio');
    $bibitemnum=$input->param('bibitemnum');
    my $oldtype=$input->param('oldtype');
    if ($bibitemnum eq '' || $itemtype ne $oldtype){
      $bibitemnum= &newbiblioitem({ biblionumber => $bibnum,
	 						 itemtype => $itemtype?$itemtype:"",
							 isben => $isbn?$isbn:"" });
    }
    &modbiblio({
        biblionumber  => $bibnum,
	title         => $title?$title:"",
	author        => $author?$author:"",
	copyrightdate => $copyright?$copyright:"",
	series        => $series?$series:"" });
  }
  if ($orderexists ne '') {
    modorder($title,$ordnum,$quantity,$listprice,$bibnum,$basketno,$supplier,$who,$notes,$bookfund,$bibitemnum,$rrp,$ecost,$gst);
  }else {
    neworder($bibnum,$title,$ordnum,$basketno,$quantity,$listprice,$supplier,$who,$notes,$bookfund,$bibitemnum,$rrp,$ecost,$gst);
  }
} else {
  $bibnum=$input->param('biblio');
  delorder($bibnum,$ordnum);
}

print $input->redirect("newbasket.pl?id=$supplier&basket=$basketno");
