#!/usr/bin/perl
package Koha::Reporting::Table::Fact::LoansZero;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends "Koha::Reporting::Table::Fact::Abstract";

sub BUILD {
    my $self = shift;
    $self->setPrimaryId('primary_key');
    $self->setDataColumn('loaned_amount');
    $self->setTableName('reporting_items_fact');

    $self->addDimension('item', 'Koha::Reporting::Table::Dimension::Item');
    $self->addDimension('date', 'Koha::Reporting::Table::Dimension::DateZero');
    $self->addDimension('location', 'Koha::Reporting::Table::Dimension::Location');

}

sub buildSelect{
    my $self = shift;
    my ($select, $from, $where, $groupBy, $having, $orderBy, $limit) = ('', '', '', '', '', '', '');
    my @bind;
    my $dimensions = $self->getDimensions();
    my ($dimension, $filters, $groups, $selectColumns);
    if($self->getTableName()){
        $select .= 'SELECT ';
        $from .= 'FROM ' . $self->getTableName() . ' ';

        my $factExtraJoins = $self->getExtraJoins();
        if(@$factExtraJoins){
            foreach my $factExtraJoin (@$factExtraJoins){
                 $from .= $factExtraJoin;
            }
        }
        foreach my $dimensionName (sort keys %$dimensions) {
            $dimension = $dimensions->{$dimensionName};
            if($dimension && $dimension->getIsNeeded() && $dimension->getTableName() && $dimension->getPrimaryId()){
                $from .= 'INNER JOIN ' . $dimension->getTableName() . ' ON ' . $self->getFullColumn($dimension->getPrimaryId()) . ' = ' . $dimension->getFullColumn($dimension->getPrimaryId()) . ' ';
                my $extraJoins = $dimension->getExtraJoins();
                if(@$extraJoins){
                    foreach my $extraJoin (@$extraJoins){
                        $from .= $extraJoin;
                    }
                }

                if($dimensionName eq 'date'){
                    $dimension->setSkipFromDate(1)
                }

                $where = $dimension->getFilterFragment($where);

                if($dimensionName eq 'date'){
                    $dimension->setSkipFromDate(0)
                }

                $groupBy = $dimension->getGroupByFragment($groupBy);
                $having = $dimension->getHavingFragment($having);
                $orderBy = $dimension->getOrderByFragment($orderBy);
                $select = $dimension->getSelectFragment($select);
            }
        }

        $where = $self->getFilterFragment($where);
        $where = $self->getZeroLoanWhere($where);
        $groupBy = $self->getGroupByFragment($groupBy). ' ';
        $having = $self->getHavingFragment($having);
        $orderBy = $self->getOrderByFragment($orderBy). ' ';
        if($groupBy ne '' && $self->getUseRollup() != 0){
            $groupBy .= ' WITH ROLLUP ';
        }

        $select = $self->getSelectFragment($select) . " '0' as loaned_amount ";
        if($self->getUseCount() && $self->getCountColumn()){
#            $select .= $self->getCountSelectFragment($self->getUseDistinct()) . ' ';
        }
        elsif($self->getUseSum()){
#            $select .= $self->getSumSelectFragment() . ' ';
        }
        else{
        #    $select .= $self->getDataColumn() . ' ';
        }

        if($self->getLimit()){
            $limit = 'LIMIT ' . $self->getLimit();
        }
    }

    if($where ne ''){
        $where = 'WHERE ' . $where;
    }
    if($having ne ''){
        $having = ' HAVING ' . $having;
    }

    $select = $select . $from . $where .$groupBy. $having .$orderBy . $limit;
#    die Dumper $select;
    return ($select, \@bind);
}

sub getZeroLoanWhere{
    my $self = shift;
    my $where = $_[0];
    my $dimensionName = 'date';
    my $dateWhere = '';
    my $select = 'SELECT reporting_loans_fact.item_id ';
    my $from = '';

    if($where eq ''){
        $where = '';
    }
    else{
        $where .= ' AND '
    }
    my $dimensions = $self->getDimensions();
    if (defined $dimensions->{$dimensionName}){
        my $dimension = $dimensions->{$dimensionName};
        if($dimension && $dimension->getIsNeeded() && $dimension->getTableName() && $dimension->getPrimaryId()){
            $from =  ' FROM reporting_loans_fact ';
            $from .= 'INNER JOIN ' . $dimension->getTableName() . ' ON reporting_loans_fact.' . $dimension->getPrimaryId() . ' = ' . $dimension->getFullColumn($dimension->getPrimaryId()) . ' ';
            my $extraJoins = $dimension->getExtraJoins();
            if(@$extraJoins){
                foreach my $extraJoin (@$extraJoins){
                    $from .= $extraJoin;
                }
            }
            $dateWhere = ' WHERE ' .$dimension->getFilterFragment($dateWhere);
            #$groupBy = $dimension->getGroupByFragment($groupBy);
           # $having = $dimension->getHavingFragment($having);
           # $orderBy = $dimension->getOrderByFragment($orderBy);
            $select = $dimension->getSelectFragment($select);
            $select = $select . $from . $dateWhere;

            $where .= $self->getTableName(). '.item_id not in ( ' .$select. ' ) ';
        }
    }

    return $where;
}


1;
