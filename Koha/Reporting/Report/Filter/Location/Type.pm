#!/usr/bin/perl
package Koha::Reporting::Report::Filter::Location::Type;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('location_type');
    $self->setDescription('Fiction / Non-fiction');
    $self->setType('multiselect');
    $self->setDimension('location');
    $self->setField('location_type');
    $self->setRule('in');
}

sub loadOptions{
    my $self = shift;
    my $options = [
        {'name' => 'kauno', 'description' => 'Kauno'},
        {'name' => 'tieto', 'description' => 'Tieto'}
    ];
    return $options;
}

1;
