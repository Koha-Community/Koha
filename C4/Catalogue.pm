package C4::Catalogue;

# Continue working on updateItem!!!!!!
#
# updateItem is looking not bad.  Need to add addSubfield and deleteSubfield
# functions
#
# Trying to track down $dbh's that aren't disconnected....


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
use C4::Context;
use MARC::Record;
use C4::Biblio;

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Catalogue - Koha functions for dealing with orders and acquisitions

=head1 SYNOPSIS

  use C4::Catalogue;

=head1 DESCRIPTION

The functions in this module deal with acquisitions, managing book
orders, converting money to different currencies, and so forth.

=head1 FUNCTIONS

=over 2

=cut

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

#
#
#
# BASKETS
#
#
#
=item basket

  ($count, @orders) = &basket($basketnumber, $booksellerID);

Looks up the pending (non-cancelled) orders with the given basket
number. If C<$booksellerID> is non-empty, only orders from that seller
are returned.

C<&basket> returns a two-element array. C<@orders> is an array of
references-to-hash, whose keys are the fields from the aqorders,
biblio, and biblioitems tables in the Koha database. C<$count> is the
number of elements in C<@orders>.

=cut
#'
sub basket {
  my ($basketno,$supplier)=@_;
  my $dbh = C4::Context->dbh;
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
  return($i,@results);
}

=item newbasket

  $basket = &newbasket();

Finds the next unused basket number in the aqorders table of the Koha
database, and returns it.

=cut
#'
# FIXME - There's a race condition here:
#	A calls &newbasket
#	B calls &newbasket (gets the same number as A)
#	A updates the basket
#	B updates the basket, and clobbers A's result.
# A better approach might be to create a dummy order (with, say,
# requisitionedby == "Dummy-$$" or notes == "dummy <time> <pid>"), and
# see which basket number it gets. Then have a cron job periodically
# remove out-of-date dummy orders.
sub newbasket {
  my $dbh = C4::Context->dbh;
  my $query="Select max(basketno) from aqorders";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_arrayref;
  my $basket=$$data[0];
  $basket++;
  $sth->finish;
  return($basket);
}

=item neworder

  &neworder($biblionumber, $title, $ordnum, $basket, $quantity, $listprice,
	$booksellerid, $who, $notes, $bookfund, $biblioitemnumber, $rrp,
	$ecost, $gst, $budget, $unitprice, $subscription,
	$booksellerinvoicenumber);

Adds a new order to the database. Any argument that isn't described
below is the new value of the field with the same name in the aqorders
table of the Koha database.

C<$ordnum> is a "minimum order number." After adding the new entry to
the aqorders table, C<&neworder> finds the first entry in aqorders
with order number greater than or equal to C<$ordnum>, and adds an
entry to the aqorderbreakdown table, with the order number just found,
and the book fund ID of the newly-added order.

C<$budget> is effectively ignored.

C<$subscription> may be either "yes", or anything else for "no".

=cut
#'
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
  my $dbh = C4::Context->dbh;
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
}

=item delorder

  &delorder($biblionumber, $ordernumber);

Cancel the order with the given order and biblio numbers. It does not
delete any entries in the aqorders table, it merely marks them as
cancelled.

If there are no items remaining with the given biblionumber,
C<&delorder> also deletes them from the marc_subfield_table and
marc_biblio tables of the Koha database.

=cut
#'
sub delorder {
  my ($bibnum,$ordnum)=@_;
  my $dbh = C4::Context->dbh;
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
}

=item modorder

  &modorder($title, $ordernumber, $quantity, $listprice,
	$biblionumber, $basketno, $supplier, $who, $notes,
	$bookfundid, $bibitemnum, $rrp, $ecost, $gst, $budget,
	$unitprice, $booksellerinvoicenumber);

Modifies an existing order. Updates the order with order number
C<$ordernumber> and biblionumber C<$biblionumber>. All other arguments
update the fields with the same name in the aqorders table of the Koha
database.

Entries with order number C<$ordernumber> in the aqorderbreakdown
table are also updated to the new book fund ID.

=cut
#'
sub modorder {
  my ($title,$ordnum,$quantity,$listprice,$bibnum,$basketno,$supplier,$who,$notes,$bookfund,$bibitemnum,$rrp,$ecost,$gst,$budget,$cost,$invoice)=@_;
  my $dbh = C4::Context->dbh;
  my $query="update aqorders set title='$title',
  quantity='$quantity',listprice='$listprice',basketno='$basketno',
  rrp='$rrp',ecost='$ecost',unitprice='$cost',
  booksellerinvoicenumber='$invoice'
  where
  ordernumber=$ordnum and biblionumber=$bibnum";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $query="update aqorderbreakdown set bookfundid=? where
  ordernumber=?";
  $sth=$dbh->prepare($query);
  $sth->execute($bookfund,$ordnum);
  $sth->finish;
}

