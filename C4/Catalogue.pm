package C4::Catalogue; #asummes C4/Acquisitions.pm

# Continue working on updateItem!!!!!!
#
# updateItem is looking not bad.  Need to add addSubfield and deleteSubfield
# functions
#
# Trying to track down $dbh's that aren't disconnected....
#



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
require Exporter;
use C4::Database;
use MARC::Record;
use C4::Biblio;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(
	     &basket &newbasket

	     &getorders &getallorders &getrecorders 
	     &getorder &neworder &delorder
	     &ordersearch
	     &modorder &getsingleorder &invoice &receiveorder
	     &updaterecorder &newordernum 

	     &bookfunds &bookfundbreakdown &updatecost 
	     &curconvert &getcurrencies &updatecurrencies &getcurrency 

	     &findall &needsmod &branches &updatesup &insertsup
	     &bookseller &breakdown &checkitems
	     &websitesearch &addwebsite &updatewebsite &deletewebsite
);
%EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],

# your exported package globals go here,
# as well as any optionally exported functions

@EXPORT_OK   = qw($Var1 %Hashit);


# non-exported package globals go here
use vars qw(@more $stuff);

# initalize package globals, first exported ones

my $Var1   = '';
my %Hashit = ();


# then the others (which are still accessible as $Some::Module::stuff)
my $stuff  = '';
my @more   = ();

# all file-scoped lexicals must be created before
# the functions below that use them.

# file-private lexicals go here
my $priv_var    = '';
my %secret_hash = ();

# here's a file-private function as a closure,
# callable as &$priv_func;  it cannot be prototyped.
my $priv_func = sub {
  # stuff goes here.
  };
  
# make all your functions, whether exported or not;


#
#
#
# BASKETS
#
#
#
sub basket {
  my ($basketno,$supplier)=@_;
  my $dbh=C4Connect;
  my $query="Select *,biblio.title from aqorders,biblio,biblioitems 
  where basketno='$basketno'
  and biblio.biblionumber=aqorders.biblionumber and biblioitems.biblioitemnumber
  =aqorders.biblioitemnumber 
  and (datecancellationprinted is NULL or datecancellationprinted =
  '0000-00-00')";
  if ($supplier ne ''){
    $query.=" and aqorders.booksellerid='$supplier'";
  }
  $query.=" group by aqorders.ordernumber";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
#  print $query;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,@results);
}

sub newbasket {
  my $dbh=C4Connect;
  my $query="Select max(basketno) from aqorders";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_arrayref;
  my $basket=$$data[0];
  $basket++;
  $sth->finish;
  $dbh->disconnect;
  return($basket);
}
sub neworder {
  my ($bibnum,$title,$ordnum,$basket,$quantity,$listprice,$supplier,$who,$notes,$bookfund,$bibitemnum,$rrp,$ecost,$gst,$budget,$cost,$sub,$invoice)=@_;
  if ($budget eq 'now'){
    $budget="now()";
  } else {
    $budget="'2001-07-01'";
  }
  if ($sub eq 'yes'){
    $sub=1;
  } else {
    $sub=0;
  }
  my $dbh=C4Connect;
  my $query="insert into aqorders (biblionumber,title,basketno,
  quantity,listprice,booksellerid,entrydate,requisitionedby,authorisedby,notes,
  biblioitemnumber,rrp,ecost,gst,unitprice,subscription,booksellerinvoicenumber)

  values
  ($bibnum,'$title',$basket,$quantity,$listprice,'$supplier',now(),
  '$who','$who','$notes',$bibitemnum,'$rrp','$ecost','$gst','$cost',
  '$sub','$invoice')";
  my $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;
  $query="select * from aqorders where
  biblionumber=$bibnum and basketno=$basket and ordernumber >=$ordnum";
  $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $ordnum=$data->{'ordernumber'};
  $query="insert into aqorderbreakdown (ordernumber,bookfundid) values
  ($ordnum,'$bookfund')";
  $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub delorder {
  my ($bibnum,$ordnum)=@_;
  my $dbh=C4Connect;
  my $query="update aqorders set datecancellationprinted=now()
  where biblionumber='$bibnum' and
  ordernumber='$ordnum'";
  my $sth=$dbh->prepare($query);
  #print $query;
  $sth->execute;
  $sth->finish;
  my $count=itemcount($bibnum);
  if ($count == 0){
    delbiblio($bibnum);
  }
  $dbh->disconnect;
}

