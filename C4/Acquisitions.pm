package C4::Acquisitions; #assumes C4/Acquisitions.pm


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

# ***
# NOTE: This module is deprecated in Koha 1.3.x, and will shortly be
# deleted.
# ***

use strict;
require Exporter;
use C4::Context;
 #use C4::Biblio;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Acquisitions - FIXME

=head1 SYNOPSIS

  use C4::Acquisitions;

=head1 DESCRIPTION

FIXME

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(&getorders &bookseller &breakdown &basket &newbasket &bookfunds
&ordersearch &newbiblio &newbiblioitem &newsubject &newsubtitle &neworder
&newordernum &modbiblio &modorder &getsingleorder &invoice &receiveorder
&bookfundbreakdown &curconvert &updatesup &insertsup &newitems &modbibitem
&getcurrencies &modsubtitle &modsubject &modaddauthor &moditem &countitems 
&findall &needsmod &delitem &deletebiblioitem &delbiblio &delorder &branches
&getallorders &getrecorders &updatecurrencies &getorder &getcurrency &updaterecorder
&updatecost &checkitems &modnote &getitemtypes &getbiblio
&getbiblioitembybiblionumber
&getbiblioitem &getitemsbybiblioitem &isbnsearch
&websitesearch &addwebsite &updatewebsite &deletewebsite);
%EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],

# your exported package globals go here,
# as well as any optionally exported functions

@EXPORT_OK   = qw($Var1 %Hashit);	# FIXME - Never used


# non-exported package globals go here
use vars qw(@more $stuff);		# FIXME - Never used

# initalize package globals, first exported ones
# FIXME - Never used
my $Var1   = '';
my %Hashit = ();



# then the others (which are still accessible as $Some::Module::stuff)
# FIXME - Never used
my $stuff  = '';
my @more   = ();

# all file-scoped lexicals must be created before
# the functions below that use them.

# file-private lexicals go here
# FIXME - Never used
my $priv_var    = '';
my %secret_hash = ();

# FIXME - Never used
# here's a file-private function as a closure,
# callable as &$priv_func;  it cannot be prototyped.
my $priv_func = sub {
  # stuff goes here.
  };
  
# make all your functions, whether exported or not;

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
# FIXME - This exact function already exists in C4::Catalogue
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

