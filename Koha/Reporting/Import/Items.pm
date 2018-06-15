#!/usr/bin/perl
package Koha::Reporting::Import::Items;

use Modern::Perl;
use Moose;
use Data::Dumper;
use POSIX qw(strftime floor);
use Time::Piece;
use utf8;
use Koha::Reporting::Table::Abstract;

extends 'Koha::Reporting::Import::Abstract';

sub BUILD {
    my $self = shift;
    $self->initFactTable('reporting_items');
    $self->setName('items_fact');

#    $self->{column_filters}->{item}->{is_yle} = 1;
#    $self->{column_filters}->{item}->{published_year} = 1;
#    $self->{column_filters}->{item}->{collection_code} = 1;
#    $self->{column_filters}->{item}->{language} = 1;
#    $self->{column_filters}->{item}->{acquired_year} = 1;
#    $self->{column_filters}->{item}->{itemtype_okm} = 1;
#    $self->{column_filters}->{item}->{itemtype} = 1;

#    $self->{column_filters}->{item}->{cn_class} = 1;
#    $self->{column_filters}->{item}->{cn_class_primary} = 1;
#    $self->{column_filters}->{item}->{cn_class_1_dec} = 1;
#    $self->{column_filters}->{item}->{cn_class_2_dec} = 1;
#    $self->{column_filters}->{item}->{cn_class_3_dec} = 1;
    $self->{column_filters}->{item}->{datelastborrowed} = 1;
    $self->{column_transform_method}->{fact}->{amount} = \&factAmount;
}

sub loadDatas{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $statistics;
    my @parameters;

    print Dumper "SELECTING";

    my $itemtypes = Koha::Reporting::Import::Abstract->getConditionValues('itemTypeToStatisticalCategory');
    my $notforloan = Koha::Reporting::Import::Abstract->getConditionValues('notForLoanStatuses');

    my $query = "select items.itemnumber, items.location, items.homebranch as branch, items.dateaccessioned as acquired_year, items.itype as itemtype, items.ccode as collection_code, ";
    $query .=  "COALESCE(items.dateaccessioned, '0000-00-00') as datetime, items.biblioitemnumber, items.cn_sort, '0' as is_deleted, items.barcode, ";
    $query .= 'biblio_metadata.metadata as marcxml, biblioitems.publicationyear as published_year ';
    $query .= 'from items ';
    $query .= 'left join biblioitems on items.biblioitemnumber=biblioitems.biblioitemnumber ';
    $query .= 'left join biblio_metadata on items.biblionumber=biblio_metadata.biblionumber ';

    my $whereItems = "where items.itype in ".$itemtypes." and items.notforloan not in ".$notforloan." ";
    if($self->getLastSelectedId()){
        $whereItems .= $self->getWhereLogic($whereItems);
        $whereItems .= " items.itemnumber  > ? ";
        push @parameters, $self->getLastSelectedId();
    }
    if($self->getLastAllowedId()){
        $whereItems .= $self->getWhereLogic($whereItems);
        $whereItems .= " items.itemnumber <= ? ";
        push @parameters, $self->getLastAllowedId();
    }

#    if($self->getLimit() && $self->getLastSelectedId()){
#        my $limits = $self->getLastSelectedId() + $self->getLimit();
#        $whereItems .= $self->getWhereLogic($whereItems);
#        $whereItems .= " items.itemnumber <= ? ";
#        push @parameters, $limits;
#    }

    $query .= $whereItems;
    $query .= 'order by itemnumber ';

    if($self->getLimit()){
        $query .= 'limit ?';
        push @parameters, $self->getLimit();
    }

    my $stmnt = $dbh->prepare($query);
    if(@parameters){
        $stmnt->execute(@parameters) or die($DBI::errstr);
    }
    else{
        $stmnt->execute() or die($DBI::errstr);
    }

    if ($stmnt->rows >= 1){
        print Dumper "ROWS: " . $stmnt->rows;
        $statistics = $stmnt->fetchall_arrayref({});
        if(defined @$statistics[-1]){
            my $lastRow =  @$statistics[-1];
            if(defined $lastRow->{itemnumber}){
                $self->updateLastSelected($lastRow->{itemnumber});
            }
        }
    }
    print Dumper 'returning';
    return $statistics;
}

sub loadLastAllowedId{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $query = "select MAX(itemnumber) from items";
    my $stmnt = $dbh->prepare($query);
    $stmnt->execute() or die($DBI::errstr);

    my $lastId;
    if($stmnt->rows == 1){
        $lastId = $stmnt->fetch()->[0];
        $self->setLastAllowedId($lastId);
    }
}

sub factAmount{
    return 1;
}

sub extraInserts{
    my $self = shift;
    my $lastInsertedFactId = $_[0];
    my $previousInsertedFactId = $self->getLastInsertedFactId();
    my $dbh = C4::Context->dbh;
    my @parameters = ($lastInsertedFactId);

    my $query = "insert into reporting_update_items (itemnumber) select distinct items.itemnumber from reporting_items_fact ";
       $query .= "join reporting_item_dim as items on reporting_items_fact.item_id = items.item_id ";
       $query .= "where reporting_items_fact.primary_key <= ? ";
    if($previousInsertedFactId){
       $query .= "and reporting_items_fact.primary_key > ? ";
       push @parameters, $previousInsertedFactId;
    }

    print Dumper $lastInsertedFactId;
    print Dumper $previousInsertedFactId;

#    $self->getTableAbstract()->setRetryCount(0);
#    $self->getTableAbstract()->execute($query, \@parameters, 'reporting_update_items');
}

1;