sub modorder {
  my ($title,$ordnum,$quantity,$listprice,$bibnum,$basketno,$supplier,$who,$notes,$bookfund,$bibitemnum,$rrp,$ecost,$gst,$budget,$cost,$invoice)=@_;
  my $dbh=C4Connect;
  my $query="update aqorders set title='$title',
  quantity='$quantity',listprice='$listprice',basketno='$basketno', 
  rrp='$rrp',ecost='$ecost',unitprice='$cost',
  booksellerinvoicenumber='$invoice'
  where
  ordernumber=$ordnum and biblionumber=$bibnum";
  my $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;
  $query="update aqorderbreakdown set bookfundid=$bookfund where
  ordernumber=$ordnum";
  $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub newordernum {
  my $dbh=C4Connect;
  my $query="Select max(ordernumber) from aqorders";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_arrayref;
  my $ordnum=$$data[0];
  $ordnum++;
  $sth->finish;
  $dbh->disconnect;
  return($ordnum);
}

sub receiveorder {
  my ($biblio,$ordnum,$quantrec,$user,$cost,$invoiceno,$bibitemno,$freight,$bookfund,$rrp)=@_;
  my $dbh=C4Connect;
  my $query="update aqorders set quantityreceived='$quantrec',
  datereceived=now(),booksellerinvoicenumber='$invoiceno',
  biblioitemnumber=$bibitemno,unitprice='$cost',freight='$freight',
  rrp='$rrp'
  where biblionumber=$biblio and ordernumber=$ordnum
  ";
#  print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $query="update aqorderbreakdown set bookfundid=$bookfund where
  ordernumber=$ordnum";
  $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;  
  $dbh->disconnect;
}
sub updaterecorder{
  my($biblio,$ordnum,$user,$cost,$bookfund,$rrp)=@_;
  my $dbh=C4Connect;
  my $query="update aqorders set
  unitprice='$cost', rrp='$rrp'
  where biblionumber=$biblio and ordernumber=$ordnum
  ";
#  print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $query="update aqorderbreakdown set bookfundid=$bookfund where
  ordernumber=$ordnum";
  $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;  
  $dbh->disconnect;
}

#
#
# ORDERS
#
#

sub getorders {
  my ($supplierid)=@_;
  my $dbh=C4Connect;
  my $query = "Select count(*),authorisedby,entrydate,basketno from aqorders where 
  booksellerid='$supplierid' and (quantity > quantityreceived or
  quantityreceived is NULL)
  and (datecancellationprinted is NULL or datecancellationprinted = '0000-00-00')";
  $query.=" group by basketno order by entrydate desc";
  #print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return ($i,\@results);
}

sub getorder{
  my ($bi,$bib)=@_;
  my $dbh=C4Connect;
  my $query="Select ordernumber from aqorders where biblionumber=$bib and
  biblioitemnumber='$bi'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $ordnum=$sth->fetchrow_hashref;
  $sth->finish;
  my $order=getsingleorder($ordnum->{'ordernumber'});
  $dbh->disconnect;
#  print $query;
  return ($order,$ordnum->{'ordernumber'});
}

sub getsingleorder {
  my ($ordnum)=@_;
  my $dbh=C4Connect;
  my $query="Select * from biblio,biblioitems,aqorders,aqorderbreakdown 
  where aqorders.ordernumber='$ordnum' 
  and biblio.biblionumber=aqorders.biblionumber and
  biblioitems.biblioitemnumber=aqorders.biblioitemnumber and
  aqorders.ordernumber=aqorderbreakdown.ordernumber";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  return($data);
}

sub getallorders {
  #gets all orders from a certain supplier, orders them alphabetically
  my ($supid)=@_;
  my $dbh=C4Connect;
  my $query="Select * from aqorders,biblio,biblioitems where booksellerid='$supid'
  and (cancelledby is NULL or cancelledby = '')
  and (quantityreceived < quantity or quantityreceived is NULL)
  and biblio.biblionumber=aqorders.biblionumber and biblioitems.biblioitemnumber=
  aqorders.biblioitemnumber
  group by aqorders.biblioitemnumber
  order by
  biblio.title";
  my $i=0;
  my @results;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,@results);
}

