#!/usr/bin/perl
package Koha::Procurement::EditX::LibraryShipNotice::ItemDetail::Kirjavalitys;

use Modern::Perl;
use Moose;

extends "Koha::Procurement::EditX::LibraryShipNotice::ItemDetail";

sub BUILD {
    my $self = shift;
    $self->setItemObjectName('Koha::Procurement::EditX::LibraryShipNotice::ItemDetail::CopyDetail::Kirjavalitys');
}

sub getNotes{
     return 'KirjavalitysScr12';
}

sub getPriceFixedRPExcludingTax {
    my $self = shift;
    my $xmlData = $self->getXmlData();
    return $xmlData->find('PricingDetail/Price[PriceQualifierCode/text() = "FixedRPExcludingTax"]/MonetaryAmount')->string_value;
}

sub getPriceSRPExcludingTax {
    my $self = shift;
    my $xmlData = $self->getXmlData();
    return $xmlData->find('PricingDetail/Price[PriceQualifierCode/text() = "FixedRPExcludingTax"]/MonetaryAmount')->string_value;
}

sub getPriceSRPECurrency {
    my $self = shift;
    my $xmlData = $self->getXmlData();
    return $xmlData->find('PricingDetail/Price[PriceQualifierCode/text() = "FixedRPExcludingTax"]/CurrencyCode')->string_value;
}

sub getPriceSRPETaxPercent {
    my $self = shift;
    my $xmlData = $self->getXmlData();
    return $xmlData->find('PricingDetail/Price[PriceQualifierCode/text() = "FixedRPExcludingTax"]/Tax/Percent')->string_value;
}



1;
