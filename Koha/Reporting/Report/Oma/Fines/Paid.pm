#!/usr/bin/perl
package Koha::Reporting::Report::Oma::Fines::Paid;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends "Koha::Reporting::Report::Fines";

sub BUILD {
    my $self = shift;
    $self->setGroup('oma');
    $self->setDescription('Fines Paid');
    $self->initFactTable('reporting_fines_paid');

    $self->addGrouping('Koha::Reporting::Report::Grouping::Branch');

    $self->addFilter('branch_category', 'Koha::Reporting::Report::Filter::BranchGroup');
    $self->addFilter('branch', 'Koha::Reporting::Report::Filter::Branch');

}

sub formatSumValue{
    my $self = shift;
    my $value = $_[0];
    $value = sprintf("%.2f", $value);
    $value =~ s/\./,/;
    return $value;
}

1;
