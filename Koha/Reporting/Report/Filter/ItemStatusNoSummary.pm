#!/usr/bin/perl
package Koha::Reporting::Report::Filter::ItemStatusNoSummary;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

has 'linked_filter' => (
    is => 'rw',
    reader => 'getLinkedFilter',
    writer => 'setLinkedFilter'
);


sub BUILD {
    my $self = shift;
    $self->setName('item_status_no_summary');
    $self->setDescription('Item status');
    $self->setType('select');
    $self->setDimension('item');
    $self->setField('item_status_no_summary');
    $self->setRule('in');

    $self->setUseCustomLogic(1);
    $self->setAddSelectAllOption(0);
    $self->setAddNotSetOption(0);

    $self->setLinkedFilter('item_status_no_summary_options');
}

sub loadOptions{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $options = [];
    my $damaged = [];
    my $notloan = [];
    my $lost = [];

    my $stmnt = $dbh->prepare("select lib, authorised_value, category from authorised_values where category in ('DAMAGED', 'NOT_LOAN', 'LOST') ");
    $stmnt->execute();
    if ($stmnt->rows >= 1){
        while ( my $row = $stmnt->fetchrow_hashref ) {
            my $name = '';
            if($row->{category} eq 'DAMAGED'){
                $name  = 'damaged-' . $row->{authorised_value};
                push $damaged, $name;
            }
            elsif($row->{category} eq 'NOT_LOAN'){
                $name  = 'notforloan-' . $row->{authorised_value};
                push $notloan, $name;
            }
            elsif($row->{category} eq 'LOST'){
                $name  = 'lost-' . $row->{authorised_value};
                push $lost, $name;
            }
        }
    }

    push $options, { 'name' => 'loaned', 'description' => 'Loaned', 'linked_filter' => 'item_status_no_summary_options'  };
    push $options, { 'name' => 'available', 'description' => 'Available' , 'linked_filter' => 'item_status_no_summary_options'};
    push $options, { 'name' => 'damaged', 'description' => 'Damaged' , 'linked_options' => $damaged, 'linked_filter' => 'item_status_no_summary_options'};
    push $options, { 'name' => 'notforloan', 'description' => 'Not for loan' , 'linked_options' => $notloan, 'linked_filter' => 'item_status_no_summary_options'};
    push $options, { 'name' => 'lost', 'description' => 'Lost' , 'linked_options' => $lost, 'linked_filter' => 'item_status_no_summary_options'};
    return $options;
}

sub customLogic{
    my $self = shift;
    my $report = $_[0];
    my $requestFilter = $_[1];
    my $dimension;
    my $linkedFilter;
    my $linkedOptions = [];
 #   die Dumper $requestFilter;
    if(defined $requestFilter->{selectedOptions}){
        my $selectedValue = $requestFilter->{selectedOptions};
        if(ref $selectedValue eq 'ARRAY' && defined @$selectedValue[0] && defined @$selectedValue[0]->{name}){
            if(defined @$selectedValue[0]->{linkedFilter}){
                $linkedFilter = @$selectedValue[0]->{linkedFilter};
            }
            $selectedValue = @$selectedValue[0]->{name};
        }
        my $dimensionName = $self->getDimension();
        if($dimensionName eq 'fact'){
            $dimension = $report->getFactTable();
        }
        else{
            $dimension = $report->getFactTable()->getDimensionByName($dimensionName);
        }

        if(defined $dimension){
            if(defined $linkedFilter && defined $linkedFilter->{selectedOptions}){
                my $linkedOptionsTmp = $linkedFilter->{selectedOptions};
                if(@$linkedOptionsTmp){
                    foreach my $linkedOption (@$linkedOptionsTmp){
                        if(defined $linkedOption->{name}){
                           push $linkedOptions, $linkedOption->{name};
                        }
                    }
                }
            }
            $dimension->setIsNeeded(1);
            if($selectedValue eq 'loaned'){
                $dimension->addExtraJoin('INNER JOIN issues on ' . $dimension->getFullColumn('itemnumber') . ' = issues.itemnumber ');
            }
            elsif($selectedValue eq 'available'){
                $dimension->addExtraJoin('INNER JOIN items on ' . $dimension->getFullColumn('itemnumber') . ' = items.itemnumber and items.notforloan = 0 ');
                $dimension->addExtraJoin('INNER JOIN branchtransfers on ' . $dimension->getFullColumn('itemnumber') . ' = branchtransfers.itemnumber and branchtransfers.datearrived is null ');
                $dimension->addExtraJoin('INNER JOIN reserves on ' . $dimension->getFullColumn('itemnumber') . ' = reserves.itemnumber and reserves.found is null ');
            }
            elsif($selectedValue eq 'damaged'){
                my $conditionString = 'items.damaged != 0';
                if(@$linkedOptions){
                    $conditionString = 'items.damaged IN(' .$self->getLinkedOptionsCondition($selectedValue, $linkedOptions) . ') ';
                }
                $dimension->addExtraJoin('INNER JOIN items on ' . $dimension->getFullColumn('itemnumber') . ' = items.itemnumber ');
                if(defined $conditionString && $conditionString ne ''){
                    push $dimension->{filters}, {'logic' => $self->getLogic(), 'condition' => $conditionString, 'type' => 'filter'};
                }
                my $processedDateSelect = 'IF(items.damaged = 3, items.timestamp, "-") ';
                my $processedAlias = 'Processed Date';
                $dimension->addFieldToSelect($processedDateSelect, $processedAlias, 1, undef, 1);
                $report->getRenderer()->addColumn($processedAlias);
            }
            elsif($selectedValue eq 'notforloan'){
                my $conditionString = 'items.notforloan != 0';
                if(@$linkedOptions){
                    $conditionString = 'items.notforloan IN(' .$self->getLinkedOptionsCondition($selectedValue, $linkedOptions) . ') ';
                }
                $dimension->addExtraJoin('INNER JOIN items on ' . $dimension->getFullColumn('itemnumber') . ' = items.itemnumber ');
                if(defined $conditionString && $conditionString ne ''){
                    push $dimension->{filters}, {'logic' => $self->getLogic(), 'condition' => $conditionString, 'type' => 'filter'};
                }
            }
            elsif($selectedValue eq 'lost'){
                my $conditionString = 'items.itemlost != 0';
                if(@$linkedOptions){
                    $conditionString = 'items.itemlost IN(' .$self->getLinkedOptionsCondition($selectedValue, $linkedOptions) . ') ';
                }
                $dimension->addExtraJoin('INNER JOIN items on ' . $dimension->getFullColumn('itemnumber') . ' = items.itemnumber ');
                if(defined $conditionString && $conditionString ne ''){
                    push $dimension->{filters}, {'logic' => $self->getLogic(), 'condition' => $conditionString, 'type' => 'filter'};
                }
            }
        }

    }
}

sub getLinkedOptionsCondition{
    my $self = shift;
    my $selectedValue = $_[0];
    my $linkedOptions = $_[1];
    my $conditionString;
    my $linkedOptionsTmp = [];
    if(defined $selectedValue && defined $linkedOptions){
        $selectedValue .= '-';
        foreach my $linkedOption (@$linkedOptions){
            $linkedOption =~ s/$selectedValue//g;
            push $linkedOptionsTmp, $linkedOption;
        }
        $conditionString = $self->getArrayCondition($linkedOptionsTmp);
    }
    return $conditionString;
}


1;
