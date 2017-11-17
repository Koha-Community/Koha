#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::BorrowerType;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('categorycode');
    $self->setAlias('Borrower category');
    $self->setDescription('Borrower category');
    $self->setDimension('borrower');
    $self->setField('categorycode');
}

1;
