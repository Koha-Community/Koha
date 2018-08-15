#!/usr/bin/perl
package Koha::Reporting::Report::Filter::ItemStatus;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('item_status');
    $self->setDescription('Item status');
    $self->setType('select');
    $self->setDimension('item');
    $self->setField('item_status_no_summary');
    $self->setRule('in');

    $self->setAddSelectAllOption(0);
    $self->setAddNotSetOption(0);
}

sub loadOptions{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $options = [];

    push @{$options}, { 'name' => 'nothing_selected', 'description' => 'Nothing Selected' };
    push @{$options}, { 'name' => 'loaned', 'description' => 'Loaned' };
    push @{$options}, { 'name' => 'available', 'description' => 'Available' };
    push @{$options}, { 'name' => 'damaged', 'description' => 'Damaged' };
    push @{$options}, { 'name' => 'notforloan', 'description' => 'Not for loan' };
    push @{$options}, { 'name' => 'lost', 'description' => 'Lost' };
    return $options;
}

1;
