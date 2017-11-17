#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::Language;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('language');
    $self->setAlias('Language');
    $self->setDescription('Language');
    $self->setDimension('item');
    $self->setField('language');
}
