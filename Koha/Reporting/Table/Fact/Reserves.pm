#!/usr/bin/perl
package Koha::Reporting::Table::Fact::Reserves;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends "Koha::Reporting::Table::Fact::Abstract";

sub BUILD {
    my $self = shift;
    $self->setPrimaryId('primary_key');
    $self->setDataColumn('amount');
    $self->setTableName('reporting_reserves_fact');

    $self->addDimension('item', 'Koha::Reporting::Table::Dimension::Item');
    $self->addDimension('location', 'Koha::Reporting::Table::Dimension::Location');
    $self->addDimension('borrower', 'Koha::Reporting::Table::Dimension::Borrower');
    $self->addDimension('date', 'Koha::Reporting::Table::Dimension::Date');
}

1;
