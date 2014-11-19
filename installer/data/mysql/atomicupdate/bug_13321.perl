#!/usr/bin/env perl

use Modern::Perl;

use C4::Context;

my $dbh = C4::Context->dbh;

$dbh->do(q|
    ALTER TABLE aqorders
        ADD COLUMN unitprice_tax_excluded decimal(28,6) default NULL AFTER unitprice,
        ADD COLUMN unitprice_tax_included decimal(28,6) default NULL AFTER unitprice_tax_excluded,
        ADD COLUMN rrp_tax_excluded decimal(28,6) default NULL AFTER rrp,
        ADD COLUMN rrp_tax_included decimal(28,6) default NULL AFTER rrp_tax_excluded,
        ADD COLUMN ecost_tax_excluded decimal(28,6) default NULL AFTER ecost,
        ADD COLUMN ecost_tax_included decimal(28,6) default NULL AFTER ecost_tax_excluded,
        ADD COLUMN tax_value decimal(6,4) default NULL AFTER gstrate
|);

# rename gstrate with tax_rate
$dbh->do(q|ALTER TABLE aqorders CHANGE COLUMN gstrate tax_rate decimal(6,4) DEFAULT NULL|);
$dbh->do(q|ALTER TABLE aqbooksellers CHANGE COLUMN gstrate tax_rate decimal(6,4) DEFAULT NULL|);

# Fill the new columns
my $orders = $dbh->selectall_arrayref(q|
    SELECT * FROM aqorders
|, { Slice => {} } );

my $sth_update_order = $dbh->prepare(q|
    UPDATE aqorders
    SET unitprice_tax_excluded = ?,
        unitprice_tax_included = ?,
        rrp_tax_excluded = ?,
        rrp_tax_included = ?,
        ecost_tax_excluded = ?,
        ecost_tax_included = ?,
        tax_value = ?
    WHERE ordernumber = ?
|);

my $sth_get_bookseller = $dbh->prepare(q|
    SELECT aqbooksellers.*
    FROM aqbooksellers
    LEFT JOIN aqbasket ON aqbasket.booksellerid = aqbooksellers.id
    LEFT JOIN aqorders ON aqorders.basketno = aqbasket.basketno
    WHERE ordernumber = ?
|);

require Koha::Number::Price;
for my $order ( @$orders ) {
    $sth_get_bookseller->execute( $order->{ordernumber} );
    my ( $bookseller ) = $sth_get_bookseller->fetchrow_hashref;
    $order->{rrp}   = Koha::Number::Price->new( $order->{rrp} )->round;
    $order->{ecost} = Koha::Number::Price->new( $order->{ecost} )->round;
    $order->{tax_rate} ||= 0 ; # tax_rate can be NULL in DB
    # Ordering
    if ( $bookseller->{listincgst} ) {
        $order->{rrp_tax_included} = $order->{rrp};
        $order->{rrp_tax_excluded} = Koha::Number::Price->new(
            $order->{rrp_tax_included} / ( 1 + $order->{tax_rate} ) )->round;
        $order->{ecost_tax_included} = $order->{ecost};
        $order->{ecost_tax_excluded} = Koha::Number::Price->new(
            $order->{ecost} / ( 1 + $order->{tax_rate} ) )->round;
    }
    else {
        $order->{rrp_tax_excluded} = $order->{rrp};
        $order->{rrp_tax_included} = Koha::Number::Price->new(
            $order->{rrp} * ( 1 + $order->{tax_rate} ) )->round;
        $order->{ecost_tax_excluded} = $order->{ecost};
        $order->{ecost_tax_included} = Koha::Number::Price->new(
            $order->{ecost} * ( 1 + $order->{tax_rate} ) )->round;
    }

    #receiving
    if ( $bookseller->{listincgst} ) {
        $order->{unitprice_tax_included} = Koha::Number::Price->new( $order->{unitprice} )->round;
        $order->{unitprice_tax_excluded} = Koha::Number::Price->new(
          $order->{unitprice_tax_included} / ( 1 + $order->{tax_rate} ) )->round;
    }
    else {
        $order->{unitprice_tax_excluded} = Koha::Number::Price->new( $order->{unitprice} )->round;
        $order->{unitprice_tax_included} = Koha::Number::Price->new(
          $order->{unitprice_tax_excluded} * ( 1 + $order->{tax_rate} ) )->round;
    }

    # If the order is received, the tax is calculated from the unit price
    if ( $order->{orderstatus} eq 'complete' ) {
        $order->{tax_value} = Koha::Number::Price->new(
          ( $order->{unitprice_tax_included} - $order->{unitprice_tax_excluded} )
          * $order->{quantity} )->round;
    } else {
        # otherwise the ecost is used
        $order->{tax_value} = Koha::Number::Price->new(
            ( $order->{ecost_tax_included} - $order->{ecost_tax_excluded} ) *
              $order->{quantity} )->round;
    }

    $sth_update_order->execute(
        $order->{unitprice_tax_excluded},
        $order->{unitprice_tax_included},
        $order->{rrp_tax_excluded},
        $order->{rrp_tax_included},
        $order->{ecost_tax_excluded},
        $order->{ecost_tax_included},
        $order->{tax_value},
        $order->{ordernumber},
    );
}
