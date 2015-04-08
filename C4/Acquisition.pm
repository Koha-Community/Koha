package C4::Acquisition;

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.


use Modern::Perl;
use Carp;
use C4::Context;
use C4::Debug;
use C4::Dates qw(format_date format_date_in_iso);
use MARC::Record;
use C4::Suggestions;
use C4::Biblio;
use C4::Contract;
use C4::Debug;
use C4::Bookseller qw(GetBookSellerFromId);
use C4::Templates qw(gettemplate);
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Acquisition::Order;

use Time::localtime;
use HTML::Entities;

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
    # set the version for version checking
    $VERSION = 3.07.00.049;
    require Exporter;
    @ISA    = qw(Exporter);
    @EXPORT = qw(
        &GetBasket &NewBasket &CloseBasket &ReopenBasket &DelBasket &ModBasket
        &GetBasketAsCSV &GetBasketGroupAsCSV
        &GetBasketsByBookseller &GetBasketsByBasketgroup
        &GetBasketsInfosByBookseller

        &GetBasketUsers &ModBasketUsers
        &CanUserManageBasket

        &ModBasketHeader

        &ModBasketgroup &NewBasketgroup &DelBasketgroup &GetBasketgroup &CloseBasketgroup
        &GetBasketgroups &ReOpenBasketgroup

        &DelOrder &ModOrder &GetOrder &GetOrders &GetOrdersByBiblionumber
        &GetLateOrders &GetOrderFromItemnumber
        &SearchOrders &GetHistory &GetRecentAcqui
        &ModReceiveOrder &CancelReceipt
        &GetCancelledOrders &TransferOrder
        &GetLastOrderNotReceivedFromSubscriptionid &GetLastOrderReceivedFromSubscriptionid
        &ModItemOrder

        &GetParcels &GetParcel

        &GetInvoices
        &GetInvoice
        &GetInvoiceDetails
        &AddInvoice
        &ModInvoice
        &CloseInvoice
        &ReopenInvoice
        &DelInvoice
        &MergeInvoices

        &GetItemnumbersFromOrder

        &AddClaim
        &GetBiblioCountByBasketno
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
                concat( b.firstname,' ',b.surname) AS authorisedbyname
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
      $basketnote, $basketbooksellernote, $basketcontractnumber, $deliveryplace, $billingplace );

Create a new basket in aqbasket table

=over

=item C<$booksellerid> is a foreign key in the aqbasket table

=item C<$authorizedby> is the username of who created the basket

=back

The other parameters are optional, see ModBasketHeader for more info on them.

=cut

sub NewBasket {
    my ( $booksellerid, $authorisedby, $basketname, $basketnote,
        $basketbooksellernote, $basketcontractnumber, $deliveryplace,
        $billingplace ) = @_;
    my $dbh = C4::Context->dbh;
    my $query =
        'INSERT INTO aqbasket (creationdate,booksellerid,authorisedby) '
      . 'VALUES  (now(),?,?)';
    $dbh->do( $query, {}, $booksellerid, $authorisedby );

    my $basket = $dbh->{mysql_insertid};
    $basketname           ||= q{}; # default to empty strings
    $basketnote           ||= q{};
    $basketbooksellernote ||= q{};
    ModBasketHeader( $basket, $basketname, $basketnote, $basketbooksellernote,
        $basketcontractnumber, $booksellerid, $deliveryplace, $billingplace );
    return $basket;
}

#------------------------------------------------------------#

=head3 CloseBasket

  &CloseBasket($basketno);

close a basket (becomes unmodifiable, except for receives)

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

    my @orders = GetOrders($basketno);
    foreach my $order (@orders) {
        $query = qq{
            UPDATE aqorders
            SET orderstatus = 'ordered'
            WHERE ordernumber = ?;
        };
        $sth = $dbh->prepare($query);
        $sth->execute($order->{'ordernumber'});
    }
}

=head3 ReopenBasket

  &ReopenBasket($basketno);

reopen a basket

=cut

sub ReopenBasket {
    my ($basketno) = @_;
    my $dbh        = C4::Context->dbh;
    my $query = "
        UPDATE aqbasket
        SET    closedate=NULL
        WHERE  basketno=?
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute($basketno);

    my @orders = GetOrders($basketno);
    foreach my $order (@orders) {
        $query = qq{
            UPDATE aqorders
            SET orderstatus = 'new'
            WHERE ordernumber = ?;
        };
        $sth = $dbh->prepare($query);
        $sth->execute($order->{'ordernumber'});
    }
}

#------------------------------------------------------------#

=head3 GetBasketAsCSV

  &GetBasketAsCSV($basketno);

Export a basket as CSV

$cgi parameter is needed for column name translation

=cut

sub GetBasketAsCSV {
    my ($basketno, $cgi) = @_;
    my $basket = GetBasket($basketno);
    my @orders = GetOrders($basketno);
    my $contract = GetContract({
        contractnumber => $basket->{'contractnumber'}
    });

    my $template = C4::Templates::gettemplate("acqui/csv/basket.tt", "intranet", $cgi);

    my @rows;
    foreach my $order (@orders) {
        my $bd = GetBiblioData( $order->{'biblionumber'} );
        my $row = {
            contractname => $contract->{'contractname'},
            ordernumber => $order->{'ordernumber'},
            entrydate => $order->{'entrydate'},
            isbn => $order->{'isbn'},
            author => $bd->{'author'},
            title => $bd->{'title'},
            publicationyear => $bd->{'publicationyear'},
            publishercode => $bd->{'publishercode'},
            collectiontitle => $bd->{'collectiontitle'},
            notes => $order->{'order_vendornote'},
            quantity => $order->{'quantity'},
            rrp => $order->{'rrp'},
            deliveryplace => C4::Branch::GetBranchName( $basket->{'deliveryplace'} ),
            billingplace => C4::Branch::GetBranchName( $basket->{'billingplace'} ),
        };
        foreach(qw(
            contractname author title publishercode collectiontitle notes
            deliveryplace billingplace
        ) ) {
            # Double the quotes to not be interpreted as a field end
            $row->{$_} =~ s/"/""/g if $row->{$_};
        }
        push @rows, $row;
    }

    @rows = sort {
        if(defined $a->{publishercode} and defined $b->{publishercode}) {
            $a->{publishercode} cmp $b->{publishercode};
        }
    } @rows;

    $template->param(rows => \@rows);

    return $template->output;
}


=head3 GetBasketGroupAsCSV

=over

&GetBasketGroupAsCSV($basketgroupid);

Export a basket group as CSV

$cgi parameter is needed for column name translation

=back

=cut

sub GetBasketGroupAsCSV {
    my ($basketgroupid, $cgi) = @_;
    my $baskets = GetBasketsByBasketgroup($basketgroupid);

    my $template = C4::Templates::gettemplate('acqui/csv/basketgroup.tt', 'intranet', $cgi);

    my @rows;
    for my $basket (@$baskets) {
        my @orders     = GetOrders( $basket->{basketno} );
        my $contract   = GetContract({
            contractnumber => $basket->{contractnumber}
        });
        my $bookseller = GetBookSellerFromId( $$basket{booksellerid} );
        my $basketgroup = GetBasketgroup( $$basket{basketgroupid} );

        foreach my $order (@orders) {
            my $bd = GetBiblioData( $order->{'biblionumber'} );
            my $row = {
                clientnumber => $bookseller->{accountnumber},
                basketname => $basket->{basketname},
                ordernumber => $order->{ordernumber},
                author => $bd->{author},
                title => $bd->{title},
                publishercode => $bd->{publishercode},
                publicationyear => $bd->{publicationyear},
                collectiontitle => $bd->{collectiontitle},
                isbn => $order->{isbn},
                quantity => $order->{quantity},
                rrp => $order->{rrp},
                discount => $bookseller->{discount},
                ecost => $order->{ecost},
                notes => $order->{order_vendornote},
                entrydate => $order->{entrydate},
                booksellername => $bookseller->{name},
                bookselleraddress => $bookseller->{address1},
                booksellerpostal => $bookseller->{postal},
                contractnumber => $contract->{contractnumber},
                contractname => $contract->{contractname},
                basketgroupdeliveryplace => C4::Branch::GetBranchName( $basketgroup->{deliveryplace} ),
                basketgroupbillingplace => C4::Branch::GetBranchName( $basketgroup->{billingplace} ),
                basketdeliveryplace => C4::Branch::GetBranchName( $basket->{deliveryplace} ),
                basketbillingplace => C4::Branch::GetBranchName( $basket->{billingplace} ),
            };
            foreach(qw(
                basketname author title publishercode collectiontitle notes
                booksellername bookselleraddress booksellerpostal contractname
                basketgroupdeliveryplace basketgroupbillingplace
                basketdeliveryplace basketbillingplace
            ) ) {
                # Double the quotes to not be interpreted as a field end
                $row->{$_} =~ s/"/""/g if $row->{$_};
            }
            push @rows, $row;
         }
     }
    $template->param(rows => \@rows);

    return $template->output;

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
    return;
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

    return;
}

