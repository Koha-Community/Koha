#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::Location;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('location');
    $self->setDescription('Location');
    $self->setAlias('Location');
    $self->setDimension('location');
    $self->setField('location');
}

1;
