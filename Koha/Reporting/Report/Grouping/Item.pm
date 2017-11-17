#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::Item;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('item');
    $self->setDescription('Item');
    $self->setDimension('item');
    $self->setField('itemnumber');

    $self->setUseAlways('1');
    $self->setNoDisplay('1');
}

1;