=item newordernum

  $order = &newordernum();

Finds the next unused order number in the aqorders table of the Koha
database, and returns it.

=cut
#'
# FIXME - Race condition
sub newordernum {
  my $dbh = C4::Context->dbh;
  my $query="Select max(ordernumber) from aqorders";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_arrayref;
  my $ordnum=$$data[0];
  $ordnum++;
  $sth->finish;
  return($ordnum);
}

=item receiveorder

  &receiveorder($biblionumber, $ordernumber, $quantityreceived, $user,
	$unitprice, $booksellerinvoicenumber, $biblioitemnumber,
	$freight, $bookfund, $rrp);

Updates an order, to reflect the fact that it was received, at least
in part. All arguments not mentioned below update the fields with the
same name in the aqorders table of the Koha database.

Updates the order with bibilionumber C<$biblionumber> and ordernumber
C<$ordernumber>.

Also updates the book fund ID in the aqorderbreakdown table.

=cut
#'
sub receiveorder {
  my ($biblio,$ordnum,$quantrec,$user,$cost,$invoiceno,$bibitemno,$freight,$bookfund,$rrp)=@_;
  my $dbh = C4::Context->dbh;
  my $query="update aqorders set quantityreceived=?,datereceived=now(),booksellerinvoicenumber=?,
  										biblioitemnumber=?,unitprice=?,freight=?,rrp=?
  						where biblionumber=? and ordernumber=?";
  my $sth=$dbh->prepare($query);
  $sth->execute($quantrec,$invoiceno,$bibitemno,$cost,$freight,$rrp,$biblio,$ordnum);
  $sth->finish;
  $query="update aqorderbreakdown set bookfundid=? where
  ordernumber=?";
  $sth=$dbh->prepare($query);
  $sth->execute($bookfund,$ordnum);
  $sth->finish;
}

=item updaterecorder

  &updaterecorder($biblionumber, $ordernumber, $user, $unitprice,
	$bookfundid, $rrp);

Updates the order with biblionumber C<$biblionumber> and order number
C<$ordernumber>. C<$bookfundid> is the new value for the book fund ID
in the aqorderbreakdown table of the Koha database. All other
arguments update the fields with the same name in the aqorders table.

C<$user> is ignored.

=cut
#'
sub updaterecorder{
  my($biblio,$ordnum,$user,$cost,$bookfund,$rrp)=@_;
  my $dbh = C4::Context->dbh;
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
}

#
#
# ORDERS
#
#

=item getorders

  ($count, $orders) = &getorders($booksellerid);

Finds pending orders from the bookseller with the given ID. Ignores
completed and cancelled orders.

C<$count> is the number of elements in C<@{$orders}>.

C<$orders> is a reference-to-array; each element is a
reference-to-hash with the following fields:

=over 4

=item C<count(*)>

Gives the number of orders in with this basket number.

=item C<authorizedby>

=item C<entrydate>

=item C<basketno>

These give the value of the corresponding field in the aqorders table
of the Koha database.

=back

Results are ordered from most to least recent.

=cut
#'
sub getorders {
  my ($supplierid)=@_;
  my $dbh = C4::Context->dbh;
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
  return ($i,\@results);
}

=item getorder

  ($order, $ordernumber) = &getorder($biblioitemnumber, $biblionumber);

Looks up the order with the given biblionumber and biblioitemnumber.

Returns a two-element array. C<$ordernumber> is the order number.
C<$order> is a reference-to-hash describing the order; its keys are
fields from the biblio, biblioitems, aqorders, and aqorderbreakdown
tables of the Koha database.

=cut
#'
# FIXME - This is effectively identical to &C4::Biblio::getorder.
# Pick one and stick with it.
sub getorder{
  my ($bi,$bib)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select ordernumber from aqorders where biblionumber=$bib and
  biblioitemnumber='$bi'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  # FIXME - Use fetchrow_array(), since we're only interested in the one
  # value.
  my $ordnum=$sth->fetchrow_hashref;
  $sth->finish;
  my $order=getsingleorder($ordnum->{'ordernumber'});
#  print $query;
  return ($order,$ordnum->{'ordernumber'});
}

=item getsingleorder

  $order = &getsingleorder($ordernumber);

Looks up an order by order number.

