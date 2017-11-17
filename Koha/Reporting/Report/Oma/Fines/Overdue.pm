#!/usr/bin/perl
package Koha::Reporting::Report::Oma::Fines::Overdue;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends "Koha::Reporting::Report::Fines";

sub BUILD {
    my $self = shift;
    $self->setGroup('oma');
    $self->setDescription('Fines Overdue');
    $self->initFactTable('reporting_fines_overdue');
    $self->setUseDateFrom(0);

    $self->addGrouping('Koha::Reporting::Report::Grouping::Branch');
    $self->addGrouping('Koha::Reporting::Report::Grouping::Overdue');

    $self->addFilter('branch_category', 'Koha::Reporting::Report::Filter::BranchGroup');
    $self->addFilter('branch', 'Koha::Reporting::Report::Filter::Branch');
    $self->addFilter('is_overdue', 'Koha::Reporting::Report::Filter::Overdue');
}

sub formatSumValue{
    my $self = shift;
    my $value = $_[0];
    $value = sprintf("%.2f", $value);
    $value =~ s/\./,/;
    return $value;
}

1;
