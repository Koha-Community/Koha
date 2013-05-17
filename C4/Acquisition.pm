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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


use strict;
use warnings;
use Carp;
use C4::Context;
use C4::Debug;
use C4::Dates qw(format_date format_date_in_iso);
use MARC::Record;
use C4::Suggestions;
use C4::Biblio;
use C4::Debug;
use C4::SQLHelper qw(InsertInTable);

use Time::localtime;
use HTML::Entities;

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
    # set the version for version checking
    $VERSION = 3.08.01.002;
    require Exporter;
    @ISA    = qw(Exporter);
    @EXPORT = qw(
        &GetBasket &NewBasket &CloseBasket &DelBasket &ModBasket
	&GetBasketAsCSV
        &GetBasketsByBookseller &GetBasketsByBasketgroup
        &GetBasketsInfosByBookseller

        &ModBasketHeader

        &ModBasketgroup &NewBasketgroup &DelBasketgroup &GetBasketgroup &CloseBasketgroup
        &GetBasketgroups &ReOpenBasketgroup

        &NewOrder &DelOrder &ModOrder &GetPendingOrders &GetOrder &GetOrders
        &GetOrderNumber &GetLateOrders &GetOrderFromItemnumber
        &SearchOrder &GetHistory &GetRecentAcqui
        &ModReceiveOrder &ModOrderBiblioitemNumber
        &GetCancelledOrders

        &NewOrderItem &ModOrderItem

        &GetParcels &GetParcel
        &GetContracts &GetContract

        &GetItemnumbersFromOrder

        &AddClaim
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

#    $sth->trace(3);

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

  $aqbasket = &GetBasket($basketnumber);

get all basket informations in aqbasket for a given basket

B<returns:> informations for a given basket returned as a hashref.

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

  $basket = &NewBasket( $booksellerid, $authorizedby, $basketname, 
      $basketnote, $basketbooksellernote, $basketcontractnumber );

Create a new basket in aqbasket table

=over

=item C<$booksellerid> is a foreign key in the aqbasket table

=item C<$authorizedby> is the username of who created the basket

=back

The other parameters are optional, see ModBasketHeader for more info on them.

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
    ModBasketHeader($basket, $basketname || '', $basketnote || '', $basketbooksellernote || '', $basketcontractnumber || undef, $booksellerid);
    return $basket;
}

#------------------------------------------------------------#

=head3 CloseBasket

  &CloseBasket($basketno);

close a basket (becomes unmodifiable,except for recieves)

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

=head3 GetBasketAsCSV

  &GetBasketAsCSV($basketno);

Export a basket as CSV

=cut

sub GetBasketAsCSV {
    my ($basketno) = @_;
    my $basket = GetBasket($basketno);
    my @orders = GetOrders($basketno);
    my $contract = GetContract($basket->{'contractnumber'});
    my $csv = Text::CSV->new();
    my $output; 

    # TODO: Translate headers
    my @headers = qw(contractname ordernumber entrydate isbn author title publishercode collectiontitle notes quantity rrp);

    $csv->combine(@headers);                                                                                                        
    $output = $csv->string() . "\n";	

    my @rows;
    foreach my $order (@orders) {
	my @cols;
	# newlines are not valid characters for Text::CSV combine()
        $order->{'notes'} =~ s/[\r\n]+//g;
	push(@cols,
		$contract->{'contractname'},
		$order->{'ordernumber'},
		$order->{'entrydate'}, 
		$order->{'isbn'},
		$order->{'author'},
		$order->{'title'},
		$order->{'publishercode'},
		$order->{'collectiontitle'},
		$order->{'notes'},
		$order->{'quantity'},
		$order->{'rrp'},
	    );
	push (@rows, \@cols);
    }

    foreach my $row (@rows) {
	$csv->combine(@$row);                                                                                                                    
	$output .= $csv->string() . "\n";    

    }
                                                                                                                                                      
    return $output;             

}


=head3 CloseBasketgroup

  &CloseBasketgroup($basketgroupno);

close a basketgroup

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

  &ReOpenBaskergroup($basketgroupno);

reopen a basketgroup

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

  &DelBasket($basketno);

Deletes the basket that has basketno field $basketno in the aqbasket table.

=over

