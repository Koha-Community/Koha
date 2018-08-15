#!/usr/bin/perl
package Koha::Reporting::Report::Renderer::Csv;

use Modern::Perl;
use Moose;
use Data::Dumper;
use Text::CSV;
use utf8;

has 'name' => (
    is => 'rw',
    reader => 'getName',
    writer => 'setName'
);

has 'groups' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    reader => 'getGroups',
    writer => 'setGroups'
);

has 'columns' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    reader => 'getColumns',
    writer => 'setColumns'
);

has 'rows' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    reader => 'getRows',
    writer => 'setRows'
);

has 'groups_values' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} },
    reader => 'getGroupsValues',
    writer => 'setGroupsValues'
);

has 'row_counters' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} },
    reader => 'getRowCounters',
    writer => 'setRowCounters'
);

has 'column_counters_hash' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} },
    reader => 'getColumnCountersHash',
    writer => 'setColumnCountersHash'
);

has 'column_counters' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    reader => 'getColumnCounters',
    writer => 'setColumnCounters'
);

has 'current_row' => (
    is => 'rw',
    reader => 'getCurrentRow',
    writer => 'setCurrentRow'
);

has 'current_column' => (
    isa => 'ArrayRef',
    default => sub { [] },
    reader => 'getCurrentColumn',
    writer => 'setCurrentColumn'
);

has 'fact_table' => (
    is => 'rw',
    reader => 'getFactTable',
    writer => 'setFactTable'
);

has 'report' => (
    is => 'rw',
    reader => 'getReport',
    writer => 'setReport'
);

sub render {
    my $self = shift;
    my $dataRows = $_[0];
    my $fact = $_[1];
    $self->setFactTable($fact);
    my ($headerRows, $rows) = $self->generateRows($dataRows, $fact->getDataColumn());
    #print Dumper $headerRows;
}

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
    if(@$dataRows){
        my $lastGroup = @{$groups}[-1];
        foreach my $row (@$dataRows) {
            if(@$groups){
                my $lastKey;
                my $dataHash = $datas;
                foreach my $group (@$groups){
                    if(!defined $row->{$group}){
                       last;
                    }
                    push @{$groupValues->{$group}}, $row->{$group};
                    my $key = $row->{$group};
                    if($group ne $lastGroup){
                        if(!defined $dataHash->{$key}){
                            $dataHash->{$key} = {};
                        }
                        $dataHash = $dataHash->{$key};
                    }
                    else{
                        $lastKey = $key;
                    }
                }
                if(!defined $lastKey){
                   $lastKey = 'rollup';
                }
                if(defined $row->{$dataColumn}){
                    $dataHash->{$lastKey} = $row->{$dataColumn};
                }
            }
        }

        foreach my $group (keys %{$groupValues}){
             my $groupArray = $groupValues->{$group};
             $groupArray = $self->uniq($groupArray);
	     my @tmp = $self->nsort(@$groupArray); 
             $groupValues->{$group} = \@tmp;
        }

        $self->setGroupsValues($groupValues);
        my @allGroups = @{$groups};
        if(defined $allGroups[0]){
            my $firstGroup =  shift @allGroups;
            my $firstGroupValues = $self->getGroupsValues()->{$firstGroup};
            $headerRows = $self->getHeaderRows(\@allGroups);
            if(!@$headerRows){
                $headerRows = $self->getOneHeaderRow($firstGroup);
            }

            foreach my $value (@$firstGroupValues){
                my $tmpDataHash;
                my $dataRow = [];
                $self->{current_column} = [];
                push @{$dataRow}, $value; #Header value
                if(defined $datas->{$value}){
                    $tmpDataHash = $datas->{$value};
                }
                if(@allGroups){
                    $self->setCurrentRow($value);
                    $dataRow = $self->getDataRow(\@allGroups, $dataRow, $tmpDataHash, $self->{current_column});
                    my $currentRow = $self->getCurrentRow();
                    if(defined $self->{row_counters}->{$currentRow}){
                        my $rowCounterValue = $self->getReport()->formatSumValue($self->{row_counters}->{$currentRow});
                        push @{$dataRow}, $rowCounterValue;
                    }
                }
                elsif(ref $tmpDataHash ne 'HASH'){
                    $self->setCurrentRow($value);
                    $self->addToRowCounter($tmpDataHash);
                    $tmpDataHash = $self->getReport()->formatSumValue($tmpDataHash);
                    push @{$dataRow}, $tmpDataHash;
                }

                if($dataRow){
                    push @{$rowDatas}, $dataRow;
                }
            }
        }
        else{
            $headerRows = $self->getOneHeaderRow();
            my $columns = $self->getColumns();
            foreach my $row (@$dataRows){
                my $rowData = [];
                foreach my $column (@$columns){
                    if(defined $row->{$column}){
                        my $colValue = $row->{$column};
                        if($column eq $dataColumn){
                            $colValue = $self->getReport()->formatSumValue($colValue);
                        }
                        push @{$rowData}, $colValue;
                    }
                }
                push @{$rowDatas}, $rowData;
            }
        }
    }
    if(@{$self->{column_counters}}){
        my $sumRow = ['sum'];
        push @{$sumRow}, $self->getColumnCounterSumValues();
        if(%{$self->{row_counters}}){
            push @{$sumRow}, $self->getRowCounterSum();
            if(@$headerRows){
                for my $index (0 .. $#$headerRows) {
                    my $headerRow = @$headerRows[$index];
                    my $heading = '';
                    if($index == 0){
                        $heading = 'sum';
                    }
                    push @{$headerRow}, $heading;
                }
            }
        }
        push @{$rowDatas}, $sumRow;
    }
    else{
        my $sumRow = ['sum'];
        if(%{$self->{row_counters}}){
            push @{$sumRow}, $self->getRowCounterSum();
            push @{$rowDatas}, $sumRow;
        }
    }
    return ($headerRows, $rowDatas);
}