#------------------------------------------------------------#

=head3 ModBasketHeader

  &ModBasketHeader($basketno, $basketname, $note, $booksellernote, $contractnumber, $booksellerid);

Modifies a basket's header.

=over

=item C<$basketno> is the "basketno" field in the "aqbasket" table;

=item C<$basketname> is the "basketname" field in the "aqbasket" table;

=item C<$note> is the "note" field in the "aqbasket" table;

=item C<$booksellernote> is the "booksellernote" field in the "aqbasket" table;

=item C<$contractnumber> is the "contractnumber" (foreign) key in the "aqbasket" table.

=item C<$booksellerid> is the id (foreign) key in the "aqbooksellers" table for the vendor.

=item C<$deliveryplace> is the "deliveryplace" field in the aqbasket table.

=item C<$billingplace> is the "billingplace" field in the aqbasket table.

=back

=cut

sub ModBasketHeader {
    my ($basketno, $basketname, $note, $booksellernote, $contractnumber, $booksellerid, $deliveryplace, $billingplace) = @_;
    my $query = qq{
        UPDATE aqbasket
        SET basketname=?, note=?, booksellernote=?, booksellerid=?, deliveryplace=?, billingplace=?
        WHERE basketno=?
    };

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute($basketname, $note, $booksellernote, $booksellerid, $deliveryplace, $billingplace, $basketno);

    if ( $contractnumber ) {
        my $query2 ="UPDATE aqbasket SET contractnumber=? WHERE basketno=?";
        my $sth2 = $dbh->prepare($query2);
        $sth2->execute($contractnumber,$basketno);
    }
    return;
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
    return $sth->fetchall_arrayref({});
}

=head3 GetBasketsInfosByBookseller

    my $baskets = GetBasketsInfosByBookseller($supplierid, $allbaskets);

The optional second parameter allbaskets is a boolean allowing you to
select all baskets from the supplier; by default only active baskets (open or 
closed but still something to receive) are returned.

Returns in a arrayref of hashref all about booksellers baskets, plus:
    total_biblios: Number of distinct biblios in basket
    total_items: Number of items in basket
    expected_items: Number of non-received items in basket

=cut

sub GetBasketsInfosByBookseller {
    my ($supplierid, $allbaskets) = @_;

    return unless $supplierid;

    my $dbh = C4::Context->dbh;
    my $query = q{
        SELECT aqbasket.*,
          SUM(aqorders.quantity) AS total_items,
          SUM(
            IF ( aqorders.orderstatus = 'cancelled', aqorders.quantity, 0 )
          ) AS total_items_cancelled,
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

    unless ( $allbaskets ) {
        $query.=" AND (closedate IS NULL OR (aqorders.quantity > aqorders.quantityreceived AND datecancellationprinted IS NULL))";
    }
    $query.=" GROUP BY aqbasket.basketno";

    my $sth = $dbh->prepare($query);
    $sth->execute($supplierid);
    my $baskets = $sth->fetchall_arrayref({});

    # Retrieve the number of biblios cancelled
    my $cancelled_biblios = $dbh->selectall_hashref( q|
        SELECT COUNT(DISTINCT(biblionumber)) AS total_biblios_cancelled, aqbasket.basketno
        FROM aqbasket
        LEFT JOIN aqorders ON aqorders.basketno = aqbasket.basketno
        WHERE booksellerid = ?
        AND aqorders.orderstatus = 'cancelled'
        GROUP BY aqbasket.basketno
    |, 'basketno', {}, $supplierid );
    map {
        $_->{total_biblios_cancelled} = $cancelled_biblios->{$_->{basketno}}{total_biblios_cancelled} || 0
    } @$baskets;

    return $baskets;
}

=head3 GetBasketUsers

    $basketusers_ids = &GetBasketUsers($basketno);

Returns a list of all borrowernumbers that are in basket users list

=cut

sub GetBasketUsers {
    my $basketno = shift;

    return unless $basketno;

    my $query = qq{
        SELECT borrowernumber
        FROM aqbasketusers
        WHERE basketno = ?
    };
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute($basketno);
    my $results = $sth->fetchall_arrayref( {} );

    my @borrowernumbers;
    foreach (@$results) {
        push @borrowernumbers, $_->{'borrowernumber'};
    }

    return @borrowernumbers;
}

=head3 ModBasketUsers

    my @basketusers_ids = (1, 2, 3);
    &ModBasketUsers($basketno, @basketusers_ids);

Delete all users from basket users list, and add users in C<@basketusers_ids>
to this users list.

=cut

sub ModBasketUsers {
    my ($basketno, @basketusers_ids) = @_;

    return unless $basketno;

    my $dbh = C4::Context->dbh;
    my $query = qq{
        DELETE FROM aqbasketusers
        WHERE basketno = ?
    };
    my $sth = $dbh->prepare($query);
    $sth->execute($basketno);

    $query = qq{
        INSERT INTO aqbasketusers (basketno, borrowernumber)
        VALUES (?, ?)
    };
    $sth = $dbh->prepare($query);
    foreach my $basketuser_id (@basketusers_ids) {
        $sth->execute($basketno, $basketuser_id);
    }
    return;
}

=head3 CanUserManageBasket

    my $bool = CanUserManageBasket($borrower, $basket[, $userflags]);
    my $bool = CanUserManageBasket($borrowernumber, $basketno[, $userflags]);

Check if a borrower can manage a basket, according to system preference
AcqViewBaskets, user permissions and basket properties (creator, users list,
branch).

First parameter can be either a borrowernumber or a hashref as returned by
C4::Members::GetMember.

Second parameter can be either a basketno or a hashref as returned by
C4::Acquisition::GetBasket.

The third parameter is optional. If given, it should be a hashref as returned
by C4::Auth::getuserflags. If not, getuserflags is called.

If user is authorised to manage basket, returns 1.
Otherwise returns 0.

=cut

sub CanUserManageBasket {
    my ($borrower, $basket, $userflags) = @_;

    if (!ref $borrower) {
        $borrower = C4::Members::GetMember(borrowernumber => $borrower);
    }
    if (!ref $basket) {
        $basket = GetBasket($basket);
    }

    return 0 unless ($basket and $borrower);

    my $borrowernumber = $borrower->{borrowernumber};
    my $basketno = $basket->{basketno};

    my $AcqViewBaskets = C4::Context->preference('AcqViewBaskets');

    if (!defined $userflags) {
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare("SELECT flags FROM borrowers WHERE borrowernumber = ?");
        $sth->execute($borrowernumber);
        my ($flags) = $sth->fetchrow_array;
        $sth->finish;

        $userflags = C4::Auth::getuserflags($flags, $borrower->{userid}, $dbh);
    }

    unless ($userflags->{superlibrarian}
    || (ref $userflags->{acquisition} && $userflags->{acquisition}->{order_manage_all})
    || (!ref $userflags->{acquisition} && $userflags->{acquisition}))
    {
        if (not exists $userflags->{acquisition}) {
            return 0;
        }

        if ( (ref $userflags->{acquisition} && !$userflags->{acquisition}->{order_manage})
        || (!ref $userflags->{acquisition} && !$userflags->{acquisition}) ) {
            return 0;
        }

        if ($AcqViewBaskets eq 'user'
        && $basket->{authorisedby} != $borrowernumber
        && grep($borrowernumber, GetBasketUsers($basketno)) == 0) {
            return 0;
        }

        if ($AcqViewBaskets eq 'branch' && defined $basket->{branch}
        && $basket->{branch} ne $borrower->{branchcode}) {
            return 0;
        }
    }

    return 1;
}

#------------------------------------------------------------#

=head3 GetBasketsByBasketgroup

  $baskets = &GetBasketsByBasketgroup($basketgroupid);

Returns a reference to all baskets that belong to basketgroup $basketgroupid.

=cut

sub GetBasketsByBasketgroup {
    my $basketgroupid = shift;
    my $query = qq{
        SELECT *, aqbasket.booksellerid as booksellerid
        FROM aqbasket
        LEFT JOIN aqcontract USING(contractnumber) WHERE basketgroupid=?
    };
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute($basketgroupid);
    return $sth->fetchall_arrayref({});
}

#------------------------------------------------------------#

=head3 NewBasketgroup

  $basketgroupid = NewBasketgroup(\%hashref);

Adds a basketgroup to the aqbasketgroups table, and add the initial baskets to it.

$hashref->{'booksellerid'} is the 'id' field of the bookseller in the aqbooksellers table,

$hashref->{'name'} is the 'name' field of the basketgroup in the aqbasketgroups table,

$hashref->{'basketlist'} is a list reference of the 'id's of the baskets that belong to this group,

$hashref->{'billingplace'} is the 'billingplace' field of the basketgroup in the aqbasketgroups table,

$hashref->{'deliveryplace'} is the 'deliveryplace' field of the basketgroup in the aqbasketgroups table,

$hashref->{'freedeliveryplace'} is the 'freedeliveryplace' field of the basketgroup in the aqbasketgroups table,

$hashref->{'deliverycomment'} is the 'deliverycomment' field of the basketgroup in the aqbasketgroups table,

$hashref->{'closed'} is the 'closed' field of the aqbasketgroups table, it is false if 0, true otherwise.

=cut

sub NewBasketgroup {
    my $basketgroupinfo = shift;
    die "booksellerid is required to create a basketgroup" unless $basketgroupinfo->{'booksellerid'};
    my $query = "INSERT INTO aqbasketgroups (";
    my @params;
    foreach my $field (qw(name billingplace deliveryplace freedeliveryplace deliverycomment closed)) {
        if ( defined $basketgroupinfo->{$field} ) {
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

$hashref->{'freedeliveryplace'} is the 'freedeliveryplace' field of the basketgroup in the aqbasketgroups table,

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
        }
    }
    return;
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
    return;
}

#------------------------------------------------------------#


=head2 FUNCTIONS ABOUT ORDERS

=head3 GetBasketgroup

  $basketgroup = &GetBasketgroup($basketgroupid);

Returns a reference to the hash containing all information about the basketgroup.

=cut

sub GetBasketgroup {
    my $basketgroupid = shift;
    die "basketgroup id is required to edit a basketgroup" unless $basketgroupid;
    my $dbh = C4::Context->dbh;
    my $result_set = $dbh->selectall_arrayref(
        'SELECT * FROM aqbasketgroups WHERE id=?',
        { Slice => {} },
        $basketgroupid
    );
    return $result_set->[0];    # id is unique
}

#------------------------------------------------------------#

=head3 GetBasketgroups

  $basketgroups = &GetBasketgroups($booksellerid);

Returns a reference to the array of all the basketgroups of bookseller $booksellerid.

=cut

sub GetBasketgroups {
    my $booksellerid = shift;
    die 'bookseller id is required to edit a basketgroup' unless $booksellerid;
    my $query = 'SELECT * FROM aqbasketgroups WHERE booksellerid=? ORDER BY id DESC';
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute($booksellerid);
    return $sth->fetchall_arrayref({});
}

#------------------------------------------------------------#

=head2 FUNCTIONS ABOUT ORDERS

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
    return () unless $basketno;
    my $dbh   = C4::Context->dbh;
    my $query  ="
        SELECT biblio.*,biblioitems.*,
                aqorders.*,
                aqbudgets.*,
                aqorders_transfers.ordernumber_from AS transferred_from,
                aqorders_transfers.timestamp AS transferred_from_timestamp
        FROM    aqorders
            LEFT JOIN aqbudgets        ON aqbudgets.budget_id = aqorders.budget_id
            LEFT JOIN biblio           ON biblio.biblionumber = aqorders.biblionumber
            LEFT JOIN biblioitems      ON biblioitems.biblionumber =biblio.biblionumber
            LEFT JOIN aqorders_transfers ON aqorders_transfers.ordernumber_to = aqorders.ordernumber
        WHERE   basketno=?
            AND (datecancellationprinted IS NULL OR datecancellationprinted='0000-00-00')
    ";

    $orderby = "biblioitems.publishercode,biblio.title" unless $orderby;
    $query .= " ORDER BY $orderby";
    my $result_set =
      $dbh->selectall_arrayref( $query, { Slice => {} }, $basketno );
    return @{$result_set};

}