=item C<$basketno> is the primary key of the basket in the aqbasket table.

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

  &ModBasket($basketinfo);

Modifies a basket, using a hashref $basketinfo for the relevant information, only $basketinfo->{'basketno'} is required.

=over

=item C<$basketno> is the primary key of the basket in the aqbasket table.

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

  &ModBasketHeader($basketno, $basketname, $note, $booksellernote, $contractnumber);

Modifies a basket's header.

=over

=item C<$basketno> is the "basketno" field in the "aqbasket" table;

=item C<$basketname> is the "basketname" field in the "aqbasket" table;

=item C<$note> is the "note" field in the "aqbasket" table;

=item C<$booksellernote> is the "booksellernote" field in the "aqbasket" table;

=item C<$contractnumber> is the "contractnumber" (foreign) key in the "aqbasket" table.

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

  @results = &GetBasketsByBookseller($booksellerid, $extra);

Returns a list of hashes of all the baskets that belong to bookseller 'booksellerid'.

=over

=item C<$booksellerid> is the 'id' field of the bookseller in the aqbooksellers table

=item C<$extra> is the extra sql parameters, can be

 $extra->{groupby}: group baskets by column
    ex. $extra->{groupby} = aqbasket.basketgroupid
 $extra->{orderby}: order baskets by column
 $extra->{limit}: limit number of results (can be helpful for pagination)

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

=head3 GetBasketsInfosByBookseller

    my $baskets = GetBasketsInfosByBookseller($supplierid);

Returns in a arrayref of hashref all about booksellers baskets, plus:
    total_biblios: Number of distinct biblios in basket
    total_items: Number of items in basket
    expected_items: Number of non-received items in basket

=cut

sub GetBasketsInfosByBookseller {
    my ($supplierid, $allbaskets) = @_;

    return unless $supplierid;

    my $dbh = C4::Context->dbh;
    my $query = qq{
        SELECT aqbasket.*,
          SUM(aqorders.quantity) AS total_items,
          COUNT(DISTINCT aqorders.biblionumber) AS total_biblios,
          SUM(
            IF(aqorders.datereceived IS NULL
              AND aqorders.datecancellationprinted IS NULL
            , aqorders.quantity
            , 0)
          ) AS expected_items
        FROM aqbasket
          LEFT JOIN aqorders ON aqorders.basketno = aqbasket.basketno
        WHERE booksellerid = ?};
    if(!$allbaskets) {
        $query.=" AND (closedate IS NULL OR (aqorders.quantity > aqorders.quantityreceived AND datecancellationprinted IS NULL))";
    }
    $query.=" GROUP BY aqbasket.basketno";

    my $sth = $dbh->prepare($query);
    $sth->execute($supplierid);
    return $sth->fetchall_arrayref({});
}


#------------------------------------------------------------#

=head3 GetBasketsByBasketgroup

  $baskets = &GetBasketsByBasketgroup($basketgroupid);

Returns a reference to all baskets that belong to basketgroup $basketgroupid.

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

  $basketgroupid = NewBasketgroup(\%hashref);

Adds a basketgroup to the aqbasketgroups table, and add the initial baskets to it.

$hashref->{'booksellerid'} is the 'id' field of the bookseller in the aqbooksellers table,

$hashref->{'name'} is the 'name' field of the basketgroup in the aqbasketgroups table,

$hashref->{'basketlist'} is a list reference of the 'id's of the baskets that belong to this group,

$hashref->{'deliveryplace'} is the 'deliveryplace' field of the basketgroup in the aqbasketgroups table,

$hashref->{'deliverycomment'} is the 'deliverycomment' field of the basketgroup in the aqbasketgroups table,

$hashref->{'closed'} is the 'closed' field of the aqbasketgroups table, it is false if 0, true otherwise.

=cut

