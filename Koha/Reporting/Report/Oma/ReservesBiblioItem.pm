#!/usr/bin/perl
package Koha::Reporting::Report::Oma::ReservesBiblioItem;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends "Koha::Reporting::Report::Abstract";

sub BUILD {
    my $self = shift;
    $self->initFactTable('reporting_reserves');
    $self->setDescription('Reserves by biblioitem');
    $self->setGroup('oma');
    $self->setRendererClass('Koha::Reporting::Report::Renderer::OneRow');

    $self->addGrouping('Koha::Reporting::Report::Grouping::BiblioItemAlways');

    $self->addGrouping('Koha::Reporting::Report::Grouping::CnClass');
    $self->addGrouping('Koha::Reporting::Report::Grouping::CnClassFictive');
    $self->addGrouping('Koha::Reporting::Report::Grouping::LanguageAll');
    $self->addGrouping('Koha::Reporting::Report::Grouping::AgeGroup');
    $self->addGrouping('Koha::Reporting::Report::Grouping::Branch');
    $self->addGrouping('Koha::Reporting::Report::Grouping::ItemType');
    $self->addGrouping('Koha::Reporting::Report::Grouping::Location');
    $self->addGrouping('Koha::Reporting::Report::Grouping::Collection');
    $self->addGrouping('Koha::Reporting::Report::Grouping::ReserveStatus');
    $self->addGrouping('Koha::Reporting::Report::Grouping::LocationType');
    $self->addGrouping('Koha::Reporting::Report::Grouping::LocationAge');
    $self->addGrouping('Koha::Reporting::Report::Grouping::PublishedYear');
    $self->addGrouping('Koha::Reporting::Report::Grouping::AcquiredYear');

    $self->addFilter('branch_category', 'Koha::Reporting::Report::Filter::BranchGroup');
    $self->addFilter('branch', 'Koha::Reporting::Report::Filter::Branch');
    $self->addFilter('location', 'Koha::Reporting::Report::Filter::Location');
    $self->addFilter('cn_class', 'Koha::Reporting::Report::Filter::CnClass::Primary');
    $self->addFilter('cn_class_fict', 'Koha::Reporting::Report::Filter::CnClass::Fictive');
    $self->addFilter('itemtype', 'Koha::Reporting::Report::Filter::Itemtype');
#    $self->addFilter('itemtype_okm', 'Koha::Reporting::Report::Filter::ItemtypeOkm');
    $self->addFilter('language', 'Koha::Reporting::Report::Filter::LanguageAll');
    $self->addFilter('published_start', 'Koha::Reporting::Report::Filter::PublishedStart');
    $self->addFilter('published_end', 'Koha::Reporting::Report::Filter::PublishedEnd');
    $self->addFilter('is_yle', 'Koha::Reporting::Report::Filter::IsYle');
    $self->addFilter('acquired_start', 'Koha::Reporting::Report::Filter::AcquiredStart');
    $self->addFilter('acquirder_end', 'Koha::Reporting::Report::Filter::AcquiredEnd');
    $self->addFilter('collection_code', 'Koha::Reporting::Report::Filter::CollectionCode');
    $self->addFilter('location_type', 'Koha::Reporting::Report::Filter::Location::Type');
    $self->addFilter('location_age', 'Koha::Reporting::Report::Filter::Location::Age');
    $self->addFilter('reserve_status', 'Koha::Reporting::Report::Filter::ReserveStatus');
    $self->addFilter('borrower_agegroup', 'Koha::Reporting::Report::Filter::Borrower::AgeGroup');

    $self->addOrdering('amount', {name => 'amount', 'dimension' => 'fact', 'field' => 'amount', 'alias'=> 'amount', default_ordering => 'desc'});
    $self->setDefaultOrdering('amount');
    $self->setHasTopLimit(1);
    $self->setDefaultLimit(500);
}

sub initSelectFieldsBefore{
    my $self = shift;
    $self->addFieldToSelect('item', 'title', 'Title');
}


1;
