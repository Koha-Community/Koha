#!/usr/bin/perl
package Koha::Reporting::Report::Filter::Location;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('location');
    $self->setDescription('Location');
    $self->setType('multiselect');
    $self->setDimension('location');
    $self->setField('location');
    $self->setRule('in');
}

sub loadOptions{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $branches = [];

    my $stmnt = $dbh->prepare("select authorised_value, lib from authorised_values where category='LOC'");
    $stmnt->execute();
    if ($stmnt->rows >= 1){
        while ( my $row = $stmnt->fetchrow_hashref ) {
            my $option = {'name' => $row->{'authorised_value'}, 'description' => $row->{'lib'}};
            push @{$branches}, $option;
        }
    }
    return $branches;
}

1;
