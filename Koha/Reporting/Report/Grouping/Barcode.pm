#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::Barcode;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('barcode');
    $self->setDescription('Barcode');
    $self->setAlias('Barcode');
    $self->setDimension('item');
    $self->setField('barcode');

    $self->setUseAlways('1');
    $self->setNoDisplay('1');
}

1;
