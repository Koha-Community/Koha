#!/usr/bin/perl
package Koha::Reporting::Table::Fact::Factory;

use Modern::Perl;
use Moose;
use Data::Dumper;
use Class::Load ':all';

extends "Koha::Reporting::Table::ObjectFactory";

has 'factTables' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} },
    reader => 'getFactTables',
    writer => 'setFactTables'
);

sub BUILD {
    my $self = shift;
    $self->addFactTable('reporting_loans' => 'Koha::Reporting::Table::Fact::Loans');
    $self->addFactTable('reporting_loans_zero' => 'Koha::Reporting::Table::Fact::LoansZero');
    $self->addFactTable('reporting_fines_overdue' => 'Koha::Reporting::Table::Fact::Fines::Overdue');
    $self->addFactTable('reporting_fines_paid' => 'Koha::Reporting::Table::Fact::Fines::Paid');
    $self->addFactTable('reporting_borrowers' => 'Koha::Reporting::Table::Fact::Borrowers');
    $self->addFactTable('reporting_acquisition' => 'Koha::Reporting::Table::Fact::Acquisitions');
    $self->addFactTable('reporting_items' => 'Koha::Reporting::Table::Fact::Items');
    $self->addFactTable('reporting_items_status' => 'Koha::Reporting::Table::Fact::ItemsStatus');
    $self->addFactTable('reporting_deleteditems' => 'Koha::Reporting::Table::Fact::DeletedItems');
    $self->addFactTable('reporting_returns' => 'Koha::Reporting::Table::Fact::Returns');
    $self->addFactTable('reporting_reserves' => 'Koha::Reporting::Table::Fact::Reserves');
    $self->addFactTable('reporting_messages' => 'Koha::Reporting::Table::Fact::Messages');

    $self->addFactTable('dummy' => 'Koha::Reporting::Table::Fact::Dummy');

}

sub create{
    my $self = shift;
    my $name = $_[0];
    my $className = $self->getClassName($name);
    my $fact =  $self->createObject($className);
    if($fact){
       $fact->setName($name);
    }
    return $fact;
}

sub getClassName{
    my $self = shift;
    my $name = $_[0];
    my $className = 0;

    if(defined $self->{factTables}->{$name}){
        $className = $self->{factTables}->{$name};
    }
    return $className;
}

sub addFactTable{
    my $self = shift;
    my $name = $_[0];
    my $class = $_[1];

    if($name && $class){
        $self->{factTables}->{$name} = $class;
    }
}

1;
