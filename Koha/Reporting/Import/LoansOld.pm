#!/usr/bin/perl
package Koha::Reporting::Import::Loans;

use Modern::Perl;
use Moose;
use Data::Dumper;
use POSIX qw(strftime floor);
use Time::Piece;
use utf8;

extends 'Koha::Reporting::Import::Abstract';

sub BUILD {
    my $self = shift;
    $self->initFactTable('reporting_loans');
    $self->setName('loans_fact');

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

    $self->{column_transform_method}->{fact}->{loan_type} = \&factLoanType;
    $self->{column_transform_method}->{fact}->{loaned_amount} = \&factLoanedAmount;

  #  $self->setInsertOnDuplicateFact(1);
}

sub loadDatas{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $statistics;
    my @parameters;
    my $query = 'select reporting_statistics_tmp.primary_id, reporting_statistics_tmp.datetime, reporting_statistics_tmp.branch, reporting_statistics_tmp.type as loan_type, ';
    $query .= 'reporting_statistics_tmp.usercode, reporting_statistics_tmp.itemtype, ';
    $query .= 'reporting_statistics_tmp.borrowernumber, reporting_statistics_tmp.ccode as collection_code, reporting_statistics_tmp.itemnumber, ';
    $query .= 'COALESCE(items.location, deleteditems.location) as location, COALESCE(items.dateaccessioned, deleteditems.dateaccessioned) as acquired_year, ';
    $query .= 'COALESCE(items.biblioitemnumber, deleteditems.biblioitemnumber) as biblioitemnumber, COALESCE(items.cn_sort, deleteditems.cn_sort) as cn_sort, COALESCE(biblioitems.marcxml, deletedbiblioitems.marcxml) as marcxml, COALESCE(items.barcode, deleteditems.barcode) as barcode, ';
    $query .= 'biblioitems.publicationyear as published_year, ';
    $query .= 'borrowers.categorycode, borrowers.zipcode as postcode, borrowers.dateofbirth, borrowers.cardnumber ';
    $query .= 'from reporting_statistics_tmp as reporting_statistics_tmp ';
    $query .= 'left join items on reporting_statistics_tmp.itemnumber=items.itemnumber ';
    $query .= 'left join deleteditems on reporting_statistics_tmp.itemnumber=deleteditems.itemnumber ';
    $query .= 'left join biblioitems on items.biblioitemnumber=biblioitems.biblioitemnumber ';
    $query .= 'left join deletedbiblioitems on deleteditems.biblioitemnumber=deletedbiblioitems.biblioitemnumber ';
    $query .= 'left join borrowers on reporting_statistics_tmp.borrowernumber = borrowers.borrowernumber ';
    $query .= "where reporting_statistics_tmp.usercode in ('HENKILO', 'MUUHUOL', 'KOTIPALVEL', 'LAPSI', 'YHTEISO') and other != 'KONVERSIO' and type in ('issue', 'renew') ";
    my ($where, $parameters) = $self->getWhere();
    push @parameters, @$parameters;

    $query .= 'order by primary_id ';

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
            if(defined $lastRow->{primary_id}){
                $self->updateLastSelected($lastRow->{primary_id});
            }
        }
    }
    return $statistics;
}

sub loadLastAllowedId{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $query = "select MAX(primary_id) from reporting_statistics_tmp where usercode in ('HENKILO', 'MUUHUOL', 'KOTIPALVEL', 'LAPSI', 'YHTEISO') and other != 'KONVERSIO' and type in ('issue', 'renew') order by datetime";
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
        $where .= "and reporting_statistics_tmp.primary_id > ? ";
        push @parameters, $self->getLastSelectedId();
    }
    if($self->getLastAllowedId()){
        $where .= "and reporting_statistics_tmp.primary_id <= ? ";
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

sub factLoanedAmount{
    my $self = shift;
    my $data = $_[0];
    my $fact = $_[1];
    my $type;
    return 1;
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

1;
