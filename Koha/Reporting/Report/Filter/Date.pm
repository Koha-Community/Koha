#!/usr/bin/perl
package Koha::Reporting::Report::Filter::Date;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('date');
    $self->setType('date');
    $self->setDimension('date');
    $self->setField('language');
    $self->setRule('');
}

1;
