#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::Categorycode;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('categorycode');
    $self->setAlias('Borrower Category');
    $self->setDescription('Borrower Category');
    $self->setDimension('borrower');
    $self->setField('categorycode');
}

1;
