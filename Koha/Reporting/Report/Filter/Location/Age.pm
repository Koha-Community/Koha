#!/usr/bin/perl
package Koha::Reporting::Report::Filter::Location::Age;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('location_age');
    $self->setDescription('Adult / Child');
    $self->setType('multiselect');
    $self->setDimension('location');
    $self->setField('location_age');
    $self->setRule('in');
}

sub loadOptions{
    my $self = shift;
    my $options = [
        {'name' => 'aikuiset', 'description' => 'Aikuiset'},
        {'name' => 'lapset', 'description' => 'Lapset'}
    ];
    return $options;
}

1;
