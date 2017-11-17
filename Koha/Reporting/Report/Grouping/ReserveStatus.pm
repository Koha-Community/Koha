#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::ReserveStatus;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('reserve_status');
    $self->setAlias('Reserve status');
    $self->setDescription('Reserve status');
    $self->setDimension('fact');
    $self->setField('reserve_status');
}

1;
