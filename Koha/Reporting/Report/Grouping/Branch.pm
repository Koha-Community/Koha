#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::Branch;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('branch');
    $self->setDescription('Branch');
    $self->setAlias('Branch');
    $self->setDimension('location');
    $self->setField('branch');
}

1;
