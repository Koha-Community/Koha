#!/usr/bin/perl
package Koha::Reporting::Report::Filter::PostcodeEnd;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('postcode_end');
    $self->setDescription('Postcode (to)');
    $self->setType('text');
    $self->setDimension('borrower');
    $self->setField('postcode');
    $self->setRule('lte');
}

1;
