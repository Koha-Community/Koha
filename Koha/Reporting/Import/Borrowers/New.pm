#!/usr/bin/perl
package Koha::Reporting::Import::Borrowers::New;
use Moose;
use Data::Dumper;
use POSIX qw(strftime floor);
use Time::Piece;
use utf8;

extends 'Koha::Reporting::Import::Abstract';

sub BUILD {
    my $self = shift;
    $self->initFactTable('reporting_borrowers');
    $self->setName('borrowers_new_fact');

    $self->{column_transform_method}->{fact}->{activity_type} = \&factActivityType;
    $self->{column_transform_method}->{fact}->{amount} = \&factAmount;
    $self->{column_transform_method}->{location}->{location} = \&locationLocation;

}

sub loadDatas{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $statistics;
    my @parameters;
    my $patroncategories = Koha::Reporting::Import::Abstract->getConditionValues('patronCategories');
    my $query = 'select borrowers.borrowernumber, borrowers.categorycode, borrowers.zipcode as postcode, borrowers.dateofbirth, ';
    $query .= 'borrowers.cardnumber , borrowers.dateenrolled as datetime, borrowers.branchcode as branch ';
    $query .= "from borrowers where dateenrolled IS NOT NULL and borrowers.categorycode in ".$patroncategories." ";

    if($self->getLastSelectedId()){
        $query .= "and borrowers.borrowernumber > ? ";
        push @parameters, $self->getLastSelectedId();
    }
    if($self->getLastAllowedId()){
        $query .= "and borrowers.borrowernumber <= ? ";
        push @parameters, $self->getLastAllowedId();
    }

    $query .= 'UNION ALL select deletedborrowers.borrowernumber, deletedborrowers.categorycode, deletedborrowers.zipcode as postcode, deletedborrowers.dateofbirth, deletedborrowers.cardnumber , deletedborrowers.dateenrolled as datetime, deletedborrowers.branchcode as branch ';
    $query .= "from deletedborrowers where deletedborrowers.dateenrolled IS NOT NULL and deletedborrowers.categorycode in ".$patroncategories." ";

    if($self->getLastSelectedId()){
        $query .= "and deletedborrowers.borrowernumber > ? ";
        push @parameters, $self->getLastSelectedId();
    }
    if($self->getLastAllowedId()){
        $query .= "and deletedborrowers.borrowernumber <= ? ";
        push @parameters, $self->getLastAllowedId();
    }

    $query .= 'order by borrowernumber ';

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
    return 2;
}

sub factAmount{
    return 1;
}

sub loadLastAllowedId{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $query = "select MAX(borrowerno) from (SELECT MAX(borrowernumber) as borrowerno from borrowers UNION ALL SELECT MAX(borrowernumber) as borrowerno from deletedborrowers) as borrowerunion";
    my $stmnt = $dbh->prepare($query);
    $stmnt->execute() or die($DBI::errstr);

    my $lastId;
    if($stmnt->rows == 1){
        $lastId = $stmnt->fetch()->[0];
        $self->setLastAllowedId($lastId);
    }
}

sub locationLocation{
  return 'AIK';
}

1;
