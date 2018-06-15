#!/usr/bin/perl
package Koha::Reporting::Report::Abstract;

use Modern::Perl;
use Moose;
use Data::Dumper;
use Koha::Reporting::Table::Fact::Factory;
use Koha::Reporting::Report::Filter::Abstract;
use POSIX qw(strftime);
use Time::Piece;
use Scalar::Util qw(looks_like_number);

has 'name' => (
    is => 'rw',
    reader => 'getName',
    writer => 'setName'
);

has 'group' => (
    is => 'rw',
    reader => 'getGroup',
    writer => 'setGroup'
);

has 'description' => (
    is => 'rw',
    reader => 'getDescription',
    writer => 'setDescription'
);

has 'use_sum' => (
    is => 'rw',
    default => 1,
    reader => 'getUseSum',
    writer => 'setUseSum'
);

has 'use_date_from' => (
    is => 'rw',
    default => 1,
    reader => 'getUseDateFrom',
    writer => 'setUseDateFrom'
);

has 'use_date_to' => (
    is => 'rw',
    default => 1,
    reader => 'getUseDateTo',
    writer => 'setUseDateTo'
);

has 'orderings' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    reader => 'getOrderings',
    writer => 'setOrderings'
);

has 'orderings_hash' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} },
    reader => 'getOrderingsHash',
    writer => 'setOrderingsHash'
);

has 'groupings' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    reader => 'getGroupings',
    writer => 'setGroupings'
);

has 'hard_coded_groupings' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    reader => 'getHardCodedGroupings',
    writer => 'setHardCodedGroupings'
);

has 'select_columns' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    reader => 'getSelectColumns',
    writer => 'setSelectColumns'
);

has 'groupings_hash' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} },
    reader => 'getGroupingsHash',
    writer => 'setGroupingsHash'
);

has 'filters' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    reader => 'getFilters',
    writer => 'setFilters'
);

has 'factTable' => (
    is => 'rw',
    reader => 'getFactTable',
    writer => 'setFactTable'
);

has 'factTableFactory' => (
    is => 'rw',
    reader => 'getFactTableFactory',
    writer => 'setFactTableFactory'
);

has 'objectFactory' => (
    is => 'rw',
    reader => 'getObjectFactory',
    writer => 'setObjectFactory'
);

has 'renderer' => (
    is => 'rw',
    reader => 'getRenderer',
    writer => 'setRenderer'
);

has 'renderer_class' => (
    is => 'rw',
    default => 'Koha::Reporting::Report::Renderer::Csv',
    reader => 'getRendererClass',
    writer => 'setRendererClass'
);

has 'default_ordering' => (
    is => 'rw',
    reader => 'getDefaultOrdering',
    writer => 'setDefaultOrdering'
);

has 'has_top_limit' => (
    is => 'rw',
    default => 0,
    reader => 'getHasTopLimit',
    writer => 'setHasTopLimit'
);

has 'default_limit' => (
    is => 'rw',
    reader => 'getDefaultLimit',
    writer => 'setDefaultLimit'
);

has 'use_data_column' => (
    is => 'rw',
    default => 1,
    reader => 'getUseDataColumn',
    writer => 'setUseDataColumn'
);

sub BUILD {
    my $self = shift;
    my $factTableFactory = new Koha::Reporting::Table::Fact::Factory;
    if($factTableFactory){
        $self->setFactTableFactory($factTableFactory);
    }
    my $objectFactory = new Koha::Reporting::Table::ObjectFactory;
    if($objectFactory){
        $self->setObjectFactory($objectFactory);
    }
}

sub initFactTable{
    my $self = shift;
    my $name = $_[0];
    if($self->getFactTableFactory()){
        my $factTable = $self->getFactTableFactory()->create($name);
        if($factTable){
            $factTable->setUseSum($self->getUseSum());
            $self->setFactTable($factTable);
        }
    }
}

sub initRenderer{
    my $self = shift;
    my $rendererClass = $self->getRendererClass();
    my $renderer = $self->getObjectFactory()->createObject($rendererClass);
    if(defined $renderer){
        $self->setRenderer($renderer);
    }
}

sub load{
    my $self = shift;
    my @rows = $self->getFactTable()->load();
    return @rows;
}