#------------------------------------------------------------#
=head3 GetOrdersByBiblionumber

  @orders = &GetOrdersByBiblionumber($biblionumber);

Looks up the orders with linked to a specific $biblionumber, including
cancelled orders and received orders.

return :
C<@orders> is an array of references-to-hash, whose keys are the
fields from the aqorders, biblio, and biblioitems tables in the Koha database.

=cut

sub GetOrdersByBiblionumber {
    my $biblionumber = shift;
    return unless $biblionumber;
    my $dbh   = C4::Context->dbh;
    my $query  ="
        SELECT biblio.*,biblioitems.*,
                aqorders.*,
                aqbudgets.*
        FROM    aqorders
            LEFT JOIN aqbudgets        ON aqbudgets.budget_id = aqorders.budget_id
            LEFT JOIN biblio           ON biblio.biblionumber = aqorders.biblionumber
            LEFT JOIN biblioitems      ON biblioitems.biblionumber =biblio.biblionumber
        WHERE   aqorders.biblionumber=?
    ";
    my $result_set =
      $dbh->selectall_arrayref( $query, { Slice => {} }, $biblionumber );
    return @{$result_set};

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
    return unless $ordernumber;

    my $dbh      = C4::Context->dbh;
    my $query = qq{SELECT
                aqorders.*,
                biblio.title,
                biblio.author,
                aqbasket.basketname,
                borrowers.branchcode,
                biblioitems.publicationyear,
                biblio.copyrightdate,
                biblioitems.editionstatement,
                biblioitems.isbn,
                biblioitems.ean,
                biblio.seriestitle,
                biblioitems.publishercode,
                aqorders.rrp              AS unitpricesupplier,
                aqorders.ecost            AS unitpricelib,
                aqorders.claims_count     AS claims_count,
                aqorders.claimed_date     AS claimed_date,
                aqbudgets.budget_name     AS budget,
                aqbooksellers.name        AS supplier,
                aqbooksellers.id          AS supplierid,
                biblioitems.publishercode AS publisher,
                ADDDATE(aqbasket.closedate, INTERVAL aqbooksellers.deliverytime DAY) AS estimateddeliverydate,
                DATE(aqbasket.closedate)  AS orderdate,
                aqorders.quantity - COALESCE(aqorders.quantityreceived,0)                 AS quantity_to_receive,
                (aqorders.quantity - COALESCE(aqorders.quantityreceived,0)) * aqorders.rrp AS subtotal,
                DATEDIFF(CURDATE( ),closedate) AS latesince
                FROM aqorders LEFT JOIN biblio ON biblio.biblionumber = aqorders.biblionumber
                LEFT JOIN biblioitems ON biblioitems.biblionumber = biblio.biblionumber
                LEFT JOIN aqbudgets ON aqorders.budget_id = aqbudgets.budget_id,
                aqbasket LEFT JOIN borrowers  ON aqbasket.authorisedby = borrowers.borrowernumber
                LEFT JOIN aqbooksellers       ON aqbasket.booksellerid = aqbooksellers.id
                WHERE aqorders.basketno = aqbasket.basketno
                    AND ordernumber=?};
    my $result_set =
      $dbh->selectall_arrayref( $query, { Slice => {} }, $ordernumber );

    # result_set assumed to contain 1 match
    return $result_set->[0];
}

=head3 GetLastOrderNotReceivedFromSubscriptionid

  $order = &GetLastOrderNotReceivedFromSubscriptionid($subscriptionid);

Returns a reference-to-hash describing the last order not received for a subscription.

=cut

sub GetLastOrderNotReceivedFromSubscriptionid {
    my ( $subscriptionid ) = @_;
    my $dbh                = C4::Context->dbh;
    my $query              = qq|
        SELECT * FROM aqorders
        LEFT JOIN subscription
            ON ( aqorders.subscriptionid = subscription.subscriptionid )
        WHERE aqorders.subscriptionid = ?
            AND aqorders.datereceived IS NULL
        LIMIT 1
    |;
    my $result_set =
      $dbh->selectall_arrayref( $query, { Slice => {} }, $subscriptionid );

    # result_set assumed to contain 1 match
    return $result_set->[0];
}

=head3 GetLastOrderReceivedFromSubscriptionid

  $order = &GetLastOrderReceivedFromSubscriptionid($subscriptionid);

Returns a reference-to-hash describing the last order received for a subscription.

=cut

