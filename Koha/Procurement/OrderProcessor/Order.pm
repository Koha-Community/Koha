#!/usr/bin/perl
package Koha::Procurement::OrderProcessor::Order;

use Moose;
use C4::Context;
use C4::Acquisition;
use Data::Dumper;

sub createOrder {
    my $self = shift;
    my ($copyDetail, $itemDetail, $order, $biblio, $basketNumber) = @_;
    my $price = $itemDetail->getPriceFixedRPExcludingTax();
    my $tax_price = $itemDetail->getPriceFixedRPIncludingTax();
    my $budgetId = $self->getBudgetId($copyDetail->getFundNumber());

    my %hash = (
        basketno => $basketNumber,
        biblionumber => $biblio,
        title => $itemDetail->getTitle(),
        quantity => $copyDetail->getCopyQuantity(),
        order_vendornote => $order->getFileName(),
        order_internalnote => $order->getFileName(),
        rrp => $itemDetail->getPriceSRPIncludingTax(),
        rrp_tax_excluded => $itemDetail->getPriceSRPExcludingTax(),
        rrp_tax_included => $itemDetail->getPriceSRPIncludingTax(),
        ecost => $price,
        ecost_tax_excluded => $price,
        ecost_tax_included => $tax_price,
        unitprice => $price,
        unitprice_tax_excluded => $price,
        unitprice_tax_included => $tax_price,
        listprice => $price,
        budget_id => $budgetId,
        currency => $itemDetail->getPriceSRPECurrency(),
        orderstatus => 'new'
        );
    $order = Koha::Acquisition::Order->new( \%hash)->insert;
    return $order->{ordernumber};
}

sub createOrderItem
{
   my $self = shift;
   my $itemnumber = shift;
   my $ordernumber = shift;

   my $order = Koha::Acquisition::Order->fetch({ ordernumber => $ordernumber });
   $order->add_item( $itemnumber );
}

sub getBudgetId {
   my $self = shift;
   my $fundNumber = $_[0];
   my $dbh = C4::Context->dbh;

   my $stmnt = $dbh->prepare("SELECT max(budget_id) FROM aqbudgets WHERE budget_code = ?");
   $stmnt->execute($fundNumber);
   my $budgetId = $stmnt->fetchrow_array();
   $stmnt->finish();

   return $budgetId;
}


1;
