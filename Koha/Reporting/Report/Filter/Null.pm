#!/usr/bin/perl
package Koha::Reporting::Report::Filter::Null;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('null');
    $self->setDescription('Null');
    $self->setType('null');
    $self->setRule('null');
}

1;
