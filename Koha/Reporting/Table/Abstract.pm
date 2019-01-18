#!/usr/bin/perl
package Koha::Reporting::Table::Abstract;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;
use Scalar::Util qw(looks_like_number);
use Try::Tiny;

has 'primary_id' => (
    is => 'rw',
    reader => 'getPrimaryId',
    writer => 'setPrimaryId'
);

has 'name' => (
    is => 'rw',
    reader => 'getName',
    writer => 'setName'
);

has 'table_name' => (
    is => 'rw',
    reader => 'getTableName',
    writer => 'setTableName'
);

has 'columns' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    reader => 'getColumns',
    writer => 'setColumns'
);

has 'select_columns' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    reader => 'getSelectColumns',
    writer => 'setSelectColumns'
);

has 'select_columns_hash' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} },
    reader => 'getSelectColumnsHash',
    writer => 'setSelectColumnsHash'
);

has 'select_columns_alias_hash' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} },
    reader => 'getSelectColumnsAliasHash',
    writer => 'setSelectColumnsAliasHash'
);

has 'filters' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    reader => 'getFilters',
    writer => 'setFilters'
);

has 'groups' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    reader => 'getGroups',
    writer => 'setGroups'
);

has 'orderings' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    reader => 'getOrderings',
    writer => 'setOrderings'
);

has 'import_rows' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    reader => 'getImportRows',
    writer => 'setImportRows'
);

has 'limit' => (
    is => 'rw',
    reader => 'getLimit',
    writer => 'setLimit'
);

has 'import_rows_by_business_key' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} },
    reader => 'getImportRowsByBusinessKey',
    writer => 'setImportRowsByBusinessKey'
);

has 'import_columns' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    reader => 'getImportColumns',
    writer => 'setImportColumns'
);

has 'import_row_bussines_key_no' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} },
    reader => 'getImportRowBusinessKeyNo',
    writer => 'setImportRowBusinessKeyNo'
);

has 'column_value_validate_method' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} },
    reader => 'getColumnValueValidateMethods',
    writer => 'setColumnValueValidateMethods'
);

has 'is_needed' => (
    is => 'rw',
    default => 0,
    reader => 'getIsNeeded',
    writer => 'setIsNeeded'
);

has 'retry_count' => (
    is => 'rw',
    default => 0,
    reader => 'getRetryCount',
    writer => 'setRetryCount'
);

has 'row_count' => (
    is => 'rw',
    default => 0,
    reader => 'getRowCount',
    writer => 'setRowCount'
);

has 'extra_joins' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    reader => 'getExtraJoins',
    writer => 'setExtraJoins'
);

sub BUILD {
   my $self = shift;
}

sub addFilter{
    my $self = shift;
    my ($filter, $options) = @_;
    my $conditionString = '';
    my $value = 0;
    my $dbh = C4::Context->dbh;

    if(defined $filter && defined $options){
        $conditionString = $filter->getConditionString($self, $options);
        if(defined $conditionString && $conditionString ne ''){
            push $self->{filters}, {'logic' => $filter->getLogic(), 'condition' => $conditionString, 'type' => $filter->getFilterType(), 'name' => $filter->getName()};
            $self->setIsNeeded(1);
        }
    }
}

sub addFieldToSelect{
    my $self = shift;
    my $field = $_[0];
    my $alias = $_[1];
    my $noFullField = $_[2];
    my $selectNulls = $_[3];
    my $skipNullIF = $_[4];
    my $selectField;

    if( defined $noFullField){
        $selectField = $field;
    }
    else{
        $selectField = $self->getFullColumn($field);
    }

    if(defined $selectNulls){
        $selectField = $self->getIfNullColumn($selectField);
    }
    elsif(!$skipNullIF){
        if(!defined $alias){
            $alias = $selectField;
        }
        $selectField = "IF(". $selectField. " = 'null', NULL, ". $selectField .")";
    }

    if(! defined $self->{select_columns_hash}->{$selectField} ){
        $self->{select_columns_hash}->{$selectField} = $field;
        push $self->{select_columns}, $selectField;
        if(defined $alias && $alias ne ''){
            $self->{select_columns_alias_hash}->{$selectField} = $alias;
        }
        $self->setIsNeeded(1);
    }
}

