#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::BorrowerActivity;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('activity_type');
    $self->setAlias('Borrower activity');
    $self->setDescription('Borrower activity');
    $self->setDimension('fact');
    $self->setField('activity_type');
}

1;