Returns a reference-to-hash describing the order. The keys of
C<$order> are fields from the biblio, biblioitems, aqorders, and
aqorderbreakdown tables of the Koha database.

=cut
#'
# FIXME - This is effectively identical to
# &C4::Biblio::getsingleorder.
# Pick one and stick with it.
sub getsingleorder {
  my ($ordnum)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from biblio,biblioitems,aqorders,aqorderbreakdown
  where aqorders.ordernumber='$ordnum'
  and biblio.biblionumber=aqorders.biblionumber and
  biblioitems.biblioitemnumber=aqorders.biblioitemnumber and
  aqorders.ordernumber=aqorderbreakdown.ordernumber";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data);
}

=item getallorders

  ($count, @results) = &getallorders($booksellerid);

Looks up all of the pending orders from the supplier with the given
bookseller ID. Ignores cancelled and completed orders.

C<$count> is the number of elements in C<@results>. C<@results> is an
array of references-to-hash. The keys of each element are fields from
the aqorders, biblio, and biblioitems tables of the Koha database.

C<@results> is sorted alphabetically by book title.

=cut
#'
sub getallorders {
  #gets all orders from a certain supplier, orders them alphabetically
  my ($supid)=@_;
  my $dbh = C4::Context->dbh;
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
  return($i,@results);
}

# FIXME - Never used
sub getrecorders {
  #gets all orders from a certain supplier, orders them alphabetically
  my ($supid)=@_;
  my $dbh = C4::Context->dbh;
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
  return($i,@results);
}

=item ordersearch

  ($count, @results) = &ordersearch($search, $biblionumber, $complete);

Searches for orders.

C<$search> may take one of several forms: if it is an ISBN,
C<&ordersearch> returns orders with that ISBN. If C<$search> is an
order number, C<&ordersearch> returns orders with that order number
and biblionumber C<$biblionumber>. Otherwise, C<$search> is considered
to be a space-separated list of search terms; in this case, all of the
terms must appear in the title (matching the beginning of title
words).

If C<$complete> is C<yes>, the results will include only completed
orders. In any case, C<&ordersearch> ignores cancelled orders.

C<&ordersearch> returns an array. C<$count> is the number of elements
in C<@results>. C<@results> is an array of references-to-hash with the
following keys:

=over 4

=item C<author>

=item C<seriestitle>

=item C<branchcode>

=item C<bookfundid>

=back

=cut
#'
sub ordersearch {
	my ($search,$id,$biblio,$catview) = @_;
	my $dbh   = C4::Context->dbh;
	my $query = "Select *,biblio.title from aqorders,biblioitems,biblio
							where aqorders.biblioitemnumber = biblioitems.biblioitemnumber
									and aqorders.booksellerid = '$id'
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
			# FIXME - Redo this properly instead of hacking off the
			# trailing 'and'.
	$query.=" ) or biblioitems.isbn='$search' or (aqorders.ordernumber='$search' and aqorders.biblionumber='$biblio')) ";
	if ($catview ne 'yes'){
		$query.=" and (quantityreceived < quantity or quantityreceived is NULL)";
	}
	$query.=" group by aqorders.ordernumber";
	my $sth=$dbh->prepare($query);
	$sth->execute;
	my $i=0;
	my @results;
	my $sth2=$dbh->prepare("Select * from biblio where biblionumber=?");
	my $sth3=$dbh->prepare("Select * from aqorderbreakdown where ordernumber=?");
	while (my $data=$sth->fetchrow_hashref){
		$sth2->execute($data->{'biblionumber'});
		my $data2=$sth2->fetchrow_hashref;
		$data->{'author'}=$data2->{'author'};
		$data->{'seriestitle'}=$data2->{'seriestitle'};
		$sth3->execute($data->{'ordernumber'});
		my $data3=$sth3->fetchrow_hashref;
		$data->{'branchcode'}=$data3->{'branchcode'};
		$data->{'bookfundid'}=$data3->{'bookfundid'};
		$results[$i]=$data;
		$i++;
	}
	$sth->finish;
	$sth2->finish;
	$sth3->finish;
	return($i,@results);
}

#
#
# MONEY
#
#
=item invoice

  ($count, @results) = &invoice($booksellerinvoicenumber);

Looks up orders by invoice number.

Returns an array. C<$count> is the number of elements in C<@results>.
C<@results> is an array of references-to-hash; the keys of each
elements are fields from the aqorders, biblio, and biblioitems tables
of the Koha database.

=cut
#'
sub invoice {
  my ($invoice)=@_;
  my $dbh = C4::Context->dbh;
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
  return($i,@results);
}

=item bookfunds

  ($count, @results) = &bookfunds();

