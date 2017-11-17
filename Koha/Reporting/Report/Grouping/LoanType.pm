#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::LoanType;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('loan_type');
    $self->setAlias('Loan type');
    $self->setDescription('Loan type');
    $self->setDimension('fact');
    $self->setField('loan_type');
}

1;
