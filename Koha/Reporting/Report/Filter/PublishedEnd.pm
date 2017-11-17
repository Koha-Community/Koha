#!/usr/bin/perl
package Koha::Reporting::Report::Filter::PublishedEnd;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('published_end');
    $self->setDescription('Published Year (to)');
    $self->setType('text');
    $self->setDimension('item');
    $self->setField('published_year');
    $self->setRule('lte');
}

1;
