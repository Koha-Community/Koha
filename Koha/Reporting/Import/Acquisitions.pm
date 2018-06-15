#!/usr/bin/perl
package Koha::Reporting::Import::Acquisitions;

use Modern::Perl;
use Moose;
use Data::Dumper;
use POSIX qw(strftime floor);
use Time::Piece;
use Date::Parse;
use utf8;

extends 'Koha::Reporting::Import::Abstract';

sub BUILD {
    my $self = shift;
    $self->initFactTable('reporting_acquisition');
    $self->setName('acquisitions_fact');

    $self->{column_filters}->{fact}->{is_first} = 1;
    $self->{column_filters}->{item}->{datelastborrowed} = 1;
    $self->{column_transform_method}->{fact}->{quantity} = \&factQuantity;
}

sub loadDatas{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $statistics;
    my @parameters;

    my $itemtypes = Koha::Reporting::Import::Abstract->getConditionValues('itemTypeToStatisticalCategory');
    my $notforloan = Koha::Reporting::Import::Abstract->getConditionValues('notForLoanStatuses');

    my $query = 'select aqorders.entrydate as datetime, aqorders.unitprice as amount, aqorders_items.itemnumber, ';
    $query .= 'allitems.homebranch as branch, allitems.location, ';
    $query .= 'allitems.dateaccessioned as acquired_year, allitems.biblioitemnumber, allitems.ccode as collection_code, ';
    $query .= 'allitems.itype as itemtype, allbmeta.metadata as marcxml, allbitems.publicationyear as published_year ';
    $query .= 'from aqorders ';
    $query .= 'inner join aqorders_items on aqorders.ordernumber = aqorders_items.ordernumber ';
    $query .= 'inner join items ';
    $query .= 'as allitems on aqorders_items.itemnumber=allitems.itemnumber and allitems.itype in '.$itemtypes.' and allitems.notforloan not in '.$notforloan.' ';
    $query .= 'inner join biblioitems as allbitems on allitems.biblioitemnumber=allbitems.biblioitemnumber ';
    $query .= 'inner join biblio_metadata as allbmeta on allbitems.biblionumber=allbmeta.biblionumber ';
    my ($where, $parameters) = $self->getWhere();
    push @parameters, @$parameters;

    my $query2 = 'UNION ALL select aqorders.entrydate as datetime, aqorders.unitprice as amount, aqorders_items.itemnumber, ';
    $query2 .= 'allitems.homebranch as branch, allitems.location, ';
    $query2 .= 'allitems.dateaccessioned as acquired_year, allitems.biblioitemnumber, allitems.ccode as collection_code, ';
    $query2 .= 'allitems.itype as itemtype, allbmeta.metadata as marcxml, allbitems.publicationyear as published_year ';
    $query2 .= 'from aqorders ';
    $query2 .= 'inner join aqorders_items on aqorders.ordernumber = aqorders_items.ordernumber ';
    $query2 .= 'inner join deleteditems ';
    $query2 .= 'as allitems on aqorders_items.itemnumber=allitems.itemnumber and allitems.itype in '.$itemtypes.' and allitems.notforloan not in '.$notforloan.' ';
    $query2 .= 'inner join biblioitems as allbitems on allitems.biblioitemnumber=allbitems.biblioitemnumber ';
    $query2 .= 'inner join biblio_metadata as allbmeta on allbitems.biblionumber=allbmeta.biblionumber ';
    my ($where2, $parameters2) = $self->getWhere();
    push @parameters, @$parameters2;

    my $query3 = 'UNION ALL select aqorders.entrydate as datetime, aqorders.unitprice as amount, aqorders_items.itemnumber, ';
    $query3 .= 'allitems.homebranch as branch, allitems.location, ';
    $query3 .= 'allitems.dateaccessioned as acquired_year, allitems.biblioitemnumber, allitems.ccode as collection_code, ';
    $query3 .= 'allitems.itype as itemtype, allbmeta.metadata as marcxml, allbitems.publicationyear as published_year ';
    $query3 .= 'from aqorders ';
    $query3 .= 'inner join aqorders_items on aqorders.ordernumber = aqorders_items.ordernumber ';
    $query3 .= 'inner join items ';
    $query3 .= 'as allitems on aqorders_items.itemnumber=allitems.itemnumber and allitems.itype in '.$itemtypes.' and allitems.notforloan not in '.$notforloan.' ';
    $query3 .= 'inner join deletedbiblioitems as allbitems on allitems.biblioitemnumber=allbitems.biblioitemnumber ';
    $query3 .= 'inner join deletedbiblio_metadata as allbmeta on allbitems.biblionumber=allbmeta.biblionumber ';
    my ($where3, $parameters3) = $self->getWhere();
    push @parameters, @$parameters3;

    my $query4 = 'UNION ALL select aqorders.entrydate as datetime, aqorders.unitprice as amount, aqorders_items.itemnumber, ';
    $query4 .= 'allitems.homebranch as branch, allitems.location, ';
    $query4 .= 'allitems.dateaccessioned as acquired_year, allitems.biblioitemnumber, allitems.ccode as collection_code, ';
    $query4 .= 'allitems.itype as itemtype, allbmeta.metadata as marcxml, allbitems.publicationyear as published_year ';
    $query4 .= 'from aqorders ';
    $query4 .= 'inner join aqorders_items on aqorders.ordernumber = aqorders_items.ordernumber ';
    $query4 .= "inner join deleteditems ";
    $query4 .= 'as allitems on aqorders_items.itemnumber=allitems.itemnumber and allitems.itype in '.$itemtypes.' and allitems.notforloan not in '.$notforloan.' ';
    $query4 .= 'inner join deletedbiblioitems as allbitems on allitems.biblioitemnumber=allbitems.biblioitemnumber ';
    $query4 .= 'inner join deletedbiblio_metadata as allbmeta on allbitems.biblionumber=allbmeta.biblionumber ';
    my ($where4, $parameters4) = $self->getWhere();
    push @parameters, @$parameters4;

    $query = $query . $where . $query2 . $where2 . $query3 . $where3 . $query4 . $where4;
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
        $statistics = $stmnt->fetchall_arrayref({});
        if(defined @$statistics[-1]){
            my $lastRow =  @$statistics[-1];
            if(defined $lastRow->{itemnumber}){
                $self->updateLastSelected($lastRow->{itemnumber});
            }
        }
    }
   # die Dumper $statistics;
    return $statistics;
}


sub getWhere{
    my $self = shift;
    my @parameters;
    my $where = "where aqorders.orderstatus != 'cancelled' and aqorders_items.itemnumber is not null ";
    if($self->getLastSelectedId()){
        $where .= $self->getWhereLogic($where);
        $where .= " aqorders_items.itemnumber > ? ";
        push @parameters, $self->getLastSelectedId();
    }
    if($self->getLastAllowedId()){
        $where .= $self->getWhereLogic($where);
        $where .= " aqorders_items.itemnumber <= ? ";
        push @parameters, $self->getLastAllowedId();
    }
    return ($where, \@parameters );
}

sub loadLastAllowedId{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $query = "select MAX(itemnumber) from aqorders_items order by itemnumber";
    my $stmnt = $dbh->prepare($query);
    $stmnt->execute() or die($DBI::errstr);

    my $lastId;
    if($stmnt->rows == 1){
        $lastId = $stmnt->fetch()->[0];
        $self->setLastAllowedId($lastId);
    }
}

sub factQuantity{
    return 1;
}

1;
