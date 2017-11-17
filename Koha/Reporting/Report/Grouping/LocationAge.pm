#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::LocationAge;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('location_age');
    $self->setDescription('Adult / Child');
    $self->setAlias('Adult / Child');
    $self->setDimension('location');
    $self->setField('location_age');
}

1;
