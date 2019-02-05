#!/usr/bin/perl
package Koha::Reporting::Import::Returns;

use Modern::Perl;
use Moose;
use Data::Dumper;
use POSIX qw(strftime floor);
use Time::Piece;
use utf8;

extends 'Koha::Reporting::Import::Abstract';

has 'limit' => (
    is => 'rw',
    writer => 'setLimit'
);

sub BUILD {
    my $self = shift;
    $self->initFactTable('reporting_returns');
    $self->setName('returns_fact');

    $self->{column_transform_method}->{fact}->{loan_type} = \&factLoanType;
    $self->{column_transform_method}->{fact}->{amount} = \&factAmount;
    $self->{column_filters}->{item}->{datelastborrowed} = 1;

  #  $self->setInsertOnDuplicateFact(1);
}

sub loadDatas{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $statistics;
    my @parameters;
    my $query = 'select reporting_statistics_tmp.datetime, reporting_statistics_tmp.branch, reporting_statistics_tmp.type as loan_type, ';
    $query .= 'reporting_statistics_tmp.usercode, ';
    $query .= 'reporting_statistics_tmp.borrowernumber, reporting_statistics_tmp.ccode as collection_code, reporting_statistics_tmp.itemnumber, ';
    $query .= 'COALESCE(items.itype, deleteditems.itype) as itemtype, ';
    $query .= 'COALESCE(items.location, deleteditems.location) as location, COALESCE(items.datereceived, deleteditems.datereceived) as acquired_year, ';
    $query .= 'COALESCE(items.biblioitemnumber, deleteditems.biblioitemnumber) as biblioitemnumber, COALESCE(items.cn_sort, deleteditems.cn_sort) as cn_sort, ';
    $query .= 'COALESCE(bibliometa.metadata, deletedbibliometa.metadata, dbibliometa.metadata, ddeletedbibliometa.metadata) as marcxml, COALESCE(items.barcode, deleteditems.barcode) as barcode, ';
    $query .= 'COALESCE(biblioitems.publicationyear, deletedbiblioitems.publicationyear, dbiblioitems.publicationyear, ddeletedbiblioitems.publicationyear) as published_year, ';
    $query .= 'borrowers.categorycode, borrowers.zipcode as postcode, borrowers.dateofbirth, borrowers.cardnumber ';
    $query .= 'from statistics as reporting_statistics_tmp ';

    $query .= 'left join items on reporting_statistics_tmp.itemnumber=items.itemnumber ';
    $query .= 'left join deleteditems on reporting_statistics_tmp.itemnumber=deleteditems.itemnumber ';

    $query .= 'left join biblioitems on items.biblioitemnumber=biblioitems.biblioitemnumber ';
    $query .= 'left join deletedbiblioitems on items.biblioitemnumber=deletedbiblioitems.biblioitemnumber ';

    $query .= 'left join biblio_metadata as bibliometa on items.biblionumber=bibliometa.biblionumber ';
    $query .= 'left join deletedbiblio_metadata as deletedbibliometa on items.biblionumber=deletedbibliometa.biblionumber ';

    $query .= 'left join biblioitems as dbiblioitems on deleteditems.biblioitemnumber=dbiblioitems.biblioitemnumber ';
    $query .= 'left join deletedbiblioitems as ddeletedbiblioitems on deleteditems.biblioitemnumber=ddeletedbiblioitems.biblioitemnumber ';

    $query .= 'left join biblio_metadata as dbibliometa on deleteditems.biblionumber=dbibliometa.biblionumber ';
    $query .= 'left join deletedbiblio_metadata as ddeletedbibliometa on deleteditems.biblionumber=ddeletedbibliometa.biblionumber ';

    $query .= 'left join borrowers on reporting_statistics_tmp.borrowernumber = borrowers.borrowernumber ';
    $query .= "where other != 'KONVERSIO' and type in ('return') and reporting_statistics_tmp.borrowernumber is not NULL ";
    my ($where, $parameters) = $self->getWhere();
    push @parameters, @$parameters;

    $query .= $where;
    $query .= 'order by datetime ';

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
            my $firstRow = @$statistics[0];
            my $lastRow =  @$statistics[-1];
            if(defined $lastRow->{datetime}){
                $self->updateLastSelected($lastRow->{datetime});
            }

            print Dumper 'first date:';
            print Dumper $firstRow->{datetime};
            print Dumper 'last date:';
            print Dumper $lastRow->{datetime};
        }
    }
    return $statistics;
}

sub loadLastAllowedId{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $query = "select MAX(datetime) from statistics where other != 'KONVERSIO' and type in ('return') and borrowernumber is not NULL";
    my $stmnt = $dbh->prepare($query);
    $stmnt->execute() or die($DBI::errstr);

    my $lastId;
    if($stmnt->rows == 1){
        $lastId = $stmnt->fetch()->[0];
        $self->setLastAllowedId($lastId);
    }
}

sub getWhere{
    my $self = shift;
    my @parameters;

    my $where = '';
    if($self->getLastSelectedId()){
        $where .= "and reporting_statistics_tmp.datetime > ? ";
        push @parameters, $self->getLastSelectedId();
    }
    if($self->getLastAllowedId()){
        $where .= "and reporting_statistics_tmp.datetime <= ? ";
        push @parameters, $self->getLastAllowedId();
    }
    return ($where, \@parameters );
}

sub factLoanType{
    my $self = shift;
    my $data = $_[0];
    my $fact = $_[1];
    my $type;

    if(defined $data->{loan_type}){
        if($data->{loan_type} eq 'return'){
            $type = 'Return';
        }
    }
    return $type;
}

