#!/usr/bin/perl
package Koha::Reporting::Report::Renderer::OneRow;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends "Koha::Reporting::Report::Renderer::Csv";

has 'columns' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    writer => 'setColumns'
);

sub generateRows {
    my $self = shift;
    my $dataRows = $_[0];
    my $report = $_[1];
    my $groups = $self->getGroups();
    my $datas = {};
    my $groupValues = {};
    my $rowDatas = [];
    my $headerRows = [];
    $self->setReport($report);
    $self->setFactTable($report->getFactTable());
    my $dataColumn = $self->getFactTable()->getDataColumn();
    $dataRows = $self->getReport()->modifyDataRows($dataRows);

    foreach my $group (@$groups){
        $groupValues->{$group} = [];
    }
#die Dumper $groups;
            $headerRows = $self->getOneHeaderRow();
            my $columns = $self->getColumns();
            foreach my $row (@$dataRows){
                my $rowData = [];
                my $skip = 0;
                foreach my $group (@$groups){
                    if(defined $row->{$group}){
                        push $rowData, $row->{$group};
                    }
                    else{
                        $skip = 1;
                    }
                }
                foreach my $column (@$columns){
                    if(defined $row->{$column}){
                        push $rowData, $row->{$column};
                    }
                    else{
                        push $rowData,'';
                    }
                }
                if(!$skip){
                    push $rowDatas, $rowData;
                }
            }


    return ($headerRows, $rowDatas);
}

sub getColumnsOneRow{
    my $self = shift;
    my $columnsTmp = $self->{columns};
    my $columns = [];
    push $columns, @$columnsTmp;
    my $groups = $self->getGroups();
    unshift  $columns, @$groups;
    return $columns;
}

sub getOneHeaderRow{
    my $self = shift;
    my $firstGroup = $_[0];
    my $headerRows = [];
    my $columns = $self->getColumnsOneRow();
    my $headerRow = [];
    if(defined $firstGroup){
        push $headerRow, $firstGroup;
    }
    foreach my $column (@$columns){
        push $headerRow, $column;
    }

    if(@$headerRow){
        push $headerRows, $headerRow;
    }
    return $headerRows;
}


1;