sub getrecorders {
  #gets all orders from a certain supplier, orders them alphabetically
  my ($supid)=@_;
  my $dbh=C4Connect;
  my $query="Select * from aqorders,biblio,biblioitems where booksellerid='$supid'
  and (cancelledby is NULL or cancelledby = '')
  and biblio.biblionumber=aqorders.biblionumber and biblioitems.biblioitemnumber=                    
  aqorders.biblioitemnumber and
  aqorders.quantityreceived>0
  and aqorders.datereceived >=now()
  group by aqorders.biblioitemnumber 
  order by
  biblio.title";
  my $i=0;
  my @results;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,@results);
}

sub ordersearch {
  my ($search,$biblio,$catview) = @_;
  my $dbh   = C4Connect;
  my $query = "Select *,biblio.title from aqorders,biblioitems,biblio
where aqorders.biblioitemnumber = biblioitems.biblioitemnumber
and biblio.biblionumber=aqorders.biblionumber
and ((datecancellationprinted is NULL)
or (datecancellationprinted = '0000-00-00'))
and ((";
  my @data  = split(' ',$search);
  my $count = @data;
  for (my $i = 0; $i < $count; $i++) {
    $query .= "(biblio.title like '$data[$i]%' or biblio.title like '% $data[$i]%') and ";
  }
  $query=~ s/ and $//;
  $query.=" ) or biblioitems.isbn='$search'
  or (aqorders.ordernumber='$search' and aqorders.biblionumber='$biblio')) ";
  if ($catview ne 'yes'){
    $query.=" and (quantityreceived < quantity or quantityreceived is NULL)";
  }
  $query.=" group by aqorders.ordernumber";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $i=0;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
     my $sth2=$dbh->prepare("Select * from biblio where
     biblionumber='$data->{'biblionumber'}'");
     $sth2->execute;
     my $data2=$sth2->fetchrow_hashref;
     $sth2->finish;
     $data->{'author'}=$data2->{'author'};
     $data->{'seriestitle'}=$data2->{'seriestitle'};
     $sth2=$dbh->prepare("Select * from aqorderbreakdown where
    ordernumber=$data->{'ordernumber'}");
    $sth2->execute;
    $data2=$sth2->fetchrow_hashref;
    $sth2->finish;
    $data->{'branchcode'}=$data2->{'branchcode'};
    $data->{'bookfundid'}=$data2->{'bookfundid'};
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,@results);
}

#
#
# MONEY
#
#
sub invoice {
  my ($invoice)=@_;
  my $dbh=C4Connect;
  my $query="Select * from aqorders,biblio,biblioitems where
  booksellerinvoicenumber='$invoice'
  and biblio.biblionumber=aqorders.biblionumber and biblioitems.biblioitemnumber=
  aqorders.biblioitemnumber group by aqorders.ordernumber,aqorders.biblioitemnumber";
  my $i=0;
  my @results;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,@results);
}

sub bookfunds {
  my $dbh=C4Connect;
  my $query="Select * from aqbookfund,aqbudget where aqbookfund.bookfundid
  =aqbudget.bookfundid
  group by aqbookfund.bookfundid order by bookfundname";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,@results);
}

sub bookfundbreakdown {
  my ($id)=@_;
  my $dbh=C4Connect;
  my $query="Select quantity,datereceived,freight,unitprice,listprice,ecost,quantityreceived,subscription
  from aqorders,aqorderbreakdown where bookfundid='$id' and 
  aqorders.ordernumber=aqorderbreakdown.ordernumber
  and (datecancellationprinted is NULL or
  datecancellationprinted='0000-00-00')";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $comtd=0;
  my $spent=0;
  while (my $data=$sth->fetchrow_hashref){
    if ($data->{'subscription'} == 1){
      $spent+=$data->{'quantity'}*$data->{'unitprice'};
    } else {
      my $leftover=$data->{'quantity'}-$data->{'quantityreceived'};
      $comtd+=($data->{'ecost'})*$leftover;
      $spent+=($data->{'unitprice'})*$data->{'quantityreceived'};
    }
  }
  $sth->finish;
  $dbh->disconnect;
  return($spent,$comtd);
}

sub curconvert {
  my ($currency,$price)=@_;
  my $dbh=C4Connect;
  my $query="Select rate from currency where currency='$currency'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  my $cur=$data->{'rate'};
  if ($cur==0){
    $cur=1;
  }
  my $price=$price / $cur;
  return($price);
}

sub getcurrencies {
  my $dbh=C4Connect;
  my $query="Select * from currency";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,\@results);
} 

