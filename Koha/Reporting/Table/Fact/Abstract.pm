#!/usr/bin/perl
package Koha::Reporting::Table::Fact::Abstract;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Table::Abstract';

has 'data_column' => (
    is => 'rw',
    reader => 'getDataColumn',
    writer => 'setDataColumn'
);

has 'data_column_table' => (
    is => 'rw',
    default => 'fact',
    reader => 'getDataColumnTable',
    writer => 'setDataColumnTable'
);

has 'count_column' => (
    is => 'rw',
    reader => 'getCountColumn',
    writer => 'setCountColumn'
);

has 'use_sum' => (
    is => 'rw',
    default => 1,
    reader => 'getUseSum',
    writer => 'setUseSum'
);

has 'use_count' => (
    is => 'rw',
    default => 0,
    reader => 'getUseCount',
    writer => 'setUseCount'
);

has 'use_data_column' => (
    is => 'rw',
    default => 1,
    reader => 'getUseDataColumn',
    writer => 'setUseDataColumn'
);

has 'use_rollup' => (
    is => 'rw',
    default => 0,
    reader => 'getUseRollup',
    writer => 'setUseRollup'
);

has 'use_distinct' => (
    is => 'rw',
    default => 0,
    reader => 'getUseDistinct',
    writer => 'setUseDistinct'
);

has 'use_decimal_truncate' => (
    is => 'rw',
    default => 0,
    reader => 'getUseDecimalTruncate',
    writer => 'setUseDecimalTruncate'
);

has 'use_replace_comma' => (
    is => 'rw',
    default => 0,
    reader => 'getUseReplaceComma',
    writer => 'setUseReplaceComma'
);

has 'dimensions' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} },
    reader => 'getDimensions',
    writer => 'setDimensions'
);

has 'tmp_import_rows' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    reader => 'getTmpImportRows',
    writer => 'setTmpImportRows'
);

has 'dimension_factory' => (
    is => 'rw',
    reader => 'getDimensionFactory',
    writer => 'setDimensionFactory'
);

has 'dimension_primary_keys' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} },
    reader => 'getDimensionPrimaryKeys',
    writer => 'setDimensionPrimaryKeys'
);

sub BUILD {
    my $self = shift;
    my $dimensionFactory = new Koha::Reporting::Table::ObjectFactory;
    $self->setDimensionFactory($dimensionFactory);
}

sub initDefaultImportColumns{
    my $self = shift;
    my $allColumns = $self->getColumns();
    my $dimensions = $self->getDimensions();
    my %dimensionPrimaryIds;
    foreach my $dimensionName (keys %$dimensions){
        my $dimension = $dimensions->{$dimensionName};
        $dimensionPrimaryIds{$dimension->getPrimaryId()} = 1;
    }
    $self->setDimensionPrimaryKeys(\%dimensionPrimaryIds);

    foreach my $column (@$allColumns){
        if($column ne $self->getPrimaryId() && !defined $dimensionPrimaryIds{$column}){
            $self->addImportColumn($column);
        }
    }
}

sub getDimensionByName{
    my $self = shift;
    my $name = $_[0];
    my $dimension = 0;
    if($name && defined $self->{dimensions}->{$name}){
        $dimension = $self->{dimensions}->{$name};
    }
    return $dimension;
}

sub getDimensionsByPrimaryKey{
    my $self = shift;
    my $dimensions = $self->getDimensions();
    my $result = {};
    foreach my $dimensionName (keys %$dimensions) {
        my $dimension = $dimensions->{$dimensionName};
        $result->{$dimension->getPrimaryId()} = $dimension;
    }
    return $result;
}

sub addDimension{
    my $self = shift;
    my $name = $_[0];
    my $className = $_[1];
    my $object = 0;
    my $dimensionFactory = $self->getDimensionFactory();
    if($name && $dimensionFactory){
        $object = $dimensionFactory->createObject($className);
    }
    if($object){
        $object->initColumns();
        $object->initDefaultImportColumns();
        $self->{dimensions}->{$name} = $object;
    }
}

sub load{
    my $self = shift;
    my @rows;
    my ($select, $bind) = $self->buildSelect();
    my $dbh = C4::Context->dbh;
    if($select ne ''){
        my $stmnt = $dbh->prepare($select);
        $stmnt->execute();
        if ($stmnt->rows >= 1){
            while ( my $row = $stmnt->fetchrow_hashref ) {
                push @rows, $row;
            }
        }
    }
    return @rows;
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
                $where = $dimension->getFilterFragment($where);
                $groupBy = $dimension->getGroupByFragment($groupBy);
                $having = $dimension->getHavingFragment($having);
                $orderBy = $dimension->getOrderByFragment($orderBy);
                $select = $dimension->getSelectFragment($select);
            }
        }

        $where = $self->getFilterFragment($where);
        $groupBy = $self->getGroupByFragment($groupBy). ' ';
        $having = $self->getHavingFragment($having);
        $orderBy = $self->getOrderByFragment($orderBy). ' ';
        if($groupBy ne '' && $self->getUseRollup() != 0){
            $groupBy .= ' WITH ROLLUP ';
        }
        $select = $self->getSelectFragment($select);
        if($self->getUseCount() && $self->getCountColumn()){
            $select .= $self->getCountSelectFragment($self->getUseDistinct()) . ' ';
        }
        elsif($self->getUseSum()){
            $select .= $self->getSumSelectFragment() . ' ';
        }
        elsif($self->getUseDataColumn()){
            $select .= $self->getDataColumn() . ' ';
        }

        if($self->getLimit()){
            $limit = ' LIMIT ' . $self->getLimit();
        }
    }

    if($where ne ''){
        $where = 'WHERE ' . $where;
    }
    if($having ne ''){
        $having = ' HAVING ' . $having;
    }

    $select = $select . $from . $where .$groupBy. $having .$orderBy . $limit;
   # die Dumper $select;
    return ($select, \@bind);
}

