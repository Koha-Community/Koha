#!/usr/bin/perl
package Koha::Reporting::Report::Fines;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends "Koha::Reporting::Report::Abstract";

sub BUILD {
    my $self = shift;
    $self->initFactTable('reporting_fines_overdue');
}

1;