sub getcurrency {
  my ($cur)=@_;
  my $dbh=C4Connect;
  my $query="Select * from currency where currency='$cur'";
  my $sth=$dbh->prepare($query);
  $sth->execute;

  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  return($data);
} 

sub updatecurrencies {
  my ($currency,$rate)=@_;
  my $dbh=C4Connect;
  my $query="update currency set rate=$rate where currency='$currency'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
} 

sub updatecost{
  my($price,$rrp,$itemnum)=@_;
  my $dbh=C4Connect;
  my $query="update items set price='$price',replacementprice='$rrp'
  where itemnumber=$itemnum";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

#
#
# OTHERS
#
#

sub bookseller {
  my ($searchstring)=@_;
  my $dbh=C4Connect;
  my $query="Select * from aqbooksellers where name like '%$searchstring%' or
  id = '$searchstring'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,@results);
}
sub breakdown {
  my ($id)=@_;
  my $dbh=C4Connect;
  my $query="Select * from aqorderbreakdown where ordernumber='$id'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,\@results);
}

sub branches {
    my $dbh   = C4Connect;
    my $query = "Select * from branches";
    my $sth   = $dbh->prepare($query);
    my $i     = 0;
    my @results;

    $sth->execute;
    while (my $data = $sth->fetchrow_hashref) {
        $results[$i] = $data;
    	$i++;
    } # while

    $sth->finish;
    $dbh->disconnect;
    return($i, @results);
} # sub branches

sub findall {
  my ($biblionumber)=@_;
  my $dbh=C4Connect;
  my $query="Select * from biblioitems,items,itemtypes where 
  biblioitems.biblionumber=$biblionumber 
  and biblioitems.biblioitemnumber=items.biblioitemnumber and
  itemtypes.itemtype=biblioitems.itemtype
  order by items.biblioitemnumber";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return(@results);
}

sub needsmod{
  my ($bibitemnum,$itemtype)=@_;
  my $dbh=C4Connect;
  my $query="Select * from biblioitems where biblioitemnumber=$bibitemnum
  and itemtype='$itemtype'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $result=0;
  if (my $data=$sth->fetchrow_hashref){
    $result=1;
  }
  $sth->finish;
  $dbh->disconnect;
  return($result);
}

