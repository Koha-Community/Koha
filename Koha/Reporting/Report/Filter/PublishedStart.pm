#!/usr/bin/perl
package Koha::Reporting::Report::Filter::PublishedStart;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('published_start');
    $self->setDescription('Published Year (from)');
    $self->setType('text');
    $self->setDimension('item');
    $self->setField('published_year');
    $self->setRule('gte');
}

1;
