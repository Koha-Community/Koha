#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::Overdue;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('overdue');
    $self->setDescription('Valid / Outdated');
    $self->setAlias('Valid / Outdated');
    $self->setDimension('fact');
    $self->setField('is_overdue');
}

1;
