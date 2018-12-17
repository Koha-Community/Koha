#!/usr/bin/perl
package Koha::Reporting::Import::Reserves;

use Modern::Perl;
use Moose;
use Data::Dumper;
use POSIX qw(strftime floor);
use Time::Piece;
use utf8;

extends 'Koha::Reporting::Import::Abstract';

sub BUILD {
    my $self = shift;
    $self->initFactTable('reporting_reserves');
    $self->setName('reserves_fact');

    $self->{column_transform_method}->{fact}->{reserve_status} = \&factReserveStatus;
    $self->{column_filters}->{item}->{datelastborrowed} = 1;
}

sub loadDatas{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $statistics;
    my @parameters;

    my $query .= 'select reserves.reservedate as datetime, reserves.reserve_id as reserve_id, "1" as amount, reserves.cancellationdate, reserves.suspend, reserves.found, reserves.pickupexpired, "0" as is_old, ';
    $query .= 'reserves.branchcode as branch, reserves.borrowernumber, COALESCE(reserves.itemnumber, items_biblio.itemnumber, deleteditems.itemnumber, deleted_items_biblio.itemnumber) as itemnumber, ';
    $query .= "COALESCE(items.location, items_biblio.location, deleteditems.location, deleted_items_biblio.location) as location, ";
    $query .= "COALESCE(items.dateaccessioned, items_biblio.dateaccessioned, deleteditems.dateaccessioned, deleted_items_biblio.dateaccessioned) as acquired_year, ";
    $query .= "COALESCE(items.itype, items_biblio.itype, deleteditems.itype, deleted_items_biblio.itype) as itemtype, ";
    $query .= "COALESCE(items.ccode, items_biblio.ccode, deleteditems.ccode, deleted_items_biblio.ccode) as collection_code, ";
    $query .= "COALESCE(items.cn_sort, items_biblio.cn_sort, deleteditems.cn_sort, deleted_items_biblio.cn_sort) as cn_sort, ";
    $query .= "COALESCE(items.barcode, items_biblio.barcode, deleteditems.barcode, deleted_items_biblio.barcode) as barcode, ";
    $query .= 'biblio_metadata.metadata as marcxml, biblioitems.publicationyear as published_year, biblioitems.biblioitemnumber, ';
    $query .= 'borrowers.categorycode, borrowers.zipcode as postcode, borrowers.dateofbirth, ';
    $query .= 'borrowers.cardnumber ';

    $query .= 'from reserves ';
    $query .= 'inner join biblio on reserves.biblionumber = biblio.biblionumber ';
    $query .= 'inner join biblioitems on biblioitems.biblionumber = biblio.biblionumber ';
    $query .= 'inner join biblio_metadata on biblio_metadata.biblionumber = biblioitems.biblionumber ';
    $query .= 'inner join borrowers on borrowers.borrowernumber = reserves.borrowernumber ';
    $query .= 'left join items as items_biblio on items_biblio.biblioitemnumber = biblioitems.biblioitemnumber and reserves.itemnumber is null ';
    $query .= 'left join items on reserves.itemnumber = items.itemnumber and reserves.itemnumber is not null ';
    $query .= 'left join deleteditems as deleted_items_biblio on deleted_items_biblio.biblioitemnumber = biblioitems.biblioitemnumber ';
    $query .= 'and reserves.itemnumber is null and items_biblio.biblioitemnumber is null and items.biblioitemnumber is null ';
    $query .= 'left join deleteditems as deleteditems on reserves.itemnumber = deleteditems.itemnumber and reserves.itemnumber is not null ';
    $query .= 'and reserves.itemnumber is null and items_biblio.biblioitemnumber is null and items.biblioitemnumber is null ';
    $query .= 'where (items_biblio.itemnumber is not null or items.itemnumber is not null ';
    $query .= 'or deleted_items_biblio.itemnumber is not null or deleteditems.itemnumber is not null) ';

    if($self->getLastSelectedId()){
        $query .= "and reserves.reserve_id > ? ";
        push @parameters, $self->getLastSelectedId();
    }
    if($self->getLastAllowedId()){
        $query .= "and reserves.reserve_id <= ? ";
        push @parameters, $self->getLastAllowedId();
    }

    $query .= 'group by reserve_id ';
    $query .= 'order by reserve_id ';

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

#die Dumper $stmnt->rows;
    if ($stmnt->rows >= 1){
        $statistics = $stmnt->fetchall_arrayref({});
        if(defined @$statistics[-1]){
            my $lastRow =  @$statistics[-1];
            if(defined $lastRow->{reserve_id}){
                $self->updateLastSelected($lastRow->{reserve_id});
            }
        }
    }
    #die Dumper $statistics;
    return $statistics;
}

sub loadLastAllowedId{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $query = "SELECT MAX(reserve_id) as res_id from reserves";
    my $stmnt = $dbh->prepare($query);
    $stmnt->execute() or die($DBI::errstr);

    my $lastId;
    if($stmnt->rows == 1){
        $lastId = $stmnt->fetch()->[0];
        $self->setLastAllowedId($lastId);
    }
}

sub factReserveStatus{
    my $self = shift;
    my $data = $_[0];
    my $dimension = $_[1];
    my $result;
    #'reserves.suspend, reserves.found, reserves.pickupexpired, "0" as is_old'
    if(defined $data->{is_old} && $data->{is_old} eq '0'){
        if(defined $data->{found} && !defined $data->{pickupexpired} && $data->{found} eq 'F'){
            $result = 'Noudettavissa';
        }
        elsif(defined $data->{suspend} && $data->{suspend} eq '0'){
            $result = 'Voimassa';
        }
        elsif(defined $data->{suspend} && $data->{suspend} eq '1'){
            $result = 'Keskeytetty';
        }
    }
    elsif(defined $data->{is_old} && $data->{is_old} eq '1'){
        if(!defined $data->{found} && !defined $data->{pickupexpired} && defined $data->{cancellationdate}){
            $result = 'Peruttu';
        }
        elsif(defined $data->{pickupexpired}){
            $result = 'Noutamaton';
        }
    }

    if(!defined $result){
        $result = 'Muu';
    }

    return $result;
}

1;
