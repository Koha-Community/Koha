#!/usr/bin/perl
package Koha::Reporting::Import::UpdateAcquisitionsIsFirst;

use Modern::Perl;
use Moose;
use Try::Tiny;
use Data::Dumper;
use C4::Context;
use Koha::Reporting::Table::Fact::Factory;
use Koha::Reporting::Table::Abstract;
use POSIX qw(strftime floor);
use Time::Piece;
use Date::Parse;

use utf8;

has 'branch_groups' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} },
    reader => 'getBranchGroups',
    writer => 'setBranchGroups'
);

has 'bunches' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    reader => 'getBunches',
    writer => 'setBunches'
);

has 'current_bunch' => (
    is => 'rw',
    default => 0,
    reader => 'getCurrentBunch',
    writer => 'setCurrentBunch'
);

has 'bunch_row_count' => (
    is => 'rw',
    default => 0,
    reader => 'getBunchRowCount',
    writer => 'setBunchRowCount'
);

has 'bunch_limit' => (
    is => 'rw',
    default => 0,
    reader => 'getBunchLimit',
    writer => 'setBunchLimit'
);

has 'date_delta' => (
    is => 'rw',
    default => '3600',
    reader => 'getDateDelta',
    writer => 'setDateDelta'
);

sub update{
    my $self = shift;
    $self->setBunchLimit(10000);
    my $dbh = C4::Context->dbh;
    $self->truncateTable();
    $self->loadBranchGroups();
    my $datas = $self->getData();
    my $isFirstByBranchGroup = {};
    my $datesByBiblioitem = {};
    my $compareDate;
    my $columns = ['item_id', 'branch_group'];
    my $bunches = [];

    foreach my $data (@$datas){
        my $biblioitemnumber = $data->{biblioitemnumber};
        my $branch = $data->{branch};
        my $date = $data->{timestamp};
        $date = $self->getUnixDate($date);
        my $itemId = $data->{item_id};
        my $branchGroups = $self->getBranchGroupsWithBranch($branch);
        if(@$branchGroups && defined $date){
            foreach my $branchGroup (@$branchGroups){
                undef $compareDate;
                if(defined $datesByBiblioitem->{$biblioitemnumber}->{$branchGroup}->{'date'}){
                    $compareDate = $datesByBiblioitem->{$biblioitemnumber}->{$branchGroup}->{'date'};
                }
                else{
                    $compareDate = $date;
                    if(!defined $datesByBiblioitem->{$biblioitemnumber}){
                        $datesByBiblioitem->{$biblioitemnumber} = {};
                    }

                    if(!defined $datesByBiblioitem->{$biblioitemnumber}->{$branchGroup}){
                        $datesByBiblioitem->{$biblioitemnumber}->{$branchGroup} = {};
                    }
                    $datesByBiblioitem->{$biblioitemnumber}->{$branchGroup}->{'item_ids'} = [];
                    $datesByBiblioitem->{$biblioitemnumber}->{$branchGroup}->{'date'} = $date;
                }

                if($self->compareDates($date, $compareDate)){
                    push $datesByBiblioitem->{$biblioitemnumber}->{$branchGroup}->{'item_ids'}, $itemId;
                }
                else{
                    $datesByBiblioitem->{$biblioitemnumber}->{$branchGroup}->{'date'} = $date;
                    $datesByBiblioitem->{$biblioitemnumber}->{$branchGroup}->{'item_ids'} = [];
                    push $datesByBiblioitem->{$biblioitemnumber}->{$branchGroup}->{'item_ids'}, $itemId;
                }
            }
        }
    }

    foreach my $bibNumber (keys $datesByBiblioitem){
       my $firstDatas = $datesByBiblioitem->{$bibNumber};
       foreach my $branchGroup (keys $firstDatas){
            if(defined $firstDatas->{$branchGroup}->{item_ids}){
                my $itemIds = $firstDatas->{$branchGroup}->{item_ids};
                if(defined $branchGroup && @$itemIds){
                    foreach my $itemId(@$itemIds){
                        if(defined $itemId && defined $branchGroup){
                            my $row = [];
                            push $row, $itemId;
                            push $row, $branchGroup;
                            $self->addRowToBunch($row);
                        }
                    }
                }
            }
        }
    }
    $bunches = $self->getBunches();
    if(@$bunches && @$columns){
        foreach my $rowData (@$bunches){
            if(@$rowData){
                my $insert = $self->createImportInsert($columns, $rowData, 'reporting_acquisitions_isfirst');
                my $stmnt = $dbh->prepare($insert);
                $stmnt->execute();
            }
        }
    }
}

