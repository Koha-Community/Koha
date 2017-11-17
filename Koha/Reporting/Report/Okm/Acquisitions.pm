#!/usr/bin/perl
package Koha::Reporting::Report::Okm::Acquisitions;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends "Koha::Reporting::Report::Abstract";

sub BUILD {
    my $self = shift;
    $self->setDescription('Acquisition (EUR)');
    $self->setGroup('okm');
    $self->initFactTable('reporting_acquisition');

    $self->addGrouping('Koha::Reporting::Report::Grouping::Location');
    $self->addGrouping('Koha::Reporting::Report::Grouping::Language');

    $self->addFilter('branch', 'Koha::Reporting::Report::Filter::Branch');
    $self->addFilter('branch_category', 'Koha::Reporting::Report::Filter::BranchGroup');
    $self->addFilter('location', 'Koha::Reporting::Report::Filter::Location');
    $self->addFilter('language', 'Koha::Reporting::Report::Filter::Language');
    $self->addFilter('itemtype', 'Koha::Reporting::Report::Filter::Itemtype');
    $self->addFilter('itemtype_okm', 'Koha::Reporting::Report::Filter::ItemtypeOkm');

}

1;
