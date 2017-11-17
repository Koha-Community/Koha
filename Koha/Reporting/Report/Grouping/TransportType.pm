#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::TransportType;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('transport_type');
    $self->setAlias('Transport type');
    $self->setDescription('Transport type');
    $self->setDimension('fact');
    $self->setField('transport_type');
}

1;
