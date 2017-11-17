#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::PublishedYear;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('published_year');
    $self->setAlias('Published year');
    $self->setDescription('Published year');
    $self->setDimension('item');
    $self->setField('published_year');
}
