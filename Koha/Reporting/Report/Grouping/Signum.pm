#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::Signum;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('signum');
    $self->setAlias('Signum');
    $self->setDescription('Signum');
    $self->setDimension('item');
    $self->setField('cn_class_signum');
}
