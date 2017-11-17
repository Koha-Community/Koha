#!/usr/bin/perl
package Koha::Reporting::Report::Filter::LoanedAmountEnd;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('loaned_amount_end');
    $self->setDescription('Loaned amount (to)');
    $self->setType('text');
    $self->setDimension('fact');
    $self->setField('loaned_amount');
    $self->setRule('lte');
    $self->setFilterType('having');
    $self->setUseFullColumn(0);
}

1;
