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
use C4::Context;
use C4::Debug;
use C4::Dates qw(format_date format_date_in_iso);
use MARC::Record;
use C4::Suggestions;
use C4::Debug;

use Time::localtime;
use HTML::Entities;

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
	# set the version for version checking
	$VERSION = 3.01;
	require Exporter;
	@ISA    = qw(Exporter);
	@EXPORT = qw(
		&GetBasket &NewBasket &CloseBasket &CloseBasketgroup &ReOpenBasketgroup &DelBasket &ModBasket
		&ModBasketHeader &GetBasketsByBookseller &GetBasketsByBasketgroup
		&ModBasketgroup &NewBasketgroup &DelBasketgroup &GetBasketgroup
		&GetBasketgroups

		&GetPendingOrders &GetOrder &GetOrders
		&GetOrderNumber &GetLateOrders &NewOrder &DelOrder
		&SearchOrder &GetHistory &GetRecentAcqui
		&ModOrder &ModOrderItem &ModReceiveOrder &ModOrderBiblioitemNumber

        &NewOrderItem

		&GetParcels &GetParcel
		&GetContracts &GetContract

        &GetOrderFromItemnumber
        &GetItemnumbersFromOrder
	);
}





sub GetOrderFromItemnumber {
    my ($itemnumber) = @_;
    my $dbh          = C4::Context->dbh;
    my $query        = qq|

    SELECT  * from aqorders    LEFT JOIN aqorders_items
    ON (     aqorders.ordernumber = aqorders_items.ordernumber   )
    WHERE itemnumber = ?  |;

    my $sth = $dbh->prepare($query);

    $sth->trace(3);

    $sth->execute($itemnumber);

    my $order = $sth->fetchrow_hashref;
	return ( $order  );

}

# Returns the itemnumber(s) associated with the ordernumber given in parameter 
sub GetItemnumbersFromOrder {
    my ($ordernumber) = @_;
    my $dbh          = C4::Context->dbh;
    my $query        = "SELECT itemnumber FROM aqorders_items WHERE ordernumber=?";
    my $sth = $dbh->prepare($query);
    $sth->execute($ordernumber);
    my @tab;

    while (my $order = $sth->fetchrow_hashref) {
	push @tab, $order->{'itemnumber'}; 
    }

    return @tab;

}






=head1 NAME

C4::Acquisition - Koha functions for dealing with orders and acquisitions

=head1 SYNOPSIS

use C4::Acquisition;

=head1 DESCRIPTION

The functions in this module deal with acquisitions, managing book
orders, basket and parcels.

=head1 FUNCTIONS

=head2 FUNCTIONS ABOUT BASKETS

=head3 GetBasket

=over 4

$aqbasket = &GetBasket($basketnumber);

get all basket informations in aqbasket for a given basket

return :
informations for a given basket returned as a hashref.

=back

=cut

sub GetBasket {
    my ($basketno) = @_;
    my $dbh        = C4::Context->dbh;
    my $query = "
        SELECT  aqbasket.*,
                concat( b.firstname,' ',b.surname) AS authorisedbyname,
                b.branchcode AS branch
        FROM    aqbasket
        LEFT JOIN borrowers b ON aqbasket.authorisedby=b.borrowernumber
        WHERE basketno=?
    ";
    my $sth=$dbh->prepare($query);
    $sth->execute($basketno);
    my $basket = $sth->fetchrow_hashref;
	return ( $basket );
}

#------------------------------------------------------------#

=head3 NewBasket

=over 4

$basket = &NewBasket( $booksellerid, $authorizedby, $basketname, $basketnote, $basketbooksellernote, $basketcontractnumber );

Create a new basket in aqbasket table

=item C<$booksellerid> is a foreign key in the aqbasket table

=item C<$authorizedby> is the username of who created the basket

The other parameters are optional, see ModBasketHeader for more info on them.

=back

=cut

# FIXME : this function seems to be unused.

sub NewBasket {
    my ( $booksellerid, $authorisedby, $basketname, $basketnote, $basketbooksellernote, $basketcontractnumber ) = @_;
    my $dbh = C4::Context->dbh;
    my $query = "
        INSERT INTO aqbasket
                (creationdate,booksellerid,authorisedby)
        VALUES  (now(),'$booksellerid','$authorisedby')
    ";
    my $sth =
      $dbh->do($query);
#find & return basketno MYSQL dependant, but $dbh->last_insert_id always returns null :-(
    my $basket = $dbh->{'mysql_insertid'};
    ModBasketHeader($basket, $basketname || '', $basketnote || '', $basketbooksellernote || '', $basketcontractnumber || undef);
    return $basket;
}

#------------------------------------------------------------#

=head3 CloseBasket

=over 4

&CloseBasket($basketno);

close a basket (becomes unmodifiable,except for recieves)

=back

=cut

sub CloseBasket {
    my ($basketno) = @_;
    my $dbh        = C4::Context->dbh;
    my $query = "
        UPDATE aqbasket
        SET    closedate=now()
        WHERE  basketno=?
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute($basketno);
}

#------------------------------------------------------------#

=head3 CloseBasketgroup

=over 4

&CloseBasketgroup($basketgroupno);

close a basketgroup

=back

=cut

