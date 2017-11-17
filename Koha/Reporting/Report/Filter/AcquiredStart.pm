#!/usr/bin/perl
package Koha::Reporting::Report::Filter::AcquiredStart;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('acquired_start');
    $self->setDescription('Acquired Year (from)');
    $self->setType('text');
    $self->setDimension('item');
    $self->setField('acquired_year');
    $self->setRule('gte');
}

1;
