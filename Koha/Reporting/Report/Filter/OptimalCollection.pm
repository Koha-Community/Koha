#!/usr/bin/perl
package Koha::Reporting::Report::Filter::OptimalCollection;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('optimal_collection_min');
    $self->setDescription('Optimal collection min');
    $self->setName2('optimal_collection_max');
    $self->setDescription2('Optimal collection max');

    $self->setUseCustomLogic(1);
    $self->setType('textdouble');
    $self->setDimension('fact');
    $self->setField('amount');
    $self->setRule('skip');
}

sub customLogic{
    my $self = shift;
    my $report = $_[0];
    my $requestFilter = $_[1];
    my ($startVal, $endVal, $field);

    if(defined $requestFilter->{selectedValue1} && defined $requestFilter->{selectedValue2} && $requestFilter->{selectedValue1} ne '' && $requestFilter->{selectedValue2} ne ''){
        $startVal = $requestFilter->{selectedValue1};
        $endVal = $requestFilter->{selectedValue2};

        $field = "IF(COUNT(distinct reporting_items_fact.item_id) >= '$startVal', IF(COUNT(distinct reporting_items_fact.item_id) <= '$endVal', 'optimal', 'too much'), 'too little' ) ";
        $report->getFactTable()->addFieldToSelect($field, 'is_optimal', 1, undef, 1);
        $report->getRenderer()->addColumn('is_optimal');
    }
    elsif(defined $requestFilter->{selectedValue1} && $requestFilter->{selectedValue1} ne '' ){
        $startVal = $requestFilter->{selectedValue1};
        $field = "IF(COUNT(distinct reporting_items_fact.item_id) >= '$startVal','optimal', 'too little' ) ";
        $report->getFactTable()->addFieldToSelect($field, 'is_optimal', 1, undef, 1);
        $report->getRenderer()->addColumn('is_optimal');
    }
    elsif(defined $requestFilter->{selectedValue2} && $requestFilter->{selectedValue2} ne ''){
        $endVal = $requestFilter->{selectedValue2};
        $field = "IF(COUNT(distinct reporting_items_fact.item_id) <= '$endVal', 'optimal', 'too much') ";
        $report->getFactTable()->addFieldToSelect($field, 'is_optimal', 1, undef, 1);
        $report->getRenderer()->addColumn('is_optimal');
    }
}

1;
