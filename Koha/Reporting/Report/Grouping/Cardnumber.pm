#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::Cardnumber;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('cardnumber');
    $self->setDescription('Cardnumber');
    $self->setAlias('Cardnumber');
    $self->setDimension('borrower');
    $self->setField('cardnumber');

    $self->setUseAlways('1');
    $self->setNoDisplay('1');
}

1;