sub CloseBasketgroup {
    my ($basketgroupno) = @_;
    my $dbh        = C4::Context->dbh;
    my $sth = $dbh->prepare("
        UPDATE aqbasketgroups
        SET    closed=1
        WHERE  id=?
    ");
    $sth->execute($basketgroupno);
}

#------------------------------------------------------------#

=head3 ReOpenBaskergroup($basketgroupno)

=over 4

&ReOpenBaskergroup($basketgroupno);

reopen a basketgroup

=back

=cut

sub ReOpenBasketgroup {
    my ($basketgroupno) = @_;
    my $dbh        = C4::Context->dbh;
    my $sth = $dbh->prepare("
        UPDATE aqbasketgroups
        SET    closed=0
        WHERE  id=?
    ");
    $sth->execute($basketgroupno);
}

#------------------------------------------------------------#


=head3 DelBasket

=over 4

&DelBasket($basketno);

Deletes the basket that has basketno field $basketno in the aqbasket table.

=over 2

=item C<$basketno> is the primary key of the basket in the aqbasket table.

=back

=back

=cut
sub DelBasket {
    my ( $basketno ) = @_;
    my $query = "DELETE FROM aqbasket WHERE basketno=?";
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute($basketno);
    $sth->finish;
}

#------------------------------------------------------------#

=head3 ModBasket

=over 4

&ModBasket($basketinfo);

Modifies a basket, using a hashref $basketinfo for the relevant information, only $basketinfo->{'basketno'} is required.

=over 2

=item C<$basketno> is the primary key of the basket in the aqbasket table.

=back

=back

=cut
sub ModBasket {
    my $basketinfo = shift;
    my $query = "UPDATE aqbasket SET ";
    my @params;
    foreach my $key (keys %$basketinfo){
        if ($key ne 'basketno'){
            $query .= "$key=?, ";
            push(@params, $basketinfo->{$key} || undef );
        }
    }
# get rid of the "," at the end of $query
    if (substr($query, length($query)-2) eq ', '){
        chop($query);
        chop($query);
        $query .= ' ';
    }
    $query .= "WHERE basketno=?";
    push(@params, $basketinfo->{'basketno'});
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute(@params);
    $sth->finish;
}

#------------------------------------------------------------#

=head3 ModBasketHeader

=over 4

&ModBasketHeader($basketno, $basketname, $note, $booksellernote, $contractnumber);

Modifies a basket's header.

=over 2

=item C<$basketno> is the "basketno" field in the "aqbasket" table;

=item C<$basketname> is the "basketname" field in the "aqbasket" table;

=item C<$note> is the "note" field in the "aqbasket" table;

=item C<$booksellernote> is the "booksellernote" field in the "aqbasket" table;

=item C<$contractnumber> is the "contractnumber" (foreign) key in the "aqbasket" table.

=back

=back

=cut
sub ModBasketHeader {
    my ($basketno, $basketname, $note, $booksellernote, $contractnumber) = @_;
    my $query = "UPDATE aqbasket SET basketname=?, note=?, booksellernote=? WHERE basketno=?";
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute($basketname,$note,$booksellernote,$basketno);
    if ( $contractnumber ) {
        my $query2 ="UPDATE aqbasket SET contractnumber=? WHERE basketno=?";
        my $sth2 = $dbh->prepare($query2);
        $sth2->execute($contractnumber,$basketno);
        $sth2->finish;
    }
    $sth->finish;
}

#------------------------------------------------------------#

=head3 GetBasketsByBookseller

=over 4

@results = &GetBasketsByBookseller($booksellerid, $extra);

Returns a list of hashes of all the baskets that belong to bookseller 'booksellerid'.

=over 2

=item C<$booksellerid> is the 'id' field of the bookseller in the aqbooksellers table

=item C<$extra> is the extra sql parameters, can be

  - $extra->{groupby}: group baskets by column
       ex. $extra->{groupby} = aqbasket.basketgroupid
  - $extra->{orderby}: order baskets by column
  - $extra->{limit}: limit number of results (can be helpful for pagination)

=back

=back

=cut

sub GetBasketsByBookseller {
    my ($booksellerid, $extra) = @_;
    my $query = "SELECT * FROM aqbasket WHERE booksellerid=?";
    if ($extra){
        if ($extra->{groupby}) {
            $query .= " GROUP by $extra->{groupby}";
        }
        if ($extra->{orderby}){
            $query .= " ORDER by $extra->{orderby}";
        }
        if ($extra->{limit}){
            $query .= " LIMIT $extra->{limit}";
        }
    }
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute($booksellerid);
    my $results = $sth->fetchall_arrayref({});
    $sth->finish;
    return $results
}

#------------------------------------------------------------#

=head3 GetBasketsByBasketgroup

=over 4

$baskets = &GetBasketsByBasketgroup($basketgroupid);

=over 2

Returns a reference to all baskets that belong to basketgroup $basketgroupid.

=back

=back

=cut

sub GetBasketsByBasketgroup {
    my $basketgroupid = shift;
    my $query = "SELECT * FROM aqbasket
                LEFT JOIN aqcontract USING(contractnumber) WHERE basketgroupid=?";
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute($basketgroupid);
    my $results = $sth->fetchall_arrayref({});
    $sth->finish;
    return $results
}

#------------------------------------------------------------#

=head3 NewBasketgroup

=over 4

$basketgroupid = NewBasketgroup(\%hashref);

=over 2

Adds a basketgroup to the aqbasketgroups table, and add the initial baskets to it.

$hashref->{'booksellerid'} is the 'id' field of the bookseller in the aqbooksellers table,

$hashref->{'name'} is the 'name' field of the basketgroup in the aqbasketgroups table,

$hashref->{'basketlist'} is a list reference of the 'id's of the baskets that belong to this group,

$hashref->{'closed'} is the 'closed' field of the aqbasketgroups table, it is false if 0, true otherwise.

=back

=back

=cut

sub NewBasketgroup {
    my $basketgroupinfo = shift;
    die "booksellerid is required to create a basketgroup" unless $basketgroupinfo->{'booksellerid'};
    my $query = "INSERT INTO aqbasketgroups (";
    my @params;
    foreach my $field ('name', 'closed') {
        if ( $basketgroupinfo->{$field} ) {
            $query .= "$field, ";
            push(@params, $basketgroupinfo->{$field});
        }
    }
    $query .= "booksellerid) VALUES (";
    foreach (@params) {
        $query .= "?, ";
    }
    $query .= "?)";
    push(@params, $basketgroupinfo->{'booksellerid'});
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute(@params);
    my $basketgroupid = $dbh->{'mysql_insertid'};
    if( $basketgroupinfo->{'basketlist'} ) {
        foreach my $basketno (@{$basketgroupinfo->{'basketlist'}}) {
            my $query2 = "UPDATE aqbasket SET basketgroupid=? WHERE basketno=?";
            my $sth2 = $dbh->prepare($query2);
            $sth2->execute($basketgroupid, $basketno);
        }
    }
    return $basketgroupid;
}

#------------------------------------------------------------#

=head3 ModBasketgroup

=over 4

ModBasketgroup(\%hashref);

=over 2

Modifies a basketgroup in the aqbasketgroups table, and add the baskets to it.

$hashref->{'id'} is the 'id' field of the basketgroup in the aqbasketgroup table, this parameter is mandatory,

$hashref->{'name'} is the 'name' field of the basketgroup in the aqbasketgroups table,

$hashref->{'basketlist'} is a list reference of the 'id's of the baskets that belong to this group,

$hashref->{'closed'} is the 'closed' field of the aqbasketgroups table, it is false if 0, true otherwise.

=back

=back

=cut

sub ModBasketgroup {
    my $basketgroupinfo = shift;
    die "basketgroup id is required to edit a basketgroup" unless $basketgroupinfo->{'id'};
    my $dbh = C4::Context->dbh;
    my $query = "UPDATE aqbasketgroups SET ";
    my @params;
    foreach my $field (qw(name closed)) {
        if ( $basketgroupinfo->{$field} ne undef) {
            $query .= "$field=?, ";
            push(@params, $basketgroupinfo->{$field});
        }
    }
    chop($query);
    chop($query);
    $query .= " WHERE id=?";
    push(@params, $basketgroupinfo->{'id'});
    my $sth = $dbh->prepare($query);
    $sth->execute(@params);
    
    $sth = $dbh->prepare('UPDATE aqbasket SET basketgroupid = NULL WHERE basketgroupid = ?');
    $sth->execute($basketgroupinfo->{'id'});
    
    if($basketgroupinfo->{'basketlist'} && @{$basketgroupinfo->{'basketlist'}}){
        $sth = $dbh->prepare("UPDATE aqbasket SET basketgroupid=? WHERE basketno=?");
        foreach my $basketno (@{$basketgroupinfo->{'basketlist'}}) {
            $sth->execute($basketgroupinfo->{'id'}, $basketno);
            $sth->finish;
        }
    }
    $sth->finish;
}

#------------------------------------------------------------#

=head3 DelBasketgroup

=over 4

DelBasketgroup($basketgroupid);

=over 2

Deletes a basketgroup in the aqbasketgroups table, and removes the reference to it from the baskets,

=item C<$basketgroupid> is the 'id' field of the basket in the aqbasketgroup table

=back

=back

=cut

sub DelBasketgroup {
    my $basketgroupid = shift;
    die "basketgroup id is required to edit a basketgroup" unless $basketgroupid;
    my $query = "DELETE FROM aqbasketgroups WHERE id=?";
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute($basketgroupid);
    $sth->finish;
}

#------------------------------------------------------------#

=back

=head2 FUNCTIONS ABOUT ORDERS

=over 2

=cut

=head3 GetBasketgroup

=over 4

$basketgroup = &GetBasketgroup($basketgroupid);

=over 2

Returns a reference to the hash containing all infermation about the basketgroup.

=back

=back

=cut

sub GetBasketgroup {
    my $basketgroupid = shift;
    die "basketgroup id is required to edit a basketgroup" unless $basketgroupid;
    my $query = "SELECT * FROM aqbasketgroups WHERE id=?";
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute($basketgroupid);
    my $result = $sth->fetchrow_hashref;
    $sth->finish;
    return $result
}

#------------------------------------------------------------#

=head3 GetBasketgroups

=over 4

$basketgroups = &GetBasketgroups($booksellerid);

=over 2

Returns a reference to the array of all the basketgroups of bookseller $booksellerid.

=back

=back

=cut

sub GetBasketgroups {
    my $booksellerid = shift;
    die "bookseller id is required to edit a basketgroup" unless $booksellerid;
    my $query = "SELECT * FROM aqbasketgroups WHERE booksellerid=?";
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute($booksellerid);
    my $results = $sth->fetchall_arrayref({});
    $sth->finish;
    return $results
}

#------------------------------------------------------------#

=back

=head2 FUNCTIONS ABOUT ORDERS

=over 2

=cut

#------------------------------------------------------------#

=head3 GetPendingOrders

=over 4

$orders = &GetPendingOrders($booksellerid, $grouped, $owner);

Finds pending orders from the bookseller with the given ID. Ignores
completed and cancelled orders.

C<$booksellerid> contains the bookseller identifier
C<$grouped> contains 0 or 1. 0 means returns the list, 1 means return the total
C<$owner> contains 0 or 1. 0 means any owner. 1 means only the list of orders entered by the user itself.

C<$orders> is a reference-to-array; each element is a
reference-to-hash with the following fields:
C<$grouped> is a boolean that, if set to 1 will group all order lines of the same basket
in a single result line

=over 2

=item C<authorizedby>

=item C<entrydate>

=item C<basketno>

These give the value of the corresponding field in the aqorders table
of the Koha database.

=back

=back

Results are ordered from most to least recent.

=cut

sub GetPendingOrders {
    my ($supplierid,$grouped,$owner,$basketno) = @_;
    my $dbh = C4::Context->dbh;
    my $strsth = "
        SELECT    ".($grouped?"count(*),":"")."aqbasket.basketno,
                    surname,firstname,aqorders.*,biblio.*,biblioitems.isbn,
                    aqbasket.closedate, aqbasket.creationdate, aqbasket.basketname
        FROM      aqorders
        LEFT JOIN aqbasket ON aqbasket.basketno=aqorders.basketno
        LEFT JOIN borrowers ON aqbasket.authorisedby=borrowers.borrowernumber
        LEFT JOIN biblio ON biblio.biblionumber=aqorders.biblionumber
        LEFT JOIN biblioitems ON biblioitems.biblionumber=biblio.biblionumber
        WHERE booksellerid=?
            AND (quantity > quantityreceived OR quantityreceived is NULL)
            AND datecancellationprinted IS NULL
            AND (to_days(now())-to_days(closedate) < 180 OR closedate IS NULL)
    ";
    ## FIXME  Why 180 days ???
    my @query_params = ( $supplierid );
    my $userenv = C4::Context->userenv;
    if ( C4::Context->preference("IndependantBranches") ) {
        if ( ($userenv) && ( $userenv->{flags} != 1 ) ) {
            $strsth .= " and (borrowers.branchcode = ?
                          or borrowers.branchcode  = '')";
            push @query_params, $userenv->{branch};
        }
    }
    if ($owner) {
        $strsth .= " AND aqbasket.authorisedby=? ";
        push @query_params, $userenv->{'number'};
    }
    if ($basketno) {
        $strsth .= " AND aqbasket.basketno=? ";
        push @query_params, $basketno;
    }
    $strsth .= " group by aqbasket.basketno" if $grouped;
    $strsth .= " order by aqbasket.basketno";

    my $sth = $dbh->prepare($strsth);
    $sth->execute( @query_params );
    my $results = $sth->fetchall_arrayref({});
    $sth->finish;
    return $results;
}

#------------------------------------------------------------#

=head3 GetOrders

=over 4

@orders = &GetOrders($basketnumber, $orderby);

Looks up the pending (non-cancelled) orders with the given basket
number. If C<$booksellerID> is non-empty, only orders from that seller
are returned.

return :
C<&basket> returns a two-element array. C<@orders> is an array of
references-to-hash, whose keys are the fields from the aqorders,
biblio, and biblioitems tables in the Koha database.

=back

=cut

sub GetOrders {
    my ( $basketno, $orderby ) = @_;
    my $dbh   = C4::Context->dbh;
    my $query  ="
         SELECT biblio.*,biblioitems.*,
                aqorders.*,
                aqbudgets.*,
                biblio.title
        FROM    aqorders
            LEFT JOIN aqbudgets        ON aqbudgets.budget_id = aqorders.budget_id
            LEFT JOIN biblio           ON biblio.biblionumber = aqorders.biblionumber
            LEFT JOIN biblioitems      ON biblioitems.biblionumber =biblio.biblionumber
        WHERE   basketno=?
            AND (datecancellationprinted IS NULL OR datecancellationprinted='0000-00-00')
    ";

    $orderby = "biblioitems.publishercode,biblio.title" unless $orderby;
    $query .= " ORDER BY $orderby";
    my $sth = $dbh->prepare($query);
    $sth->execute($basketno);
    my $results = $sth->fetchall_arrayref({});
    $sth->finish;
    return @$results;
}

#------------------------------------------------------------#

=head3 GetOrderNumber

=over 4

$ordernumber = &GetOrderNumber($biblioitemnumber, $biblionumber);

=back

Looks up the ordernumber with the given biblionumber and biblioitemnumber.

Returns the number of this order.

=over 4

=item C<$ordernumber> is the order number.

=back

=cut
sub GetOrderNumber {
    my ( $biblionumber,$biblioitemnumber ) = @_;
    my $dbh = C4::Context->dbh;
    my $query = "
        SELECT ordernumber
        FROM   aqorders
        WHERE  biblionumber=?
        AND    biblioitemnumber=?
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute( $biblionumber, $biblioitemnumber );

    return $sth->fetchrow;
}

#------------------------------------------------------------#

=head3 GetOrder

=over 4

$order = &GetOrder($ordernumber);

Looks up an order by order number.

Returns a reference-to-hash describing the order. The keys of
C<$order> are fields from the biblio, biblioitems, aqorders tables of the Koha database.

=back

=cut

sub GetOrder {
    my ($ordnum) = @_;
    my $dbh      = C4::Context->dbh;
    my $query = "
        SELECT biblioitems.*, biblio.*, aqorders.*
        FROM   aqorders
        LEFT JOIN biblio on           biblio.biblionumber=aqorders.biblionumber
        LEFT JOIN biblioitems on       biblioitems.biblionumber=aqorders.biblionumber
        WHERE aqorders.ordernumber=?

    ";
    my $sth= $dbh->prepare($query);
    $sth->execute($ordnum);
    my $data = $sth->fetchrow_hashref;
    $sth->finish;
    return $data;
}

#------------------------------------------------------------#

=head3 NewOrder

=over 4

&NewOrder(\%hashref);

Adds a new order to the database. Any argument that isn't described
below is the new value of the field with the same name in the aqorders
table of the Koha database.

=over 4

=item $hashref->{'basketno'} is the basketno foreign key in aqorders, it is mandatory


=item $hashref->{'ordnum'} is a "minimum order number." 

=item $hashref->{'budgetdate'} is effectively ignored.
  If it's undef (anything false) or the string 'now', the current day is used.
  Else, the upcoming July 1st is used.

=item $hashref->{'subscription'} may be either "yes", or anything else for "no".

=item $hashref->{'uncertainprice'} may be 0 for "the price is known" or 1 for "the price is uncertain"

The following keys are used: "biblionumber", "title", "basketno", "quantity", "notes", "biblioitemnumber", "rrp", "ecost", "gst", "unitprice", "subscription", "sort1", "sort2", "booksellerinvoicenumber", "listprice", "budgetdate", "purchaseordernumber", "branchcode", "booksellerinvoicenumber", "bookfundid".

=back

=back

=cut

sub NewOrder {
    my $orderinfo = shift;
#### ------------------------------
    my $dbh = C4::Context->dbh;
    my @params;


    # if these parameters are missing, we can't continue
    for my $key (qw/basketno quantity biblionumber budget_id/) {
        die "Mandatory parameter $key missing" unless $orderinfo->{$key};
    }

    if ( $orderinfo->{'subscription'} eq 'yes' ) {
        $orderinfo->{'subscription'} = 1;
    } else {
        $orderinfo->{'subscription'} = 0;
    }

    my $query = "INSERT INTO aqorders (";
    foreach my $orderinfokey (keys %{$orderinfo}) {
        next if $orderinfokey =~ m/branchcode|entrydate/;   # skip branchcode and entrydate, branchcode isnt a vaild col, entrydate we add manually with NOW()
        $query .= "$orderinfokey,";
        push(@params, $orderinfo->{$orderinfokey});
    }

    $query .= "entrydate) VALUES (";
    foreach (@params) {
        $query .= "?,";
    }
    $query .= " NOW() )";  #ADDING CURRENT DATE TO  'budgetdate, entrydate, purchaseordernumber'...

    my $sth = $dbh->prepare($query);

    $sth->execute(@params);
    $sth->finish;

    #get ordnum MYSQL dependant, but $dbh->last_insert_id returns null
    my $ordnum = $dbh->{'mysql_insertid'};

    $sth->finish;
    return ( $orderinfo->{'basketno'}, $ordnum );
}



#------------------------------------------------------------#

=head3 NewOrderItem

=over 4

&NewOrderItem();


=back

=cut

sub NewOrderItem {
    #my ($biblioitemnumber,$ordnum, $biblionumber) = @_;
    my ($itemnumber, $ordernumber)  = @_;
    my $dbh = C4::Context->dbh;
    my $query = qq|
            INSERT INTO aqorders_items
                (itemnumber, ordernumber)
            VALUES (?,?)    |;

    my $sth = $dbh->prepare($query);
    $sth->execute( $itemnumber, $ordernumber);
}

#------------------------------------------------------------#

=head3 ModOrder

=over 4

&ModOrder(\%hashref);

=over 2

Modifies an existing order. Updates the order with order number
$hashref->{'ordernumber'} and biblionumber $hashref->{'biblionumber'}. All other keys of the hash
update the fields with the same name in the aqorders table of the Koha database.

=back

=back

=cut

sub ModOrder {
    my $orderinfo = shift;

    die "Ordernumber is required"     if $orderinfo->{'ordernumber'} eq  '' ;
    die "Biblionumber is required"  if  $orderinfo->{'biblionumber'} eq '';

    my $dbh = C4::Context->dbh;
    my @params;
#    delete($orderinfo->{'branchcode'});
    # the hash contains a lot of entries not in aqorders, so get the columns ...
    my $sth = $dbh->prepare("SELECT * FROM aqorders LIMIT 1;");
    $sth->execute;
    my $colnames = $sth->{NAME};
    my $query = "UPDATE aqorders SET ";

    foreach my $orderinfokey (grep(!/ordernumber/, keys %$orderinfo)){
        # ... and skip hash entries that are not in the aqorders table
        # FIXME : probably not the best way to do it (would be better to have a correct hash)
        next unless grep(/^$orderinfokey$/, @$colnames);
            $query .= "$orderinfokey=?, ";
            push(@params, $orderinfo->{$orderinfokey});
    }

    $query .= "timestamp=NOW()  WHERE  ordernumber=?";
#   push(@params, $specorderinfo{'ordernumber'});
    push(@params, $orderinfo->{'ordernumber'} );
    $sth = $dbh->prepare($query);
    $sth->execute(@params);
    $sth->finish;
}

#------------------------------------------------------------#

=head3 ModOrderItem

=over 4

&ModOrderItem(\%hashref);

=over 2

Modifies the itemnumber in the aqorders_items table. The input hash needs three entities:
  - itemnumber: the old itemnumber
  - ordernumber: the order this item is attached to
  - newitemnumber: the new itemnumber we want to attach the line to

=back

=back

=cut

sub ModOrderItem {
    my $orderiteminfo = shift;
    if (! $orderiteminfo->{'ordernumber'} || ! $orderiteminfo->{'itemnumber'} || ! $orderiteminfo->{'newitemnumber'}){
        die "Ordernumber, itemnumber and newitemnumber is required";
    }

    my $dbh = C4::Context->dbh;

    my $query = "UPDATE aqorders_items set itemnumber=? where itemnumber=? and ordernumber=?";
    my @params = ($orderiteminfo->{'newitemnumber'}, $orderiteminfo->{'itemnumber'}, $orderiteminfo->{'ordernumber'});
    warn $query;
    warn Data::Dumper::Dumper(@params);
    my $sth = $dbh->prepare($query);
    $sth->execute(@params);
    return 0;
}

#------------------------------------------------------------#


=head3 ModOrderBibliotemNumber

=over 4

&ModOrderBiblioitemNumber($biblioitemnumber,$ordnum, $biblionumber);

Modifies the biblioitemnumber for an existing order.
Updates the order with order number C<$ordernum> and biblionumber C<$biblionumber>.

=back

=cut

#FIXME: is this used at all?
sub ModOrderBiblioitemNumber {
    my ($biblioitemnumber,$ordnum, $biblionumber) = @_;
    my $dbh = C4::Context->dbh;
    my $query = "
      UPDATE aqorders
      SET    biblioitemnumber = ?
      WHERE  ordernumber = ?
      AND biblionumber =  ?";
    my $sth = $dbh->prepare($query);
    $sth->execute( $biblioitemnumber, $ordnum, $biblionumber );
}

#------------------------------------------------------------#

=head3 ModReceiveOrder

=over 4

&ModReceiveOrder($biblionumber, $ordernumber, $quantityreceived, $user,
    $unitprice, $booksellerinvoicenumber, $biblioitemnumber,
    $freight, $bookfund, $rrp);

Updates an order, to reflect the fact that it was received, at least
in part. All arguments not mentioned below update the fields with the
same name in the aqorders table of the Koha database.

If a partial order is received, splits the order into two.  The received
portion must have a booksellerinvoicenumber.

Updates the order with bibilionumber C<$biblionumber> and ordernumber
C<$ordernumber>.

=back

=cut


sub ModReceiveOrder {
    my (
        $biblionumber,    $ordnum,  $quantrec, $user, $cost,
        $invoiceno, $freight, $rrp, $budget_id, $datereceived
      )
      = @_;
    my $dbh = C4::Context->dbh;
#     warn "DATE BEFORE : $daterecieved";
#    $daterecieved=POSIX::strftime("%Y-%m-%d",CORE::localtime) unless $daterecieved;
#     warn "DATE REC : $daterecieved";
	$datereceived = C4::Dates->output('iso') unless $datereceived;
    my $suggestionid = GetSuggestionFromBiblionumber( $dbh, $biblionumber );
    if ($suggestionid) {
        ModStatus( $suggestionid, 'AVAILABLE', '', $biblionumber );
    }

	my $sth=$dbh->prepare("
        SELECT * FROM   aqorders  
	    WHERE           biblionumber=? AND aqorders.ordernumber=?");

    $sth->execute($biblionumber,$ordnum);
    my $order = $sth->fetchrow_hashref();
    $sth->finish();

	if ( $order->{quantity} > $quantrec ) {
        $sth=$dbh->prepare("
            UPDATE aqorders
            SET quantityreceived=?
                , datereceived=?
                , booksellerinvoicenumber=?
                , unitprice=?
                , freight=?
                , rrp=?
                , quantityreceived=?
            WHERE biblionumber=? AND ordernumber=?");

        $sth->execute($quantrec,$datereceived,$invoiceno,$cost,$freight,$rrp,$quantrec,$biblionumber,$ordnum);
        $sth->finish;

        # create a new order for the remaining items, and set its bookfund.
        foreach my $orderkey ( "linenumber", "allocation" ) {
            delete($order->{'$orderkey'});
        }
        my $newOrder = NewOrder($order);
  } else {
        $sth=$dbh->prepare("update aqorders
							set quantityreceived=?,datereceived=?,booksellerinvoicenumber=?,
								unitprice=?,freight=?,rrp=?
                            where biblionumber=? and ordernumber=?");
        $sth->execute($quantrec,$datereceived,$invoiceno,$cost,$freight,$rrp,$biblionumber,$ordnum);
        $sth->finish;
    }
    return $datereceived;
}
#------------------------------------------------------------#

=head3 SearchOrder

@results = &SearchOrder($search, $biblionumber, $complete);

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

C<&ordersearch> returns an array.
C<@results> is an array of references-to-hash with the following keys:

=over 4

=item C<author>

=item C<seriestitle>

=item C<branchcode>

=item C<bookfundid>

=back

=cut

sub SearchOrder {
#### -------- SearchOrder-------------------------------
    my ($ordernumber, $search, $supplierid, $basket) = @_;

    my $dbh = C4::Context->dbh;
    my @args = ();
    my $query =
            "SELECT *
            FROM aqorders
            LEFT JOIN biblio ON aqorders.biblionumber=biblio.biblionumber
            LEFT JOIN biblioitems ON biblioitems.biblionumber=biblio.biblionumber
            LEFT JOIN aqbasket ON aqorders.basketno = aqbasket.basketno
                WHERE  (datecancellationprinted is NULL)";
                
    if($ordernumber){
        $query .= " AND (aqorders.ordernumber=?)";
        push @args, $ordernumber;
    }
    if($search){
        $query .= " AND (biblio.title like ? OR biblio.author LIKE ? OR biblioitems.isbn like ?)";
        push @args, ("%$search%","%$search%","%$search%");
    }
    if($supplierid){
        $query .= "AND aqbasket.booksellerid = ?";
        push @args, $supplierid;
    }
    if($basket){
        $query .= "AND aqorders.basketno = ?";
        push @args, $basket;
    }

    my $sth = $dbh->prepare($query);
    $sth->execute(@args);
    my $results = $sth->fetchall_arrayref({});
    $sth->finish;
    return $results;
}

#------------------------------------------------------------#

=head3 DelOrder

=over 4

&DelOrder($biblionumber, $ordernumber);

Cancel the order with the given order and biblio numbers. It does not
delete any entries in the aqorders table, it merely marks them as
cancelled.

=back

=cut

sub DelOrder {
    my ( $bibnum, $ordnum ) = @_;
    my $dbh = C4::Context->dbh;
    my $query = "
        UPDATE aqorders
        SET    datecancellationprinted=now()
        WHERE  biblionumber=? AND ordernumber=?
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute( $bibnum, $ordnum );
    $sth->finish;
}

=head2 FUNCTIONS ABOUT PARCELS

=cut

#------------------------------------------------------------#

=head3 GetParcel

=over 4

@results = &GetParcel($booksellerid, $code, $date);

Looks up all of the received items from the supplier with the given
bookseller ID at the given date, for the given code (bookseller Invoice number). Ignores cancelled and completed orders.

C<@results> is an array of references-to-hash. The keys of each element are fields from
the aqorders, biblio, and biblioitems tables of the Koha database.

C<@results> is sorted alphabetically by book title.

=back

=cut

sub GetParcel {
    #gets all orders from a certain supplier, orders them alphabetically
    my ( $supplierid, $code, $datereceived ) = @_;
    my $dbh     = C4::Context->dbh;
    my @results = ();
    $code .= '%'
      if $code;  # add % if we search on a given code (otherwise, let him empty)
    my $strsth ="
        SELECT  authorisedby,
                creationdate,
                aqbasket.basketno,
                closedate,surname,
                firstname,
                aqorders.biblionumber,
                aqorders.ordernumber,
                aqorders.quantity,
                aqorders.quantityreceived,
                aqorders.unitprice,
                aqorders.listprice,
                aqorders.rrp,
                aqorders.ecost,
                biblio.title
        FROM aqorders
        LEFT JOIN aqbasket ON aqbasket.basketno=aqorders.basketno
        LEFT JOIN borrowers ON aqbasket.authorisedby=borrowers.borrowernumber
        LEFT JOIN biblio ON aqorders.biblionumber=biblio.biblionumber
        WHERE
            aqbasket.booksellerid = ?
            AND aqorders.booksellerinvoicenumber LIKE ?
            AND aqorders.datereceived = ? ";

    my @query_params = ( $supplierid, $code, $datereceived );
    if ( C4::Context->preference("IndependantBranches") ) {
        my $userenv = C4::Context->userenv;
        if ( ($userenv) && ( $userenv->{flags} != 1 ) ) {
            $strsth .= " and (borrowers.branchcode = ?
                          or borrowers.branchcode  = '')";
            push @query_params, $userenv->{branch};
        }
    }
    $strsth .= " ORDER BY aqbasket.basketno";
    # ## parcelinformation : $strsth
    my $sth = $dbh->prepare($strsth);
    $sth->execute( @query_params );
    while ( my $data = $sth->fetchrow_hashref ) {
        push( @results, $data );
    }
    # ## countparcelbiblio: scalar(@results)
    $sth->finish;

    return @results;
}

#------------------------------------------------------------#

=head3 GetParcels

=over 4

$results = &GetParcels($bookseller, $order, $code, $datefrom, $dateto);
get a lists of parcels.

=back

* Input arg :

=over 4

=item $bookseller
is the bookseller this function has to get parcels.

=item $order
To know on what criteria the results list has to be ordered.

=item $code
is the booksellerinvoicenumber.

=item $datefrom & $dateto
to know on what date this function has to filter its search.

* return:
a pointer on a hash list containing parcel informations as such :

=item Creation date

=item Last operation

=item Number of biblio

=item Number of items

=back

=cut

sub GetParcels {
    my ($bookseller,$order, $code, $datefrom, $dateto) = @_;
    my $dbh    = C4::Context->dbh;
    my @query_params = ();
    my $strsth ="
        SELECT  aqorders.booksellerinvoicenumber,
                datereceived,purchaseordernumber,
                count(DISTINCT biblionumber) AS biblio,
                sum(quantity) AS itemsexpected,
                sum(quantityreceived) AS itemsreceived
        FROM   aqorders LEFT JOIN aqbasket ON aqbasket.basketno = aqorders.basketno
        WHERE aqbasket.booksellerid = $bookseller and datereceived IS NOT NULL
    ";

    if ( defined $code ) {
        $strsth .= ' and aqorders.booksellerinvoicenumber like ? ';
        # add a % to the end of the code to allow stemming.
        push @query_params, "$code%";
    }

    if ( defined $datefrom ) {
        $strsth .= ' and datereceived >= ? ';
        push @query_params, $datefrom;
    }

    if ( defined $dateto ) {
        $strsth .=  'and datereceived <= ? ';
        push @query_params, $dateto;
    }

    $strsth .= "group by aqorders.booksellerinvoicenumber,datereceived ";

    # can't use a placeholder to place this column name.
    # but, we could probably be checking to make sure it is a column that will be fetched.
    $strsth .= "order by $order " if ($order);

    my $sth = $dbh->prepare($strsth);

    $sth->execute( @query_params );
    my $results = $sth->fetchall_arrayref({});
    $sth->finish;
    return @$results;
}

#------------------------------------------------------------#

=head3 GetLateOrders

=over 4

@results = &GetLateOrders;

Searches for bookseller with late orders.

return:
the table of supplier with late issues. This table is full of hashref.

=back

=cut

sub GetLateOrders {
    my $delay      = shift;
    my $supplierid = shift;
    my $branch     = shift;

    my $dbh = C4::Context->dbh;

    #BEWARE, order of parenthesis and LEFT JOIN is important for speed
    my $dbdriver = C4::Context->config("db_scheme") || "mysql";

    my @query_params = ($delay);	# delay is the first argument regardless
	my $select = "
      SELECT aqbasket.basketno,
          aqorders.ordernumber,
          DATE(aqbasket.closedate)  AS orderdate,
          aqorders.rrp              AS unitpricesupplier,
          aqorders.ecost            AS unitpricelib,
          aqbudgets.budget_name     AS budget,
          borrowers.branchcode      AS branch,
          aqbooksellers.name        AS supplier,
          biblio.author,
          biblioitems.publishercode AS publisher,
          biblioitems.publicationyear,
	";
	my $from = "
      FROM (((
          (aqorders LEFT JOIN biblio     ON biblio.biblionumber         = aqorders.biblionumber)
          LEFT JOIN biblioitems          ON biblioitems.biblionumber    = biblio.biblionumber)
          LEFT JOIN aqbudgets            ON aqorders.budget_id          = aqbudgets.budget_id),
          (aqbasket LEFT JOIN borrowers  ON aqbasket.authorisedby       = borrowers.borrowernumber)
          LEFT JOIN aqbooksellers        ON aqbasket.booksellerid       = aqbooksellers.id
          WHERE aqorders.basketno = aqbasket.basketno
          AND ( (datereceived = '' OR datereceived IS NULL)
              OR (aqorders.quantityreceived < aqorders.quantity)
          )
    ";
	my $having = "";
    if ($dbdriver eq "mysql") {
		$select .= "
           aqorders.quantity - IFNULL(aqorders.quantityreceived,0)                 AS quantity,
          (aqorders.quantity - IFNULL(aqorders.quantityreceived,0)) * aqorders.rrp AS subtotal,
          DATEDIFF(CURDATE( ),closedate) AS latesince
		";
        $from .= " AND (closedate <= DATE_SUB(CURDATE( ),INTERVAL ? DAY)) ";
		$having = "
         HAVING quantity          <> 0
            AND unitpricesupplier <> 0
            AND unitpricelib      <> 0
		";
    } else {
		# FIXME: account for IFNULL as above
        $select .= "
                aqorders.quantity                AS quantity,
                aqorders.quantity * aqorders.rrp AS subtotal,
                (CURDATE - closedate)            AS latesince
		";
        $from .= " AND (closedate <= (CURDATE -(INTERVAL ? DAY)) ";
    }
    if (defined $supplierid) {
		$from .= ' AND aqbasket.booksellerid = ? ';
        push @query_params, $supplierid;
    }
    if (defined $branch) {
        $from .= ' AND borrowers.branchcode LIKE ? ';
        push @query_params, $branch;
    }
    if (C4::Context->preference("IndependantBranches")
             && C4::Context->userenv
             && C4::Context->userenv->{flags} != 1 ) {
        $from .= ' AND borrowers.branchcode LIKE ? ';
        push @query_params, C4::Context->userenv->{branch};
    }
	my $query = "$select $from $having\nORDER BY latesince, basketno, borrowers.branchcode, supplier";
	$debug and print STDERR "GetLateOrders query: $query\nGetLateOrders args: " . join(" ",@query_params);
    my $sth = $dbh->prepare($query);
    $sth->execute(@query_params);
    my @results;
    while (my $data = $sth->fetchrow_hashref) {
        $data->{orderdate} = format_date($data->{orderdate});
        push @results, $data;
    }
    return @results;
}

#------------------------------------------------------------#

=head3 GetHistory

=over 4

(\@order_loop, $total_qty, $total_price, $total_qtyreceived) = GetHistory( $title, $author, $name, $from_placed_on, $to_placed_on );

  Retreives some acquisition history information

  returns:
    $order_loop is a list of hashrefs that each look like this:
              {
                'author'           => 'Twain, Mark',
                'basketno'         => '1',
                'biblionumber'     => '215',
                'count'            => 1,
                'creationdate'     => 'MM/DD/YYYY',
                'datereceived'     => undef,
                'ecost'            => '1.00',
                'id'               => '1',
                'invoicenumber'    => undef,
                'name'             => '',
                'ordernumber'      => '1',
                'quantity'         => 1,
                'quantityreceived' => undef,
                'title'            => 'The Adventures of Huckleberry Finn'
              }
    $total_qty is the sum of all of the quantities in $order_loop
    $total_price is the cost of each in $order_loop times the quantity
    $total_qtyreceived is the sum of all of the quantityreceived entries in $order_loop

=back

=cut

sub GetHistory {
    my ( $title, $author, $name, $from_placed_on, $to_placed_on ) = @_;
    my @order_loop;
    my $total_qty         = 0;
    my $total_qtyreceived = 0;
    my $total_price       = 0;

# don't run the query if there are no parameters (list would be too long for sure !)
    if ( $title || $author || $name || $from_placed_on || $to_placed_on ) {
        my $dbh   = C4::Context->dbh;
        my $query ="
            SELECT
                biblio.title,
                biblio.author,
                aqorders.basketno,
                name,aqbasket.creationdate,
                aqorders.datereceived,
                aqorders.quantity,
                aqorders.quantityreceived,
                aqorders.ecost,
                aqorders.ordernumber,
                aqorders.booksellerinvoicenumber as invoicenumber,
                aqbooksellers.id as id,
                aqorders.biblionumber
            FROM aqorders
            LEFT JOIN aqbasket ON aqorders.basketno=aqbasket.basketno
            LEFT JOIN aqbooksellers ON aqbasket.booksellerid=aqbooksellers.id
            LEFT JOIN biblio ON biblio.biblionumber=aqorders.biblionumber";

        $query .= " LEFT JOIN borrowers ON aqbasket.authorisedby=borrowers.borrowernumber"
          if ( C4::Context->preference("IndependantBranches") );

        $query .= " WHERE (datecancellationprinted is NULL or datecancellationprinted='0000-00-00') ";

        my @query_params  = ();

        if ( defined $title ) {
            $query .= " AND biblio.title LIKE ? ";
            push @query_params, "%$title%";
        }

        if ( defined $author ) {
            $query .= " AND biblio.author LIKE ? ";
            push @query_params, "%$author%";
        }

        if ( defined $name ) {
            $query .= " AND name LIKE ? ";
            push @query_params, "%$name%";
        }

        if ( defined $from_placed_on ) {
            $query .= " AND creationdate >= ? ";
            push @query_params, $from_placed_on;
        }

        if ( defined $to_placed_on ) {
            $query .= " AND creationdate <= ? ";
            push @query_params, $to_placed_on;
        }

        if ( C4::Context->preference("IndependantBranches") ) {
            my $userenv = C4::Context->userenv;
            if ( ($userenv) && ( $userenv->{flags} != 1 ) ) {
                $query .= " AND (borrowers.branchcode = ? OR borrowers.branchcode ='' ) ";
                push @query_params, $userenv->{branch};
            }
        }
        $query .= " ORDER BY booksellerid";
        my $sth = $dbh->prepare($query);
        $sth->execute( @query_params );
        my $cnt = 1;
        while ( my $line = $sth->fetchrow_hashref ) {
            $line->{count} = $cnt++;
            $line->{toggle} = 1 if $cnt % 2;
            push @order_loop, $line;
            $line->{creationdate} = format_date( $line->{creationdate} );
            $line->{datereceived} = format_date( $line->{datereceived} );
            $total_qty         += $line->{'quantity'};
            $total_qtyreceived += $line->{'quantityreceived'};
            $total_price       += $line->{'quantity'} * $line->{'ecost'};
        }
    }
    return \@order_loop, $total_qty, $total_price, $total_qtyreceived;
}

=head2 GetRecentAcqui

   $results = GetRecentAcqui($days);

   C<$results> is a ref to a table which containts hashref

=cut

sub GetRecentAcqui {
    my $limit  = shift;
    my $dbh    = C4::Context->dbh;
    my $query = "
        SELECT *
        FROM   biblio
        ORDER BY timestamp DESC
        LIMIT  0,".$limit;

    my $sth = $dbh->prepare($query);
    $sth->execute;
    my $results = $sth->fetchall_arrayref({});
    return $results;
}

=head3 GetContracts

=over 4

$contractlist = &GetContracts($booksellerid, $activeonly);

Looks up the contracts that belong to a bookseller

Returns a list of contracts

=item C<$booksellerid> is the "id" field in the "aqbooksellers" table.

=item C<$activeonly> if exists get only contracts that are still active.

=back

=cut
sub GetContracts {
    my ( $booksellerid, $activeonly ) = @_;
    my $dbh = C4::Context->dbh;
    my $query;
    if (! $activeonly) {
        $query = "
            SELECT *
            FROM   aqcontract
            WHERE  booksellerid=?
        ";
    } else {
        $query = "SELECT *
            FROM aqcontract
            WHERE booksellerid=?
                AND contractenddate >= CURDATE( )";
    }
    my $sth = $dbh->prepare($query);
    $sth->execute( $booksellerid );
    my @results;
    while (my $data = $sth->fetchrow_hashref ) {
        push(@results, $data);
    }
    $sth->finish;
    return @results;
}

#------------------------------------------------------------#

=head3 GetContract

=over 4

$contract = &GetContract($contractID);

Looks up the contract that has PRIMKEY (contractnumber) value $contractID

Returns a contract

=back

=cut
sub GetContract {
    my ( $contractno ) = @_;
    my $dbh = C4::Context->dbh;
    my $query = "
        SELECT *
        FROM   aqcontract
        WHERE  contractnumber=?
        ";

    my $sth = $dbh->prepare($query);
    $sth->execute( $contractno );
    my $result = $sth->fetchrow_hashref;
    return $result;
}

1;
__END__

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
