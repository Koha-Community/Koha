#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::AgeGroup;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('age_group');
    $self->setAlias('Age Group');
    $self->setDescription('Age Group');
    $self->setDimension('borrower');
    $self->setField('age_group');
}

1;
