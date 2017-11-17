#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::AcquiredYear;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('acquired_year');
    $self->setAlias('Acquired year');
    $self->setDescription('Acquired year');
    $self->setDimension('item');
    $self->setField('acquired_year');
}
