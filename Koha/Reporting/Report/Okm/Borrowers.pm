#!/usr/bin/perl
package Koha::Reporting::Report::Borrowers;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends "Koha::Reporting::Report::Abstract";

sub BUILD {
    my $self = shift;
    $self->initFactTable('reporting_borrowers');

    $self->getFactTable()->setUseRollup(0);
    $self->getFactTable()->setUseCount(1);
    $self->getFactTable()->setCountColumn('borrower_id');
    $self->getFactTable()->setUseDistinct(1);

    $self->setDescription('Borrowers');
    $self->setGroup('okm');

    $self->addGrouping('Koha::Reporting::Report::Grouping::Branch');
    $self->addGrouping('Koha::Reporting::Report::Grouping::Categorycode');
    $self->addGrouping('Koha::Reporting::Report::Grouping::Postcode');
    $self->addGrouping('Koha::Reporting::Report::Grouping::AgeGroup');

    $self->addFilter('branch', 'Koha::Reporting::Report::Filter::Branch');
    $self->addFilter('branch_category', 'Koha::Reporting::Report::Filter::BranchGroup');
    $self->addFilter('borrower_action_type', 'Koha::Reporting::Report::Filter::Borrower::ActionType');
}



1;
