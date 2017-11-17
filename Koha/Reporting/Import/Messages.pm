#!/usr/bin/perl
package Koha::Reporting::Import::Messages;

use Modern::Perl;
use Moose;
use Data::Dumper;
use POSIX qw(strftime floor);
use Time::Piece;
use utf8;

extends 'Koha::Reporting::Import::Abstract';

sub BUILD {
    my $self = shift;
    $self->initFactTable('reporting_messages');
    $self->setName('messages_fact');

    $self->{column_transform_method}->{fact}->{amount} = \&factAmount;
    $self->{column_transform_method}->{location}->{location} = \&locationLocation;

}

sub loadDatas{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $statistics;
    my @parameters;

    my $query = 'select message_queue.message_id, message_queue.borrowernumber, message_queue.letter_code as message_type, message_queue.message_transport_type as transport_type, message_queue.time_queued as datetime, ';
    $query .= 'borrowers.categorycode, borrowers.zipcode as postcode, borrowers.dateofbirth, ';
    $query .= 'borrowers.cardnumber , borrowers.branchcode as branch ';
    $query .= 'from message_queue ';
    $query .= 'left join borrowers on message_queue.borrowernumber = borrowers.borrowernumber ';
    $query .= 'where message_queue.borrowernumber is not null ';

    if($self->getLastSelectedId()){
        $query .= "and message_queue.message_id > ? ";
        push @parameters, $self->getLastSelectedId();
    }
    if($self->getLastAllowedId()){
        $query .= "and message_queue.message_id <= ? ";
        push @parameters, $self->getLastAllowedId();
    }
    $query .= 'order by message_id ';

    if($self->getLimit()){
        $query .= 'limit ?';
        push @parameters, $self->getLimit();
    }
#    die Dumper $query;

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
            if(defined $lastRow->{message_id}){
                $self->updateLastSelected($lastRow->{message_id});
            }
        }
    }
#    print Dumper $statistics;

    return $statistics;
}

sub loadLastAllowedId{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $query = "select MAX(message_id) from message_queue order by message_id";
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

sub factAmount{
    return 1;
}

1;
