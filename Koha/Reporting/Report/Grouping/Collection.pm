#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::Collection;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('collection_code');
    $self->setAlias('Collection');
    $self->setDescription('Collection');
    $self->setDimension('item');
    $self->setField('collection_code');
}
