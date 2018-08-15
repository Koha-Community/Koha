#!/usr/bin/perl
package Koha::Reporting::Report::Filter::CollectionCode;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('collection_code');
    $self->setDescription('Collection');
    $self->setType('multiselect');
    $self->setDimension('item');
    $self->setField('collection_code');
    $self->setRule('in');
}

sub loadOptions{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $options = [];

    my $stmnt = $dbh->prepare("select authorised_value, lib from authorised_values where category='CCODE' order by lib");
    $stmnt->execute();
    if ($stmnt->rows >= 1){
        while ( my $row = $stmnt->fetchrow_hashref ) {
            my $option = {'name' => $row->{'authorised_value'}, 'description' => $row->{'lib'}};
            push @{$options}, $option;
        }
    }
    return $options;
}

1;
