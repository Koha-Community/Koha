#!/usr/bin/perl

#script to add an order into the system
#written 29/2/00 by chris@katipo.co.nz

use strict;
use CGI;
use C4::Output;
use C4::Acquisitions;
use C4::Biblio;
#use Date::Manip;

my $input = new CGI;
#print $input->header;
#print startpage();
#print startmenu('acquisitions');
#print $input->dump;
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
#check to see if orderexists
my $orderexists=$input->param('orderexists');

#check to see if biblio exists
if ($quantity ne '0'){

  if ($existing eq 'no'){
    #if it doesnt create it
    $bibnum = &newbiblio({ title     => $title,
	                   author    =>$author,
	                   copyright => $copyright });
    $bibitemnum = &newbiblioitem({ biblionumber => $bibnum,
 	                           itemtype     => $itemtype,
	                           isben        => $isbn });
    newsubtitle($bibnum);
    modbiblio($bibnum,$title,$author,$copyright,$series);
  } else {
    $bibnum=$input->param('biblio');
    $bibitemnum=$input->param('bibitemnum');
    my $oldtype=$input->param('oldtype');
    if ($bibitemnum eq '' || $itemtype ne $oldtype){
      $bibitemnum=newbiblioitem($bibnum,$itemtype,$isbn);
    }
    modbiblio($bibnum,$title,$author,$copyright,$series);
  }
  if ($orderexists ne ''){
    modorder($title,$ordnum,$quantity,$listprice,$bibnum,$basketno,$supplier,$who,$notes,$bookfund,$bibitemnum,$rrp,$ecost,$gst);
  }else {
    neworder($bibnum,$title,$ordnum,$basketno,$quantity,$listprice,$supplier,$who,$notes,$bookfund,$bibitemnum,$rrp,$ecost,$gst);
  }
} else {
  #print $input->header;
  #print "del";
  $bibnum=$input->param('biblio');
  delorder($bibnum,$ordnum);
}

print $input->redirect("newbasket.pl?id=$supplier&basket=$basketno");
#print $input->dump;
#print endmenu('acquisitions');
#print endpage();