# Only used internally
# FIXME - This is the same as &C4::Biblio::itemcount, but not
# the same as &C4::Search::itemcount
sub itemcount{
  my ($biblio)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select count(*) from items where biblionumber=$biblio";
#  print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data->{'count(*)'});
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
# FIXME - There are functions &getorder and &getorders. Isn't this
# somewhat likely to cause confusion?
# FIXME - Almost the exact same function is already in C4::Catalogue
sub getorder{
  my ($bi,$bib)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select ordernumber 
 	from aqorders 
 	where biblionumber=? and biblioitemnumber=?";
  my $sth=$dbh->prepare($query);
  $sth->execute($bib,$bi);
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
# FIXME - This is practically the same function as
# &C4::Catalogue::getsingleorder and &C4::Biblio::getsingleorder.
sub getsingleorder {
  my ($ordnum)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from biblio,biblioitems,aqorders,aqorderbreakdown 
  where aqorders.ordernumber=? 
  and biblio.biblionumber=aqorders.biblionumber and
  biblioitems.biblioitemnumber=aqorders.biblioitemnumber and
  aqorders.ordernumber=aqorderbreakdown.ordernumber";
  my $sth=$dbh->prepare($query);
  $sth->execute($ordnum);
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data);
}

=item invoice

  ($count, @results) = &invoice($booksellerinvoicenumber);

Looks up orders by invoice number.

Returns an array. C<$count> is the number of elements in C<@results>.
C<@results> is an array of references-to-hash; the keys of each
elements are fields from the aqorders, biblio, and biblioitems tables
of the Koha database.

=cut
#'
# FIXME - This exact function is already in C4::Catalogue
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

=item getallorders

  ($count, @results) = &getallorders($booksellerid);

Looks up all of the pending orders from the supplier with the given
bookseller ID. Ignores cancelled orders.

C<$count> is the number of elements in C<@results>. C<@results> is an
array of references-to-hash. The keys of each element are fields from
the aqorders, biblio, and biblioitems tables of the Koha database.

C<@results> is sorted alphabetically by book title.

=cut
#'
# FIXME - Almost (but not quite) the same function appears in C4::Catalogue
# That one only lists incomplete orders.
sub getallorders {
  #gets all orders from a certain supplier, orders them alphabetically
  my ($supid)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from aqorders,biblio,biblioitems where booksellerid='$supid'
  and (cancelledby is NULL or cancelledby = '')
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

# FIXME - There's a getrecorders in C4::Catalogue
# FIXME - Never used (neither is the other one, actually)
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
# FIXME - The same function (modulo whitespace) appears in C4::Catalogue
sub ordersearch {
  my ($search,$biblio,$catview)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select *,biblio.title from aqorders,biblioitems,biblio
	where aqorders.biblioitemnumber = biblioitems.biblioitemnumber
	and biblio.biblionumber=aqorders.biblionumber
	and ((datecancellationprinted is NULL)
	or (datecancellationprinted = '0000-00-00'))
  and ((";
  my @data=split(' ',$search);
  my $count=@data;
  for (my $i=0;$i<$count;$i++){
    $query.= "(biblio.title like '$data[$i]%' or biblio.title like '% $data[$i]%') and ";
  }
  $query=~ s/ and $//;
  $query.=" ) or biblioitems.isbn='$search' 
  or (aqorders.ordernumber='$search' and aqorders.biblionumber='$biblio')) ";
  if ($catview ne 'yes'){
    $query.=" and (quantityreceived < quantity or quantityreceived is NULL)";
  }
  $query.=" group by aqorders.ordernumber";
  my $sth=$dbh->prepare($query);
#  print $query;
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
  return($i,@results);
}

=item bookseller

  ($count, @results) = &bookseller($searchstring);

Looks up a book seller. C<$searchstring> may be either a book seller
ID, or a string to look for in the book seller's name.

C<$count> is the number of elements in C<@results>. C<@results> is an
array of references-to-hash, whose keys are the fields of of the
aqbooksellers table in the Koha database.

=cut
#'
# FIXME - This function appears in C4::Catalogue
sub bookseller {
  my ($searchstring)=@_;
  my $dbh = C4::Context->dbh;
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
# FIXME - This function appears in C4::Catalogue.
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
# FIXME - Almost the same function (with less error-checking) appears in
# C4::Catalogue.pm
sub basket {
  my ($basketno,$supplier)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select *,biblio.title from aqorders,biblio,biblioitems 
  where basketno='$basketno'
  and biblio.biblionumber=aqorders.biblionumber and biblioitems.biblioitemnumber
  =aqorders.biblioitemnumber 
  and (datecancellationprinted is NULL or datecancellationprinted =
  '0000-00-00')";
  if (defined $supplier && $supplier ne ''){
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
# FIXME - This function appears in C4::Catalogue.pm
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

=item bookfunds

  ($count, @results) = &bookfunds();

Returns a list of all book funds started on Sep 1, 2001.

C<$count> is the number of elements in C<@results>. C<@results> is an
array of references-to-hash, whose keys are fields from the aqbookfund
and aqbudget tables of the Koha database. Results are ordered
alphabetically by book fund name.

=cut
#'
# FIXME - An identical function (without the hardcoded date) appears in
# C4::Catalogue
sub bookfunds {
  my $dbh = C4::Context->dbh;
  my $query="Select * from aqbookfund,aqbudget where aqbookfund.bookfundid
  =aqbudget.bookfundid 
   and aqbudget.startdate='2001-07-01'
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

=item branches

  ($count, @results) = &branches();

Returns a list of all library branches.

C<$count> is the number of elements in C<@results>. C<@results> is an
array of references-to-hash, whose keys are the fields of the branches
table of the Koha database.

=cut
#'
# FIXME - This function (modulo whitespace) appears in C4::Catalogue
sub branches {
  my $dbh = C4::Context->dbh;
  my $query="Select * from branches";
  my $sth=$dbh->prepare($query);
  my $i=0;
  my @results;

    $sth->execute;
  while (my $data = $sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
    } # while

  $sth->finish;
  return($i, @results);
} # sub branches

# FIXME - POD. But I can't figure out what this function is doing
# FIXME - An almost identical function appears in C4::Catalogue
sub bookfundbreakdown {
  my ($id)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select quantity,datereceived,freight,unitprice,listprice,ecost,quantityreceived,subscription
  from aqorders,aqorderbreakdown where bookfundid='$id' and 
   aqorders.ordernumber=aqorderbreakdown.ordernumber and ((budgetdate >=
   '2001-07-01' and budgetdate <'2002-07-01') or
   (datereceived >= '2001-07-01' and datereceived < '2002-07-01'))
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

# FIXME - This is in effect identical to &C4::Biblio::newbiblio.
# Pick one and stick with it.
# XXX - POD
sub newbiblio {
  my ($biblio) = @_;
  my $dbh    = C4::Context->dbh;
  my $query  = "Select max(biblionumber) from biblio";
  my $sth    = $dbh->prepare($query);
  $sth->execute;
  my $data   = $sth->fetchrow_arrayref;
  my $bibnum = $$data[0] + 1;
  my $series = 0;

  $biblio->{'title'}       = $dbh->quote($biblio->{'title'});
  $biblio->{'author'}      = $dbh->quote($biblio->{'author'});
  $biblio->{'copyright'}   = $dbh->quote($biblio->{'copyright'});
  $biblio->{'seriestitle'} = $dbh->quote($biblio->{'seriestitle'});
  $biblio->{'notes'}	   = $dbh->quote($biblio->{'notes'});
  $biblio->{'abstract'}    = $dbh->quote($biblio->{'abstract'});
  if ($biblio->{'seriestitle'}) { $series = 1 };

  $sth->finish;
  # FIXME - Use $dbh->do();
  $query = "insert into biblio set
biblionumber  = $bibnum,
title         = $biblio->{'title'},
author        = $biblio->{'author'},
copyrightdate = $biblio->{'copyright'},
serial        = $series,
seriestitle   = $biblio->{'seriestitle'},
notes         = $biblio->{'notes'},
abstract      = $biblio->{'abstract'}";

  $sth = $dbh->prepare($query);
  $sth->execute;

  $sth->finish;
  return($bibnum);
}

# FIXME - This is in effect the same as &C4::Biblio::modbiblio.
# Pick one and stick with it.
# XXX - POD
sub modbiblio {
  my ($biblio) = @_;
  my $dbh   = C4::Context->dbh;
  my $query;
  my $sth;
  
  $biblio->{'title'}         = $dbh->quote($biblio->{'title'});
  $biblio->{'author'}        = $dbh->quote($biblio->{'author'});
  $biblio->{'abstract'}      = $dbh->quote($biblio->{'abstract'});
  $biblio->{'copyrightdate'} = $dbh->quote($biblio->{'copyrightdate'});
  $biblio->{'seriestitle'}   = $dbh->quote($biblio->{'serirestitle'});
  $biblio->{'serial'}        = $dbh->quote($biblio->{'serial'});
  $biblio->{'unititle'}      = $dbh->quote($biblio->{'unititle'});
  $biblio->{'notes'}         = $dbh->quote($biblio->{'notes'});

  $query = "Update biblio set
title         = $biblio->{'title'},
author        = $biblio->{'author'},
abstract      = $biblio->{'abstract'},
copyrightdate = $biblio->{'copyrightdate'},
seriestitle   = $biblio->{'seriestitle'},
serial        = $biblio->{'serial'},
unititle      = $biblio->{'unititle'},
notes         = $biblio->{'notes'}
where biblionumber = $biblio->{'biblionumber'}";
  $sth   = $dbh->prepare($query);

  $sth->execute;

  $sth->finish;
  return($biblio->{'biblionumber'});
} # sub modbiblio

# FIXME - This is in effect identical to &C4::Biblio::modsubtitle.
# Pick one and stick with it.
# XXX - POD
sub modsubtitle {
  my ($bibnum, $subtitle) = @_;
  my $dbh   = C4::Context->dbh;
  my $query = "update bibliosubtitle set
subtitle = '$subtitle'
where biblionumber = $bibnum";
  my $sth   = $dbh->prepare($query);

  $sth->execute;
  $sth->finish;
} # sub modsubtitle

# XXX - POD
# FIXME - This is functionally identical to &C4::Biblio::modaddauthor
# Pick one and stick with it.
sub modaddauthor {
    my ($bibnum, $author) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "Delete from additionalauthors where biblionumber = $bibnum";
    my $sth = $dbh->prepare($query);

    $sth->execute;
    $sth->finish;

    if ($author ne '') {
        $query = "Insert into additionalauthors set
author       = '$author',
biblionumber = '$bibnum'";
        $sth   = $dbh->prepare($query);

        $sth->execute;

        $sth->finish;
    } # if
} # sub modaddauthor

# FIXME - This is in effect identical to &C4::Biblio::modsubject.
# Pick one and stick with it.
# XXX - POD
sub modsubject {
  my ($bibnum, $force, @subject) = @_;
  my $dbh   = C4::Context->dbh;
  my $count = @subject;
  my $error;
  for (my $i = 0; $i < $count; $i++) {
    $subject[$i] =~ s/^ //g;
    $subject[$i] =~ s/ $//g;
    my $query = "select * from catalogueentry
where entrytype = 's'
and catalogueentry = '$subject[$i]'";
    my $sth   = $dbh->prepare($query);
    $sth->execute;

    if (my $data = $sth->fetchrow_hashref) {
    } else {
      if ($force eq $subject[$i]) {

         # subject not in aut, chosen to force anway
         # so insert into cataloguentry so its in auth file
	 $query = "Insert into catalogueentry
(entrytype,catalogueentry)
values ('s','$subject[$i]')";
	 my $sth2 = $dbh->prepare($query);

	 $sth2->execute;
	 $sth2->finish;

      } else {

        $error = "$subject[$i]\n does not exist in the subject authority file";
        $query = "Select * from catalogueentry
where entrytype = 's'
and (catalogueentry like '$subject[$i] %'
or catalogueentry like '% $subject[$i] %'
or catalogueentry like '% $subject[$i]')";
        my $sth2 = $dbh->prepare($query);

        $sth2->execute;
        while (my $data = $sth2->fetchrow_hashref) {
          $error = $error."<br>$data->{'catalogueentry'}";
        } # while
        $sth2->finish;
      } # else
    } # else
    $sth->finish;
  } # else

  if ($error eq '') {
    my $query = "Delete from bibliosubject where biblionumber = $bibnum";
    my $sth   = $dbh->prepare($query);

    $sth->execute;
    $sth->finish;

    for (my $i = 0; $i < $count; $i++) {
      $sth = $dbh->prepare("Insert into bibliosubject
values ('$subject[$i]', $bibnum)");

      $sth->execute;
      $sth->finish;
    } # for
  } # if

  return($error);
} # sub modsubject

# FIXME - This is very similar to &C4::Biblio::modbibitem.
# Pick one and stick with it.
# XXX - POD
sub modbibitem {
    my ($biblioitem) = @_;
    my $dbh   = C4::Context->dbh;
    my $query;

    # FIXME -
    #	foreach my $field (qw( ... ))
    #	{
    #		$biblioitem->{$field} = $dbh->quote($biblioitem->{$field});
    #	}
    $biblioitem->{'itemtype'}        = $dbh->quote($biblioitem->{'itemtype'});
    $biblioitem->{'url'}             = $dbh->quote($biblioitem->{'url'});
    $biblioitem->{'isbn'}            = $dbh->quote($biblioitem->{'isbn'});
    $biblioitem->{'publishercode'}   = $dbh->quote($biblioitem->{'publishercode'});
    $biblioitem->{'publicationyear'} = $dbh->quote($biblioitem->{'publicationyear'});
    $biblioitem->{'classification'}  = $dbh->quote($biblioitem->{'classification'});
    $biblioitem->{'dewey'}	     = $dbh->quote($biblioitem->{'dewey'});
    $biblioitem->{'subclass'}	     = $dbh->quote($biblioitem->{'subclass'});
    $biblioitem->{'illus'}           = $dbh->quote($biblioitem->{'illus'});
    $biblioitem->{'pages'}           = $dbh->quote($biblioitem->{'pages'});
    $biblioitem->{'volumeddesc'}     = $dbh->quote($biblioitem->{'volumeddesc'});
    $biblioitem->{'notes'}           = $dbh->quote($biblioitem->{'notes'});
    $biblioitem->{'size'}            = $dbh->quote($biblioitem->{'size'});
    $biblioitem->{'place'}           = $dbh->quote($biblioitem->{'place'});

    $query = "Update biblioitems set
itemtype        = $biblioitem->{'itemtype'},
url             = $biblioitem->{'url'},
isbn            = $biblioitem->{'isbn'},
publishercode   = $biblioitem->{'publishercode'},
publicationyear = $biblioitem->{'publicationyear'},
classification  = $biblioitem->{'classification'},
dewey           = $biblioitem->{'dewey'},
subclass        = $biblioitem->{'subclass'},
illus           = $biblioitem->{'illus'},
pages           = $biblioitem->{'pages'},
volumeddesc     = $biblioitem->{'volumeddesc'},
notes 		= $biblioitem->{'notes'},
size		= $biblioitem->{'size'},
place		= $biblioitem->{'place'}
where biblioitemnumber = $biblioitem->{'biblioitemnumber'}";

    $dbh->do($query);
} # sub modbibitem

# FIXME - This is in effect identical to &C4::Biblio::modnote.
# Pick one and stick with it.
# XXX - POD
sub modnote {
  my ($bibitemnum,$note)=@_;
  my $dbh = C4::Context->dbh;
  # FIXME - Use $dbh->do();
  my $query="update biblioitems set notes='$note' where
  biblioitemnumber='$bibitemnum'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
}

# XXX - POD
# FIXME - &C4::Biblio::newbiblioitem is quite similar to this
sub newbiblioitem {
  my ($biblioitem) = @_;
  my $dbh   = C4::Context->dbh;
  my $query = "Select max(biblioitemnumber) from biblioitems";
  my $sth   = $dbh->prepare($query);
  my $data;
  my $bibitemnum;

  $biblioitem->{'volume'}          = $dbh->quote($biblioitem->{'volume'});
  $biblioitem->{'number'} 	   = $dbh->quote($biblioitem->{'number'});
  $biblioitem->{'classification'}  = $dbh->quote($biblioitem->{'classification'});
  $biblioitem->{'itemtype'}        = $dbh->quote($biblioitem->{'itemtype'});
  $biblioitem->{'url'}             = $dbh->quote($biblioitem->{'url'});
  $biblioitem->{'isbn'}            = $dbh->quote($biblioitem->{'isbn'});
  $biblioitem->{'issn'}            = $dbh->quote($biblioitem->{'issn'});
  $biblioitem->{'dewey'}           = $dbh->quote($biblioitem->{'dewey'});
  $biblioitem->{'subclass'}        = $dbh->quote($biblioitem->{'subclass'});
  $biblioitem->{'publicationyear'} = $dbh->quote($biblioitem->{'publicationyear'});
  $biblioitem->{'publishercode'}   = $dbh->quote($biblioitem->{'publishercode'});
  $biblioitem->{'volumedate'}      = $dbh->quote($biblioitem->{'volumedate'});
  $biblioitem->{'volumeddesc'}     = $dbh->quote($biblioitem->{'volumeddesc'});  $biblioitem->{'illus'}            = $dbh->quote($biblioitem->{'illus'});
  $biblioitem->{'illus'}	   = $dbh->quote($biblioitem->{'illus'});
  $biblioitem->{'pages'}           = $dbh->quote($biblioitem->{'pages'});
  $biblioitem->{'notes'}           = $dbh->quote($biblioitem->{'notes'});
  $biblioitem->{'size'}            = $dbh->quote($biblioitem->{'size'});
  $biblioitem->{'place'}           = $dbh->quote($biblioitem->{'place'});
  $biblioitem->{'lccn'}            = $dbh->quote($biblioitem->{'lccn'});
  $biblioitem->{'marc'}            = $dbh->quote($biblioitem->{'marc'});
  
  $sth->execute;
  $data       = $sth->fetchrow_arrayref;
  $bibitemnum = $$data[0] + 1;

  $sth->finish;

  $query = "insert into biblioitems set
biblioitemnumber = $bibitemnum,
biblionumber 	 = $biblioitem->{'biblionumber'},
volume		 = $biblioitem->{'volume'},
number		 = $biblioitem->{'number'},
classification   = $biblioitem->{'classification'},
itemtype         = $biblioitem->{'itemtype'},
url              = $biblioitem->{'url'},
isbn		 = $biblioitem->{'isbn'},
issn		 = $biblioitem->{'issn'},
dewey		 = $biblioitem->{'dewey'},
subclass	 = $biblioitem->{'subclass'},
publicationyear	 = $biblioitem->{'publicationyear'},
publishercode	 = $biblioitem->{'publishercode'},
volumedate	 = $biblioitem->{'volumedate'},
volumeddesc	 = $biblioitem->{'volumeddesc'},
illus		 = $biblioitem->{'illus'},
pages		 = $biblioitem->{'pages'},
notes		 = $biblioitem->{'notes'},
size		 = $biblioitem->{'size'},
lccn		 = $biblioitem->{'lccn'},
marc		 = $biblioitem->{'marc'},
place		 = $biblioitem->{'place'}";

  $sth = $dbh->prepare($query);
  $sth->execute;

  $sth->finish;
  return($bibitemnum);
}

# FIXME - This is in effect identical to &C4::Biblio::newsubject.
# Pick one and stick with it.
# XXX - POD
sub newsubject {
  my ($bibnum)=@_;
  my $dbh = C4::Context->dbh;
  my $query="insert into bibliosubject (biblionumber) values
  ($bibnum)";
  my $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;
}

# XXX - POD
# FIXME - This is in effect the same as &C4::Biblio::newsubtitle
# Pick one and stick with it.
sub newsubtitle {
  my ($bibnum, $subtitle) = @_;
  my $dbh   = C4::Context->dbh;
  $subtitle = $dbh->quote($subtitle);
  my $query = "insert into bibliosubtitle set
biblionumber = $bibnum,
subtitle = $subtitle";
  my $sth   = $dbh->prepare($query);

  $sth->execute;

  $sth->finish;
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
# FIXME - This function appears in C4::Catalogue
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
# FIXME - This function appears in C4::Catalogue
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
# FIXME - This function appears in C4::Catalogue
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
#  print $query;
  $sth->execute;
  $sth->finish;
  $query="update aqorderbreakdown set bookfundid=$bookfund where
  ordernumber=$ordnum";
  $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;
}

=item newordernum

  $order = &newordernum();

Finds the next unused order number in the aqorders table of the Koha
database, and returns it.

=cut
#'
# FIXME - Race condition
# FIXME - This function appears in C4::Catalogue
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
# FIXME - This function appears in C4::Catalogue
sub receiveorder {
  my ($biblio,$ordnum,$quantrec,$user,$cost,$invoiceno,$bibitemno,$freight,$bookfund,$rrp)=@_;
  my $dbh = C4::Context->dbh;
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
# FIXME - This function appears in C4::Catalogue
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

=item curconvert

  $foreignprice = &curconvert($currency, $localprice);

Converts the price C<$localprice> to foreign currency C<$currency> by
dividing by the exchange rate, and returns the result.

If no exchange rate is found, C<&curconvert> assumes the rate is one
to one.

=cut
#'
# FIXME - An almost identical version of this function appears in
# C4::Catalogue
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
  $price=$price / $cur;
  return($price);
}

=item getcurrencies

  ($count, $currencies) = &getcurrencies();

Returns the list of all known currencies.

C<$count> is the number of elements in C<$currencies>. C<$currencies>
is a reference-to-array; its elements are references-to-hash, whose
keys are the fields from the currency table in the Koha database.

=cut
#'
# FIXME - This function appears in C4::Catalogue
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

# FIXME - This function appears in C4::Catalogue. Neither one is used.
sub getcurrency {
  my ($cur)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from currency where currency='$cur'";
  my $sth=$dbh->prepare($query);
  $sth->execute;

  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data);
} 

=item updatecurrencies

  &updatecurrencies($currency, $newrate);

Sets the exchange rate for C<$currency> to be C<$newrate>.

=cut
#'
# FIXME - This function appears in C4::Catalogue
sub updatecurrencies {
  my ($currency,$rate)=@_;
  my $dbh = C4::Context->dbh;
  my $query="update currency set rate=$rate where currency='$currency'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
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
# FIXME - This function appears in C4::Catalogue
sub updatesup {
   my ($data)=@_;
   my $dbh = C4::Context->dbh;
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
#   print $query;
}

# XXX - POD
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

=item insertsup

  $id = &insertsup($bookseller);

Creates a new bookseller. C<$bookseller> is a reference-to-hash whose
keys are the fields of the aqbooksellers table in the Koha database.
All fields must be present.

Returns the ID of the newly-created bookseller.

=cut
#'
# FIXME - This function appears in C4::Catalogue
# FIXME - This is different from &C4::Biblio::newitems, though both
# are exported.
sub newitems {
  my ($item, @barcodes) = @_;
  my $dbh   = C4::Context->dbh;
  my $query = "Select max(itemnumber) from items";
  my $sth   = $dbh->prepare($query);
  my $data;
  my $itemnumber;
  my $error;

  $sth->execute;
  $data       = $sth->fetchrow_hashref;
  $itemnumber = $data->{'max(itemnumber)'} + 1;
  $sth->finish;
  
  $item->{'booksellerid'}     = $dbh->quote($item->{'booksellerid'});
  $item->{'homebranch'}       = $dbh->quote($item->{'homebranch'});
  $item->{'price'}            = $dbh->quote($item->{'price'});
  $item->{'replacementprice'} = $dbh->quote($item->{'replacementprice'});
  $item->{'itemnotes'}        = $dbh->quote($item->{'itemnotes'});

  foreach my $barcode (@barcodes) {
    $barcode = uc($barcode);
    $barcode = $dbh->quote($barcode);
    $query   = "Insert into items set
itemnumber           = $itemnumber,
biblionumber         = $item->{'biblionumber'},
biblioitemnumber     = $item->{'biblioitemnumber'},
barcode              = $barcode,
booksellerid         = $item->{'booksellerid'},
dateaccessioned      = NOW(),
homebranch           = $item->{'homebranch'},
holdingbranch        = $item->{'homebranch'},
price                = $item->{'price'},
replacementprice     = $item->{'replacementprice'},
replacementpricedate = NOW(),
itemnotes            = $item->{'itemnotes'}";

    if ($item->{'loan'}) {
      $query .= ",
notforloan           = $item->{'loan'}";
    } # if

    $sth = $dbh->prepare($query);
    $sth->execute;

    $error .= $sth->errstr;

    $sth->finish;
    $itemnumber++;
  } # for

  return($error);
}

# FIXME - This is the same as &C4::Biblio::Checkitems.
# Pick one and stick with it.
# XXX - POD
sub checkitems{
  my ($count,@barcodes)=@_;
  my $dbh = C4::Context->dbh;
  my $error;
  for (my $i=0;$i<$count;$i++){
    $barcodes[$i]=uc $barcodes[$i];
    my $query="Select * from items where barcode='$barcodes[$i]'";
    my $sth=$dbh->prepare($query);
    $sth->execute;
    if (my $data=$sth->fetchrow_hashref){
      $error.=" Duplicate Barcode: $barcodes[$i]";
    }
    $sth->finish;
  }
  return($error);
}

# FIXME - This appears to be functionally equivalent to
# &C4::Biblio::moditem.
# Pick one and stick with it.
# XXX - POD
sub moditem {
  my ($loan,$itemnum,$bibitemnum,$barcode,$notes,$homebranch,$lost,$wthdrawn,$replacement)=@_;
  my $dbh = C4::Context->dbh;
  my $query="update items set biblioitemnumber=$bibitemnum,
  barcode='$barcode',itemnotes='$notes'
  where itemnumber=$itemnum";
  if ($barcode eq ''){
    $query="update items set biblioitemnumber=$bibitemnum,notforloan=$loan where itemnumber=$itemnum";
  }
  if ($lost ne ''){
    $query="update items set biblioitemnumber=$bibitemnum,
      barcode='$barcode',itemnotes='$notes',homebranch='$homebranch',
      itemlost='$lost',wthdrawn='$wthdrawn' where itemnumber=$itemnum";
  }
  if ($replacement ne ''){
    $query=~ s/ where/,replacementprice='$replacement' where/;
  }

  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
}

# FIXME - This function appears in C4::Catalogue. Neither one is used
sub updatecost{
  my($price,$rrp,$itemnum)=@_;
  my $dbh = C4::Context->dbh;
  my $query="update items set price='$price',replacementprice='$rrp'
  where itemnumber=$itemnum";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
}

# FIXME - This is identical to &C4::Biblio::countitems.
# Pick one and stick with it.
# XXX - POD
sub countitems{
  my ($bibitemnum)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select count(*) from items where biblioitemnumber='$bibitemnum'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data->{'count(*)'});
}

# FIXME - This function appears in C4::Catalogue. Neither one is used.
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

# FIXME - This function appears in C4::Catalogue. Neither one is used
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

# FIXME - A nearly-identical function, appears in C4::Biblio
# Pick one and stick with it.
# XXX - POD
sub delitem{
  my ($itemnum)=@_;
  my $dbh = C4::Context->dbh;
  my $query="select * from items where itemnumber=$itemnum";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @data=$sth->fetchrow_array;
  $sth->finish;
  $query="Insert into deleteditems values (";
  foreach my $temp (@data){
    $query=$query."'$temp',";
  }
  $query=~ s/\,$/\)/;
#  print $query;
  $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $query = "Delete from items where itemnumber=$itemnum";
  $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
}

# FIXME - This is functionally identical to &C4::Biblio::deletebiblioitem.
# Pick one and stick with it.
# XXX - POD
sub deletebiblioitem {
    my ($biblioitemnumber) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "Select * from biblioitems
where biblioitemnumber = $biblioitemnumber";
    my $sth   = $dbh->prepare($query);
    my @results;

    $sth->execute;
  
    if (@results = $sth->fetchrow_array) {

        $query = "Insert into deletedbiblioitems values (";
        foreach my $value (@results) {
            $value  = $dbh->quote($value);
            $query .= "$value,";
        } # foreach

        $query =~ s/\,$/\)/;
        $dbh->do($query);

        $query = "Delete from biblioitems
where biblioitemnumber = $biblioitemnumber";
        $dbh->do($query);
    } # if

    $sth->finish;

# Now delete all the items attached to the biblioitem

    $query = "Select * from items where biblioitemnumber = $biblioitemnumber";
    $sth   = $dbh->prepare($query);

    $sth->execute;

    while (@results = $sth->fetchrow_array) {

	$query = "Insert into deleteditems values (";
	foreach my $value (@results) {
	    $value  = $dbh->quote($value);
	    $query .= "$value,";
	} # foreach

	$query =~ s/\,$/\)/;
	$dbh->do($query);
    } # while

    $sth->finish;

    $query = "Delete from items where biblioitemnumber = $biblioitemnumber";
    $dbh->do($query);
    
} # sub deletebiblioitem

# FIXME - This is functionally identical to &C4::Biblio::delbiblio.
# Pick one and stick with it.
# XXX - POD
sub delbiblio{
  my ($biblio)=@_;
  my $dbh = C4::Context->dbh;
  my $query="select * from biblio where biblionumber=$biblio";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  if (my @data=$sth->fetchrow_array){
    $sth->finish;
    $query="Insert into deletedbiblio values (";
    foreach my $temp (@data){
      $temp=~ s/\'/\\\'/g;
      $query=$query."'$temp',";
    }
    $query=~ s/\,$/\)/;
#   print $query;
    $sth=$dbh->prepare($query);
    $sth->execute;
    $sth->finish;
    $query = "Delete from biblio where biblionumber=$biblio";
    $sth=$dbh->prepare($query);
    $sth->execute;
    $sth->finish;
  }

  $sth->finish;
}

# XXX - POD
sub getitemtypes {
  my $dbh   = C4::Context->dbh;
  my $query = "select * from itemtypes";
  my $sth   = $dbh->prepare($query);
    # || die "Cannot prepare $query" . $dbh->errstr;
  my $count = 0;
  my @results;
  
  $sth->execute;
    # || die "Cannot execute $query\n" . $sth->errstr;
  while (my $data = $sth->fetchrow_hashref) {
    $results[$count] = $data;
    $count++;
  } # while
  
  $sth->finish;
  return($count, @results);
} # sub getitemtypes

# FIXME - This is identical to &C4::Biblio::getitemtypes.
# Pick one and stick with it.
# XXX - POD
sub getbiblio {
    my ($biblionumber) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "Select * from biblio where biblionumber = $biblionumber";
    my $sth   = $dbh->prepare($query);
      # || die "Cannot prepare $query\n" . $dbh->errstr;
    my $count = 0;
    my @results;
    
    $sth->execute;
      # || die "Cannot execute $query\n" . $sth->errstr;
    while (my $data = $sth->fetchrow_hashref) {
      $results[$count] = $data;
      $count++;
    } # while
    
    $sth->finish;
    return($count, @results);
} # sub getbiblio

# XXX - POD
sub getbiblioitem {
    my ($biblioitemnum) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "Select * from biblioitems where
biblioitemnumber = $biblioitemnum";
    my $sth   = $dbh->prepare($query);
    my $count = 0;
    my @results;

    $sth->execute;

    while (my $data = $sth->fetchrow_hashref) {
        $results[$count] = $data;
	$count++;
    } # while

    $sth->finish;
    return($count, @results);
} # sub getbiblioitem

# FIXME - This is identical to &C4::Biblio::getbiblioitem.
# Pick one and stick with it.
# XXX - POD
sub getbiblioitembybiblionumber {
    my ($biblionumber) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "Select * from biblioitems where biblionumber =
$biblionumber";
    my $sth   = $dbh->prepare($query);
    my $count = 0;
    my @results;

    $sth->execute;

    while (my $data = $sth->fetchrow_hashref) {
        $results[$count] = $data;
	$count++;
    } # while

    $sth->finish;
    return($count, @results);
} # sub

# FIXME - This is identical to
# &C4::Biblio::getbiblioitembybiblionumber.
# Pick one and stick with it.
# XXX - POD
sub getitemsbybiblioitem {
    my ($biblioitemnum) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "Select * from items, biblio where
biblio.biblionumber = items.biblionumber and biblioitemnumber
= $biblioitemnum";
    my $sth   = $dbh->prepare($query);
      # || die "Cannot prepare $query\n" . $dbh->errstr;
    my $count = 0;
    my @results;
    
    $sth->execute;
      # || die "Cannot execute $query\n" . $sth->errstr;
    while (my $data = $sth->fetchrow_hashref) {
      $results[$count] = $data;
      $count++;
    } # while
    
    $sth->finish;
    return($count, @results);
} # sub getitemsbybiblioitem

# FIXME - This is identical to &C4::Biblio::isbnsearch.
# Pick one and stick with it.
# XXX - POD
sub isbnsearch {
    my ($isbn) = @_;
    my $dbh   = C4::Context->dbh;
    my $count = 0;
    my $query;
    my $sth;
    my @results;
    
    $isbn  = $dbh->quote($isbn);
    $query = "Select biblio.* from biblio, biblioitems where
biblio.biblionumber = biblioitems.biblionumber
and isbn = $isbn";
    $sth   = $dbh->prepare($query);
    
    $sth->execute;
    while (my $data = $sth->fetchrow_hashref) {
        $results[$count] = $data;
	$count++;
    } # while

    $sth->finish;
    return($count, @results);
} # sub isbnsearch

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
# FIXME - This function appears in C4::Catalogue
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
# FIXME - This function appears in C4::Catalogue
sub addwebsite {
    my ($website) = @_;
    my $dbh = C4::Context->dbh;
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
} # sub website

=item updatewebsite

  &updatewebsite($website);

Updates an existing web site. C<$website> is a reference-to-hash with
the keys C<websitenumber>, C<title>, C<description>, and C<url>. All
of these are mandatory. C<$website-E<gt>{websitenumber}> identifies
the entry to update.

=cut
#'
# FIXME - This function appears in C4::Catalogue
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
# FIXME - This function appears in C4::Catalogue
sub deletewebsite {
    my ($websitenumber) = @_;
    my $dbh = C4::Context->dbh;
    # FIXME - $query is unnecessary: just use
    # $dbh->do(<<EOT);
    #	DELETE FROM websites where websitenumber=$websitenumber
    # EOT
    my $query = "Delete from websites where websitenumber = $websitenumber";
    
    $dbh->do($query);
} # sub deletewebsite


END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=head1 SEE ALSO

L<perl>.

=cut