Returns a list of all book funds.

C<$count> is the number of elements in C<@results>. C<@results> is an
array of references-to-hash, whose keys are fields from the aqbookfund
and aqbudget tables of the Koha database. Results are ordered
alphabetically by book fund name.

=cut
#'
sub bookfunds {
  my $dbh = C4::Context->dbh;
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
  return($i,@results);
}

# FIXME - POD. I can't figure out what this function is doing. Then
# again, I don't think it's being used (anymore).
sub bookfundbreakdown {
  my ($id)=@_;
  my $dbh = C4::Context->dbh;
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
  return($spent,$comtd);
}

=item curconvert

  $foreignprice = &curconvert($currency, $localprice);

Converts the price C<$localprice> to foreign currency C<$currency> by
dividing by the exchange rate, and returns the result.

If no exchange rate is found, C<&curconvert> assumes the rate is one
to one.

=cut
#'
sub curconvert {
  my ($currency,$price)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select rate from currency where currency='$currency'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  my $cur=$data->{'rate'};
  if ($cur==0){
    $cur=1;
  }
  return($price / $cur);
}

=item getcurrencies

  ($count, $currencies) = &getcurrencies();

Returns the list of all known currencies.

C<$count> is the number of elements in C<$currencies>. C<$currencies>
is a reference-to-array; its elements are references-to-hash, whose
keys are the fields from the currency table in the Koha database.

=cut
#'
sub getcurrencies {
  my $dbh = C4::Context->dbh;
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
  return($i,\@results);
}

=item updatecurrencies

  &updatecurrencies($currency, $newrate);

Sets the exchange rate for C<$currency> to be C<$newrate>.

=cut
#'
sub updatecurrencies {
  my ($currency,$rate)=@_;
  my $dbh = C4::Context->dbh;
  my $query="update currency set rate=$rate where currency='$currency'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
}

# FIXME - This is never used
sub updatecost{
  my($price,$rrp,$itemnum)=@_;
  my $dbh = C4::Context->dbh;
  my $query="update items set price='$price',replacementprice='$rrp'
  where itemnumber=$itemnum";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
}

#
#
# OTHERS
#
#

=item bookseller

  ($count, @results) = &bookseller($searchstring);

Looks up a book seller. C<$searchstring> may be either a book seller
ID, or a string to look for in the book seller's name.

C<$count> is the number of elements in C<@results>. C<@results> is an
array of references-to-hash, whose keys are the fields of of the
aqbooksellers table in the Koha database.

=cut
#'
sub bookseller {
  my ($searchstring)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from aqbooksellers where name like '$searchstring%' or
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
  return($i,@results);
}

=item breakdown

  ($count, $results) = &breakdown($ordernumber);

Looks up an order by order ID, and returns its breakdown.

C<$count> is the number of elements in C<$results>. C<$results> is a
reference-to-array; its elements are references-to-hash, whose keys
are the fields of the aqorderbreakdown table in the Koha database.

=cut
#'
sub breakdown {
  my ($id)=@_;
  my $dbh = C4::Context->dbh;
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
  return($i,\@results);
}

=item branches

  ($count, @results) = &branches();

Returns a list of all library branches.

C<$count> is the number of elements in C<@results>. C<@results> is an
array of references-to-hash, whose keys are the fields of the branches
table of the Koha database.

=cut
#'
sub branches {
    my $dbh   = C4::Context->dbh;
    my $query = "Select * from branches order by branchname";
    my $sth   = $dbh->prepare($query);
    my $i     = 0;
    my @results;

    $sth->execute;
    while (my $data = $sth->fetchrow_hashref) {
        $results[$i] = $data;
    	$i++;
    } # while

    $sth->finish;
    return($i, @results);
} # sub branches

# FIXME - Never used
sub findall {
  my ($biblionumber)=@_;
  my $dbh = C4::Context->dbh;
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
  return(@results);
}

# FIXME - Never used
sub needsmod{
  my ($bibitemnum,$itemtype)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from biblioitems where biblioitemnumber=$bibitemnum
  and itemtype='$itemtype'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $result=0;
  if (my $data=$sth->fetchrow_hashref){
    $result=1;
  }
  $sth->finish;
  return($result);
}

=item updatesup

  &updatesup($bookseller);

Updates the information for a given bookseller. C<$bookseller> is a
reference-to-hash whose keys are the fields of the aqbooksellers table
in the Koha database. It must contain entries for all of the fields.
The entry to modify is determined by C<$bookseller-E<gt>{id}>.

The easiest way to get all of the necessary fields is to look up a
book seller with C<&booksellers>, modify what's necessary, then call
C<&updatesup> with the result.