sub getHeaderRows{
    my $self = shift;
    my @groups = reverse @{$_[0]};
    my $headerRows = [];
    my $groupLengths = [];
    my $groupValuesLengths = [];
    foreach my $group (@groups){
        my $row = [];
        my $groupsValues = $self->getGroupsValues()->{$group};
        my $groupValuesLength = @$groupsValues;
        foreach my $value (@$groupsValues){
            push @{$row}, $value;
            push @{$row}, $self->addEmptyColumns($groupValuesLengths);
        }
        push @{$headerRows}, $row;
        push @{$groupValuesLengths}, $groupValuesLength;
    }
    $headerRows = $self->multiplyHeaderRows($headerRows);
    my @headerRows = reverse @$headerRows;
    return \@headerRows;
}

sub getOneHeaderRow{
    my $self = shift;
    my $firstGroup = $_[0];
    my $headerRows = [];
    my $columns = $self->getColumns();
    my $headerRow = [];
    if(defined $firstGroup){
        push @{$headerRow}, $firstGroup;
    }
    foreach my $column (@$columns){
        push @{$headerRow}, $column;
    }

    if(@$headerRow){
        push @{$headerRows}, $headerRow;
    }
    return $headerRows;
}

sub multiplyHeaderRows{
    my $self = shift;
    my $headerRows = $_[0];
    my $newHeader = [];
    if(@$headerRows >= 1){
        my $lastHeader = @$headerRows[-1];
        my $lastLength = @$lastHeader;
        if($lastLength){
            foreach my $row (@$headerRows){
                my $rowLength = @$row;
                my $tmpRow = [''];
                if($rowLength){
                    my $multiplier = $lastLength / $rowLength;
                    while($multiplier > 0){
                        push @{$tmpRow}, @$row;
                        $multiplier--;
                    }
                    push @{$newHeader}, $tmpRow;
                }
            }
        }
    }
    return $newHeader;
}

sub addEmptyColumns{
    my $self = shift;
    my $lengths = $_[0];
    my @columns;
    if(@$lengths){
       my $lenSum = 1;
       foreach my $length (@$lengths){
          $lenSum = $lenSum * $length;
       }
       $lenSum = $lenSum - 1;
       my $i = $lenSum;
       while ($i > 0){
           push @columns, '';
           $i = $i -1;
       }
    }
    return @columns;
}

sub getDataRow{
    my $self = shift;
    my @groups = @{$_[0]};
    my $row = $_[1];
    my $dataHash = $_[2];
    my @origCurrentColumn = @{$_[3]};
    my $currentGroup;

    if(defined $groups[0]){
        $currentGroup = shift @groups;
    }

    my $isLastGroup = 0;
    if(!@groups){
        $isLastGroup = 1;
    }
    my $dataValues = $self->getGroupsValues()->{$currentGroup};
    foreach my $value (@$dataValues){
         my @currentColumn = @origCurrentColumn;
         if($isLastGroup){
             my $val;
             if(defined $dataHash->{$value}){
                 $val = $dataHash->{$value};
             }
             else{
                $val = '0';
             }
             $self->addToColumnCounter(\@currentColumn, $value, $val);
             $self->addToRowCounter($val);
             $val = $self->getReport()->formatSumValue($val);
             push @{$row}, $val;
         }
         else{
             push @currentColumn, $value;
             my $tmpDataHash;
             if(defined $dataHash->{$value}){
                 $tmpDataHash = $dataHash->{$value};
             }
             $row = $self->getDataRow(\@groups, $row, $tmpDataHash, \@currentColumn);
         }
    }
    return $row;
}

