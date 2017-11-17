#!/usr/bin/perl
package Koha::Reporting::Table::Fact::Messages;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends "Koha::Reporting::Table::Fact::Abstract";

sub BUILD {
    my $self = shift;
    $self->setPrimaryId('primary_key');
    $self->setDataColumn('amount');
    $self->setTableName('reporting_messages_fact');

    $self->addDimension('borrower', 'Koha::Reporting::Table::Dimension::Borrower');
    $self->addDimension('location', 'Koha::Reporting::Table::Dimension::Location');
    $self->addDimension('date', 'Koha::Reporting::Table::Dimension::Date');
}

1;
