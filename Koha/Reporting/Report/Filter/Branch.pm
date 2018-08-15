#!/usr/bin/perl
package Koha::Reporting::Report::Filter::Branch;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('branch');
    $self->setDescription('Branch');
    $self->setType('multiselect');
    $self->setDimension('location');
    $self->setField('branch');
    $self->setRule('in');
}

sub loadOptions{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $branches = [];

    my $stmnt = $dbh->prepare('select branchcode, branchname from branches order by branchname');
    $stmnt->execute();
    if ($stmnt->rows >= 1){
        while ( my $row = $stmnt->fetchrow_hashref ) {
            my $option = {'name' => $row->{'branchcode'}, 'description' => $row->{'branchname'}};
            push @{$branches}, $option;
        }
    }
    return $branches;
}

1;
