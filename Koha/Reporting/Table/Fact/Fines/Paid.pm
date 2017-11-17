#!/usr/bin/perl
package Koha::Reporting::Table::Fact::Fines::Paid;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends "Koha::Reporting::Table::Fact::Abstract";

sub BUILD {
    my $self = shift;
    $self->setPrimaryId('primary_key');
    $self->setDataColumn('amount');
    $self->setTableName('reporting_fines_paid_fact');
    $self->setUseDecimalTruncate(1);
    $self->setUseReplaceComma(1);
    $self->addDimension('date', 'Koha::Reporting::Table::Dimension::Date');
    $self->addDimension('borrower', 'Koha::Reporting::Table::Dimension::Borrower');
    $self->addDimension('location', 'Koha::Reporting::Table::Dimension::Location');

}

1;
