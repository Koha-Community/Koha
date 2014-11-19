#!/usr/bin/env perl

use Modern::Perl;
use C4::Context;

my $dbh = C4::Context->dbh;

# Add the new columns
$dbh->do(q|
    ALTER TABLE aqorders
        ADD COLUMN tax_rate_on_ordering   decimal(6,4) default NULL AFTER tax_rate,
        ADD COLUMN tax_rate_on_receiving  decimal(6,4) default NULL AFTER tax_rate_on_ordering,
        ADD COLUMN tax_value_on_ordering  decimal(28,6) default NULL AFTER tax_value,
        ADD COLUMN tax_value_on_receiving decimal(28,6) default NULL AFTER tax_value_on_ordering
|);

my $orders = $dbh->selectall_arrayref(q|
    SELECT * FROM aqorders
|, { Slice => {} } );

my $sth_update_order = $dbh->prepare(q|
    UPDATE aqorders
    SET tax_rate_on_ordering = tax_rate,
        tax_rate_on_receiving = tax_rate,
        tax_value_on_ordering = ?,
        tax_value_on_receiving = ?
    WHERE ordernumber = ?
|);

require Koha::Number::Price;
for my $order (@$orders) {
    my $tax_value_on_ordering =
      $order->{quantity} *
      $order->{ecost_tax_excluded} *
      $order->{tax_rate};

    my $tax_value_on_receiving =
      ( defined $order->{unitprice_tax_excluded} )
      ? $order->{quantity} * $order->{unitprice_tax_excluded} * $order->{tax_rate}
      : undef;

    $sth_update_order->execute( $tax_value_on_ordering,
        $tax_value_on_receiving, $order->{ordernumber} );
}

# Remove the old columns
$dbh->do(q|
    ALTER TABLE aqorders
        CHANGE COLUMN tax_value tax_value_bak  decimal(28,6) default NULL,
        CHANGE COLUMN tax_rate tax_rate_bak decimal(6,4) default NULL
|);