sub addToRowCounter{
    my $self = shift;
    my $value = $_[0];
    my $currentRow = $self->getCurrentRow();
    if(!defined $self->{row_counters}->{$currentRow}){
        $self->{row_counters}->{$currentRow} = 0;
    }
    $self->{row_counters}->{$currentRow} += $value;
}

sub addToColumnCounter{
    my $self = shift;
    my ($currentColumn, $lastColumnPart, $value) = @_;
    my $counters = $self->getColumnCountersHash();
    my $hash = $counters;
    foreach my $part (@$currentColumn){
       if(!defined $hash->{$part}){
           $hash->{$part} = {};
       }
       $hash = $hash->{$part};
    }

    if(!defined $hash->{$lastColumnPart}){
        my $index = 0;
        if(defined $self->{column_counters} && @{$self->{column_counters}}){
            $index = @{$self->{column_counters}};
        }
        $hash->{$lastColumnPart} = @{$self->{column_counters}};
        push @{$self->{column_counters}}, $value;
    }
    else{
        $self->{column_counters}[$hash->{$lastColumnPart}] += $value;
    }
}

sub getRowCounterSum{
    my $self = shift;
    my $counters = $self->getRowCounters();
    my $sum = 0;
    foreach my $counter (keys %{$counters}){
        my $value = $counters->{$counter};
        $sum += $value;
    }
    $sum = $self->getReport()->formatSumValue($sum);
    return $sum;
}

sub getColumnCounterSumValues{
    my $self = shift;
    my $counterValues = [];
    foreach my $counterValue (@{$self->{column_counters}}){
        push @{$counterValues}, $self->getReport()->formatSumValue($counterValue);
    }
    return @$counterValues;
}

sub generateCsv{
    my $self = shift;
    my $header = $_[0];
    my $rows = $_[1];
    my $data;
    open my $fh, '>', \$data;
    my $csv = Text::CSV->new ( {binary => 1, eol => $/, sep_char => ';' } );
    foreach my $hederRow (@$header){
        $csv->print($fh, $hederRow);
    }
    foreach my $row (@$rows){
        $csv->print($fh, $row);
    }
    return $data;
}

sub addGroup{
    my $self = shift;
    my $groupField = $_[0];

   if($groupField){
       push @{$self->{groups}}, $groupField;
   }
}

sub addColumn{
    my $self = shift;
    my $column = $_[0];

   if($column){
       push @{$self->{columns}}, $column;
   }
}

sub uniq {
    my $self = shift;
    my $arrayRef = $_[0];
    my $valueHash = {};
    my $result = [];
    foreach my $value (@$arrayRef){
        if(!defined $valueHash->{$value}){
            $valueHash->{$value} = $value;
            push @{$result}, $value;
        }
    }
    return $result;
};

sub nsort {
    my $self = shift;
    my($cmp, $lc);
    return @_ if @_ < 2;

    my($x, $i);
    map
        $_->[0],

    sort {
        $x = 0;
        $i = 1;

        while($i < @$a and $i < @$b) {
            last if ($x = ($a->[$i] cmp $b->[$i])); # lexicographic
            ++$i;

            last if ($x = ($a->[$i] <=> $b->[$i])); # numeric
            ++$i;
        }

        $x || (@$a <=> @$b) || ($a->[0] cmp $b->[0]);
    }

    map {
        my @bit = ($x = defined($_) ? $_ : '');

        if($x =~ m/^[+-]?(?=\d|\.\d)\d*(?:\.\d*)?(?:[Ee](?:[+-]?\d+))?\z/s) {
            push @bit, '', $x;
        } else {
            while(length $x) {
                push @bit, ($x =~ s/^(\D+)//s) ? lc($1) : '';
                push @bit, ($x =~ s/^(\d+)//s) ?    $1  :  0;
            }
        }
        \@bit;
    }
    @_;
}



1;
