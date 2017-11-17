#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::Postcode;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('postcode');
    $self->setAlias('Postcode');
    $self->setDescription('Postcode');
    $self->setDimension('borrower');
    $self->setField('postcode');
}
