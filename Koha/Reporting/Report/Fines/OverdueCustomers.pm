#!/usr/bin/perl
package Koha::Reporting::Report::Fines::OverdueCustomers;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends "Koha::Reporting::Report::Fines";

sub BUILD {
    my $self = shift;
    $self->setGroup('oma');
    $self->setDescription('Fines Overdue (customerlist)');
    $self->initFactTable('reporting_fines_overdue');
#    $self->setUseDateFrom(0);
    $self->addGrouping('Koha::Reporting::Report::Grouping::Cardnumber');

    $self->addFilter('branch_category', 'Koha::Reporting::Report::Filter::BranchGroup');
    $self->addFilter('branch', 'Koha::Reporting::Report::Filter::Branch');
    $self->addFilter('is_overdue', 'Koha::Reporting::Report::Filter::Overdue');
}

1;
