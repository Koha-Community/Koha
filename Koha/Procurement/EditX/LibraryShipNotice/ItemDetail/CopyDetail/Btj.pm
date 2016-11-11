#!/usr/bin/perl
package Koha::Procurement::EditX::LibraryShipNotice::ItemDetail::CopyDetail::Btj;

use Modern::Perl;
use Moose;

use Data::Dumper;

extends "Koha::Procurement::EditX::LibraryShipNotice::ItemDetail::CopyDetail";


sub getEditionStatement {
    my $self = shift;
    my $marcRecord = $self->getMarcData();
    my $editionStatement;

    if($marcRecord){
        $editionStatement = $marcRecord->subfield('250','a');
    }
    if(!$editionStatement){
       my $xmlData = $self->getItemDetail()->getXmlData();
       my $result = $xmlData->find('ItemDescription/EditionStatement')->string_value;
    }
    if(!$editionStatement){
       $editionStatement = '';
    }
    return $editionStatement;
}

# sub getDeliverToLocation {
#     my $self = shift;
#     return $self->getFundNumber();
# }

# sub getDestinationLocation {
#     my $self = shift;
#     return $self->getFundNumber();
# }

sub getFundMonetaryAmount {
    my $self = shift;
    return $self->getItemDetail()->getPriceSRPExcludingTax();
}

1;
