#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::Time::Month;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('month');
    $self->setDescription('Month');
    $self->setAlias('Month');
    $self->setDimension('date');
    $self->setField('month');
}

1;
