package C4::Acquisition;

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
use C4::Date;
use MARC::Record;
use C4::Suggestions;
# use C4::Biblio;

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Acquisition - Koha functions for dealing with orders and acquisitions

=head1 SYNOPSIS

  use C4::Acquisition;

=head1 DESCRIPTION

The functions in this module deal with acquisitions, managing book
orders, converting money to different currencies, and so forth.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(
		&getbasket &getbasketcontent &newbasket &closebasket

		&getorders &getallorders &getrecorders
		&getorder &neworder &delorder
		&ordersearch &histsearch
		&modorder &getsingleorder &invoice &receiveorder
		&updaterecorder &newordernum
		&getsupplierlistwithlateorders
		&getlateorders

		&bookfunds &curconvert &getcurrencies &bookfundbreakdown
		&updatecurrencies &getcurrency

		&updatesup &insertsup
		&bookseller &breakdown
);

#
#
#
# BASKETS
#
#
#
=item getbasket

  $aqbasket = &getbasket($basketnumber);

get all basket informations in aqbasket for a given basket
=cut

sub getbasket {
	my ($basketno)=@_;
	my $dbh=C4::Context->dbh;
	my $sth=$dbh->prepare("select aqbasket.*,borrowers.firstname+' '+borrowers.surname as authorisedbyname, borrowers.branchcode as branch from aqbasket left join borrowers on aqbasket.authorisedby=borrowers.borrowernumber where basketno=?");
	$sth->execute($basketno);
	return($sth->fetchrow_hashref);
}

=item getbasketcontent

  ($count, @orders) = &getbasketcontent($basketnumber, $booksellerID);

Looks up the pending (non-cancelled) orders with the given basket
number. If C<$booksellerID> is non-empty, only orders from that seller
are returned.

C<&basket> returns a two-element array. C<@orders> is an array of
references-to-hash, whose keys are the fields from the aqorders,
biblio, and biblioitems tables in the Koha database. C<$count> is the
number of elements in C<@orders>.

