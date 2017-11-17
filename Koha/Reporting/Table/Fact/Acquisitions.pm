#!/usr/bin/perl
package Koha::Reporting::Table::Fact::Acquisitions;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends "Koha::Reporting::Table::Fact::Abstract";

sub BUILD {
    my $self = shift;
    $self->setPrimaryId('primary_key');
    $self->setDataColumn('amount');
    $self->setTableName('reporting_acquisitions_fact');

    $self->addDimension('item', 'Koha::Reporting::Table::Dimension::Item');
    $self->addDimension('date', 'Koha::Reporting::Table::Dimension::Date');
    $self->addDimension('location', 'Koha::Reporting::Table::Dimension::Location');
}

1;