sub GetLastOrderReceivedFromSubscriptionid {
    my ( $subscriptionid ) = @_;
    my $dbh                = C4::Context->dbh;
    my $query              = qq|
        SELECT * FROM aqorders
        LEFT JOIN subscription
            ON ( aqorders.subscriptionid = subscription.subscriptionid )
        WHERE aqorders.subscriptionid = ?
            AND aqorders.datereceived =
                (
                    SELECT MAX( aqorders.datereceived )
                    FROM aqorders
                    LEFT JOIN subscription
                        ON ( aqorders.subscriptionid = subscription.subscriptionid )
                        WHERE aqorders.subscriptionid = ?
                            AND aqorders.datereceived IS NOT NULL
                )
        ORDER BY ordernumber DESC
        LIMIT 1
    |;
    my $result_set =
      $dbh->selectall_arrayref( $query, { Slice => {} }, $subscriptionid, $subscriptionid );

    # result_set assumed to contain 1 match
    return $result_set->[0];

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
        #FIXME Be careful. If aqorders would have columns with diacritics,
        #you should need to decode what you get back from NAME.
        #See report 10110 and guided_reports.pl
    my $query = "UPDATE aqorders SET ";

    foreach my $orderinfokey (grep(!/ordernumber/, keys %$orderinfo)){
        # ... and skip hash entries that are not in the aqorders table
        # FIXME : probably not the best way to do it (would be better to have a correct hash)
        next unless grep(/^$orderinfokey$/, @$colnames);
            $query .= "$orderinfokey=?, ";
            push(@params, $orderinfo->{$orderinfokey});
    }

    $query .= "timestamp=NOW()  WHERE  ordernumber=?";
    push(@params, $orderinfo->{'ordernumber'} );
    $sth = $dbh->prepare($query);
    $sth->execute(@params);
    return;
}

#------------------------------------------------------------#

=head3 ModItemOrder

    ModItemOrder($itemnumber, $ordernumber);

Modifies the ordernumber of an item in aqorders_items.

=cut

sub ModItemOrder {
    my ($itemnumber, $ordernumber) = @_;

    return unless ($itemnumber and $ordernumber);

    my $dbh = C4::Context->dbh;
    my $query = qq{
        UPDATE aqorders_items
        SET ordernumber = ?
        WHERE itemnumber = ?
    };
    my $sth = $dbh->prepare($query);
    return $sth->execute($ordernumber, $itemnumber);
}

#------------------------------------------------------------#

=head3 GetCancelledOrders

  my @orders = GetCancelledOrders($basketno, $orderby);

Returns cancelled orders for a basket

=cut

