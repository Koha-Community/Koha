#!/usr/bin/perl
package Koha::Reporting::Table::Dimension::Location;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Table::Dimension::Abstract';

sub BUILD {
    my $self = shift;
    $self->setPrimaryId('location_id');
    $self->setBusinessKey(['branch', 'location', 'location_type', 'location_age']);
    $self->setTableName('reporting_location_dim');

    $self->{column_value_validate_method}->{location_type} = \&validateAllowAll;
    $self->{column_value_validate_method}->{location_age} = \&validateAllowAll;

}

sub validateAllowAll{
    return 1;
}
1;
