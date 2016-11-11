#!/usr/bin/perl
package Koha::Procurement::EditX::LibraryShipNotice::ItemDetail::Booky;

use Modern::Perl;
use Moose;

extends "Koha::Procurement::EditX::LibraryShipNotice::ItemDetail";

sub BUILD {
    my $self = shift;
    $self->setItemObjectName('Koha::Procurement::EditX::LibraryShipNotice::ItemDetail::CopyDetail::Booky');
}

sub getNotes{
     return 'BookyScr12';
}

1;
