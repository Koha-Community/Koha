#!/usr/bin/perl
package Koha::Reporting::Report::Filter::AcquiredEnd;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('acquired_end');
    $self->setDescription('Acquired Year (to)');
    $self->setType('text');
    $self->setDimension('item');
    $self->setField('acquired_year');
    $self->setRule('lte');
}

1;