sub NewBasketgroup {
    my $basketgroupinfo = shift;
    die "booksellerid is required to create a basketgroup" unless $basketgroupinfo->{'booksellerid'};
    my $query = "INSERT INTO aqbasketgroups (";
    my @params;
    foreach my $field ('name', 'deliveryplace', 'deliverycomment', 'closed') {
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

  ModBasketgroup(\%hashref);

Modifies a basketgroup in the aqbasketgroups table, and add the baskets to it.

$hashref->{'id'} is the 'id' field of the basketgroup in the aqbasketgroup table, this parameter is mandatory,

$hashref->{'name'} is the 'name' field of the basketgroup in the aqbasketgroups table,

$hashref->{'basketlist'} is a list reference of the 'id's of the baskets that belong to this group,

$hashref->{'billingplace'} is the 'billingplace' field of the basketgroup in the aqbasketgroups table,

$hashref->{'deliveryplace'} is the 'deliveryplace' field of the basketgroup in the aqbasketgroups table,

$hashref->{'deliverycomment'} is the 'deliverycomment' field of the basketgroup in the aqbasketgroups table,

$hashref->{'closed'} is the 'closed' field of the aqbasketgroups table, it is false if 0, true otherwise.

=cut

sub ModBasketgroup {
    my $basketgroupinfo = shift;
    die "basketgroup id is required to edit a basketgroup" unless $basketgroupinfo->{'id'};
    my $dbh = C4::Context->dbh;
    my $query = "UPDATE aqbasketgroups SET ";
    my @params;
    foreach my $field (qw(name billingplace deliveryplace freedeliveryplace deliverycomment closed)) {
        if ( defined $basketgroupinfo->{$field} ) {
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

  DelBasketgroup($basketgroupid);

Deletes a basketgroup in the aqbasketgroups table, and removes the reference to it from the baskets,

=over

=item C<$basketgroupid> is the 'id' field of the basket in the aqbasketgroup table

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


=head2 FUNCTIONS ABOUT ORDERS

=head3 GetBasketgroup

  $basketgroup = &GetBasketgroup($basketgroupid);

Returns a reference to the hash containing all infermation about the basketgroup.

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

  $basketgroups = &GetBasketgroups($booksellerid);

Returns a reference to the array of all the basketgroups of bookseller $booksellerid.

=cut

sub GetBasketgroups {
    my $booksellerid = shift;
    die "bookseller id is required to edit a basketgroup" unless $booksellerid;
    my $query = "SELECT * FROM aqbasketgroups WHERE booksellerid=? ORDER BY `id` DESC";
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute($booksellerid);
    my $results = $sth->fetchall_arrayref({});
    $sth->finish;
    return $results
}

#------------------------------------------------------------#

=head2 FUNCTIONS ABOUT ORDERS

=cut

#------------------------------------------------------------#

=head3 GetPendingOrders

$orders = &GetPendingOrders($supplierid,$grouped,$owner,$basketno,$ordernumber,$search,$ean);

Finds pending orders from the bookseller with the given ID. Ignores
completed and cancelled orders.

C<$booksellerid> contains the bookseller identifier
C<$owner> contains 0 or 1. 0 means any owner. 1 means only the list of orders entered by the user itself.
C<$grouped> is a boolean that, if set to 1 will group all order lines of the same basket
in a single result line
C<$orders> is a reference-to-array; each element is a reference-to-hash.

Used also by the filter in parcel.pl
I have added:

C<$ordernumber>
C<$search>
C<$ean>

These give the value of the corresponding field in the aqorders table
of the Koha database.

Results are ordered from most to least recent.

=cut

sub GetPendingOrders {
    my ($supplierid,$grouped,$owner,$basketno,$ordernumber,$search,$ean) = @_;
    my $dbh = C4::Context->dbh;
    my $strsth = "
        SELECT ".($grouped?"count(*),":"")."aqbasket.basketno,
               surname,firstname,biblio.*,biblioitems.isbn,
               aqbasket.closedate, aqbasket.creationdate, aqbasket.basketname,
               aqorders.*
        FROM aqorders
        LEFT JOIN aqbasket ON aqbasket.basketno=aqorders.basketno
        LEFT JOIN borrowers ON aqbasket.authorisedby=borrowers.borrowernumber
        LEFT JOIN biblio ON biblio.biblionumber=aqorders.biblionumber
        LEFT JOIN biblioitems ON biblioitems.biblionumber=biblio.biblionumber
        WHERE (quantity > quantityreceived OR quantityreceived is NULL)
        AND datecancellationprinted IS NULL";
    my @query_params;
    my $userenv = C4::Context->userenv;
    if ( C4::Context->preference("IndependantBranches") ) {
        if ( ($userenv) && ( $userenv->{flags} != 1 ) ) {
            $strsth .= " AND (borrowers.branchcode = ?
                        or borrowers.branchcode  = '')";
            push @query_params, $userenv->{branch};
        }
    }
    if ($supplierid) {
        $strsth .= " AND aqbasket.booksellerid = ?";
        push @query_params, $supplierid;
    }
    if($ordernumber){
        $strsth .= " AND (aqorders.ordernumber=?)";
        push @query_params, $ordernumber;
    }
    if($search){
        $strsth .= " AND (biblio.title like ? OR biblio.author LIKE ? OR biblioitems.isbn like ?)";
        push @query_params, ("%$search%","%$search%","%$search%");
    }
    if ($ean) {
        $strsth .= " AND biblioitems.ean = ?";
        push @query_params, $ean;
    }
    if ($basketno) {
        $strsth .= " AND aqbasket.basketno=? ";
        push @query_params, $basketno;
    }
    if ($owner) {
        $strsth .= " AND aqbasket.authorisedby=? ";
        push @query_params, $userenv->{'number'};
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

  @orders = &GetOrders($basketnumber, $orderby);

Looks up the pending (non-cancelled) orders with the given basket
number. If C<$booksellerID> is non-empty, only orders from that seller
are returned.

return :
C<&basket> returns a two-element array. C<@orders> is an array of
references-to-hash, whose keys are the fields from the aqorders,
biblio, and biblioitems tables in the Koha database.

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

  $ordernumber = &GetOrderNumber($biblioitemnumber, $biblionumber);

Looks up the ordernumber with the given biblionumber and biblioitemnumber.

Returns the number of this order.

=over

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

  $order = &GetOrder($ordernumber);

Looks up an order by order number.

Returns a reference-to-hash describing the order. The keys of
C<$order> are fields from the biblio, biblioitems, aqorders tables of the Koha database.

=cut

sub GetOrder {
    my ($ordernumber) = @_;
    my $dbh      = C4::Context->dbh;
    my $query = "
        SELECT biblioitems.*, biblio.*, aqorders.*
        FROM   aqorders
        LEFT JOIN biblio on           biblio.biblionumber=aqorders.biblionumber
        LEFT JOIN biblioitems on       biblioitems.biblionumber=aqorders.biblionumber
        WHERE aqorders.ordernumber=?

    ";
    my $sth= $dbh->prepare($query);
    $sth->execute($ordernumber);
    my $data = $sth->fetchrow_hashref;
    $sth->finish;
    return $data;
}

#------------------------------------------------------------#

=head3 NewOrder

  &NewOrder(\%hashref);

Adds a new order to the database. Any argument that isn't described
below is the new value of the field with the same name in the aqorders
table of the Koha database.

=over

=item $hashref->{'basketno'} is the basketno foreign key in aqorders, it is mandatory

=item $hashref->{'ordernumber'} is a "minimum order number."

=item $hashref->{'budgetdate'} is effectively ignored.
If it's undef (anything false) or the string 'now', the current day is used.
Else, the upcoming July 1st is used.

=item $hashref->{'subscription'} may be either "yes", or anything else for "no".

=item $hashref->{'uncertainprice'} may be 0 for "the price is known" or 1 for "the price is uncertain"

=item defaults entrydate to Now

The following keys are used: "biblionumber", "title", "basketno", "quantity", "notes", "biblioitemnumber", "rrp", "ecost", "gst", "unitprice", "subscription", "sort1", "sort2", "booksellerinvoicenumber", "listprice", "budgetdate", "purchaseordernumber", "branchcode", "booksellerinvoicenumber", "bookfundid".

=back

=cut

sub NewOrder {
    my $orderinfo = shift;
#### ------------------------------
    my $dbh = C4::Context->dbh;
    my @params;


    # if these parameters are missing, we can't continue
    for my $key (qw/basketno quantity biblionumber budget_id/) {
        croak "Mandatory parameter $key missing" unless $orderinfo->{$key};
    }

    if ( defined $orderinfo->{subscription} && $orderinfo->{'subscription'} eq 'yes' ) {
        $orderinfo->{'subscription'} = 1;
    } else {
        $orderinfo->{'subscription'} = 0;
    }
    $orderinfo->{'entrydate'} ||= C4::Dates->new()->output("iso");
    if (!$orderinfo->{quantityreceived}) {
        $orderinfo->{quantityreceived} = 0;
    }

    my $ordernumber=InsertInTable("aqorders",$orderinfo);
    return ( $orderinfo->{'basketno'}, $ordernumber );
}



#------------------------------------------------------------#

=head3 NewOrderItem

  &NewOrderItem();

=cut

sub NewOrderItem {
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

  &ModOrder(\%hashref);

Modifies an existing order. Updates the order with order number
$hashref->{'ordernumber'} and biblionumber $hashref->{'biblionumber'}. All 
other keys of the hash update the fields with the same name in the aqorders 
table of the Koha database.

=cut

sub ModOrder {
    my $orderinfo = shift;

    die "Ordernumber is required"     if $orderinfo->{'ordernumber'} eq  '' ;
    die "Biblionumber is required"  if  $orderinfo->{'biblionumber'} eq '';

    my $dbh = C4::Context->dbh;
    my @params;

    # update uncertainprice to an integer, just in case (under FF, checked boxes have the value "ON" by default)
    $orderinfo->{uncertainprice}=1 if $orderinfo->{uncertainprice};

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

  &ModOrderItem(\%hashref);

Modifies the itemnumber in the aqorders_items table. The input hash needs three entities:

=over

=item - itemnumber: the old itemnumber
=item - ordernumber: the order this item is attached to
=item - newitemnumber: the new itemnumber we want to attach the line to

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
    my $sth = $dbh->prepare($query);
    $sth->execute(@params);
    return 0;
}

#------------------------------------------------------------#


=head3 ModOrderBibliotemNumber

  &ModOrderBiblioitemNumber($biblioitemnumber,$ordernumber, $biblionumber);

Modifies the biblioitemnumber for an existing order.
Updates the order with order number C<$ordernum> and biblionumber C<$biblionumber>.

=cut

#FIXME: is this used at all?
sub ModOrderBiblioitemNumber {
    my ($biblioitemnumber,$ordernumber, $biblionumber) = @_;
    my $dbh = C4::Context->dbh;
    my $query = "
    UPDATE aqorders
    SET    biblioitemnumber = ?
    WHERE  ordernumber = ?
    AND biblionumber =  ?";
    my $sth = $dbh->prepare($query);
    $sth->execute( $biblioitemnumber, $ordernumber, $biblionumber );
}

=head3 GetCancelledOrders

  my @orders = GetCancelledOrders($basketno, $orderby);

Returns cancelled orders for a basket

=cut

sub GetCancelledOrders {
    my ( $basketno, $orderby ) = @_;

    return () unless $basketno;

    my $dbh   = C4::Context->dbh;
    my $query = "
        SELECT biblio.*, biblioitems.*, aqorders.*, aqbudgets.*
        FROM aqorders
          LEFT JOIN aqbudgets   ON aqbudgets.budget_id = aqorders.budget_id
          LEFT JOIN biblio      ON biblio.biblionumber = aqorders.biblionumber
          LEFT JOIN biblioitems ON biblioitems.biblionumber = biblio.biblionumber
        WHERE basketno = ?
          AND (datecancellationprinted IS NOT NULL
               AND datecancellationprinted <> '0000-00-00')
    ";

    $orderby = "aqorders.datecancellationprinted desc, aqorders.timestamp desc"
        unless $orderby;
    $query .= " ORDER BY $orderby";
    my $sth = $dbh->prepare($query);
    $sth->execute($basketno);
    my $results = $sth->fetchall_arrayref( {} );

    return @$results;
}


#------------------------------------------------------------#

=head3 ModReceiveOrder

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

=cut


sub ModReceiveOrder {
    my (
        $biblionumber,    $ordernumber,  $quantrec, $user, $cost,
        $invoiceno, $freight, $rrp, $budget_id, $datereceived
    )
    = @_;
    my $dbh = C4::Context->dbh;
    $datereceived = C4::Dates->output('iso') unless $datereceived;
    my $suggestionid = GetSuggestionFromBiblionumber( $biblionumber );
    if ($suggestionid) {
        ModSuggestion( {suggestionid=>$suggestionid,
                        STATUS=>'AVAILABLE',
                        biblionumber=> $biblionumber}
                        );
    }

    my $sth=$dbh->prepare("
        SELECT * FROM   aqorders
        WHERE           biblionumber=? AND aqorders.ordernumber=?");

    $sth->execute($biblionumber,$ordernumber);
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
                , quantity=?
            WHERE biblionumber=? AND ordernumber=?");

        $sth->execute($quantrec,$datereceived,$invoiceno,$cost,$freight,$rrp,$quantrec,$biblionumber,$ordernumber);
        $sth->finish;

        # create a new order for the remaining items, and set its bookfund.
        foreach my $orderkey ( "linenumber", "allocation" ) {
            delete($order->{'$orderkey'});
        }
        $order->{'quantity'} -= $quantrec;
        $order->{'quantityreceived'} = 0;
        my $newOrder = NewOrder($order);
} else {
        $sth=$dbh->prepare("update aqorders
                            set quantityreceived=?,datereceived=?,booksellerinvoicenumber=?,
                                unitprice=?,freight=?,rrp=?
                            where biblionumber=? and ordernumber=?");
        $sth->execute($quantrec,$datereceived,$invoiceno,$cost,$freight,$rrp,$biblionumber,$ordernumber);
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

  &DelOrder($biblionumber, $ordernumber);

Cancel the order with the given order and biblio numbers. It does not
delete any entries in the aqorders table, it merely marks them as
cancelled.

=cut

sub DelOrder {
    my ( $bibnum, $ordernumber ) = @_;
    my $dbh = C4::Context->dbh;
    my $query = "
        UPDATE aqorders
        SET    datecancellationprinted=now()
        WHERE  biblionumber=? AND ordernumber=?
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute( $bibnum, $ordernumber );
    $sth->finish;
    my @itemnumbers = GetItemnumbersFromOrder( $ordernumber );
    foreach my $itemnumber (@itemnumbers){
    	C4::Items::DelItem( $dbh, $bibnum, $itemnumber );
    }
    
}

=head2 FUNCTIONS ABOUT PARCELS

=cut

#------------------------------------------------------------#

=head3 GetParcel

  @results = &GetParcel($booksellerid, $code, $date);

Looks up all of the received items from the supplier with the given
bookseller ID at the given date, for the given code (bookseller Invoice number). Ignores cancelled and completed orders.

C<@results> is an array of references-to-hash. The keys of each element are fields from
the aqorders, biblio, and biblioitems tables of the Koha database.

C<@results> is sorted alphabetically by book title.

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

  $results = &GetParcels($bookseller, $order, $code, $datefrom, $dateto);

get a lists of parcels.

* Input arg :

=over

=item $bookseller
is the bookseller this function has to get parcels.

=item $order
To know on what criteria the results list has to be ordered.

=item $code
is the booksellerinvoicenumber.

=item $datefrom & $dateto
to know on what date this function has to filter its search.

=back

* return:
a pointer on a hash list containing parcel informations as such :

=over

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
        WHERE aqbasket.booksellerid = ? and datereceived IS NOT NULL
    ";
    push @query_params, $bookseller;

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

  @results = &GetLateOrders;

Searches for bookseller with late orders.

return:
the table of supplier with late issues. This table is full of hashref.

=cut

sub GetLateOrders {
    my $delay      = shift;
    my $supplierid = shift;
    my $branch     = shift;
    my $estimateddeliverydatefrom = shift;
    my $estimateddeliverydateto = shift;

    my $dbh = C4::Context->dbh;

    #BEWARE, order of parenthesis and LEFT JOIN is important for speed
    my $dbdriver = C4::Context->config("db_scheme") || "mysql";

    my @query_params = ();
    my $select = "
    SELECT aqbasket.basketno,
        aqorders.ordernumber,
        DATE(aqbasket.closedate)  AS orderdate,
        aqorders.rrp              AS unitpricesupplier,
        aqorders.ecost            AS unitpricelib,
        aqorders.claims_count     AS claims_count,
        aqorders.claimed_date     AS claimed_date,
        aqbudgets.budget_name     AS budget,
        borrowers.branchcode      AS branch,
        aqbooksellers.name        AS supplier,
        aqbooksellers.id          AS supplierid,
        biblio.author, biblio.title,
        biblioitems.publishercode AS publisher,
        biblioitems.publicationyear,
        ADDDATE(aqbasket.closedate, INTERVAL aqbooksellers.deliverytime DAY) AS estimateddeliverydate,
    ";
    my $from = "
    FROM
        aqorders LEFT JOIN biblio     ON biblio.biblionumber         = aqorders.biblionumber
        LEFT JOIN biblioitems         ON biblioitems.biblionumber    = biblio.biblionumber
        LEFT JOIN aqbudgets           ON aqorders.budget_id          = aqbudgets.budget_id,
        aqbasket LEFT JOIN borrowers  ON aqbasket.authorisedby       = borrowers.borrowernumber
        LEFT JOIN aqbooksellers       ON aqbasket.booksellerid       = aqbooksellers.id
        WHERE aqorders.basketno = aqbasket.basketno
        AND ( datereceived = ''
            OR datereceived IS NULL
            OR aqorders.quantityreceived < aqorders.quantity
        )
        AND aqbasket.closedate IS NOT NULL
        AND (aqorders.datecancellationprinted IS NULL OR aqorders.datecancellationprinted='0000-00-00')
    ";
    my $having = "";
    if ($dbdriver eq "mysql") {
        $select .= "
        aqorders.quantity - IFNULL(aqorders.quantityreceived,0)                 AS quantity,
        (aqorders.quantity - IFNULL(aqorders.quantityreceived,0)) * aqorders.rrp AS subtotal,
        DATEDIFF(CAST(now() AS date),closedate) AS latesince
        ";
        if ( defined $delay ) {
            $from .= " AND (closedate <= DATE_SUB(CAST(now() AS date),INTERVAL ? DAY)) " ;
            push @query_params, $delay;
        }
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
                (CAST(now() AS date) - closedate)            AS latesince
        ";
        if ( defined $delay ) {
            $from .= " AND (closedate <= (CAST(now() AS date) -(INTERVAL ? DAY)) ";
            push @query_params, $delay;
        }
    }
    if (defined $supplierid) {
        $from .= ' AND aqbasket.booksellerid = ? ';
        push @query_params, $supplierid;
    }
    if (defined $branch) {
        $from .= ' AND borrowers.branchcode LIKE ? ';
        push @query_params, $branch;
    }
    if ( defined $estimateddeliverydatefrom ) {
        $from .= '
            AND aqbooksellers.deliverytime IS NOT NULL
            AND ADDDATE(aqbasket.closedate, INTERVAL aqbooksellers.deliverytime DAY) >= ?';
        push @query_params, $estimateddeliverydatefrom;
    }
    if ( defined $estimateddeliverydatefrom and defined $estimateddeliverydateto ) {
        $from .= ' AND ADDDATE(aqbasket.closedate, INTERVAL aqbooksellers.deliverytime DAY) <= ?';
        push @query_params, $estimateddeliverydateto;
    } elsif ( defined $estimateddeliverydatefrom ) {
        $from .= ' AND ADDDATE(aqbasket.closedate, INTERVAL aqbooksellers.deliverytime DAY) <= CAST(now() AS date)';
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
        $data->{claimed_date} = format_date($data->{claimed_date});
        push @results, $data;
    }
    return @results;
}

#------------------------------------------------------------#

=head3 GetHistory

  (\@order_loop, $total_qty, $total_price, $total_qtyreceived) = GetHistory( %params );

Retreives some acquisition history information

params:  
  title
  author
  name
  from_placed_on
  to_placed_on
  basket                  - search both basket name and number
  booksellerinvoicenumber 

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

=cut

sub GetHistory {
# don't run the query if there are no parameters (list would be too long for sure !)
    croak "No search params" unless @_;
    my %params = @_;
    my $title = $params{title};
    my $author = $params{author};
    my $isbn   = $params{isbn};
    my $name = $params{name};
    my $from_placed_on = $params{from_placed_on};
    my $to_placed_on = $params{to_placed_on};
    my $basket = $params{basket};
    my $booksellerinvoicenumber = $params{booksellerinvoicenumber};

    my @order_loop;
    my $total_qty         = 0;
    my $total_qtyreceived = 0;
    my $total_price       = 0;

    my $dbh   = C4::Context->dbh;
    my $query ="
        SELECT
            biblio.title,
            biblio.author,
	    biblioitems.isbn,
            aqorders.basketno,
    aqbasket.basketname,
    aqbasket.basketgroupid,
    aqbasketgroups.name as groupname,
            aqbooksellers.name,
    aqbasket.creationdate,
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
    LEFT JOIN aqbasketgroups ON aqbasket.basketgroupid=aqbasketgroups.id
        LEFT JOIN aqbooksellers ON aqbasket.booksellerid=aqbooksellers.id
	LEFT JOIN biblioitems ON biblioitems.biblionumber=aqorders.biblionumber
        LEFT JOIN biblio ON biblio.biblionumber=aqorders.biblionumber";

    $query .= " LEFT JOIN borrowers ON aqbasket.authorisedby=borrowers.borrowernumber"
    if ( C4::Context->preference("IndependantBranches") );

    $query .= " WHERE (datecancellationprinted is NULL or datecancellationprinted='0000-00-00') ";

    my @query_params  = ();

    if ( $title ) {
        $query .= " AND biblio.title LIKE ? ";
        $title =~ s/\s+/%/g;
        push @query_params, "%$title%";
    }

    if ( $author ) {
        $query .= " AND biblio.author LIKE ? ";
        push @query_params, "%$author%";
    }

    if ( $isbn ) {
        $query .= " AND biblioitems.isbn LIKE ? ";
        push @query_params, "%$isbn%";
    }

    if ( $name ) {
        $query .= " AND aqbooksellers.name LIKE ? ";
        push @query_params, "%$name%";
    }

    if ( $from_placed_on ) {
        $query .= " AND creationdate >= ? ";
        push @query_params, $from_placed_on;
    }

    if ( $to_placed_on ) {
        $query .= " AND creationdate <= ? ";
        push @query_params, $to_placed_on;
    }

    if ($basket) {
        if ($basket =~ m/^\d+$/) {
            $query .= " AND aqorders.basketno = ? ";
            push @query_params, $basket;
        } else {
            $query .= " AND aqbasket.basketname LIKE ? ";
            push @query_params, "%$basket%";
        }
    }

    if ($booksellerinvoicenumber) {
        $query .= " AND (aqorders.booksellerinvoicenumber LIKE ? OR aqbasket.booksellerinvoicenumber LIKE ?)";
        push @query_params, "%$booksellerinvoicenumber%", "%$booksellerinvoicenumber%";
    }

    if ( C4::Context->preference("IndependantBranches") ) {
        my $userenv = C4::Context->userenv;
        if ( $userenv && ($userenv->{flags} || 0) != 1 ) {
            $query .= " AND (borrowers.branchcode = ? OR borrowers.branchcode ='' ) ";
            push @query_params, $userenv->{branch};
        }
    }
    $query .= " ORDER BY id";
    my $sth = $dbh->prepare($query);
    $sth->execute( @query_params );
    my $cnt = 1;
    while ( my $line = $sth->fetchrow_hashref ) {
        $line->{count} = $cnt++;
        $line->{toggle} = 1 if $cnt % 2;
        push @order_loop, $line;
        $total_qty         += $line->{'quantity'};
        $total_qtyreceived += $line->{'quantityreceived'};
        $total_price       += $line->{'quantity'} * $line->{'ecost'};
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

  $contractlist = &GetContracts($booksellerid, $activeonly);

Looks up the contracts that belong to a bookseller

Returns a list of contracts

=over

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

  $contract = &GetContract($contractID);

Looks up the contract that has PRIMKEY (contractnumber) value $contractID

Returns a contract

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

=head3 AddClaim

=over 4

&AddClaim($ordernumber);

Add a claim for an order

=back

=cut
sub AddClaim {
    my ($ordernumber) = @_;
    my $dbh          = C4::Context->dbh;
    my $query        = "
        UPDATE aqorders SET
            claims_count = claims_count + 1,
            claimed_date = CURDATE()
        WHERE ordernumber = ?
        ";
    my $sth = $dbh->prepare($query);
    $sth->execute($ordernumber);

}

1;
__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut
