#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::DateLastLoaned;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('datelastborrowed');
    $self->setAlias('Date last borrowed');
    $self->setDescription('Date last borrowed');
    $self->setDimension('item');
    $self->setField('datelastborrowed');
}

1;