sub initFromRequest{
    my $self = shift;
    my $request = $_[0];
    my $startId;
    my $endId;
    if(defined $request->{dateFilter}){
       my $dateFilter = $request->{dateFilter};
       if(defined $dateFilter->{to} && $dateFilter->{from}){
            $startId = $self->getDateId($dateFilter->{from}, '00');
            $endId = $self->getDateId($dateFilter->{to}, '23');
            if(defined $startId && $dateFilter->{useFrom} eq '1'){
                my $fromFilter = new Koha::Reporting::Report::Filter::Abstract;
                $fromFilter->setName('date_from');
                $fromFilter->setDimension('date');
                $fromFilter->setField('date_id');
                $fromFilter->setRule('gte');
                $self->filter('date', $fromFilter, $startId);
            }
            if(defined $endId && $dateFilter->{useTo} eq '1'){
                my $toFilter = new Koha::Reporting::Report::Filter::Abstract;
                $toFilter->setName('date_to');
                $toFilter->setDimension('date');
                $toFilter->setField('date_id');
                $toFilter->setRule('lte');
                $self->filter('date', $toFilter, $endId);
            }
       }
    }

    my $nullSelectColumns = {};
    my $nullSelected;
    if(defined $request->{filters}){
        my $requestFilters = $request->{filters};
        if(@$requestFilters){
            foreach my $requestFilter (@$requestFilters){
                my $addNullFilter = 0;
                if(defined $requestFilter->{name} && defined $requestFilter->{selectedValue1}){
                    my $filter = $self->getFilterByName($requestFilter->{name});
                    if($filter->getUseCustomLogic()){
                       $filter->customLogic($self, $requestFilter);
                    }
                    elsif($filter->getDimension() && $filter->getField() && $filter->getRule()){
                        my $rule;
                        my $options;
                        if(defined $requestFilter->{selectedValue1} && $requestFilter->{selectedValue1} ne ''){
                            $options = $requestFilter->{selectedValue1};
                        }
                        elsif(defined $requestFilter->{selectedOptions} && $requestFilter->{selectedOptions} ne ''){
                            my $tmpOptions = [];
                            foreach my $selectedOption (@{$requestFilter->{selectedOptions}}){
                                if(defined $selectedOption->{name}){
                                    if($selectedOption->{name} eq 'null'){
                                         $nullSelected = 1;
                                         #$nullSelectColumns->{$filter->getField()} = 1;
                                    }
                                    push $tmpOptions, $selectedOption->{name};
                                }
                            }
                            $tmpOptions = $filter->modifyOptions($tmpOptions);
                            if($tmpOptions &&  @$tmpOptions){
                                $options = $tmpOptions;
                            }
                        }
                        if($options){
                            $filter->setFromDate($startId);
                            $filter->setToDate($endId);
                            $self->filter($filter->getDimension(), $filter, $options);
                        }

                    }
                }
            }
        }
    }

    if(defined $request->{selectedOrdering}){
       my $selectedOrdering = $request->{selectedOrdering};
        if(defined $selectedOrdering->{name}){
            my $ordering = $self->getOrderingByName($selectedOrdering->{name});
            if($ordering->{dimension} && $ordering->{field}){
                my $direction = 'asc';
                if(defined $request->{selectedDirection}){
                    $direction = $request->{selectedDirection};
                }
                my $noFullSelectColumnOrder;
                if(defined $ordering->{no_full_select_column}){
                    $noFullSelectColumnOrder = $ordering->{no_full_select_column};
                }
                my $selectAliasOrder;
                if(defined $ordering->{alias}){
                    $selectAliasOrder = $ordering->{alias};
                }
                $self->orderBy($ordering->{dimension}, $ordering->{field}, $direction, $noFullSelectColumnOrder, $selectAliasOrder);
            }
        }
    }
    elsif(defined $self->{default_ordering}){
        my $defaultOrdering = $self->{default_ordering};
        if(defined $defaultOrdering){
            my $ordering = $self->getOrderingByName($defaultOrdering);
            if($ordering->{dimension} && $ordering->{field}){
                my $direction = 'asc';
                if(defined $ordering->{default_ordering}){
                    $direction = $ordering->{default_ordering};
                }
                my $noFullSelectColumnOrder;
                if(defined $ordering->{no_full_select_column}){
                    $noFullSelectColumnOrder = $ordering->{no_full_select_column};
                }
                my $selectAliasOrder;
                if(defined $ordering->{alias}){
                    $selectAliasOrder = $ordering->{alias};
                }
                $self->orderBy($ordering->{dimension}, $ordering->{field}, $direction, $noFullSelectColumnOrder, $selectAliasOrder);
            }
        }
    }

    if(defined $request->{limit} && $request->{limit} ne ''){
        $self->limit($request->{limit});
    }

    $self->initSelectFieldsBefore();
    if( @{$self->getHardCodedGroupings()} ){
        foreach my $hcGroup (@{$self->getHardCodedGroupings()}){
            my $group = $self->getGroupingByName($hcGroup);
            if($group->{dimension} && $group->{field}){
                $self->groupBy($group->{dimension}, $group->{field}, $group->{alias});
            }
        }
    }

    $self->addHardcodedFilters();

    if(defined $request->{groupings}){
        my $requestGroups = $request->{groupings};
        if(@$requestGroups){
            foreach my $requestGroup (@$requestGroups){
                if(defined $requestGroup->{name} && defined $requestGroup->{selectedValue} && $requestGroup->{selectedValue} == 1){
                    my $group = $self->getGroupingByName($requestGroup->{name}, $requestGroup->{selectedOptions});
                    if($group->{dimension} && $group->{field}){
                        my $noFullSelectColumn;
                        if(defined $group->{no_full_select_column}){
                            $noFullSelectColumn = $group->{no_full_select_column};
                        }
                        my $selectAlias;
                        if($nullSelected){
                            $selectAlias = $group->{field};
                        }
                        if(defined $group->{alias}){
                            $selectAlias = $group->{alias};
                        }
                        $self->groupBy($group->{dimension}, $group->{field}, $selectAlias, $noFullSelectColumn, $nullSelected);
                    }
                }
            }
        }
    }

}