sub factAmount{
    my $self = shift;
    my $data = $_[0];
    my $fact = $_[1];
    my $type;
    return 1;
}

sub extraInserts{
    my $self = shift;
#    my $lastInsertedFactId = $_[0];
#    my $previousInsertedFactId = $self->getLastInsertedFactId();
#    my $dbh = C4::Context->dbh;
#    my @parameters = ($lastInsertedFactId);

#    my $query = "insert into reporting_borrowers_fact (date_id, borrower_id, location_id, activity_type, amount) select date_id, borrower_id, location_id, '1' as activity_type, SUM(loaned_amount) as amount from reporting_loans_fact ";
#       $query .= "where reporting_loans_fact.primary_key <= ? ";
#    if($previousInsertedFactId){
#       $query .= "and reporting_loans_fact.primary_key > ? ";
#       push @parameters, $previousInsertedFactId;
#    }
#       $query .= 'group by date_id, borrower_id';

#    my $stmnt = $dbh->prepare($query);
#    $stmnt->execute(@parameters) or die($DBI::errstr);

 #   $self->updateItems();
}



sub updateItems{
 #   my $self = shift;
 #   my $lastInsertedFactId = $_[0];
 #   my $previousInsertedFactId = $self->getLastInsertedFactId();
 #   my $dbh = C4::Context->dbh;
 #   my @parameters;

 #   my $query = "insert into reporting_update_items (itemnumber) select distinct items.itemnumber from reporting_loans_fact ";
 #      $query .= "join reporting_item_dim as items on reporting_loans_fact.item_id = items.item_id ";
 #   if($lastInsertedFactId){
 #      push  @parameters, $lastInsertedFactId;
 #      $query .= "where reporting_loans_fact.primary_key <= ? ";
 #   }
 #   if($previousInsertedFactId){
 #      $query .= "and reporting_loans_fact.primary_key > ? ";
 #      push @parameters, $previousInsertedFactId;
 #   }

#    $self->getTableAbstract()->setRetryCount(0);
#    $self->getTableAbstract()->execute($query, \@parameters, 'reporting_update_items');
}

sub getLimit{
    my $self = shift;
    my $lastSelectedId = $self->getLastSelectedId();
    my $defaultLimit = $self->{limit};
    my $limitOffset = 0;
    my $idAtLimit = $self->getRowIdAtLimit($defaultLimit);
    if(defined $idAtLimit){
        my $limitRowCount = $self->getLimitRowCount($idAtLimit);
        $limitOffset = $self->getLimitOffset($defaultLimit, $limitRowCount, $idAtLimit);
    }
    return $defaultLimit + $limitOffset;
}

sub getRowIdAtLimit{
    my $self = shift;
    my $defaultLimit = $_[0];
    my @parameters;
    my $dbh = C4::Context->dbh;
    my $lastId;
    my $lastSelectedId = $self->getLastSelectedId();
    my $limitStart = $defaultLimit -1;
    my $query = "select datetime from statistics ";
    $query .= "where other != 'KONVERSIO' and type in ('return') and borrowernumber is not NULL ";
    if(defined $lastSelectedId){
        push @parameters, $lastSelectedId;
        $query .= "and datetime > ? ";
    }
    $query .= "order by datetime LIMIT 1 OFFSET $limitStart";
    my $stmnt = $dbh->prepare($query);
    if(@parameters){
       $stmnt->execute(@parameters) or die($DBI::errstr);
    }
    else{
        $stmnt->execute() or die($DBI::errstr);
    }
    $stmnt->execute(@parameters) or die($DBI::errstr);
    if($stmnt->rows == 1){
        $lastId = $stmnt->fetch()->[0];
    }
    return $lastId;
}

sub getLimitRowCount{
    my $self = shift;
    my $idAtLimit = $_[0];
    my @parameters;
    my $rowCount = 0;
    my $dbh = C4::Context->dbh;
    my $query = "select count(1) as row_count from statistics where datetime = '$idAtLimit' and other != 'KONVERSIO' and type in ('return') and borrowernumber is not NULL";
    my $stmnt = $dbh->prepare($query);
    $stmnt->execute(@parameters) or die($DBI::errstr);
    if($stmnt->rows == 1){
        $rowCount = $stmnt->fetch()->[0];
    }
    return $rowCount;
}

sub getLimitOffset{
    my $self = shift;
    my $defaultLimit = $_[0];
    my $idRowCount = $_[1];
    my $idAtLimit = $_[2];
    my @parameters;
    my $dbh = C4::Context->dbh;
    my $idRows;
    my $offset = 0;
    my $lastSelectedId = $self->getLastSelectedId();
    my $limitStart = $defaultLimit -1;
    push @parameters, $lastSelectedId;

    my $query = "select datetime from statistics where datetime > ? and other != 'KONVERSIO' and type in ('return') and borrowernumber is not NULL ";
    $query .= "order by datetime LIMIT $idRowCount OFFSET $limitStart";
    my $stmnt = $dbh->prepare($query);
    $stmnt->execute(@parameters) or die($DBI::errstr);
    if($stmnt->rows > 0){
        $idRows = $stmnt->fetchall_arrayref({});
        foreach my $idRow (@$idRows){
            if(defined $idRow->{datetime} && $idRow->{datetime} eq $idAtLimit){
                $offset++;
            }
        }
    }
    if($offset > 0){
       $offset--;
    }
    return $offset;
}






1;
