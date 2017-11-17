#!/usr/bin/perl
package Koha::Reporting::Table::Dimension::Loan;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Table::Dimension::Abstract';

sub BUILD {
    my $self = shift;
    $self->setPrimaryId('loan_id');
    $self->setBusinessKey(['borrowernumber']);
    $self->setTableName('reporting_loan_dim');
}