sub getDateId{
    my $self = shift;
    my $dateString = $_[0];
    my $forceHour = $_[1];
    my ($dateid);
    if($dateString){
       my $date = Time::Piece->strptime($dateString, "%d.%m.%Y");
       if($date && defined $date->year && defined $date->mon && defined $date->mday){
           my $hour = $date->hour;
           if(defined $forceHour){
               $hour = $forceHour;
           }
           $hour = sprintf("%02d", $hour);
           $dateid = $date->year . sprintf("%02d", $date->mon) . sprintf("%02d", $date->mday) . $hour;
       }
    }
    return $dateid;
}

sub getDateValues{
    my $self = shift;
    my $dateString = $_[0];
    my ($year, $month, $day);
    if($dateString){
       my $date = Time::Piece->strptime($dateString, "%d.%m.%Y");
       if($date && defined $date->year && defined $date->mon && defined $date->mday){
           $year = $date->year;
           $month = $date->mon;
           $day = $date->mday;
       }
    }
    return ($year, $month, $day);
}

sub addGrouping{
    my $self = shift;
    my $class = $_[0];
    my $grouping = $self->getObjectFactory()->createObject($class);
    if($grouping && $grouping->getName()){
        $self->{groupingsHash}->{$grouping->getName()} = $grouping;
        push $self->{groupings}, $grouping;

        if(defined $grouping->getUseAlways()){
            push $self->{hard_coded_groupings}, $grouping->getName();
        }
    }
}

sub getGroupingByName{
    my $self = shift;
    my $name = $_[0];
    my $options = $_[1];
    my $grouping;
    if(defined $self->{groupingsHash}->{$name}){
        $grouping = $self->{groupingsHash}->{$name};
    }
    if($grouping && defined $options){
        $grouping->optionModifier($options);
    }
    return $grouping;
}

sub getOrderingByName{
    my $self = shift;
    my $name = $_[0];
    my $ordering;
    if(defined $self->{orderingsHash}->{$name}){
        $ordering = $self->{orderingsHash}->{$name};
    }
    return $ordering;
}

sub addOrdering{
    my $self = shift;
    my $name = $_[0];
    my $ordering = $_[1];
    if($name && $ordering){
        $self->{orderingsHash}->{$name} = $ordering;
        push $self->{orderings}, $ordering;
    }
}

