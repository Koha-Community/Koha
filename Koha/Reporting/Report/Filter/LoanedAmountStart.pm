#!/usr/bin/perl
package Koha::Reporting::Report::Filter::LoanedAmountStart;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('loaned_amount_start');
    $self->setDescription('Loaned amount (from)');
    $self->setType('text');
    $self->setDimension('fact');
    $self->setField('loaned_amount');
    $self->setRule('gte');
    $self->setFilterType('having');
    $self->setUseFullColumn(0);
}

1;
