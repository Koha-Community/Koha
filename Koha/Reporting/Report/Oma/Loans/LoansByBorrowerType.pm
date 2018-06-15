#!/usr/bin/perl
package Koha::Reporting::Report::Oma::Loans::LoansByBorrowerType;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends "Koha::Reporting::Report::Loans";

sub BUILD {
    my $self = shift;
    $self->setDescription('Loans by Borrower type');
    $self->setGroup('oma');

    $self->addGrouping('Koha::Reporting::Report::Grouping::Postcode');
    $self->addGrouping('Koha::Reporting::Report::Grouping::CnClass');
    $self->addGrouping('Koha::Reporting::Report::Grouping::CnClassFictive');
    $self->addGrouping('Koha::Reporting::Report::Grouping::LanguageAll');
    $self->addGrouping('Koha::Reporting::Report::Grouping::AgeGroup');
    $self->addGrouping('Koha::Reporting::Report::Grouping::Branch');
    $self->addGrouping('Koha::Reporting::Report::Grouping::ItemType');
    $self->addGrouping('Koha::Reporting::Report::Grouping::Location');
    $self->addGrouping('Koha::Reporting::Report::Grouping::Categorycode');
    $self->addGrouping('Koha::Reporting::Report::Grouping::LocationType');
    $self->addGrouping('Koha::Reporting::Report::Grouping::LocationAge');
    $self->addGrouping('Koha::Reporting::Report::Grouping::LoanType');
    $self->addGrouping('Koha::Reporting::Report::Grouping::Time::Hour');
    $self->addGrouping('Koha::Reporting::Report::Grouping::Time::Day');
    $self->addGrouping('Koha::Reporting::Report::Grouping::Time::Month');


    $self->addFilter('branch_category', 'Koha::Reporting::Report::Filter::BranchGroup');
    $self->addFilter('branch', 'Koha::Reporting::Report::Filter::Branch');
    $self->addFilter('location', 'Koha::Reporting::Report::Filter::Location');
    $self->addFilter('cn_class', 'Koha::Reporting::Report::Filter::CnClass::Primary');
    $self->addFilter('cn_class_fict', 'Koha::Reporting::Report::Filter::CnClass::Fictive');
    $self->addFilter('itemtype', 'Koha::Reporting::Report::Filter::Itemtype');
    $self->addFilter('language', 'Koha::Reporting::Report::Filter::LanguageAll');
    $self->addFilter('location_type', 'Koha::Reporting::Report::Filter::Location::Type');
    $self->addFilter('location_age', 'Koha::Reporting::Report::Filter::Location::Age');
    $self->addFilter('borrower_category', 'Koha::Reporting::Report::Filter::BorrowerCategory');
    $self->addFilter('postcode_from', 'Koha::Reporting::Report::Filter::PostcodeStart');
    $self->addFilter('postcode_to', 'Koha::Reporting::Report::Filter::PostcodeEnd');
    $self->addFilter('borrower_agegroup', 'Koha::Reporting::Report::Filter::Borrower::AgeGroup');
    $self->addFilter('loan_type', 'Koha::Reporting::Report::Filter::LoanType');
    $self->addFilter('time_month', 'Koha::Reporting::Report::Filter::Time::Month');
    $self->addFilter('time_day', 'Koha::Reporting::Report::Filter::Time::Day');
    $self->addFilter('time_day', 'Koha::Reporting::Report::Filter::Time::Hour');
}

1;
