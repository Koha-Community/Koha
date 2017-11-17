#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::LocationType;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('location_type');
    $self->setDescription('Fiction / Non-fiction');
    $self->setAlias('Fiction / Non-fiction');
    $self->setDimension('location');
    $self->setField('location_type');
}

1;
