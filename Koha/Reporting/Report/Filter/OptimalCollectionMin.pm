#!/usr/bin/perl
package Koha::Reporting::Report::Filter::OptimalCollectionMin;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('optimal_collection_min');
    $self->setDescription('Optimal collection min');
    $self->setType('text');
    $self->setDimension('fact');
    $self->setField('amount');
    $self->setRule('gte');
}

1;
