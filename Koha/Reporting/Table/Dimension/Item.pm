#!/usr/bin/perl
package Koha::Reporting::Table::Dimension::Item;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Table::Dimension::Abstract';

sub BUILD {
    my $self = shift;
    $self->setPrimaryId('item_id');
    $self->setBusinessKey(['itemnumber']);
    $self->setTableName('reporting_item_dim');

    $self->{column_value_validate_method}->{biblioitemnumber} = \&validateAllowAll;
    $self->{column_value_validate_method}->{is_yle} = \&validateAllowAll;
    $self->{column_value_validate_method}->{published_year} = \&validateAllowAll;
    $self->{column_value_validate_method}->{collection_code} = \&validateAllowAll;
    $self->{column_value_validate_method}->{language} = \&validateAllowAll;
    $self->{column_value_validate_method}->{acquired_year} = \&validateAllowAll;
    $self->{column_value_validate_method}->{itemtype_okm} = \&validateAllowAll;
    $self->{column_value_validate_method}->{itemtype} = \&validateAllowAll;
    $self->{column_value_validate_method}->{barcode} = \&validateAllowAll;
    $self->{column_value_validate_method}->{title} = \&validateAllowAll;
    $self->{column_value_validate_method}->{language_all} = \&validateAllowAll;

    $self->{column_value_validate_method}->{cn_class} = \&validateAllowAll;
    $self->{column_value_validate_method}->{cn_class_fict} = \&validateAllowAll;
    $self->{column_value_validate_method}->{cn_class_primary} = \&validateAllowAll;
    $self->{column_value_validate_method}->{cn_class_1_dec} = \&validateAllowAll;
    $self->{column_value_validate_method}->{cn_class_2_dec} = \&validateAllowAll;
    $self->{column_value_validate_method}->{cn_class_3_dec} = \&validateAllowAll;
    $self->{column_value_validate_method}->{cn_class_signum} = \&validateAllowAll;

    $self->{column_value_validate_method}->{datelastborrowed} = \&validateAllowAll;

}

sub validateAllowAll{
    return 1;
}

1;
