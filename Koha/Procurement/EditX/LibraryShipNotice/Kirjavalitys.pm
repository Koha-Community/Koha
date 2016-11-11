#!/usr/bin/perl
package Koha::Procurement::EditX::LibraryShipNotice::Kirjavalitys;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends "Koha::Procurement::EditX::LibraryShipNotice";

sub BUILD {
    my $self = shift;
    $self->setItemObjectName('Koha::Procurement::EditX::LibraryShipNotice::ItemDetail::Kirjavalitys');
}

sub determineObjectClass{
     my $self = shift;
     my $xmlObject = $_[0];
     my $parser = $_[1];
     my $sellerName = '';
     my $result = 0;

     my $header = $self->getHeader($xmlObject,$parser);
     $sellerName = $self->getSellerName($xmlObject, $header);

     if( $sellerName eq 'Kirjavälitys Oy' ){
        print "Kirjavälitys \n";
        $result = 1;
     }

    return $result;
}

1;
