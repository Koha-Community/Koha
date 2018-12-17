#!/usr/bin/perl
package Koha::Reporting::Import::Loans;

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
    $self->initFactTable('reporting_loans');
    $self->setName('loans_fact');

    $self->{column_transform_method}->{fact}->{loan_type} = \&factLoanType;
    $self->{column_transform_method}->{fact}->{loaned_amount} = \&factLoanedAmount;
    $self->{column_transform_method}->{fact}->{loan_ccode} = \&factLoanCcode;
    $self->{column_transform_method}->{item}->{datelastborrowed} = \&itemDatelastborrowed;
    #$self->setInsertOnDuplicateFact(1);
}

sub loadDatas{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $statistics;
    my @parameters;
    my $patroncategories = Koha::Reporting::Import::Abstract->getConditionValues('patronCategories');

    my $query = 'select reporting_statistics_tmp.datetime, reporting_statistics_tmp.branch, reporting_statistics_tmp.type as loan_type, ';
    $query .= 'reporting_statistics_tmp.usercode, ';
    $query .= 'reporting_statistics_tmp.borrowernumber, reporting_statistics_tmp.ccode as loan_ccode, reporting_statistics_tmp.itemnumber, ';
    $query .= 'COALESCE(items.ccode, deleteditems.ccode) as collection_code, ';
    $query .= 'COALESCE(items.itype, deleteditems.itype) as itemtype, ';
    $query .= 'COALESCE(items.location, deleteditems.location) as location, COALESCE(items.dateaccessioned, deleteditems.dateaccessioned) as acquired_year, ';
    $query .= 'COALESCE(items.biblioitemnumber, deleteditems.biblioitemnumber) as biblioitemnumber, COALESCE(items.cn_sort, deleteditems.cn_sort) as cn_sort, ';
    $query .= 'COALESCE(bibliometa.metadata, deletedbibliometa.metadata, dbibliometa.metadata, ddeletedbibliometa.metadata) as marcxml, COALESCE(items.barcode, deleteditems.barcode) as barcode, ';
    $query .= 'COALESCE(biblioitems.publicationyear, deletedbiblioitems.publicationyear, dbiblioitems.publicationyear, ddeletedbiblioitems.publicationyear) as published_year, ';
    $query .= 'borrowers.categorycode, borrowers.zipcode as postcode, borrowers.dateofbirth, borrowers.cardnumber ';
    $query .= 'from statistics as reporting_statistics_tmp ';
    $query .= 'left join items on reporting_statistics_tmp.itemnumber=items.itemnumber ';
    $query .= 'left join deleteditems on reporting_statistics_tmp.itemnumber=deleteditems.itemnumber ';

    $query .= 'left join biblioitems on items.biblioitemnumber=biblioitems.biblioitemnumber ';
    $query .= 'left join deletedbiblioitems on items.biblioitemnumber=deletedbiblioitems.biblioitemnumber ';

    $query .= 'left join biblio_metadata as bibliometa on biblioitems.biblionumber=bibliometa.biblionumber ';
    $query .= 'left join deletedbiblio_metadata as deletedbibliometa on deletedbiblioitems.biblionumber=deletedbibliometa.biblionumber ';

    $query .= 'left join biblioitems as dbiblioitems on deleteditems.biblioitemnumber=dbiblioitems.biblioitemnumber ';
    $query .= 'left join deletedbiblioitems as ddeletedbiblioitems on deleteditems.biblioitemnumber=ddeletedbiblioitems.biblioitemnumber ';

    $query .= 'left join biblio_metadata as dbibliometa on dbiblioitems.biblionumber=dbibliometa.biblionumber ';
    $query .= 'left join deletedbiblio_metadata as ddeletedbibliometa on ddeletedbiblioitems.biblionumber=ddeletedbibliometa.biblionumber ';

    $query .= 'left join borrowers on reporting_statistics_tmp.borrowernumber = borrowers.borrowernumber ';
    $query .= "where reporting_statistics_tmp.usercode in ".$patroncategories." and other != 'KONVERSIO' and type in ('issue', 'renew') ";
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
    my $patroncategories = Koha::Reporting::Import::Abstract->getConditionValues('patronCategories');
    my $query = "select MAX(datetime) from statistics where usercode in ".$patroncategories." and other != 'KONVERSIO' and type in ('issue', 'renew') order by datetime";
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
        if($data->{loan_type} eq 'issue'){
            $type = 'Issue';
        }
        elsif($data->{loan_type} eq 'renew'){
            $type = 'Renew';
        }
    }
    return $type;
}