sub GetCancelledOrders {
    my ( $basketno, $orderby ) = @_;

    return () unless $basketno;

    my $dbh   = C4::Context->dbh;
    my $query = "
        SELECT
            biblio.*,
            biblioitems.*,
            aqorders.*,
            aqbudgets.*,
            aqorders_transfers.ordernumber_to AS transferred_to,
            aqorders_transfers.timestamp AS transferred_to_timestamp
        FROM aqorders
          LEFT JOIN aqbudgets   ON aqbudgets.budget_id = aqorders.budget_id
          LEFT JOIN biblio      ON biblio.biblionumber = aqorders.biblionumber
          LEFT JOIN biblioitems ON biblioitems.biblionumber = biblio.biblionumber
          LEFT JOIN aqorders_transfers ON aqorders_transfers.ordernumber_from = aqorders.ordernumber
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

  &ModReceiveOrder({
    biblionumber => $biblionumber,
    ordernumber => $ordernumber,
    quantityreceived => $quantityreceived,
    user => $user,
    cost => $cost,
    ecost => $ecost,
    invoiceid => $invoiceid,
    rrp => $rrp,
    budget_id => $budget_id,
    datereceived => $datereceived,
    received_itemnumbers => \@received_itemnumbers,
    order_internalnote => $order_internalnote,
    order_vendornote => $order_vendornote,
   });

Updates an order, to reflect the fact that it was received, at least
in part. All arguments not mentioned below update the fields with the
same name in the aqorders table of the Koha database.

If a partial order is received, splits the order into two.

Updates the order with bibilionumber C<$biblionumber> and ordernumber
C<$ordernumber>.

=cut


sub ModReceiveOrder {
    my ( $params ) = @_;
    my $biblionumber = $params->{biblionumber};
    my $ordernumber = $params->{ordernumber};
    my $quantrec = $params->{quantityreceived};
    my $user = $params->{user};
    my $cost = $params->{cost};
    my $ecost = $params->{ecost};
    my $invoiceid = $params->{invoiceid};
    my $rrp = $params->{rrp};
    my $budget_id = $params->{budget_id};
    my $datereceived = $params->{datereceived};
    my $received_items = $params->{received_items};
    my $order_internalnote = $params->{order_internalnote};
    my $order_vendornote = $params->{order_vendornote};

    my $dbh = C4::Context->dbh;
    $datereceived = C4::Dates->output('iso') unless $datereceived;
    my $suggestionid = GetSuggestionFromBiblionumber( $biblionumber );
    if ($suggestionid) {
        ModSuggestion( {suggestionid=>$suggestionid,
                        STATUS=>'AVAILABLE',
                        biblionumber=> $biblionumber}
                        );
    }

    my $result_set = $dbh->selectall_arrayref(
q{SELECT * FROM aqorders WHERE biblionumber=? AND aqorders.ordernumber=?},
        { Slice => {} }, $biblionumber, $ordernumber
    );

    # we assume we have a unique order
    my $order = $result_set->[0];

    my $new_ordernumber = $ordernumber;
    if ( $order->{quantity} > $quantrec ) {
        # Split order line in two parts: the first is the original order line
        # without received items (the quantity is decreased),
        # the second part is a new order line with quantity=quantityrec
        # (entirely received)
        my $query = q|
            UPDATE aqorders
            SET quantity = ?,
                orderstatus = 'partial'|;
        $query .= q|, order_internalnote = ?| if defined $order_internalnote;
        $query .= q|, order_vendornote = ?| if defined $order_vendornote;
        $query .= q| WHERE ordernumber = ?|;
        my $sth = $dbh->prepare($query);

        $sth->execute(
            $order->{quantity} - $quantrec,
            ( defined $order_internalnote ? $order_internalnote : () ),
            ( defined $order_vendornote ? $order_vendornote : () ),
            $ordernumber
        );

        delete $order->{'ordernumber'};
        $order->{'budget_id'} = ( $budget_id || $order->{'budget_id'} );
        $order->{'quantity'} = $quantrec;
        $order->{'quantityreceived'} = $quantrec;
        $order->{'datereceived'} = $datereceived;
        $order->{'invoiceid'} = $invoiceid;
        $order->{'unitprice'} = $cost;
        $order->{'rrp'} = $rrp;
        $order->{ecost} = $ecost;
        $order->{'orderstatus'} = 'complete';
        $new_ordernumber = Koha::Acquisition::Order->new($order)->insert->{ordernumber};

        if ($received_items) {
            foreach my $itemnumber (@$received_items) {
                ModItemOrder($itemnumber, $new_ordernumber);
            }
        }
    } else {
        my $query = q|
            update aqorders
            set quantityreceived=?,datereceived=?,invoiceid=?,
                unitprice=?,rrp=?,ecost=?,budget_id=?,orderstatus='complete'|;
        $query .= q|, order_internalnote = ?| if defined $order_internalnote;
        $query .= q|, order_vendornote = ?| if defined $order_vendornote;
        $query .= q| where biblionumber=? and ordernumber=?|;
        my $sth = $dbh->prepare( $query );
        $sth->execute(
            $quantrec,
            $datereceived,
            $invoiceid,
            $cost,
            $rrp,
            $ecost,
            $budget_id,
            ( defined $order_internalnote ? $order_internalnote : () ),
            ( defined $order_vendornote ? $order_vendornote : () ),
            $biblionumber,
            $ordernumber
        );
    }
    return ($datereceived, $new_ordernumber);
}

=head3 CancelReceipt

    my $parent_ordernumber = CancelReceipt($ordernumber);

    Cancel an order line receipt and update the parent order line, as if no
    receipt was made.
    If items are created at receipt (AcqCreateItem = receiving) then delete
    these items.

=cut

sub CancelReceipt {
    my $ordernumber = shift;

    return unless $ordernumber;

    my $dbh = C4::Context->dbh;
    my $query = qq{
        SELECT datereceived, parent_ordernumber, quantity
        FROM aqorders
        WHERE ordernumber = ?
    };
    my $sth = $dbh->prepare($query);
    $sth->execute($ordernumber);
    my $order = $sth->fetchrow_hashref;
    unless($order) {
        warn "CancelReceipt: order $ordernumber does not exist";
        return;
    }
    unless($order->{'datereceived'}) {
        warn "CancelReceipt: order $ordernumber is not received";
        return;
    }

    my $parent_ordernumber = $order->{'parent_ordernumber'};

    my @itemnumbers = GetItemnumbersFromOrder( $ordernumber );

    if($parent_ordernumber == $ordernumber || not $parent_ordernumber) {
        # The order line has no parent, just mark it as not received
        $query = qq{
            UPDATE aqorders
            SET quantityreceived = ?,
                datereceived = ?,
                invoiceid = ?,
                orderstatus = 'ordered'
            WHERE ordernumber = ?
        };
        $sth = $dbh->prepare($query);
        $sth->execute(0, undef, undef, $ordernumber);
        _cancel_items_receipt( $ordernumber );
    } else {
        # The order line has a parent, increase parent quantity and delete
        # the order line.
        $query = qq{
            SELECT quantity, datereceived
            FROM aqorders
            WHERE ordernumber = ?
        };
        $sth = $dbh->prepare($query);
        $sth->execute($parent_ordernumber);
        my $parent_order = $sth->fetchrow_hashref;
        unless($parent_order) {
            warn "Parent order $parent_ordernumber does not exist.";
            return;
        }
        if($parent_order->{'datereceived'}) {
            warn "CancelReceipt: parent order is received.".
                " Can't cancel receipt.";
            return;
        }
        $query = qq{
            UPDATE aqorders
            SET quantity = ?,
                orderstatus = 'ordered'
            WHERE ordernumber = ?
        };
        $sth = $dbh->prepare($query);
        my $rv = $sth->execute(
            $order->{'quantity'} + $parent_order->{'quantity'},
            $parent_ordernumber
        );
        unless($rv) {
            warn "Cannot update parent order line, so do not cancel".
                " receipt";
            return;
        }
        _cancel_items_receipt( $ordernumber, $parent_ordernumber );
        # Delete order line
        $query = qq{
            DELETE FROM aqorders
            WHERE ordernumber = ?
        };
        $sth = $dbh->prepare($query);
        $sth->execute($ordernumber);

    }

    if(C4::Context->preference('AcqCreateItem') eq 'ordering') {
        my @affects = split q{\|}, C4::Context->preference("AcqItemSetSubfieldsWhenReceiptIsCancelled");
        if ( @affects ) {
            for my $in ( @itemnumbers ) {
                my $biblionumber = C4::Biblio::GetBiblionumberFromItemnumber( $in );
                my $frameworkcode = GetFrameworkCode($biblionumber);
                my ( $itemfield ) = GetMarcFromKohaField( 'items.itemnumber', $frameworkcode );
                my $item = C4::Items::GetMarcItem( $biblionumber, $in );
                for my $affect ( @affects ) {
                    my ( $sf, $v ) = split q{=}, $affect, 2;
                    foreach ( $item->field($itemfield) ) {
                        $_->update( $sf => $v );
                    }
                }
                C4::Items::ModItemFromMarc( $item, $biblionumber, $in );
            }
        }
    }

    return $parent_ordernumber;
}

sub _cancel_items_receipt {
    my ( $ordernumber, $parent_ordernumber ) = @_;
    $parent_ordernumber ||= $ordernumber;

    my @itemnumbers = GetItemnumbersFromOrder($ordernumber);
    if(C4::Context->preference('AcqCreateItem') eq 'receiving') {
        # Remove items that were created at receipt
        my $query = qq{
            DELETE FROM items, aqorders_items
            USING items, aqorders_items
            WHERE items.itemnumber = ? AND aqorders_items.itemnumber = ?
        };
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare($query);
        foreach my $itemnumber (@itemnumbers) {
            $sth->execute($itemnumber, $itemnumber);
        }
    } else {
        # Update items
        foreach my $itemnumber (@itemnumbers) {
            ModItemOrder($itemnumber, $parent_ordernumber);
        }
    }
}

#------------------------------------------------------------#

=head3 SearchOrders

@results = &SearchOrders({
    ordernumber => $ordernumber,
    search => $search,
    biblionumber => $biblionumber,
    ean => $ean,
    booksellerid => $booksellerid,
    basketno => $basketno,
    owner => $owner,
    pending => $pending
    ordered => $ordered
});

Searches for orders.

C<$owner> Finds order for the logged in user.
C<$pending> Finds pending orders. Ignores completed and cancelled orders.
C<$ordered> Finds orders to receive only (status 'ordered' or 'partial').


C<@results> is an array of references-to-hash with the keys are fields
from aqorders, biblio, biblioitems and aqbasket tables.

=cut

sub SearchOrders {
    my ( $params ) = @_;
    my $ordernumber = $params->{ordernumber};
    my $search = $params->{search};
    my $ean = $params->{ean};
    my $booksellerid = $params->{booksellerid};
    my $basketno = $params->{basketno};
    my $basketname = $params->{basketname};
    my $basketgroupname = $params->{basketgroupname};
    my $owner = $params->{owner};
    my $pending = $params->{pending};
    my $ordered = $params->{ordered};
    my $biblionumber = $params->{biblionumber};
    my $budget_id = $params->{budget_id};

    my $dbh = C4::Context->dbh;
    my @args = ();
    my $query = q{
        SELECT aqbasket.basketno,
               borrowers.surname,
               borrowers.firstname,
               biblio.*,
               biblioitems.isbn,
               biblioitems.biblioitemnumber,
               aqbasket.authorisedby,
               aqbasket.booksellerid,
               aqbasket.closedate,
               aqbasket.creationdate,
               aqbasket.basketname,
               aqbasketgroups.id as basketgroupid,
               aqbasketgroups.name as basketgroupname,
               aqorders.*
        FROM aqorders
            LEFT JOIN aqbasket ON aqorders.basketno = aqbasket.basketno
            LEFT JOIN aqbasketgroups ON aqbasket.basketgroupid = aqbasketgroups.id
            LEFT JOIN borrowers ON aqbasket.authorisedby=borrowers.borrowernumber
            LEFT JOIN biblio ON aqorders.biblionumber=biblio.biblionumber
            LEFT JOIN biblioitems ON biblioitems.biblionumber=biblio.biblionumber
    };

    # If we search on ordernumber, we retrieve the transfered order if a transfer has been done.
    $query .= q{
            LEFT JOIN aqorders_transfers ON aqorders_transfers.ordernumber_to = aqorders.ordernumber
    } if $ordernumber;

    $query .= q{
        WHERE (datecancellationprinted is NULL)
    };

    if ( $pending or $ordered ) {
        $query .= q{ AND (quantity > quantityreceived OR quantityreceived is NULL)};
    }
    if ( $ordered ) {
        $query .= q{ AND aqorders.orderstatus IN ( "ordered", "partial" )};
    }

    my $userenv = C4::Context->userenv;
    if ( C4::Context->preference("IndependentBranches") ) {
        unless ( C4::Context->IsSuperLibrarian() ) {
            $query .= q{
                AND (
                    borrowers.branchcode = ?
                    OR borrowers.branchcode  = ''
                )
            };
            push @args, $userenv->{branch};
        }
    }

    if ( $ordernumber ) {
        $query .= ' AND ( aqorders.ordernumber = ? OR aqorders_transfers.ordernumber_from = ? ) ';
        push @args, ( $ordernumber, $ordernumber );
    }
    if ( $biblionumber ) {
        $query .= 'AND aqorders.biblionumber = ?';
        push @args, $biblionumber;
    }
    if( $search ) {
        $query .= ' AND (biblio.title LIKE ? OR biblio.author LIKE ? OR biblioitems.isbn LIKE ?)';
        push @args, ("%$search%","%$search%","%$search%");
    }
    if ( $ean ) {
        $query .= ' AND biblioitems.ean = ?';
        push @args, $ean;
    }
    if ( $booksellerid ) {
        $query .= 'AND aqbasket.booksellerid = ?';
        push @args, $booksellerid;
    }
    if( $basketno ) {
        $query .= 'AND aqbasket.basketno = ?';
        push @args, $basketno;
    }
    if( $basketname ) {
        $query .= 'AND aqbasket.basketname LIKE ?';
        push @args, "%$basketname%";
    }
    if( $basketgroupname ) {
        $query .= ' AND aqbasketgroups.name LIKE ?';
        push @args, "%$basketgroupname%";
    }

    if ( $owner ) {
        $query .= ' AND aqbasket.authorisedby=? ';
        push @args, $userenv->{'number'};
    }

    if ( $budget_id ) {
        $query .= ' AND aqorders.budget_id = ?';
        push @args, $budget_id;
    }

    $query .= ' ORDER BY aqbasket.basketno';

    my $sth = $dbh->prepare($query);
    $sth->execute(@args);
    return $sth->fetchall_arrayref({});
}

#------------------------------------------------------------#

=head3 DelOrder

  &DelOrder($biblionumber, $ordernumber);

Cancel the order with the given order and biblio numbers. It does not
delete any entries in the aqorders table, it merely marks them as
cancelled.

=cut

sub DelOrder {
    my ( $bibnum, $ordernumber, $delete_biblio, $reason ) = @_;

    my $error;
    my $dbh = C4::Context->dbh;
    my $query = "
        UPDATE aqorders
        SET    datecancellationprinted=now(), orderstatus='cancelled'
    ";
    if($reason) {
        $query .= ", cancellationreason = ? ";
    }
    $query .= "
        WHERE biblionumber=? AND ordernumber=?
    ";
    my $sth = $dbh->prepare($query);
    if($reason) {
        $sth->execute($reason, $bibnum, $ordernumber);
    } else {
        $sth->execute( $bibnum, $ordernumber );
    }
    $sth->finish;

    my @itemnumbers = GetItemnumbersFromOrder( $ordernumber );
    foreach my $itemnumber (@itemnumbers){
        my $delcheck = C4::Items::DelItemCheck( $dbh, $bibnum, $itemnumber );

        if($delcheck != 1) {
            $error->{'delitem'} = 1;
        }
    }

    if($delete_biblio) {
        # We get the number of remaining items
        my $itemcount = C4::Items::GetItemsCount($bibnum);

        # If there are no items left,
        if ( $itemcount == 0 ) {
            # We delete the record
            my $delcheck = DelBiblio($bibnum);

            if($delcheck) {
                $error->{'delbiblio'} = 1;
            }
        }
    }

    return $error;
}

=head3 TransferOrder

    my $newordernumber = TransferOrder($ordernumber, $basketno);

Transfer an order line to a basket.
Mark $ordernumber as cancelled with an internal note 'Cancelled and transfered
to BOOKSELLER on DATE' and create new order with internal note
'Transfered from BOOKSELLER on DATE'.
Move all attached items to the new order.
Received orders cannot be transfered.
Return the ordernumber of created order.

=cut

sub TransferOrder {
    my ($ordernumber, $basketno) = @_;

    return unless ($ordernumber and $basketno);

    my $order = GetOrder( $ordernumber );
    return if $order->{datereceived};
    my $basket = GetBasket($basketno);
    return unless $basket;

    my $dbh = C4::Context->dbh;
    my ($query, $sth, $rv);

    $query = q{
        UPDATE aqorders
        SET datecancellationprinted = CAST(NOW() AS date)
        WHERE ordernumber = ?
    };
    $sth = $dbh->prepare($query);
    $rv = $sth->execute($ordernumber);

    delete $order->{'ordernumber'};
    delete $order->{parent_ordernumber};
    $order->{'basketno'} = $basketno;

    my $newordernumber = Koha::Acquisition::Order->new($order)->insert->{ordernumber};

    $query = q{
        UPDATE aqorders_items
        SET ordernumber = ?
        WHERE ordernumber = ?
    };
    $sth = $dbh->prepare($query);
    $sth->execute($newordernumber, $ordernumber);

    $query = q{
        INSERT INTO aqorders_transfers (ordernumber_from, ordernumber_to)
        VALUES (?, ?)
    };
    $sth = $dbh->prepare($query);
    $sth->execute($ordernumber, $newordernumber);

    return $newordernumber;
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
                aqorders.parent_ordernumber,
                aqorders.quantity,
                aqorders.quantityreceived,
                aqorders.unitprice,
                aqorders.listprice,
                aqorders.rrp,
                aqorders.ecost,
                aqorders.gstrate,
                biblio.title
        FROM aqorders
        LEFT JOIN aqbasket ON aqbasket.basketno=aqorders.basketno
        LEFT JOIN borrowers ON aqbasket.authorisedby=borrowers.borrowernumber
        LEFT JOIN biblio ON aqorders.biblionumber=biblio.biblionumber
        LEFT JOIN aqinvoices ON aqorders.invoiceid = aqinvoices.invoiceid
        WHERE
            aqbasket.booksellerid = ?
            AND aqinvoices.invoicenumber LIKE ?
            AND aqorders.datereceived = ? ";

    my @query_params = ( $supplierid, $code, $datereceived );
    if ( C4::Context->preference("IndependentBranches") ) {
        unless ( C4::Context->IsSuperLibrarian() ) {
            $strsth .= " and (borrowers.branchcode = ?
                        or borrowers.branchcode  = '')";
            push @query_params, C4::Context->userenv->{branch};
        }
    }
    $strsth .= " ORDER BY aqbasket.basketno";
    my $result_set = $dbh->selectall_arrayref(
        $strsth,
        { Slice => {} },
        @query_params);

    return @{$result_set};
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
        SELECT  aqinvoices.invoicenumber,
                datereceived,purchaseordernumber,
                count(DISTINCT biblionumber) AS biblio,
                sum(quantity) AS itemsexpected,
                sum(quantityreceived) AS itemsreceived
        FROM   aqorders LEFT JOIN aqbasket ON aqbasket.basketno = aqorders.basketno
        LEFT JOIN aqinvoices ON aqorders.invoiceid = aqinvoices.invoiceid
        WHERE aqbasket.booksellerid = ? and datereceived IS NOT NULL
    ";
    push @query_params, $bookseller;

    if ( defined $code ) {
        $strsth .= ' and aqinvoices.invoicenumber like ? ';
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

    $strsth .= "group by aqinvoices.invoicenumber,datereceived ";

    # can't use a placeholder to place this column name.
    # but, we could probably be checking to make sure it is a column that will be fetched.
    $strsth .= "order by $order " if ($order);

    my $sth = $dbh->prepare($strsth);

    $sth->execute( @query_params );
    my $results = $sth->fetchall_arrayref({});
    return @{$results};
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
        aqbasket.basketname       AS basketname,
        aqbasket.basketgroupid    AS basketgroupid,
        aqbasketgroups.name       AS basketgroupname,
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
        LEFT JOIN aqbasketgroups      ON aqbasket.basketgroupid      = aqbasketgroups.id
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
        aqorders.quantity - COALESCE(aqorders.quantityreceived,0)                 AS quantity,
        (aqorders.quantity - COALESCE(aqorders.quantityreceived,0)) * aqorders.rrp AS subtotal,
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

    if ( defined $estimateddeliverydatefrom or defined $estimateddeliverydateto ) {
        $from .= ' AND aqbooksellers.deliverytime IS NOT NULL ';
    }
    if ( defined $estimateddeliverydatefrom ) {
        $from .= ' AND ADDDATE(aqbasket.closedate, INTERVAL aqbooksellers.deliverytime DAY) >= ?';
        push @query_params, $estimateddeliverydatefrom;
    }
    if ( defined $estimateddeliverydateto ) {
        $from .= ' AND ADDDATE(aqbasket.closedate, INTERVAL aqbooksellers.deliverytime DAY) <= ?';
        push @query_params, $estimateddeliverydateto;
    }
    if ( defined $estimateddeliverydatefrom and not defined $estimateddeliverydateto ) {
        $from .= ' AND ADDDATE(aqbasket.closedate, INTERVAL aqbooksellers.deliverytime DAY) <= CAST(now() AS date)';
    }
    if (C4::Context->preference("IndependentBranches")
            && !C4::Context->IsSuperLibrarian() ) {
        $from .= ' AND borrowers.branchcode LIKE ? ';
        push @query_params, C4::Context->userenv->{branch};
    }
    $from .= " AND orderstatus <> 'cancelled' ";
    my $query = "$select $from $having\nORDER BY latesince, basketno, borrowers.branchcode, supplier";
    $debug and print STDERR "GetLateOrders query: $query\nGetLateOrders args: " . join(" ",@query_params);
    my $sth = $dbh->prepare($query);
    $sth->execute(@query_params);
    my @results;
    while (my $data = $sth->fetchrow_hashref) {
        push @results, $data;
    }
    return @results;
}

#------------------------------------------------------------#

=head3 GetHistory

  \@order_loop = GetHistory( %params );

Retreives some acquisition history information

params:  
  title
  author
  name
  isbn
  ean
  from_placed_on
  to_placed_on
  basket                  - search both basket name and number
  booksellerinvoicenumber 
  basketgroupname
  budget
  orderstatus (note that orderstatus '' will retrieve orders
               of any status except cancelled)
  biblionumber
  get_canceled_order (if set to a true value, cancelled orders will
                      be included)

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

=cut

sub GetHistory {
# don't run the query if there are no parameters (list would be too long for sure !)
    croak "No search params" unless @_;
    my %params = @_;
    my $title = $params{title};
    my $author = $params{author};
    my $isbn   = $params{isbn};
    my $ean    = $params{ean};
    my $name = $params{name};
    my $from_placed_on = $params{from_placed_on};
    my $to_placed_on = $params{to_placed_on};
    my $basket = $params{basket};
    my $booksellerinvoicenumber = $params{booksellerinvoicenumber};
    my $basketgroupname = $params{basketgroupname};
    my $budget = $params{budget};
    my $orderstatus = $params{orderstatus};
    my $biblionumber = $params{biblionumber};
    my $get_canceled_order = $params{get_canceled_order} || 0;
    my $ordernumber = $params{ordernumber};
    my $search_children_too = $params{search_children_too} || 0;

    my @order_loop;
    my $total_qty         = 0;
    my $total_qtyreceived = 0;
    my $total_price       = 0;

    my $dbh   = C4::Context->dbh;
    my $query ="
        SELECT
            COALESCE(biblio.title,     deletedbiblio.title)     AS title,
            COALESCE(biblio.author,    deletedbiblio.author)    AS author,
            COALESCE(biblioitems.isbn, deletedbiblioitems.isbn) AS isbn,
            COALESCE(biblioitems.ean,  deletedbiblioitems.ean)  AS ean,
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
            aqorders.invoiceid,
            aqinvoices.invoicenumber,
            aqbooksellers.id as id,
            aqorders.biblionumber,
            aqorders.orderstatus,
            aqorders.parent_ordernumber,
            aqbudgets.budget_name
            ";
    $query .= ", aqbudgets.budget_id AS budget" if defined $budget;
    $query .= "
        FROM aqorders
        LEFT JOIN aqbasket ON aqorders.basketno=aqbasket.basketno
        LEFT JOIN aqbasketgroups ON aqbasket.basketgroupid=aqbasketgroups.id
        LEFT JOIN aqbooksellers ON aqbasket.booksellerid=aqbooksellers.id
        LEFT JOIN biblioitems ON biblioitems.biblionumber=aqorders.biblionumber
        LEFT JOIN biblio ON biblio.biblionumber=aqorders.biblionumber
        LEFT JOIN aqbudgets ON aqorders.budget_id=aqbudgets.budget_id
        LEFT JOIN aqinvoices ON aqorders.invoiceid = aqinvoices.invoiceid
        LEFT JOIN deletedbiblio ON deletedbiblio.biblionumber=aqorders.biblionumber
        LEFT JOIN deletedbiblioitems ON deletedbiblioitems.biblionumber=aqorders.biblionumber
        ";

    if ( C4::Context->preference("IndependentBranches") ) {
        $query .= " LEFT JOIN borrowers ON aqbasket.authorisedby=borrowers.borrowernumber";
    }

    $query .= " WHERE 1 ";

    unless ($get_canceled_order or (defined $orderstatus and $orderstatus eq 'cancelled')) {
        $query .= " AND (datecancellationprinted is NULL or datecancellationprinted='0000-00-00') ";
    }

    my @query_params  = ();

    if ( $biblionumber ) {
        $query .= " AND biblio.biblionumber = ?";
        push @query_params, $biblionumber;
    }

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
    if ( $ean ) {
        $query .= " AND biblioitems.ean = ? ";
        push @query_params, "$ean";
    }
    if ( $name ) {
        $query .= " AND aqbooksellers.name LIKE ? ";
        push @query_params, "%$name%";
    }

    if ( $budget ) {
        $query .= " AND aqbudgets.budget_id = ? ";
        push @query_params, "$budget";
    }

    if ( $from_placed_on ) {
        $query .= " AND creationdate >= ? ";
        push @query_params, $from_placed_on;
    }

    if ( $to_placed_on ) {
        $query .= " AND creationdate <= ? ";
        push @query_params, $to_placed_on;
    }

    if ( defined $orderstatus and $orderstatus ne '') {
        $query .= " AND aqorders.orderstatus = ? ";
        push @query_params, "$orderstatus";
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
        $query .= " AND aqinvoices.invoicenumber LIKE ? ";
        push @query_params, "%$booksellerinvoicenumber%";
    }

    if ($basketgroupname) {
        $query .= " AND aqbasketgroups.name LIKE ? ";
        push @query_params, "%$basketgroupname%";
    }

    if ($ordernumber) {
        $query .= " AND (aqorders.ordernumber = ? ";
        push @query_params, $ordernumber;
        if ($search_children_too) {
            $query .= " OR aqorders.parent_ordernumber = ? ";
            push @query_params, $ordernumber;
        }
        $query .= ") ";
    }


    if ( C4::Context->preference("IndependentBranches") ) {
        unless ( C4::Context->IsSuperLibrarian() ) {
            $query .= " AND (borrowers.branchcode = ? OR borrowers.branchcode ='' ) ";
            push @query_params, C4::Context->userenv->{branch};
        }
    }
    $query .= " ORDER BY id";

    return $dbh->selectall_arrayref( $query, { Slice => {} }, @query_params );
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

#------------------------------------------------------------#

=head3 AddClaim

=over

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

=head3 GetInvoices

    my @invoices = GetInvoices(
        invoicenumber => $invoicenumber,
        supplierid => $supplierid,
        suppliername => $suppliername,
        shipmentdatefrom => $shipmentdatefrom, # ISO format
        shipmentdateto => $shipmentdateto, # ISO format
        billingdatefrom => $billingdatefrom, # ISO format
        billingdateto => $billingdateto, # ISO format
        isbneanissn => $isbn_or_ean_or_issn,
        title => $title,
        author => $author,
        publisher => $publisher,
        publicationyear => $publicationyear,
        branchcode => $branchcode,
        order_by => $order_by
    );

Return a list of invoices that match all given criteria.

$order_by is "column_name (asc|desc)", where column_name is any of
'invoicenumber', 'booksellerid', 'shipmentdate', 'billingdate', 'closedate',
'shipmentcost', 'shipmentcost_budgetid'.

asc is the default if omitted

=cut

sub GetInvoices {
    my %args = @_;

    my @columns = qw(invoicenumber booksellerid shipmentdate billingdate
        closedate shipmentcost shipmentcost_budgetid);

    my $dbh = C4::Context->dbh;
    my $query = qq{
        SELECT aqinvoices.*, aqbooksellers.name AS suppliername,
          COUNT(
            DISTINCT IF(
              aqorders.datereceived IS NOT NULL,
              aqorders.biblionumber,
              NULL
            )
          ) AS receivedbiblios,
          COUNT(
             DISTINCT IF(
              aqorders.subscriptionid IS NOT NULL,
              aqorders.subscriptionid,
              NULL
            )
          ) AS is_linked_to_subscriptions,
          SUM(aqorders.quantityreceived) AS receiveditems
        FROM aqinvoices
          LEFT JOIN aqbooksellers ON aqbooksellers.id = aqinvoices.booksellerid
          LEFT JOIN aqorders ON aqorders.invoiceid = aqinvoices.invoiceid
          LEFT JOIN aqbasket ON aqbasket.basketno=aqorders.basketno
          LEFT JOIN borrowers ON aqbasket.authorisedby=borrowers.borrowernumber
          LEFT JOIN biblio ON aqorders.biblionumber = biblio.biblionumber
          LEFT JOIN biblioitems ON biblio.biblionumber = biblioitems.biblionumber
          LEFT JOIN subscription ON biblio.biblionumber = subscription.biblionumber
    };

    my @bind_args;
    my @bind_strs;
    if($args{supplierid}) {
        push @bind_strs, " aqinvoices.booksellerid = ? ";
        push @bind_args, $args{supplierid};
    }
    if($args{invoicenumber}) {
        push @bind_strs, " aqinvoices.invoicenumber LIKE ? ";
        push @bind_args, "%$args{invoicenumber}%";
    }
    if($args{suppliername}) {
        push @bind_strs, " aqbooksellers.name LIKE ? ";
        push @bind_args, "%$args{suppliername}%";
    }
    if($args{shipmentdatefrom}) {
        push @bind_strs, " aqinvoices.shipmentdate >= ? ";
        push @bind_args, $args{shipmentdatefrom};
    }
    if($args{shipmentdateto}) {
        push @bind_strs, " aqinvoices.shipmentdate <= ? ";
        push @bind_args, $args{shipmentdateto};
    }
    if($args{billingdatefrom}) {
        push @bind_strs, " aqinvoices.billingdate >= ? ";
        push @bind_args, $args{billingdatefrom};
    }
    if($args{billingdateto}) {
        push @bind_strs, " aqinvoices.billingdate <= ? ";
        push @bind_args, $args{billingdateto};
    }
    if($args{isbneanissn}) {
        push @bind_strs, " (biblioitems.isbn LIKE CONCAT('%', ?, '%') OR biblioitems.ean LIKE CONCAT('%', ?, '%') OR biblioitems.issn LIKE CONCAT('%', ?, '%') ) ";
        push @bind_args, $args{isbneanissn}, $args{isbneanissn}, $args{isbneanissn};
    }
    if($args{title}) {
        push @bind_strs, " biblio.title LIKE CONCAT('%', ?, '%') ";
        push @bind_args, $args{title};
    }
    if($args{author}) {
        push @bind_strs, " biblio.author LIKE CONCAT('%', ?, '%') ";
        push @bind_args, $args{author};
    }
    if($args{publisher}) {
        push @bind_strs, " biblioitems.publishercode LIKE CONCAT('%', ?, '%') ";
        push @bind_args, $args{publisher};
    }
    if($args{publicationyear}) {
        push @bind_strs, " ((biblioitems.publicationyear LIKE CONCAT('%', ?, '%')) OR (biblio.copyrightdate LIKE CONCAT('%', ?, '%'))) ";
        push @bind_args, $args{publicationyear}, $args{publicationyear};
    }
    if($args{branchcode}) {
        push @bind_strs, " borrowers.branchcode = ? ";
        push @bind_args, $args{branchcode};
    }

    $query .= " WHERE " . join(" AND ", @bind_strs) if @bind_strs;
    $query .= " GROUP BY aqinvoices.invoiceid ";

    if($args{order_by}) {
        my ($column, $direction) = split / /, $args{order_by};
        if(grep /^$column$/, @columns) {
            $direction ||= 'ASC';
            $query .= " ORDER BY $column $direction";
        }
    }

    my $sth = $dbh->prepare($query);
    $sth->execute(@bind_args);

    my $results = $sth->fetchall_arrayref({});
    return @$results;
}

=head3 GetInvoice

    my $invoice = GetInvoice($invoiceid);

Get informations about invoice with given $invoiceid

Return a hash filled with aqinvoices.* fields

=cut

sub GetInvoice {
    my ($invoiceid) = @_;
    my $invoice;

    return unless $invoiceid;

    my $dbh = C4::Context->dbh;
    my $query = qq{
        SELECT *
        FROM aqinvoices
        WHERE invoiceid = ?
    };
    my $sth = $dbh->prepare($query);
    $sth->execute($invoiceid);

    $invoice = $sth->fetchrow_hashref;
    return $invoice;
}

=head3 GetInvoiceDetails

    my $invoice = GetInvoiceDetails($invoiceid)

Return informations about an invoice + the list of related order lines

Orders informations are in $invoice->{orders} (array ref)

=cut

sub GetInvoiceDetails {
    my ($invoiceid) = @_;

    if ( !defined $invoiceid ) {
        carp 'GetInvoiceDetails called without an invoiceid';
        return;
    }

    my $dbh = C4::Context->dbh;
    my $query = q{
        SELECT aqinvoices.*, aqbooksellers.name AS suppliername
        FROM aqinvoices
          LEFT JOIN aqbooksellers ON aqinvoices.booksellerid = aqbooksellers.id
        WHERE invoiceid = ?
    };
    my $sth = $dbh->prepare($query);
    $sth->execute($invoiceid);

    my $invoice = $sth->fetchrow_hashref;

    $query = q{
        SELECT aqorders.*,
                biblio.*,
                biblio.copyrightdate,
                biblioitems.publishercode,
                biblioitems.publicationyear,
                aqbasket.basketname,
                aqbasketgroups.id AS basketgroupid,
                aqbasketgroups.name AS basketgroupname
        FROM aqorders
          LEFT JOIN aqbasket ON aqorders.basketno = aqbasket.basketno
          LEFT JOIN aqbasketgroups ON aqbasket.basketgroupid = aqbasketgroups.id
          LEFT JOIN biblio ON aqorders.biblionumber = biblio.biblionumber
          LEFT JOIN biblioitems ON aqorders.biblionumber = biblioitems.biblionumber
        WHERE invoiceid = ?
    };
    $sth = $dbh->prepare($query);
    $sth->execute($invoiceid);
    $invoice->{orders} = $sth->fetchall_arrayref({});
    $invoice->{orders} ||= []; # force an empty arrayref if fetchall_arrayref fails

    return $invoice;
}

=head3 AddInvoice

    my $invoiceid = AddInvoice(
        invoicenumber => $invoicenumber,
        booksellerid => $booksellerid,
        shipmentdate => $shipmentdate,
        billingdate => $billingdate,
        closedate => $closedate,
        shipmentcost => $shipmentcost,
        shipmentcost_budgetid => $shipmentcost_budgetid
    );

Create a new invoice and return its id or undef if it fails.

=cut

sub AddInvoice {
    my %invoice = @_;

    return unless(%invoice and $invoice{invoicenumber});

    my @columns = qw(invoicenumber booksellerid shipmentdate billingdate
        closedate shipmentcost shipmentcost_budgetid);

    my @set_strs;
    my @set_args;
    foreach my $key (keys %invoice) {
        if(0 < grep(/^$key$/, @columns)) {
            push @set_strs, "$key = ?";
            push @set_args, ($invoice{$key} || undef);
        }
    }

    my $rv;
    if(@set_args > 0) {
        my $dbh = C4::Context->dbh;
        my $query = "INSERT INTO aqinvoices SET ";
        $query .= join (",", @set_strs);
        my $sth = $dbh->prepare($query);
        $rv = $sth->execute(@set_args);
        if($rv) {
            $rv = $dbh->last_insert_id(undef, undef, 'aqinvoices', undef);
        }
    }
    return $rv;
}

=head3 ModInvoice

    ModInvoice(
        invoiceid => $invoiceid,    # Mandatory
        invoicenumber => $invoicenumber,
        booksellerid => $booksellerid,
        shipmentdate => $shipmentdate,
        billingdate => $billingdate,
        closedate => $closedate,
        shipmentcost => $shipmentcost,
        shipmentcost_budgetid => $shipmentcost_budgetid
    );

Modify an invoice, invoiceid is mandatory.

Return undef if it fails.

=cut

sub ModInvoice {
    my %invoice = @_;

    return unless(%invoice and $invoice{invoiceid});

    my @columns = qw(invoicenumber booksellerid shipmentdate billingdate
        closedate shipmentcost shipmentcost_budgetid);

    my @set_strs;
    my @set_args;
    foreach my $key (keys %invoice) {
        if(0 < grep(/^$key$/, @columns)) {
            push @set_strs, "$key = ?";
            push @set_args, ($invoice{$key} || undef);
        }
    }

    my $dbh = C4::Context->dbh;
    my $query = "UPDATE aqinvoices SET ";
    $query .= join(",", @set_strs);
    $query .= " WHERE invoiceid = ?";

    my $sth = $dbh->prepare($query);
    $sth->execute(@set_args, $invoice{invoiceid});
}

=head3 CloseInvoice

    CloseInvoice($invoiceid);

Close an invoice.

Equivalent to ModInvoice(invoiceid => $invoiceid, closedate => undef);

=cut

sub CloseInvoice {
    my ($invoiceid) = @_;

    return unless $invoiceid;

    my $dbh = C4::Context->dbh;
    my $query = qq{
        UPDATE aqinvoices
        SET closedate = CAST(NOW() AS DATE)
        WHERE invoiceid = ?
    };
    my $sth = $dbh->prepare($query);
    $sth->execute($invoiceid);
}

=head3 ReopenInvoice

    ReopenInvoice($invoiceid);

Reopen an invoice

Equivalent to ModInvoice(invoiceid => $invoiceid, closedate => C4::Dates->new()->output('iso'))

=cut

sub ReopenInvoice {
    my ($invoiceid) = @_;

    return unless $invoiceid;

    my $dbh = C4::Context->dbh;
    my $query = qq{
        UPDATE aqinvoices
        SET closedate = NULL
        WHERE invoiceid = ?
    };
    my $sth = $dbh->prepare($query);
    $sth->execute($invoiceid);
}

=head3 DelInvoice

    DelInvoice($invoiceid);

Delete an invoice if there are no items attached to it.

=cut

sub DelInvoice {
    my ($invoiceid) = @_;

    return unless $invoiceid;

    my $dbh   = C4::Context->dbh;
    my $query = qq{
        SELECT COUNT(*)
        FROM aqorders
        WHERE invoiceid = ?
    };
    my $sth = $dbh->prepare($query);
    $sth->execute($invoiceid);
    my $res = $sth->fetchrow_arrayref;
    if ( $res && $res->[0] == 0 ) {
        $query = qq{
            DELETE FROM aqinvoices
            WHERE invoiceid = ?
        };
        my $sth = $dbh->prepare($query);
        return ( $sth->execute($invoiceid) > 0 );
    }
    return;
}

=head3 MergeInvoices

    MergeInvoices($invoiceid, \@sourceids);

Merge the invoices identified by the IDs in \@sourceids into
the invoice identified by $invoiceid.

=cut

sub MergeInvoices {
    my ($invoiceid, $sourceids) = @_;

    return unless $invoiceid;
    foreach my $sourceid (@$sourceids) {
        next if $sourceid == $invoiceid;
        my $source = GetInvoiceDetails($sourceid);
        foreach my $order (@{$source->{'orders'}}) {
            $order->{'invoiceid'} = $invoiceid;
            ModOrder($order);
        }
        DelInvoice($source->{'invoiceid'});
    }
    return;
}

=head3 GetBiblioCountByBasketno

$biblio_count = &GetBiblioCountByBasketno($basketno);

Looks up the biblio's count that has basketno value $basketno

Returns a quantity

=cut

sub GetBiblioCountByBasketno {
    my ($basketno) = @_;
    my $dbh          = C4::Context->dbh;
    my $query        = "
        SELECT COUNT( DISTINCT( biblionumber ) )
        FROM   aqorders
        WHERE  basketno = ?
            AND (datecancellationprinted IS NULL OR datecancellationprinted='0000-00-00')
        ";

    my $sth = $dbh->prepare($query);
    $sth->execute($basketno);
    return $sth->fetchrow;
}

1;
__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut
