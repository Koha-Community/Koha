#!/usr/bin/perl
package Koha::Reporting::Import::DeletedItems;

use Modern::Perl;
use Moose;
use Data::Dumper;
use POSIX qw(strftime floor);
use Time::Piece;
use utf8;

extends 'Koha::Reporting::Import::Abstract';

sub BUILD {
    my $self = shift;
    $self->initFactTable('reporting_deleteditems');
    $self->setName('deleteditems_fact');
    $self->{column_transform_method}->{fact}->{amount} = \&factAmount;
    $self->{column_filters}->{item}->{datelastborrowed} = 1;
}

sub loadDatas{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $statistics;
    my @parameters;

    print Dumper "SELECTING";

    my $itemtypes = Koha::Reporting::Import::Abstract->getConditionValues('itemTypeToStatisticalCategory');

    my $query = "select deleteditems.itemnumber, deleteditems.location, deleteditems.barcode, deleteditems.homebranch as branch, deleteditems.datereceived as acquired_year, deleteditems.itype as itemtype, COALESCE(deleteditems.timestamp) as datetime, deleteditems.biblioitemnumber, deleteditems.cn_sort, ";
    $query .= 'COALESCE(bibliometa.metadata, deletedbibliometa.metadata) as marcxml, COALESCE(biblioitems.publicationyear, deletedbiblioitems.publicationyear) as published_year ';
    $query .= 'from deleteditems ';
    $query .= 'left join biblioitems on deleteditems.biblioitemnumber = biblioitems.biblioitemnumber ';
    $query .= 'left join biblio_metadata as bibliometa on biblioitems.biblionumber = bibliometa.biblionumber ';
    $query .= 'left join deletedbiblioitems on deleteditems.biblioitemnumber = deletedbiblioitems.biblioitemnumber ';
    $query .= 'left join deletedbiblio_metadata as deletedbibliometa on deletedbiblioitems.biblionumber = deletedbibliometa.biblionumber ';

    my $whereDeleted = "where deleteditems.itype in ".$itemtypes;
    if($self->getLastSelectedId()){
        $whereDeleted .= $self->getWhereLogic($whereDeleted);
        $whereDeleted .= " deleteditems.itemnumber > ? ";
        push @parameters, $self->getLastSelectedId();
    }
    if($self->getLastAllowedId()){
        $whereDeleted .= $self->getWhereLogic($whereDeleted);
        $whereDeleted .= " deleteditems.itemnumber <= ? ";
        push @parameters, $self->getLastAllowedId();
    }

    if($self->getLimit() && $self->getLastSelectedId()){
#        my $limitsDel = $self->getLastSelectedId() + $self->getLimit();
#        $whereDeleted .= $self->getWhereLogic($whereDeleted );
#        $whereDeleted .= " deleteditems.itemnumber <= ? ";
#        push @parameters, $limitsDel;
    }

    $query .= $whereDeleted;
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
    my $query = "select MAX(itemnumber) from deleteditems order by itemnumber";
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

1;
