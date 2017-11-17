#!/usr/bin/perl
package Koha::Reporting::Report::Filter::OptimalCollectionMax;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('optimal_collection_max');
    $self->setDescription('Optimal collection max');
    $self->setType('text');
    $self->setDimension('fact');
    $self->setField('amount');
    $self->setRule('lte');
}

1;
