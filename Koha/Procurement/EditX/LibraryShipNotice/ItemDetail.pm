#!/usr/bin/perl
package Koha::Procurement::EditX::LibraryShipNotice::ItemDetail;

use Modern::Perl;
use Moose;
use utf8;
no utf8;

use Data::Dumper;

has 'xmlData' => (
    is => 'rw',
    reader => 'getXmlData',
    writer => 'setXmlData',
    isa => 'XML::LibXML::Element'
);

has 'documentXmlData' => (
    is => 'rw',
    reader => 'getDocumentXmlData',
    writer => 'setDocumentXmlData',
);

has 'parser' => (
    is => 'rw',
    reader => 'getParser',
    writer => 'setParser',
);

has 'copyDetailObjectName' => (
    is => 'rw',
    reader => 'getItemObjectName',
    writer => 'setItemObjectName'
);

has 'copyDetails' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    reader => 'getCopyDetail',
    writer => 'setCopyDetail'
);

has 'parent' => (
    is => 'rw',
    reader => 'getParent',
    writer => 'setParent'
);

sub BUILD {
    my $self = shift;
    $self->setItemObjectName('Koha::Procurement::EditX::LibraryShipNotice::ItemDetail::CopyDetail');
}

sub getLibraryShipNotice{
   my $self = shift;
   return $self->getParent();
}

sub getCopydetails{
    my $self = shift;
    my $xmlData = $self->getXmlData();
    my $parser = $self->getParser();

    return $xmlData->findnodes('CopyDetail', $parser);
}

sub addItem{
    my $self = shift;
    my $copyDetail = $_[0];

    if($copyDetail && $copyDetail->isa($self->getItemObjectName())){
        push $self->{copyDetails}, $copyDetail;
    }
}

sub getAuthor{
    my $self = shift;
    my $xmlData = $self->getXmlData();

    my $result = $xmlData->find('ItemDescription/Author')->string_value;
    return $result;
}

sub getTitle{
    my $self = shift;
    my $xmlData = $self->getXmlData();

    my $result = $xmlData->find('ItemDescription/Title')->string_value;
    return $result;
}

sub getNotes{
    return '';
}

sub getSeriesTitle{
    my $self = shift;
    my $xmlData = $self->getXmlData();

    my $result = $xmlData->find('ItemDescription/SeriesTitle')->string_value;
    return $result;
}

sub getProductForm{
    my $self = shift;
    my $xmlData = $self->getXmlData();

    my $result = $xmlData->find('ItemDescription/ProductForm')->string_value;
    return $result;
}

sub getSellerIdentifier{
    my $self = shift;
    my $xmlData = $self->getXmlData();
    my $result = $xmlData->find('ProductID[ProductIDType/text() = "Seller" ]/Identifier')->string_value;
    return $result;
}

sub getEanIdentifier{
    my $self = shift;
    my $xmlData = $self->getXmlData();

    my $result = $xmlData->find('ProductID[ProductIDType/text() = "EAN13" ]/Identifier')->string_value;
    return $result;
}

sub getProductIdType{
    return '';
}

sub getPriceFixedRPExcludingTax {
    my $self = shift;
    my $xmlData = $self->getXmlData();
    return $xmlData->find('PricingDetail/Price[PriceQualifierCode/text() = "FixedRPExcludingTax"]/MonetaryAmount')->string_value;
}

sub getPriceSRPExcludingTax {
    my $self = shift;
    my $xmlData = $self->getXmlData();
    return $xmlData->find('PricingDetail/Price[PriceQualifierCode/text() = "SRPExcludingTax"]/MonetaryAmount')->string_value;
}

sub getPriceSRPECurrency {
    my $self = shift;
    my $xmlData = $self->getXmlData();
    return $xmlData->find('PricingDetail/Price[PriceQualifierCode/text() = "SRPExcludingTax"]/CurrencyCode')->string_value;
}

sub getPriceSRPETaxPercent {
    my $self = shift;
    my $xmlData = $self->getXmlData();
    return $xmlData->find('PricingDetail/Price[PriceQualifierCode/text() = "SRPExcludingTax"]/Tax/Percent')->string_value;
}

sub getIsbns {
     my $self = shift;
     my $isbns = [];
     my $isbnSeller = $self->getSellerIdentifier();
     if($isbnSeller && $isbnSeller ne ''){
         push $isbns, $isbnSeller;
     }

     my $isbnEan = $self->getEanIdentifier();
     if($isbnEan && $isbnEan ne '' ){
         push $isbns, $isbnEan;
     }
     return $isbns;
 }
1;