sub getSumSelectFragment{
    my $self = shift;
    my $select =  '*';
    my $column;

    if($self->getDataColumn()){
        $column = $self->getFullColumn($self->getDataColumn());
    }

    if($column){
        $select = 'SUM(' . $column . ') ';
        if($self->getUseDecimalTruncate()){
            $select = 'TRUNCATE(' . $select .',2)';
        }
        $select .= 'AS ' . $self->getDataColumn();
    }

    return $select;
}

sub getSumColumn{
    my $self = shift;
    my $column;
    if($self->getUseDecimalTruncate()){
        $column = 'TRUNCATE(' . $self->getFullColumn($self->getDataColumn()) .',2)';
    }
    else{
        $column = $self->getFullColumn($self->getDataColumn());
    }
    return $column;
}

sub getCountSelectFragment{
    my $self = shift;
    my $distinct = $_[0];
    my $select = '';
    my $countColumn;
    my $dimensions = $self->getDimensions();
    if($self->getDataColumnTable() eq 'fact'){
        $countColumn = $self->getFullColumn($self->getCountColumn());
    }
    elsif(defined $dimensions->{$self->getDataColumnTable()}){
       my $dimension = $dimensions->{$self->getDataColumnTable()};
       $countColumn = $dimension->getFullColumn($self->getCountColumn());
    }

    if($countColumn){
        $select .= 'COUNT( ';
        if($distinct == 1){
            $select .= 'DISTINCT ';
        }
        $select .= $countColumn. ' ) AS ' . $self->getDataColumn();
    }
    return $select;
}

sub addImportColumn{
    my $self = shift;
    my $column = $_[0];
    my $ref;
    if($column){
        push $self->{import_columns}, $column;
    }
}

sub addTmpImportRow{
    my $self = shift;
    my $row = $_[0];
    if(%$row){
        push $self->{tmp_import_rows}, $row;
    }
}

sub addImportRow{
    my $self = shift;
    my $row = $_[0];
    if(@$row){
        push $self->{import_rows}, $row;
    }
}

sub validateTmpFactRow{
    my $self = shift;
    my %row = %{$_[0]};
    my $result = 0;
    my $length = 0;

    if( exists $row{row_data} ){
        my $rowData = $row{row_data};
        $length = $length + @$rowData;
        delete $row{row_data};
    }

    $length = $length + keys %row;

    my $importColumns = $self->getImportColumns();
    my $dimensionPrimaryKeys = $self->getDimensionPrimaryKeys();
    my $importLength = @$importColumns + keys %$dimensionPrimaryKeys;

    if($importLength == $length && $length > 0){
        $result = 1;
    }
    else{
        print Dumper "invalid tmp fact";
        print  Dumper %row;
    }

    return $result;
}

sub validateImportRow{
    my $self = shift;
    my $row = $_[0];
    my $result = 0;;

    my $importColumns = $self->getImportColumns();
    if(@$importColumns == @$row){
        $result = 1;
    }
    return $result;
}

sub createImportInsert{
    my $self = shift;
    my $duplicate = $_[0];
    my $columns = $self->getImportColumns();
    my $rows = $self->getImportRows();
    my $tableName = $self->getTableName();
    my $dbh = C4::Context->dbh;
    my $insert = '';
    if($tableName && @$columns && @$rows){
        $insert .= 'INSERT INTO ' . $tableName . ' ( ';
        my $updateColumns = '';
        my $lastColumn = @$columns[-1];
        foreach my $column (@$columns){
            if($column){
                $insert .= $column;
                if($self->getDataColumn() eq $column){
                    $updateColumns .= $column .'=VALUES('.$column.') + '. $column;
                }
                else{
                    $updateColumns .= $column .'=VALUES('.$column.')';
                }
                if($column ne $lastColumn){
                    $insert .= ', ';
                    $updateColumns .= ', ';
                }
            }
        }
        $insert .= ' ) VALUES ';
        my $lastRowKey = $#$rows;
        my $i = -1;
        foreach my $row (@$rows){
            $i++;
            my $lastValueKey = $#$row;
            if(@$row){
                $insert .= '(';
                my $j = -1;
                foreach my $value (@$row){
                    $j++;
                    $insert .= $dbh->quote($value);
                    if($lastValueKey != $j){
                        $insert .= ', ';
                    }
                }
                $insert .= ')';
                if($lastRowKey != $i){
                    $insert .= ', ';
                }
            }
        }
        if($duplicate){
            $insert .= ' ON DUPLICATE KEY UPDATE ' . $updateColumns;
        }

    }
    return $insert;
}

1;
