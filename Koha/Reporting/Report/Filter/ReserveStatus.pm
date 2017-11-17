#!/usr/bin/perl
package Koha::Reporting::Report::Filter::ReserveStatus;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('reserve_status');
    $self->setDescription('Reserve status');
    $self->setType('multiselect');
    $self->setDimension('fact');
    $self->setField('reserve_status');
    $self->setRule('in');
}

sub loadOptions{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $options = [
        {'name' => 'Voimassa', 'description' => 'Voimassa'},
        {'name' => 'Keskeytetty', 'description' => 'Keskeytetty'},
        {'name' => 'Peruttu', 'description' => 'Peruttu'},
        {'name' => 'Noudettavissa', 'description' => 'Noudettavissa'},
        {'name' => 'Noutamaton', 'description' => 'Noutamaton'},
    ];

    return $options;
}

1;
