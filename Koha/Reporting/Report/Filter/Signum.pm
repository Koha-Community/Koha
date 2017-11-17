#!/usr/bin/perl
package Koha::Reporting::Report::Filter::Signum;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('signum');
    $self->setDescription('Signum');
    $self->setType('text');
    $self->setDimension('item');
    $self->setField('cn_class_signum');
    $self->setRule('like%');
}

1;