sub updatesup {
   my ($data)=@_;
   my $dbh=C4Connect;
   my $query="Update aqbooksellers set
   name='$data->{'name'}',address1='$data->{'address1'}',address2='$data->{'address2'}',
   address3='$data->{'address3'}',address4='$data->{'address4'}',postal='$data->{'postal'}',
   phone='$data->{'phone'}',fax='$data->{'fax'}',url='$data->{'url'}',
   contact='$data->{'contact'}',contpos='$data->{'contpos'}',
   contphone='$data->{'contphone'}', contfax='$data->{'contfax'}', contaltphone=
   '$data->{'contaltphone'}', contemail='$data->{'contemail'}', contnotes=
   '$data->{'contnotes'}', active=$data->{'active'},
   listprice='$data->{'listprice'}', invoiceprice='$data->{'invoiceprice'}',
   gstreg=$data->{'gstreg'}, listincgst=$data->{'listincgst'},
   invoiceincgst=$data->{'invoiceincgst'}, specialty='$data->{'specialty'}',
   discount='$data->{'discount'}',invoicedisc='$data->{'invoicedisc'}',
   nocalc='$data->{'nocalc'}'
   where id='$data->{'id'}'";
   my $sth=$dbh->prepare($query);
   $sth->execute;
   $sth->finish;
   $dbh->disconnect;
#   print $query;
}

sub insertsup {
  my ($data)=@_;
  my $dbh=C4Connect;
  my $sth=$dbh->prepare("Select max(id) from aqbooksellers");
  $sth->execute;
  my $data2=$sth->fetchrow_hashref;
  $sth->finish;
  $data2->{'max(id)'}++;
  $sth=$dbh->prepare("Insert into aqbooksellers (id) values ($data2->{'max(id)'})");
  $sth->execute;
  $sth->finish;
  $data->{'id'}=$data2->{'max(id)'};
  $dbh->disconnect;
  updatesup($data);
  return($data->{'id'});
}

sub websitesearch {
    my ($keywordlist) = @_;
    my $dbh   = C4Connect;
    my $query = "Select distinct biblio.* from biblio, biblioitems where
biblio.biblionumber = biblioitems.biblionumber and (";
    my $count = 0;
    my $sth;
    my @results;
    my @keywords = split(/ +/, $keywordlist);
    my $keyword = shift(@keywords);

    $keyword =~ s/%/\\%/g;
    $keyword =~ s/_/\\_/;
    $keyword = "%" . $keyword . "%";
    $keyword = $dbh->quote($keyword);
    $query  .= " (url like $keyword)";

    foreach $keyword (@keywords) {
        $keyword =~ s/%/\\%/;
	$keyword =~ s/_/\\_/;
	$keyword = "%" . $keyword . "%";
        $keyword = $dbh->quote($keyword);
	$query  .= " or (url like $keyword)";
    } # foreach

    $query .= ")";
    $sth    = $dbh->prepare($query);
    $sth->execute;

    while (my $data = $sth->fetchrow_hashref) {
        $results[$count] = $data;
	$count++;
    } # while

    $sth->finish;
    $dbh->disconnect;
    return($count, @results);
} # sub websitesearch


sub addwebsite {
    my ($website) = @_;
    my $dbh = C4Connect;
    my $query;
    
    $website->{'biblionumber'} = $dbh->quote($website->{'biblionumber'});
    $website->{'title'}        = $dbh->quote($website->{'title'});
    $website->{'description'}  = $dbh->quote($website->{'description'});
    $website->{'url'}          = $dbh->quote($website->{'url'});
    
    $query = "Insert into websites set
biblionumber = $website->{'biblionumber'},
title        = $website->{'title'},
description  = $website->{'description'},
url          = $website->{'url'}";
    
    $dbh->do($query);
    
    $dbh->disconnect;
} # sub website


sub updatewebsite {
    my ($website) = @_;
    my $dbh = C4Connect;
    my $query;
    
    $website->{'title'}      = $dbh->quote($website->{'title'});
    $website->{'description'} = $dbh->quote($website->{'description'});
    $website->{'url'}        = $dbh->quote($website->{'url'});
    
    $query = "Update websites set
title       = $website->{'title'},
description = $website->{'description'},
url         = $website->{'url'}
where websitenumber = $website->{'websitenumber'}";

    $dbh->do($query);
    
    $dbh->disconnect;
} # sub updatewebsite


sub deletewebsite {
    my ($websitenumber) = @_;
    my $dbh = C4Connect;
    my $query = "Delete from websites where websitenumber = $websitenumber";
    
    $dbh->do($query);
    
    $dbh->disconnect;
} # sub deletewebsite

END { }       # module clean-up code here (global destructor)
