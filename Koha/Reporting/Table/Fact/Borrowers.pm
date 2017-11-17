#!/usr/bin/perl
package Koha::Reporting::Table::Fact::Borrowers;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends "Koha::Reporting::Table::Fact::Abstract";

sub BUILD {
    my $self = shift;
    $self->setPrimaryId('primary_key');
    $self->setDataColumn('amount');
    $self->setTableName('reporting_borrowers_fact');

    $self->addDimension('date', 'Koha::Reporting::Table::Dimension::Date');
    $self->addDimension('borrower', 'Koha::Reporting::Table::Dimension::Borrower');
    $self->addDimension('location', 'Koha::Reporting::Table::Dimension::Location');
}

1;