sub getUnixDate{
    my $self = shift;
    my $date = $_[0];
    my $unixDate;
    if(defined $date){
       $unixDate = str2time($date);
    }
    return $unixDate;
}

sub compareDates{
    my $self = shift;
    my $date = $_[0];
    my $compareDate = $_[1];
    my $result = 0;

    my $delta = abs($compareDate - $date);
    if($delta <= $self->getDateDelta()){
        $result = 1;
    }
    return $result;
}

sub getData{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $query = " select reporting_acquisitions_fact.item_id, reporting_location_dim.branch, reporting_item_dim.biblioitemnumber, reporting_acquisitions_fact.date_id, ";
    $query .= "aqorders_items.timestamp ";
    $query .= "from reporting_acquisitions_fact ";
    $query .= "join reporting_item_dim on reporting_acquisitions_fact.item_id = reporting_item_dim.item_id ";
    $query .= "join reporting_location_dim on reporting_location_dim.location_id = reporting_acquisitions_fact.location_id ";
    $query .= "join aqorders_items on reporting_item_dim.itemnumber = aqorders_items.itemnumber";
    my $data = [];
    my $stmnt = $dbh->prepare($query);
    $stmnt->execute() or die($DBI::errstr);

    if($stmnt->rows > 0){
        $data = $stmnt->fetchall_arrayref({});
    }
    return $data;
}

sub loadBranchGroups{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $branchGroups = [];
    my $data = [];

    my $select = 'select branchcategories.categorycode, branchrelations.branchcode from branchcategories ';
    $select .= 'left join branchrelations on branchcategories.categorycode = branchrelations.categorycode ';
    $select .= 'order by branchcategories.categoryname';

    my $stmnt = $dbh->prepare($select);
    $stmnt->execute();

    if ($stmnt->rows >= 1){
        $data = $stmnt->fetchall_arrayref({});
        foreach my $row (@$data){
            if(defined $row->{categorycode} && defined $row->{branchcode}){
                if(!defined $self->{branch_groups}->{$row->{branchcode}}){
                    $self->{branch_groups}->{$row->{branchcode}} = [];
                }
                push $self->{branch_groups}->{$row->{branchcode}}, $row->{categorycode};
            }
        }
    }
}

sub getBranchGroupsWithBranch{
    my $self = shift;
    my $branch = $_[0];
    my $branchGroups = [];
    if(defined $branch && defined $self->{branch_groups}->{$branch}){
        $branchGroups = $self->{branch_groups}->{$branch};
    }
    return $branchGroups;
}

sub createImportInsert{
    my $self = shift;
    my $duplicate = 1;
    my $columns = $_[0];
    my $rows = $_[1];
    my $tableName = $_[2];
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
    return $insert;
}

sub truncateTable{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $query = "truncate reporting_acquisitions_isfirst";
    my $stmnt = $dbh->prepare($query);
    $stmnt->execute() or die($DBI::errstr);
}

sub addRowToBunch{
    my $self = shift;
    my $row = $_[0];

    if(@$row){
        my $currentBunch = $self->getCurrentBunch();
        my $bunches = $self->getBunches();
        my $bunchRowCount = $self->getBunchRowCount();
        if(@$bunches == 0){
            push $bunches, [];
        }

        if($bunchRowCount >= $self->getBunchLimit()){
            $currentBunch++;
            $self->setCurrentBunch($currentBunch);
            $bunchRowCount = 0;
            push $bunches, [];
        }
        if(defined @$bunches[$currentBunch]){
            push @$bunches[$currentBunch], $row;
        }
        $self->setBunches($bunches);
        $bunchRowCount++;
        $self->setBunchRowCount($bunchRowCount);
    }
}

1;
