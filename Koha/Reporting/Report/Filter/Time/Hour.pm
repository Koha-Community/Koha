#!/usr/bin/perl
package Koha::Reporting::Report::Filter::Time::Hour;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('hour');
    $self->setDescription('Hour');
    $self->setType('multiselect');
    $self->setDimension('date');
    $self->setField('hour');
    $self->setRule('in');
}

sub loadOptions{
    my $self = shift;
    my $options = [];
    my $i = 0;

    while ($i < 24 ) {
       $i++;
       push @{$options}, {'name' => "$i", 'description' => "$i"};
    }

    return $options;
}


1;