sub addFilter{
    my $self = shift;
    my $class = $_[1];
    my $filter = $self->getObjectFactory()->createObject($class);
    if($filter && $filter->getName()){
        $self->{filtersHash}->{$filter->getName()} = $filter;
        push $self->{filters}, $filter;
    }
}

sub getNullFilter{
    my $self = shift;
    my $filter = $self->getObjectFactory()->createObject('Koha::Reporting::Report::Filter::Null');
    return $filter;
}

sub getFilterByName{
    my $self = shift;
    my $name = $_[0];
    my $filter;
    if(defined $self->{filtersHash}->{$name}){
        $filter = $self->{filtersHash}->{$name};
    }
    return $filter;
}

sub filter{
    my $self = shift;
    my ($dimensionName, $filter, $options) = @_;
    my $dimension;
    if($dimensionName && $filter && $options){
        if($dimensionName eq 'fact'){
            $self->getFactTable()->addFilter($filter, $options);
        }
        else{
            $dimension = $self->getFactTable()->getDimensionByName($dimensionName);
            if($dimension){
                $dimension->addFilter($filter, $options);
            }
        }
    }
}

sub groupBy{
    my $self = shift;
    my ($dimensionName, $fieldName, $alias, $noFullSelectColumn, $selectNull) = @_;
    my ($dimension, $groupColumn);
    if($dimensionName && $fieldName){
        if($dimensionName eq 'fact'){
            $groupColumn = $self->getFactTable()->groupBy($fieldName, $alias, $noFullSelectColumn, $selectNull);
            if($self->getRenderer()){
                $self->getRenderer()->addGroup($groupColumn);
            }
        }
        else{
            $dimension = $self->getFactTable()->getDimensionByName($dimensionName);
            if($dimension){
                $groupColumn = $dimension->groupBy($fieldName, $alias, $noFullSelectColumn, $selectNull);
                if($self->getRenderer()){
                    $self->getRenderer()->addGroup($groupColumn);
                }
            }
        }
    }
}

sub orderBy{
    my $self = shift;
    my ($dimensionName, $fieldName, $direction, $noFullSelectColumn, $selectAlias) = @_;
    my $dimension;

    if($dimensionName && $fieldName){
        if($dimensionName eq 'fact'){
            $self->getFactTable()->orderBy($fieldName, $direction, $noFullSelectColumn, $selectAlias);
        }
        else{
            $dimension = $self->getFactTable()->getDimensionByName($dimensionName);
            if($dimension){
                $dimension->orderBy($fieldName, $direction, $noFullSelectColumn, $selectAlias);
            }
        }
    }
}

sub limit{
    my $self = shift;
    my ($rowCount) = @_;
    if(looks_like_number($rowCount)){
        $self->getFactTable()->limit($rowCount);
    }
}

sub addFieldToSelect{
    my $self = shift;
    my ($dimensionName, $fieldName, $alias) = @_;
    my ($dimension, $field);
    if($dimensionName && $fieldName){
        if($dimensionName eq 'fact'){
            $self->getFactTable()->addFieldToSelect($fieldName, $alias);
            if(defined $alias){
                $field = $alias;
            }
            else{
                $field = $self->getFactTable()->getFullColumn($fieldName);
            }
            $self->getRenderer()->addColumn($field);
        }
        else{
            $dimension = $self->getFactTable()->getDimensionByName($dimensionName);
            if($dimension){
                if(defined $alias){
                    $field = $alias;
                }
                else{
                    $field = $dimension->getFullColumn($fieldName);
                }
                $dimension->addFieldToSelect($fieldName, $alias);
                $self->getRenderer()->addColumn($field);
            }
        }
    }
}

sub initSelectFieldsBefore{}

sub getReportFileName{
    my $self = shift;
    my $time = Time::Piece->new;
    my $filename = $self->getName(). '-'. $time->datetime . '.csv';
}

sub formatSumValue{
    my $self = shift;
    my $value = $_[0];
    return $value;
}

sub modifyDataRows{
    my $self = shift;
    my $dataRows = $_[0];
    return $dataRows;
}

sub addHardcodedFilters{}


1;