=cut
#'
sub updatesup {
   my ($data)=@_;
   my $dbh = C4::Context->dbh;
   my $query="Update aqbooksellers set
   name=?,address1=?,address2=?,address3=?,address4=?,postal=?,
   phone=?,fax=?,url=?,contact=?,contpos=?,contphone=?,contfax=?,contaltphone=?,
   contemail=?,contnotes=?,active=?,
   listprice=?, invoiceprice=?,gstreg=?, listincgst=?,
   invoiceincgst=?, specialty=?,discount=?,invoicedisc=?,
   nocalc=?
   where id=?";
   my $sth=$dbh->prepare($query);
   $sth->execute($data->{'name'},$data->{'address1'},$data->{'address2'},
   $data->{'address3'},$data->{'address4'},$data->{'postal'},$data->{'phone'},
   $data->{'fax'},$data->{'url'},$data->{'contact'},$data->{'contpos'},
   $data->{'contphone'},$data->{'contfax'},$data->{'contaltphone'},
   $data->{'contemail'},
   $data->{'contnote'},$data->{'active'},$data->{'listprice'},
   $data->{'invoiceprice'},$data->{'gstreg'},$data->{'listincgst'},
   $data->{'invoiceincgst'},$data->{'specialty'},$data->{'discount'},
   $data->{'invoicedisc'},$data->{'nocalc'},$data->{'id'});
   $sth->finish;
#   print $query;
}

=item insertsup

  $id = &insertsup($bookseller);

Creates a new bookseller. C<$bookseller> is a reference-to-hash whose
keys are the fields of the aqbooksellers table in the Koha database.
All fields must be present.

Returns the ID of the newly-created bookseller.

=cut
#'
sub insertsup {
  my ($data)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select max(id) from aqbooksellers");
  $sth->execute;
  my $data2=$sth->fetchrow_hashref;
  $sth->finish;
  $data2->{'max(id)'}++;
  $sth=$dbh->prepare("Insert into aqbooksellers (id) values ($data2->{'max(id)'})");
  $sth->execute;
  $sth->finish;
  $data->{'id'}=$data2->{'max(id)'};
  updatesup($data);
  return($data->{'id'});
}

=item websitesearch

  ($count, @results) = &websitesearch($keywordlist);

Looks up biblioitems by URL.

C<$keywordlist> is a space-separated list of search terms.
C<&websitesearch> returns those biblioitems whose URL contains at
least one of the search terms.

C<$count> is the number of elements in C<@results>. C<@results> is an
array of references-to-hash, whose keys are the fields of the biblio
and biblioitems tables in the Koha database.

=cut
#'
sub websitesearch {
    my ($keywordlist) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "Select distinct biblio.* from biblio, biblioitems where
biblio.biblionumber = biblioitems.biblionumber and (";
    my $count = 0;
    my $sth;
    my @results;
    my @keywords = split(/ +/, $keywordlist);
    my $keyword = shift(@keywords);

    # FIXME - Can use
    #	$query .= join(" and ",
    #		apply { url like "%$_%" } @keywords

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
    return($count, @results);
} # sub websitesearch

=item addwebsite

  &addwebsite($website);

Adds a new web site. C<$website> is a reference-to-hash, with the keys
C<biblionumber>, C<title>, C<description>, and C<url>. All of these
are mandatory.

=cut
#'
sub addwebsite {
    my ($website) = @_;
    my $dbh = C4::Context->dbh;
    my $query;

    # FIXME -
    #	for (qw( biblionumber title description url )) # and any others
    #	{
    #		$website->{$_} = $dbh->quote($_);
    #	}
    # Perhaps extend this to building the query as well. This might allow
    # some of the fields to be optional.
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
} # sub website

=item updatewebsite

  &updatewebsite($website);

Updates an existing web site. C<$website> is a reference-to-hash with
the keys C<websitenumber>, C<title>, C<description>, and C<url>. All
of these are mandatory. C<$website-E<gt>{websitenumber}> identifies
the entry to update.

=cut
#'
sub updatewebsite {
    my ($website) = @_;
    my $dbh = C4::Context->dbh;
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
} # sub updatewebsite

=item deletewebsite

  &deletewebsite($websitenumber);

Deletes the web site with number C<$websitenumber>.

=cut
#'
sub deletewebsite {
    my ($websitenumber) = @_;
    my $dbh = C4::Context->dbh;
    # FIXME - $query is unneeded
    my $query = "Delete from websites where websitenumber = $websitenumber";

    $dbh->do($query);
} # sub deletewebsite

END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