sub factLoanCcode{
    my $self = shift;
    my $data = $_[0];
    my $fact = $_[1];

    my $ccode;
    if(defined $data->{loan_ccode}){
       $ccode = $data->{loan_ccode}
    }
    else{
       $ccode = '';
    }
    return $ccode;
}

sub factLoanedAmount{
    my $self = shift;
    my $data = $_[0];
    my $fact = $_[1];
    my $type;
    return 1;
}

sub itemDatelastborrowed{
    my $self = shift;
    my $data = $_[0];
    my $result;
    if(defined $data->{datetime}){
        $result = $data->{datetime};
    }
    return $result;
}

sub extraInserts{
    my $self = shift;
    my $lastInsertedFactId = $_[0];
    my $previousInsertedFactId = $self->getLastInsertedFactId();
    my $dbh = C4::Context->dbh;
    my @parameters = ($lastInsertedFactId);

    my $query = "insert into reporting_borrowers_fact (date_id, borrower_id, location_id, activity_type, amount) select date_id, borrower_id, location_id, '1' as activity_type, SUM(loaned_amount) as amount from reporting_loans_fact ";
       $query .= "where reporting_loans_fact.primary_key <= ? ";
    if($previousInsertedFactId){
       $query .= "and reporting_loans_fact.primary_key > ? ";
       push @parameters, $previousInsertedFactId;
    }
       $query .= 'group by date_id, borrower_id';

    my $stmnt = $dbh->prepare($query);
    $stmnt->execute(@parameters) or die($DBI::errstr);

 #   $self->updateItems();
}



sub updateItems{
    my $self = shift;
    my $lastInsertedFactId = $_[0];
    my $previousInsertedFactId = $self->getLastInsertedFactId();
    my $dbh = C4::Context->dbh;
    my @parameters;

    my $query = "insert into reporting_update_items (itemnumber) select distinct items.itemnumber from reporting_loans_fact ";
       $query .= "join reporting_item_dim as items on reporting_loans_fact.item_id = items.item_id ";
    if($lastInsertedFactId){
       push  @parameters, $lastInsertedFactId;
       $query .= "where reporting_loans_fact.primary_key <= ? ";
    }
    if($previousInsertedFactId){
       $query .= "and reporting_loans_fact.primary_key > ? ";
       push @parameters, $previousInsertedFactId;
    }

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
    my $patroncategories = Koha::Reporting::Import::Abstract->getConditionValues('patronCategories');
    my $query = "select datetime from statistics ";
    $query .= "where  usercode in ".$patroncategories." and other != 'KONVERSIO' and type in ('issue', 'renew') ";
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
    my $patroncategories = Koha::Reporting::Import::Abstract->getConditionValues('patronCategories');
    my $dbh = C4::Context->dbh;
    my $query = "select count(1) as row_count from statistics where datetime = '$idAtLimit' and usercode in ".$patroncategories." and other != 'KONVERSIO' and type in ('issue', 'renew')";
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
    my $patroncategories = Koha::Reporting::Import::Abstract->getConditionValues('patronCategories');
    push @parameters, $lastSelectedId;

    my $query = "select datetime from statistics where datetime > ? and usercode in ".$patroncategories." and other != 'KONVERSIO' and type in ('issue', 'renew')";
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