=cut
#'
sub getbasketcontent {
	my ($basketno,$supplier,$orderby)=@_;
	my $dbh = C4::Context->dbh;
	my $query="Select aqorderbreakdown.*,biblio.*,biblioitems.*,aqorders.*,biblio.title from aqorders,biblio,biblioitems
	left join aqorderbreakdown on aqorderbreakdown.ordernumber=aqorders.ordernumber
	where basketno='$basketno'
	and biblio.biblionumber=aqorders.biblionumber and biblioitems.biblioitemnumber
	=aqorders.biblioitemnumber
	and (datecancellationprinted is NULL or datecancellationprinted =
	'0000-00-00')";
	if ($supplier ne ''){
		$query.=" and aqorders.booksellerid='$supplier'";
	}
	
	$orderby="biblioitems.publishercode" unless $orderby;
	$query.=" order by $orderby";
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

Create a new basket in aqbasket table
=cut

sub newbasket {
	my ($booksellerid,$authorisedby) = @_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->do("insert into aqbasket (creationdate,booksellerid,authorisedby) values(now(),'$booksellerid','$authorisedby')");
	#find & return basketno MYSQL dependant, but $dbh->last_insert_id always returns null :-(
	my $basket = $dbh->{'mysql_insertid'};
	return($basket);
}

=item closebasket

  &newbasket($basketno);

close a basket (becomes unmodifiable,except for recieves
=cut

sub closebasket {
	my ($basketno) = @_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("update aqbasket set closedate=now() where basketno=?");
	$sth->execute($basketno);
}

=item neworder

  &neworder($basket, $biblionumber, $title, $quantity, $listprice,
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
	my ($basketno,$bibnum,$title,$quantity,$listprice,$booksellerid,$authorisedby,$notes,$bookfund,$bibitemnum,$rrp,$ecost,$gst,$budget,$cost,$sub,$invoice,$sort1,$sort2)=@_;
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
	# if $basket empty, it's also a new basket, create it
	unless ($basketno) {
		$basketno=newbasket($booksellerid,$authorisedby);
	}
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("insert into aqorders 
								(biblionumber,title,basketno,quantity,listprice,notes,
								biblioitemnumber,rrp,ecost,gst,unitprice,subscription,sort1,sort2)
								values (?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
	$sth->execute($bibnum,$title,$basketno,$quantity,$listprice,$notes,
					$bibitemnum,$rrp,$ecost,$gst,$cost,$sub,$sort1,$sort2);
	$sth->finish;
	#get ordnum MYSQL dependant, but $dbh->last_insert_id returns null
	my $ordnum = $dbh->{'mysql_insertid'};
	$sth=$dbh->prepare("insert into aqorderbreakdown (ordernumber,bookfundid) values
	(?,?)");
	$sth->execute($ordnum,$bookfund);
	$sth->finish;
	return $basketno;
}

=item delorder

  &delorder($biblionumber, $ordernumber);

Cancel the order with the given order and biblio numbers. It does not
delete any entries in the aqorders table, it merely marks them as
cancelled.

=cut
#'
sub delorder {
  my ($bibnum,$ordnum)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("update aqorders set datecancellationprinted=now()
  where biblionumber=? and ordernumber=?");
  $sth->execute($bibnum,$ordnum);
  $sth->finish;
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
  my ($title,$ordnum,$quantity,$listprice,$bibnum,$basketno,$supplier,$who,$notes,$bookfund,$bibitemnum,$rrp,$ecost,$gst,$budget,$cost,$invoice,$sort1,$sort2)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("update aqorders set title=?,
  quantity=?,listprice=?,basketno=?,
  rrp=?,ecost=?,unitprice=?,booksellerinvoicenumber=?,
  notes=?,sort1=?, sort2=?
  where
  ordernumber=? and biblionumber=?");
  $sth->execute($title,$quantity,$listprice,$basketno,$rrp,$ecost,$cost,$invoice,$notes,$sort1,$sort2,$ordnum,$bibnum);
  $sth->finish;
  $sth=$dbh->prepare("update aqorderbreakdown set bookfundid=? where
  ordernumber=?");
  unless ($sth->execute($bookfund,$ordnum)) { # zero rows affected [Bug 734]
    my $query="insert into aqorderbreakdown (ordernumber,bookfundid) values (?,?)";
    $sth=$dbh->prepare($query);
    $sth->execute($ordnum,$bookfund);
  }
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
  my $sth=$dbh->prepare("Select max(ordernumber) from aqorders");
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
	my ($biblio,$ordnum,$quantrec,$user,$cost,$invoiceno,$freight,$rrp)=@_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("update aqorders set quantityreceived=?,datereceived=now(),booksellerinvoicenumber=?,
											unitprice=?,freight=?,rrp=?
							where biblionumber=? and ordernumber=?");
	my $suggestionid = findsuggestion_from_biblionumber($dbh,$biblio);
	if ($suggestionid) {
		changestatus($suggestionid,'AVAILABLE','',$biblio);
	}
	$sth->execute($quantrec,$invoiceno,$cost,$freight,$rrp,$biblio,$ordnum);
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
  my $sth=$dbh->prepare("update aqorders set
  unitprice=?, rrp=?
  where biblionumber=? and ordernumber=?
  ");
  $sth->execute($cost,$rrp,$biblio,$ordnum);
  $sth->finish;
  $sth=$dbh->prepare("update aqorderbreakdown set bookfundid=? where ordernumber=?");
  $sth->execute($bookfund,$ordnum);
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
	my $strsth ="Select count(*),authorisedby,creationdate,aqbasket.basketno,
closedate,surname,firstname,aqorders.title 
from aqorders 
left join aqbasket on aqbasket.basketno=aqorders.basketno 
left join borrowers on aqbasket.authorisedby=borrowers.borrowernumber
where booksellerid=? and (quantity > quantityreceived or
quantityreceived is NULL) and datecancellationprinted is NULL ";
		
	if (C4::Context->preference("IndependantBranches")) {
		my $userenv = C4::Context->userenv;
		unless ($userenv->{flags} == 1){
			$strsth .= " and (borrowers.branchcode = '".$userenv->{branch}."' or borrowers.branchcode ='')";
		}
	}
	$strsth.=" group by basketno order by aqbasket.basketno";
	my $sth=$dbh->prepare($strsth);
	$sth->execute($supplierid);
	my @results = ();
	while (my $data=$sth->fetchrow_hashref){
		push(@results,$data);
	}
	$sth->finish;
	return (scalar(@results),\@results);
}

=item getorder

  ($order, $ordernumber) = &getorder($biblioitemnumber, $biblionumber);

Looks up the order with the given biblionumber and biblioitemnumber.

Returns a two-element array. C<$ordernumber> is the order number.
C<$order> is a reference-to-hash describing the order; its keys are
fields from the biblio, biblioitems, aqorders, and aqorderbreakdown
tables of the Koha database.

=cut

sub getorder{
  my ($bi,$bib)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select ordernumber from aqorders where biblionumber=? and biblioitemnumber=?");
  $sth->execute($bib,$bi);
  # FIXME - Use fetchrow_array(), since we're only interested in the one
  # value.
  my $ordnum=$sth->fetchrow_hashref;
  $sth->finish;
  my $order=getsingleorder($ordnum->{'ordernumber'});
  return ($order,$ordnum->{'ordernumber'});
}

=item getsingleorder

  $order = &getsingleorder($ordernumber);

Looks up an order by order number.

Returns a reference-to-hash describing the order. The keys of
C<$order> are fields from the biblio, biblioitems, aqorders, and
aqorderbreakdown tables of the Koha database.

=cut

sub getsingleorder {
  my ($ordnum)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select * from biblio,biblioitems,aqorders left join aqorderbreakdown
  on aqorders.ordernumber=aqorderbreakdown.ordernumber
  where aqorders.ordernumber=?
  and biblio.biblionumber=aqorders.biblionumber and
  biblioitems.biblioitemnumber=aqorders.biblioitemnumber");
  $sth->execute($ordnum);
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
  my ($supplierid)=@_;
  my $dbh = C4::Context->dbh;
  my @results = ();
  my $strsth="Select *,aqorders.title as suggestedtitle,biblio.title as truetitle from aqorders,biblio,biblioitems,aqbasket,aqbooksellers "; 
	$strsth .= ",borrowers " if (C4::Context->preference("IndependantBranches")); 
	$strsth .=" where aqorders.basketno=aqbasket.basketno and aqbasket.booksellerid=aqbooksellers.id and biblio.biblionumber=aqorders.biblionumber ";
	$strsth .= " and aqbasket.authorisedby=borrowers.borrowernumber" if (C4::Context->preference("IndependantBranches"));
	$strsth.=" and booksellerid=? and (cancelledby is NULL or cancelledby = '')
  and (quantityreceived < quantity or quantityreceived is NULL)
  and biblio.biblionumber=aqorders.biblionumber and biblioitems.biblioitemnumber=
  aqorders.biblioitemnumber ";
	if (C4::Context->preference("IndependantBranches")) {
		my $userenv = C4::Context->userenv;
		unless ($userenv->{flags} == 1){
			$strsth .= " and (borrowers.branchcode = '".$userenv->{branch}."' or borrowers.branchcode ='')";
		}
	}
	$strsth .= " group by aqorders.biblioitemnumber order by biblio.title";
  my $sth=$dbh->prepare($strsth);
  $sth->execute($supplierid);
  while (my $data=$sth->fetchrow_hashref){
    push(@results,$data);
  }
  $sth->finish;
  return(scalar(@results),@results);
}
=item getsupplierlistwithlateorders

  %results = &getsupplierlistwithlateorders;

Searches for suppliers with late orders.

=cut
#'
sub getsupplierlistwithlateorders {
	my $delay=shift;
	my $dbh = C4::Context->dbh;
#FIXME NOT quite sure that this operation is valid for DBMs different from Mysql, HOPING so
#should be tested with other DBMs
	
	my $strsth;
	my $dbdriver = C4::Context->config("db_scheme")||"mysql";
	if ($dbdriver eq "mysql"){
		$strsth="SELECT DISTINCT aqbasket.booksellerid, aqbooksellers.name
					FROM aqorders, aqbasket
					LEFT JOIN aqbooksellers ON aqbasket.booksellerid = aqbooksellers.id
					WHERE aqorders.basketno = aqbasket.basketno AND
					(closedate < DATE_SUB(CURDATE( ),INTERVAL $delay DAY) AND (datereceived = '' or datereceived is null))
					";
	}else {
		$strsth="SELECT DISTINCT aqbasket.booksellerid, aqbooksellers.name
			FROM aqorders, aqbasket
			LEFT JOIN aqbooksellers ON aqbasket.aqbooksellerid = aqbooksellers.id
			WHERE aqorders.basketno = aqbasket.basketno AND
			(closedate < (CURDATE( )-(INTERVAL $delay DAY))) AND (datereceived = '' or datereceived is null))
			";
	}
#	warn "C4::Acquisition getsupplierlistwithlateorders : ".$strsth;
	my $sth = $dbh->prepare($strsth);
	$sth->execute;
	my %supplierlist;
	while (my ($id,$name) = $sth->fetchrow) {
		$supplierlist{$id} = $name;
	}
	return %supplierlist;
}

=item getlateorders

  %results = &getlateorders;

Searches for suppliers with late orders.

=cut
#'
sub getlateorders {
	my $delay=shift;
	my $supplierid = shift;
	my $branch = shift;
	
	my $dbh = C4::Context->dbh;
#BEWARE, order of parenthesis and LEFT JOIN is important for speed 
	my $strsth;
	my $dbdriver = C4::Context->config("db_scheme")||"mysql";
#	warn " $dbdriver";
	if ($dbdriver eq "mysql"){
		$strsth ="SELECT aqbasket.basketno,
					DATE(aqbasket.closedate) as orderdate, aqorders.quantity - IFNULL(aqorders.quantityreceived,0) as quantity, aqorders.rrp as unitpricesupplier,aqorders.ecost as unitpricelib,
					(aqorders.quantity - IFNULL(aqorders.quantityreceived,0)) * aqorders.rrp as subtotal, aqbookfund.bookfundname as budget, borrowers.branchcode as branch,
					aqbooksellers.name as supplier,
					aqorders.title, biblio.author, biblioitems.publishercode as publisher, biblioitems.publicationyear,
					DATEDIFF(CURDATE( ),closedate) AS latesince
					FROM 
						((	(
								(aqorders LEFT JOIN biblio on biblio.biblionumber = aqorders.biblionumber) LEFT JOIN biblioitems on  biblioitems.biblionumber=biblio.biblionumber
							)  LEFT JOIN aqorderbreakdown on aqorders.ordernumber = aqorderbreakdown.ordernumber
						) LEFT JOIN aqbookfund on aqorderbreakdown.bookfundid = aqbookfund.bookfundid
						),(aqbasket LEFT JOIN borrowers on aqbasket.authorisedby = borrowers.borrowernumber) LEFT JOIN aqbooksellers ON aqbasket.booksellerid = aqbooksellers.id
					WHERE aqorders.basketno = aqbasket.basketno AND (closedate < DATE_SUB(CURDATE( ),INTERVAL $delay DAY)) 
					AND ((datereceived = '' OR datereceived is null) OR (aqorders.quantityreceived < aqorders.quantity) ) ";
		$strsth .= " AND aqbasket.booksellerid = $supplierid " if ($supplierid);
		$strsth .= " AND borrowers.branchcode like \'".$branch."\'" if ($branch);
		$strsth .= " AND borrowers.branchcode like \'".C4::Context->userenv->{branch}."\'" if (C4::Context->preference("IndependantBranches") && C4::Context->userenv && C4::Context->userenv->{flags}!=1);
		$strsth .= " HAVING quantity<>0 AND unitpricesupplier<>0 AND unitpricelib<>0 ORDER BY latesince,basketno,borrowers.branchcode, supplier ";
	} else {
		$strsth ="SELECT aqbasket.basketno,
					DATE(aqbasket.closedate) as orderdate, 
					aqorders.quantity, aqorders.rrp as unitpricesupplier,aqorders.ecost as unitpricelib, aqorders.quantity * aqorders.rrp as subtotal
					aqbookfund.bookfundname as budget, borrowers.branchcode as branch,
					aqbooksellers.name as supplier,
					biblio.title, biblio.author, biblioitems.publishercode as publisher, biblioitems.publicationyear,
					(CURDATE -  closedate) AS latesince
					FROM 
						((	(
								(aqorders LEFT JOIN biblio on biblio.biblionumber = aqorders.biblionumber) LEFT JOIN biblioitems on  biblioitems.biblionumber=biblio.biblionumber
							)  LEFT JOIN aqorderbreakdown on aqorders.ordernumber = aqorderbreakdown.ordernumber
						) LEFT JOIN aqbookfund on aqorderbreakdown.bookfundid = aqbookfund.bookfundid
						),(aqbasket LEFT JOIN borrowers on aqbasket.authorisedby = borrowers.borrowernumber) LEFT JOIN aqbooksellers ON aqbasket.booksellerid = aqbooksellers.id
					WHERE aqorders.basketno = aqbasket.basketno AND (closedate < (CURDATE -(INTERVAL $delay DAY)) 
					AND ((datereceived = '' OR datereceived is null) OR (aqorders.quantityreceived < aqorders.quantity) ) ";
		$strsth .= " AND aqbasket.booksellerid = $supplierid " if ($supplierid);
		$strsth .= " AND borrowers.branchcode like \'".$branch."\'" if ($branch);
		$strsth .= " AND borrowers.branchcode like \'".C4::Context->userenv->{branch}."\'" if (C4::Context->preference("IndependantBranches") && C4::Context->userenv->{flags}!=1);
		$strsth .= " ORDER BY latesince,basketno,borrowers.branchcode, supplier";
	}
	warn "C4::Acquisition : getlateorders SQL:".$strsth;
	my $sth = $dbh->prepare($strsth);
	$sth->execute;
	my @results;
	my $hilighted = 1;
	while (my $data = $sth->fetchrow_hashref) {
		$data->{hilighted}=$hilighted if ($hilighted>0);
		$data->{orderdate} = format_date($data->{orderdate});
		push @results, $data;
		$hilighted= -$hilighted;
	}
	$sth->finish;
	return(scalar(@results),@results);
}

# FIXME - Never used
sub getrecorders {
  #gets all orders from a certain supplier, orders them alphabetically
  my ($supid)=@_;
  my $dbh = C4::Context->dbh;
  my @results= ();
  my $sth=$dbh->prepare("Select * from aqorders,biblio,biblioitems where booksellerid=?
  and (cancelledby is NULL or cancelledby = '')
  and biblio.biblionumber=aqorders.biblionumber and biblioitems.biblioitemnumber=
  aqorders.biblioitemnumber and
  aqorders.quantityreceived>0
  and aqorders.datereceived >=now()
  group by aqorders.biblioitemnumber
  order by
  biblio.title");
  $sth->execute($supid);
  while (my $data=$sth->fetchrow_hashref){
    push(@results,$data);
  }
  $sth->finish;
  return(scalar(@results),@results);
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
	my @data  = split(' ',$search);
	my @searchterms = ($id);
	map { push(@searchterms,"$_%","% $_%") } @data;
	push(@searchterms,$search,$search,$biblio);
	my $sth=$dbh->prepare("Select biblio.*,biblioitems.*,aqorders.*,aqbasket.*,biblio.title from aqorders,biblioitems,biblio,aqbasket
		where aqorders.biblioitemnumber = biblioitems.biblioitemnumber and
		aqorders.basketno = aqbasket.basketno
		and aqbasket.booksellerid = ?
		and biblio.biblionumber=aqorders.biblionumber
		and ((datecancellationprinted is NULL)
		or (datecancellationprinted = '0000-00-00'))
		and (("
		.(join(" and ",map { "(biblio.title like ? or biblio.title like ?)" } @data))
		.") or biblioitems.isbn=? or (aqorders.ordernumber=? and aqorders.biblionumber=?)) "
		.(($catview ne 'yes')?" and (quantityreceived < quantity or quantityreceived is NULL)":"")
		." group by aqorders.ordernumber");
	$sth->execute(@searchterms);
	my @results = ();
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
		push(@results,$data);
	}
	$sth->finish;
	$sth2->finish;
	$sth3->finish;
	return(scalar(@results),@results);
}


sub histsearch {
	my ($title,$author,$name,$from_placed_on,$to_placed_on)=@_;
	my @order_loop;
	my $total_qty=0;
	my $total_qtyreceived=0;
	my $total_price=0;
	# don't run the query if there are no parameters (list would be too long for sure !
	if ($title || $author || $name || $from_placed_on || $to_placed_on) {
		my $dbh= C4::Context->dbh;
		my $query = "select biblio.title,biblio.author,aqorders.basketno,name,aqbasket.creationdate,aqorders.datereceived, aqorders.quantity, aqorders.quantityreceived, aqorders.ecost from aqorders,aqbasket,aqbooksellers,biblio";
		$query .= ",borrowers " if (C4::Context->preference("IndependantBranches")); 
		$query .=" where aqorders.basketno=aqbasket.basketno and aqbasket.booksellerid=aqbooksellers.id and biblio.biblionumber=aqorders.biblionumber ";
		$query .= " and aqbasket.authorisedby=borrowers.borrowernumber" if (C4::Context->preference("IndependantBranches"));
		$query .= " and biblio.title like ".$dbh->quote("%".$title."%") if $title;
		$query .= " and biblio.author like ".$dbh->quote("%".$author."%") if $author;
		$query .= " and name like ".$dbh->quote("%".$name."%") if $name;
		$query .= " and creationdate >" .$dbh->quote($from_placed_on) if $from_placed_on;
		$query .= " and creationdate<".$dbh->quote($to_placed_on) if $to_placed_on;
		if (C4::Context->preference("IndependantBranches")) {
			my $userenv = C4::Context->userenv;
			if (($userenv) &&($userenv->{flags} != 1)){
				$query .= " and (borrowers.branchcode = '".$userenv->{branch}."' or borrowers.branchcode ='')";
			}
		}
		$query .=" order by booksellerid";
		warn "query histearch: ".$query;
		my $sth = $dbh->prepare($query);
		$sth->execute;
		my $cnt=1;
		while (my $line = $sth->fetchrow_hashref) {
			$line->{count}=$cnt++;
			$line->{toggle}=1 if $cnt %2;
			push @order_loop, $line;
			$line->{creationdate} = format_date($line->{creationdate});
			$line->{datereceived} = format_date($line->{datereceived});
			$total_qty += $line->{'quantity'};
			$total_qtyreceived += $line->{'quantityreceived'};
			$total_price += $line->{'quantity'}*$line->{'ecost'};
		}
	}
	return \@order_loop,$total_qty,$total_price,$total_qtyreceived;
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
  my @results = ();
  my $sth=$dbh->prepare("Select * from aqorders,biblio,biblioitems where
  booksellerinvoicenumber=?
  and biblio.biblionumber=aqorders.biblionumber and biblioitems.biblioitemnumber=
  aqorders.biblioitemnumber group by aqorders.ordernumber,aqorders.biblioitemnumber");
  $sth->execute($invoice);
  while (my $data=$sth->fetchrow_hashref){
    push(@results,$data);
  }
  $sth->finish;
  return(scalar(@results),@results);
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
  my ($branch)=@_;
  my $dbh = C4::Context->dbh;
  my $strsth;
  
  if ($branch) {
      $strsth="Select * from aqbookfund,aqbudget where aqbookfund.bookfundid
      =aqbudget.bookfundid and startdate<now() and enddate>now() and (aqbookfund.branchcode is null or aqbookfund.branchcode='' or aqbookfund.branchcode= ? )
      group by aqbookfund.bookfundid order by bookfundname";
  } else {
      $strsth="Select * from aqbookfund,aqbudget where aqbookfund.bookfundid
      =aqbudget.bookfundid and startdate<now() and enddate>now()
      group by aqbookfund.bookfundid order by bookfundname";
  }
  my $sth=$dbh->prepare($strsth);
  if ($branch){
      $sth->execute($branch);
  } else {
      $sth->execute;
  }
  my @results = ();
  while (my $data=$sth->fetchrow_hashref){
    push(@results,$data);
  }
  $sth->finish;
  return(scalar(@results),@results);
}

=item bookfundbreakdown

	returns the total comtd & spent for a given bookfund, and a given year
	used in acqui-home.pl
=cut
#'

sub bookfundbreakdown {
  my ($id, $year)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("SELECT startdate, enddate, quantity, datereceived, freight, unitprice, listprice, ecost, quantityreceived, subscription
FROM aqorders, aqorderbreakdown, aqbudget, aqbasket
WHERE aqorderbreakdown.bookfundid = ?
AND aqorders.ordernumber = aqorderbreakdown.ordernumber
AND (
datecancellationprinted IS NULL
OR datecancellationprinted = '0000-00-00'
)
AND aqbudget.bookfundid = aqorderbreakdown.bookfundid
AND aqbasket.basketno = aqorders.basketno
AND aqbasket.creationdate >= startdate
AND enddate >= aqbasket.creationdate
and startdate<=now() and enddate>=now()");
  $sth->execute($id);
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
  my $sth=$dbh->prepare("Select rate from currency where currency=?");
  $sth->execute($currency);
  my $cur=($sth->fetchrow_array())[0];
  $sth->finish;
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
  my $sth=$dbh->prepare("Select * from currency");
  $sth->execute;
  my @results = ();
  while (my $data=$sth->fetchrow_hashref){
    push(@results,$data);
  }
  $sth->finish;
  return(scalar(@results),\@results);
}

=item updatecurrencies

  &updatecurrencies($currency, $newrate);

Sets the exchange rate for C<$currency> to be C<$newrate>.

=cut
#'
sub updatecurrencies {
  my ($currency,$rate)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("update currency set rate=? where currency=?");
  $sth->execute($rate,$currency);
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
  my $sth=$dbh->prepare("Select * from aqbooksellers where name like ? or id = ?");
  $sth->execute("$searchstring%",$searchstring);
  my @results;
  while (my $data=$sth->fetchrow_hashref){
    push(@results,$data);
  }
  $sth->finish;
  return(scalar(@results),@results);
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
  my $sth=$dbh->prepare("Select * from aqorderbreakdown where ordernumber=?");
  $sth->execute($id);
  my @results = ();
  while (my $data=$sth->fetchrow_hashref){
    push(@results,$data);
  }
  $sth->finish;
  return(scalar(@results),\@results);
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
   my $sth=$dbh->prepare("Update aqbooksellers set
   name=?,address1=?,address2=?,address3=?,address4=?,postal=?,
   phone=?,fax=?,url=?,contact=?,contpos=?,contphone=?,contfax=?,contaltphone=?,
   contemail=?,contnotes=?,active=?,
   listprice=?, invoiceprice=?,gstreg=?, listincgst=?,
   invoiceincgst=?, specialty=?,discount=?,invoicedisc=?,
   nocalc=?
   where id=?");
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
  $sth=$dbh->prepare("Insert into aqbooksellers (id) values (?)");
  $sth->execute($data2->{'max(id)'});
  $sth->finish;
  $data->{'id'}=$data2->{'max(id)'};
  updatesup($data);
  return($data->{'id'});
}

END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
