#!/usr/bin/perl
package Koha::Reporting::Import::Borrowers::Deleted;

use Modern::Perl;
use Moose;
use Data::Dumper;
use POSIX qw(strftime floor);
use Time::Piece;
use utf8;

extends 'Koha::Reporting::Import::Abstract';

sub BUILD {
    my $self = shift;
    $self->initFactTable('reporting_borrowers');
    $self->setName('borrowers_deleted_fact');

    $self->{column_transform_method}->{fact}->{activity_type} = \&factActivityType;
    $self->{column_transform_method}->{fact}->{amount} = \&factAmount;
    $self->{column_transform_method}->{location}->{location} = \&locationLocation;
    $self->{column_transform_method}->{location}->{location_type} = \&locationLocationType;
    $self->{column_transform_method}->{location}->{location_age} = \&locationLocationAge;

}

sub loadDatas{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $statistics;
    my @parameters;
    my $patroncategories = Koha::Reporting::Import::Abstract->getConditionValues('patronCategories');
    my $query = 'select deletedborrowers.borrowernumber, deletedborrowers.categorycode, deletedborrowers.zipcode as postcode, deletedborrowers.dateofbirth, deletedborrowers.cardnumber, deletedborrowers.branchcode as branch, ';
    $query .= 'action_logs.timestamp as datetime ';
    $query .= 'from deletedborrowers ';
    $query .= "inner join action_logs on deletedborrowers.borrowernumber = action_logs.object and action_logs.action = 'DELETE' and action_logs.module = 'MEMBERS' ";
    $query .= "where deletedborrowers.categorycode in ".$patroncategories." ";

    if($self->getLastSelectedId()){
        $query .= "and deletedborrowers.borrowernumber > ? ";
        push @parameters, $self->getLastSelectedId();
    }
    if($self->getLastAllowedId()){
        $query .= "and deletedborrowers.borrowernumber <= ? ";
        push @parameters, $self->getLastAllowedId();
    }

    $query .= 'order by deletedborrowers.borrowernumber ';

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
         print Dumper $stmnt->rows;
        $statistics = $stmnt->fetchall_arrayref({});
        if(defined @$statistics[-1]){
            my $lastRow =  @$statistics[-1];
            if(defined $lastRow->{borrowernumber}){
                $self->updateLastSelected($lastRow->{borrowernumber});
            }
        }
    }
    return $statistics;
}

sub factActivityType{
    return 3;
}

sub factAmount{
    return 1;
}

sub loadLastAllowedId{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $patroncategories = Koha::Reporting::Import::Abstract->getConditionValues('patronCategories');
    my $query = 'select MAX(deletedborrowers.borrowernumber) as borrowernumber ';
    $query .= 'from deletedborrowers ';
    $query .= "inner join action_logs on deletedborrowers.borrowernumber = action_logs.object and action_logs.action = 'DELETE' and action_logs.module = 'MEMBERS' ";
    $query .= "where deletedborrowers.categorycode in ".$patroncategories." ";

    my $stmnt = $dbh->prepare($query);
    $stmnt->execute() or die($DBI::errstr);

    my $lastId;
    if($stmnt->rows == 1){
        $lastId = $stmnt->fetch()->[0];
        $self->setLastAllowedId($lastId);
    }
}

sub locationLocation{
  return 'null';
}

sub locationLocationType{
  return 'null';
}

sub locationLocationAge{
  return 'null';
}

1;
