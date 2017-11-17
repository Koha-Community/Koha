#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::BiblioItemAlways;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('biblioitem_always');
    $self->setDescription('Biblioitem');
    $self->setAlias('Biblioitem');
    $self->setDimension('item');
    $self->setField('biblioitemnumber');

    $self->setUseAlways('1');
    $self->setNoDisplay('1');
}

1;
