#!/usr/bin/perl
package Koha::Procurement::EditX::LibraryShipNotice::ItemDetail::Btj;

use Modern::Perl;
use Moose;

extends "Koha::Procurement::EditX::LibraryShipNotice::ItemDetail";

sub BUILD {
    my $self = shift;
    $self->setItemObjectName('Koha::Procurement::EditX::LibraryShipNotice::ItemDetail::CopyDetail::Btj');
}

sub getNotes{
     return 'BtjScr12';
}

sub getSellerIdentifier{ # ISBN
    my $self = shift;
    my $xmlData = $self->getXmlData();

    my $result = $xmlData->find('ProductID[ProductIDType/text() = "ISBN" ]/Identifier')->string_value;
    return $result;
}

sub getPriceFixedRPExcludingTax {
    my $self = shift;
    my $xmlData = $self->getXmlData();
    return $xmlData->find('PricingDetail/Price[PriceQualifierCode/text() = "UnitCostExcludingTax"]/MonetaryAmount')->string_value;
}

sub getPriceSRPExcludingTax {
    my $self = shift;
    my $xmlData = $self->getXmlData();
    return $xmlData->find('PricingDetail/Price[PriceQualifierCode/text() = "UnitCostExcludingTax"]/MonetaryAmount')->string_value;
}

sub getPriceSRPECurrency {
    my $self = shift;
    my $xmlData = $self->getXmlData();
    return $xmlData->find('PricingDetail/Price[PriceQualifierCode/text() = "UnitCostExcludingTax"]/CurrencyCode')->string_value;
}

sub getPriceSRPETaxPercent {
    my $self = shift;
    my $xmlData = $self->getXmlData();
    return $xmlData->find('PricingDetail/Price[PriceQualifierCode/text() = "UnitCostExcludingTax"]/Tax/Percent')->string_value;
}

sub getDiscountPercentage {
    my $self = shift;
    my $xmlData = $self->getXmlData();
    return $xmlData->find('PricingDetail/Price[PriceQualifierCode/text() = "UnitCostExcludingTax"]/../DiscountPercentage')->string_value;

}

1;
