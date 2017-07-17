#!/usr/bin/perl
package Koha::Procurement::EditX::LibraryShipNotice::ItemDetail::CopyDetail::Booky;

use Modern::Perl;
use Moose;

use Data::Dumper;

extends "Koha::Procurement::EditX::LibraryShipNotice::ItemDetail::CopyDetail";

sub getBookyString {
    my $self = shift;
    my $xmlObject = $_[0];
    my $parser = $_[1];
    my $result = '';

    my $query = '../Message[MessageType/text() = "04"]/MessageLine/xmlns:collection/xmlns:record/xmlns:controlfield[@tag="003"]';
    my $bookyString = $xmlObject->findnodes($query, $parser);
    if($bookyString && $bookyString->size() >= 1){
        $result = $bookyString->get_node(1)->string_value();
    }
    return $result;
}

sub getBooksellerCode {
    my $self = shift;
    my $marcRecord = $self->getMarcData();
    my $booksellerCode;

    if($marcRecord){
        $booksellerCode = $marcRecord->subfield('040','a');
    }
    if(!$booksellerCode){
       $booksellerCode = '';
    }
    return $booksellerCode;
}

sub getIsbnHyphen {
    my $self = shift;
    my $marcRecord = $self->getMarcData();
    my $isbn;

    if($marcRecord){
        $isbn = $marcRecord->subfield('020','a');
    }
    if(!$isbn){
       $isbn = '';
    }
    return $isbn;
}

sub getControl001 {
    my $self = shift;
    my $marcRecord = $self->getMarcData();
    my $isbn;

    if($marcRecord){
        my $field = $marcRecord->field('001');
        if($field){
            $isbn = $field->data();
        }
    }
    if(!$isbn){
       $isbn = '';
    }
    return $isbn;
}

sub getIsbns {
     my $self = shift;
     my $isbns = [];
     my $isbnh = $self->getIsbnHyphen();
     if($isbnh && $isbnh ne '' ){
         push @$isbns, $isbnh;
     }

     my $control001 = $self->getControl001();
     if($control001 && $control001 ne ''){
          push @$isbns, $control001;
     }
     return $isbns;
 }

1;
