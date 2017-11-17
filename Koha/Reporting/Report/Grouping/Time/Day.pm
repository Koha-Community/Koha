#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::Time::Day;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('day');
    $self->setDescription('Day');
    $self->setAlias('Day');
    $self->setDimension('date');
    $self->setField('day');
}

1;
