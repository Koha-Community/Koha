#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::Time::Hour;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('hour');
    $self->setDescription('Hour');
    $self->setAlias('Hour');
    $self->setDimension('date');
    $self->setField('hour');
}

1;
