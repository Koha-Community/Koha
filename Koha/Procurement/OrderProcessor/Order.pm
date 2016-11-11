#!/usr/bin/perl
package Koha::Procurement::OrderProcessor::Order;

use Moose;
use C4::Context;
use C4::Acquisition;
use Data::Dumper;

sub createOrder {
    my $self = shift;
    my ($copyDetail, $itemDetail, $order, $biblio, $basketNumber) = @_;
    my $price = $itemDetail->getPriceSRPExcludingTax();
    #my $gstrate = ($itemDetail->getPriceSRPETaxPercent() /100);
    my $gstrate = 0;
    my $budgetId = $self->getBudgetId($copyDetail->getFundNumber());

    my %hash = (
        basketno => $basketNumber,
        biblionumber => $biblio,
        title => $itemDetail->getTitle(),
        quantity => $copyDetail->getCopyQuantity(),
        order_vendornote => $order->getFileName(),
        order_internalnote => $order->getFileName(),
        rrp => $price,
        ecost => $price,
        unitprice => $price,
        listprice => $price,
        budget_id => $budgetId,
        currency => $itemDetail->getPriceSRPECurrency(),
        gstrate => $gstrate,
        orderstatus => 'new'
        );

    return NewOrder(\%hash);
}

sub createOrderItem
{
   my $self = shift;
   my @array = @_;

   NewOrderItem(@array);
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
