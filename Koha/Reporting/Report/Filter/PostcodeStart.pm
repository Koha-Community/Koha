#!/usr/bin/perl
package Koha::Reporting::Report::Filter::PostcodeStart;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('postcode_start');
    $self->setDescription('Postcode (from)');
    $self->setType('text');
    $self->setDimension('borrower');
    $self->setField('postcode');
    $self->setRule('gte');
}

1;