sub groupBy{
    my $self = shift;
    my $field = $_[0];
    my $alias = $_[1];
    my $noFullField = $_[2];
    my $selectNulls = $_[3];
    my ($groupField, $usedGroupSelectColumn);

    if( defined $noFullField){
        $groupField = $field;
    }
    else{
        $groupField = $self->getFullColumn($field);
    }

    if(defined $groupField){
        $self->addFieldToSelect($field, $alias, $noFullField, $selectNulls);
        push $self->{groups}, $groupField;
        $self->setIsNeeded(1);
    }

    if(defined $alias && $alias ne ''){
        $usedGroupSelectColumn = $alias;
    }
    else{
        $usedGroupSelectColumn = $groupField;
    }
    return $usedGroupSelectColumn;
}

sub orderBy{
    my $self = shift;
    my ($field, $direcition, $noFullSelectColumn, $selectAlias ) = @_;
    my $orderField;
    if(defined $direcition && $direcition eq 'desc'){
        $direcition = 'DESC';
    }
    else{
        $direcition = 'ASC';
    }

    if(defined $selectAlias){
        $orderField = $selectAlias;
    }
    elsif(defined $noFullSelectColumn){
        $orderField = $field;
    }
    else{
        $orderField = $self->getFullColumn($field);
    }

    if($field){
        push $self->{orderings}, {'field' => $orderField, 'direction' => $direcition };
        $self->setIsNeeded(1);
    }
}

sub limit {
    my $self = shift;
    my $rowCount = $_[0];
    if(looks_like_number($rowCount)){
        $self->setLimit($rowCount);
    }

}

sub addExtraJoin{
    my $self = shift;
    my $join = $_[0];
    if(defined $join){
        push $self->{extra_joins}, $join;
    }
}

sub getFullColumn{
    my $self = shift;
    my $columnName = $_[0];
    if($columnName && $self->getTableName()){
       $columnName = $self->getTableName() . '.' . $columnName;
    }
    return $columnName;
}

sub getIfNullColumn{
    my $self = shift;
    my $columnName = $_[0];
    if(defined $columnName && $columnName ne ''){
        $columnName = 'IFNULL(' . $columnName . ", 'Ei määritetty')";
    }
    return $columnName;
}

sub getGroupByFragment{
    my $self = shift;
    my ($groupBy) = @_;
    if($self->getGroups()){
        my $groups = $self->getGroups();
        foreach my $group (@$groups){
            if($group){
                if($groupBy eq ''){
                    $groupBy = 'GROUP BY '
                }
                else{
                    $groupBy .= ', '
                }
                $groupBy .= $group;
            }
        }
    }
    return $groupBy;
}

sub getFilterFragment{
    my $self = shift;
    my $where = $_[0];
    if($self->getFilters()){
        my $filters = $self->getFilters();
        foreach my $filter (@$filters){
            if($filter->{type} eq 'filter'){
                if($where eq ''){
                    $where = '';
                }
                elsif($filter->{logic} eq 'AND'){
                    $where .= 'AND '
                }
                elsif($filter->{logic} eq 'OR'){
                    $where = '('. $where .') OR '
                }
                $where .= $filter->{condition} . ' ';
            }
        }
    }
    return $where;
}

sub getHavingFragment{
    my $self = shift;
    my $having = $_[0];
    if($self->getFilters()){
        my $filters = $self->getFilters();
        foreach my $filter (@$filters){
            if($filter->{type} eq 'having'){
                if($having eq ''){
                    $having = '';
                }
                elsif($filter->{logic} eq 'AND'){
                    $having .= 'AND '
                }
                elsif($filter->{logic} eq 'OR'){
                    $having = '('. $having .') OR '
                }
                $having .= $filter->{condition} . ' ';
            }
        }
    }
    return $having;
}

sub getOrderByFragment{
    my $self = shift;
    my $orderBy = $_[0];

    if($self->getOrderings()){
        my $orderings = $self->getOrderings();
        foreach my $ordering (@$orderings){
            my $field;
            my $direction;
            if(defined $ordering->{field} && defined $ordering->{direction}){
                $field = $ordering->{field};
                $direction = $ordering->{direction};
            }
            else{
                next;
            }

            if(defined $orderBy && $orderBy eq ''){
                $orderBy .= 'ORDER BY ' . $field . ' '.$direction.' ';
            }
            elsif(defined $orderBy){
                $orderBy .= ', ' . $field. ' ' . $direction;
            }
        }
    }
    return $orderBy;
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
    }
    return $select;
}

