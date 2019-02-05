#!/usr/bin/perl
package Koha::Reporting::Import::UpdateItems;

use Modern::Perl;
use Moose;
use Data::Dumper;
use POSIX qw(strftime floor);
use Time::Piece;
use utf8;

extends 'Koha::Reporting::Import::Abstract';

sub BUILD {
    my $self = shift;
    $self->initFactTable('dummy');
    $self->setName('items_update');
    $self->{column_transform_method}->{fact}->{amount} = \&factAmount;
}

sub loadDatas{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $statistics;
    my @parameters;

    print Dumper "SELECTING";

    my $query = "select items.itemnumber, items.location, items.homebranch as branch, items.datereceived as acquired_year, items.itype as itemtype, ";
    $query .=  "COALESCE(items.datereceived, '0000-00-00') as datetime, items.biblioitemnumber, items.cn_sort, '0' as is_deleted, ";
    $query .= 'biblio_metadata.metadata, biblioitems.publicationyear as published_year ';
    $query .= 'from reporting_update_items as update_items ';
    $query .= 'left join items on items.itemnumber=update_items.itemnumber ';
    $query .= 'left join biblioitems on items.biblioitemnumber=biblioitems.biblioitemnumber ';
    $query .= 'left join biblio_metadata on biblioitems.biblioitemnumber=biblio_metadata.biblionumber ';

    my $whereItems = '';
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

    if($self->getLimit() && $self->getLastSelectedId()){
        my $limits = $self->getLastSelectedId() + $self->getLimit();
        $whereItems .= $self->getWhereLogic($whereItems);
        $whereItems .= " items.itemnumber <= ? ";
        push @parameters, $limits;
    }

    $query .= $whereItems;

#    $query .= "UNION ALL select deleteditems.itemnumber, deleteditems.location, deleteditems.homebranch as branch, deleteditems.dateaccessioned as acquired_year, deleteditems.itype as itemtype, COALESCE(deleteditems.dateaccessioned, '0000-00-00') as datetime, deleteditems.biblioitemnumber, deleteditems.cn_sort, '1' as is_deleted, ";
#    $query .= 'COALESCE(biblioitems.marcxml, deletedbiblioitems.marcxml) as marcxml, COALESCE(biblioitems.publicationyear, deletedbiblioitems.publicationyear) as published_year ';
#    $query .= 'from deleteditems ';
#    $query .= 'left join biblioitems on deleteditems.biblioitemnumber = biblioitems.biblioitemnumber ';
#    $query .= 'left join deletedbiblioitems on deleteditems.biblioitemnumber = deletedbiblioitems.biblioitemnumber ';

#    my $whereDeleted = '';
#    if($self->getLastSelectedId()){
#        $whereDeleted .= $self->getWhereLogic($whereDeleted);
#        $whereDeleted .= " deleteditems.itemnumber > ? ";
#        push @parameters, $self->getLastSelectedId();
#    }
#    if($self->getLastAllowedId()){
#        $whereDeleted .= $self->getWhereLogic($whereDeleted);
#        $whereDeleted .= " deleteditems.itemnumber <= ? ";
#        push @parameters, $self->getLastAllowedId();
#    }

#    if($self->getLimit() && $self->getLastSelectedId()){
#        my $limitsDel = $self->getLastSelectedId() + $self->getLimit();
#        $whereDeleted .= $self->getWhereLogic($whereDeleted );
#        $whereDeleted .= " deleteditems.itemnumber <= ? ";
#        push @parameters, $limitsDel;
#    }

#    $query .= $whereDeleted;

    $query .= 'order by itemnumber ';

    if($self->getLimit()){
        $query .= 'limit ?';
        push @parameters, $self->getLimit();
    }
#$query .= 'limit 1';

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
    my $query = "select MAX(allitems.itemnumber) from (select MAX(itemnumber) as itemnumber from items UNION ALL select MAX(itemnumber) as itemnumber from deleteditems) as allitems";
    my $stmnt = $dbh->prepare($query);
    $stmnt->execute() or die($DBI::errstr);

    my $lastId;
    if($stmnt->rows == 1){
        $lastId = $stmnt->fetch()->[0];
        $self->setLastAllowedId($lastId);
    }
}

sub truncateUpdateTable{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $query = "truncate table reporting_update_items";
    my $stmnt = $dbh->prepare($query);
    $stmnt->execute() or die($DBI::errstr);
}

1;
