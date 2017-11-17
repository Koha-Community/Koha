#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::ItemTypeOkm;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('itemtype_okm');
    $self->setAlias('Item type');
    $self->setDescription('Item type');
    $self->setDimension('item');
    $self->setField('itemtype_okm');
}

1;