sub getColumnAlias{
    my $self = shift;
    my $selectColumn = $_[0];
    my $alias;
    if(defined $self->{select_columns_alias_hash}->{$selectColumn}){
        $alias = $self->{select_columns_alias_hash}->{$selectColumn};
    }
    else{
        $alias = $selectColumn;
    }
    return $alias;
}

sub initColumns{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $table = $self->getTableName();
    if($table){
         my $columns = $dbh->selectcol_arrayref( qq{describe $table} );
         if($columns){
             $self->setColumns($columns);
         }
    }
}

sub addImportRow{}

sub getRowBusinessKey{
    my $self = shift;
    my $row = $_[0];
    my $keys = {};
    my $businessKeyNumbers = $self->getImportRowBusinessKeyNo();
    foreach my $column (keys $businessKeyNumbers){
        if($row && defined $businessKeyNumbers->{$column} && defined $$row[$businessKeyNumbers->{$column}]){
           $keys->{$column} = $$row[$businessKeyNumbers->{$column}];
        }
    }
    return $keys;
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
                $updateColumns .= $column .'=VALUES('.$column.')';
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
    #print Dumper $insert;
    return $insert;
}

sub addImportColumn{
    my $self = shift;
    my $column = $_[0];
    my $ref;
    if($column){
        push $self->{import_columns}, $column;
        my $businessKeys = $self->getBusinessKey();
        foreach my $businessKey (@$businessKeys){
           if($businessKey eq $column){
                $ref = $self->{import_columns};
                $self->addImportRowBusinessKeyNo($column, $#$ref);
            }
        }
    }
}

sub addImportRowBusinessKeyNo{
    my $self = shift;
    my $column = $_[0];
    my $number = $_[1];
    if($column && defined $number){
        $self->{import_row_bussines_key_no}->{$column} = $number;
    }
}

sub validateColumnValue{
    my $self = shift;
    my ($column, $value) = @_;
    my $result = 0;
    if(defined $self->{column_value_validate_method}->{$column}){
        $result = $self->{column_value_validate_method}->{$column}->($self, $value);
    }
    elsif($column && defined $value){
        $result = 1;
    }

    return $result;
}

sub execute{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my ($query, $parameters ,$tableName) = @_;
#    print Dumper $query;
    my $stmnt = $dbh->prepare($query);
    my $result;
    if($stmnt){
        if(ref $parameters eq 'ARRAY' && @{$parameters}){
            $result = $stmnt->execute(@{$parameters});
        }
        else{
            $result = $stmnt->execute();
        }
        my $rowCount = $self->getInsertedRowCount($result);
        my $tableRowCount = $self->getTableRowCount($tableName);
        print Dumper "Rows inserted: " . $rowCount;
        print Dumper "All rows: ". $tableRowCount;

        my $realInserted = $tableRowCount - $self->getRowCount();

        $self->setRowCount($tableRowCount);

        print Dumper "Real inserted: ". $realInserted;

        if($rowCount <= 0 || !$result){
            if($self->getRetryCount() <= 5){
                #print $stmnt->{Statement};
                print Dumper "Retrying previous query";
                $self->setRetryCount($self->getRetryCount() + 1);
                C4::Context->dbh->disconnect();
                C4::Context->dbh({'new' => 1});
                $self->changeWaitTimeOut();
                sleep(5);
                print Dumper "Starting re-insert";
                $self->execute($query, $parameters, $tableName);
            }
            else{
                print Dumper "ERROR:";
                if(defined $DBI::errst){
                    die($DBI::errst);
                }
            }
        }
    }
    return $stmnt;
}

sub getInsertedRowCount{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $result = 0;
    my $execResult = $_[0];
    my $stmnt = $dbh->prepare('SELECT ROW_COUNT() as count');
    $stmnt->execute();

    my $row = $stmnt->fetchrow_hashref();
    if(defined $row->{count}){
        $result = $row->{count};
    }

    if($result == 0 && $execResult > 0){
	$result = $execResult;
    }

    return $result;
}

sub getTableRowCount{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $result = 0;
    my $tableName = $_[0];
    if(!defined $tableName){
        $tableName = $self->getTableName();
    }

    my $stmnt = $dbh->prepare('SELECT count(1) as count from '. $tableName);
    $stmnt->execute();

    my $row = $stmnt->fetchrow_hashref();
    if(defined $row->{count}){
        $result = $row->{count};
    }
    return $result;
}


sub changeWaitTimeOut{
    my $dbh = C4::Context->dbh;
    my $stmnt = $dbh->prepare('set wait_timeout = 49');
    $stmnt->execute();
}

1;
