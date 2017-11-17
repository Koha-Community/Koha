#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::CnClassFictive;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('cn_class_fict');
    $self->setAlias('Class fictive');
    $self->setDescription('Class fictive');
    $self->setDimension('item');
    $self->setField('cn_class_fict');
}


1;
