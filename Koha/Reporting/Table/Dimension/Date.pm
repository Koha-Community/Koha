#!/usr/bin/perl
package Koha::Reporting::Table::Dimension::Date;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Table::Dimension::Abstract';

sub BUILD {
    my $self = shift;
    $self->setPrimaryId('date_id');
    $self->setBusinessKey(['date_id']);
    $self->setTableName('reporting_date_dim');
}

sub initDefaultImportColumns{
    my $self = shift;
    my $allColumns = $self->getColumns();
    foreach my $column (@$allColumns){
        $self->addImportColumn($column);
    }
}

1;
