#!/usr/bin/perl
package Koha::Reporting::Table::Dimension::ItemStatus;

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
    $self->{column_value_validate_method}->{cn_class_primary} = \&validateAllowAll;
    $self->{column_value_validate_method}->{cn_class_1_dec} = \&validateAllowAll;
    $self->{column_value_validate_method}->{cn_class_2_dec} = \&validateAllowAll;
    $self->{column_value_validate_method}->{cn_class_3_dec} = \&validateAllowAll;

}

sub validateAllowAll{
    return 1;
}

sub getSelectFragment{
    my $self = shift;
    my $select = $_[0];
    if($self->getSelectColumns()){
        my $selectColumns = $self->getSelectColumns();
        foreach my $selectColumn (@$selectColumns){
            my $alias = $self->getColumnAlias($selectColumn);
            if($selectColumn && $alias){
                $select .= $selectColumn .' AS "' .$alias.  '", ';
            }
        }
#        $select .= $self->addStatusSelect();
    }
    return $select;
}

sub addStatusSelect{
    my $self = shift;
    my $select = $_[0];
    $select .= 'items.notforloan AS "notforloan", ';
    $select .= 'items.damaged AS "damaged", ';
    $select .= 'items.itemlost AS "itemlost", ';
    return $select;
}


1;
