#!/usr/bin/perl
package Koha::Reporting::Table::Dimension::Borrower;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Table::Dimension::Abstract';

sub BUILD {
    my $self = shift;
    $self->setPrimaryId('borrower_id');
    $self->setBusinessKey(['borrowernumber']);
    $self->setTableName('reporting_borrower_dim');

    $self->{column_value_validate_method}->{age_group} = \&validateAllowAll;
    $self->{column_value_validate_method}->{cardnumber} = \&validateAllowAll;
    $self->{column_value_validate_method}->{categorycode} = \&validateAllowAll;
    $self->{column_value_validate_method}->{postcode} = \&validateAllowAll;

}

sub validateAllowAll{
    return 1;
}


1;
