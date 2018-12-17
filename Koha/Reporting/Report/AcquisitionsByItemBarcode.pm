#!/usr/bin/perl
package Koha::Reporting::Report::AcquisitionsByItemBarcode;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends "Koha::Reporting::Report::Abstract";

sub BUILD {
    my $self = shift;
    $self->setDescription('Acquisitions by Item (barcodes and titles)');
    $self->setGroup('oma');
    $self->initFactTable('reporting_acquisition');

    $self->setRendererClass('Koha::Reporting::Report::Renderer::OneRow');

    $self->addGrouping('Koha::Reporting::Report::Grouping::Barcode');

    $self->addGrouping('Koha::Reporting::Report::Grouping::CnClass');
    $self->addGrouping('Koha::Reporting::Report::Grouping::LanguageAll');
    $self->addGrouping('Koha::Reporting::Report::Grouping::Branch');
    $self->addGrouping('Koha::Reporting::Report::Grouping::ItemType');
    $self->addGrouping('Koha::Reporting::Report::Grouping::Location');
    $self->addGrouping('Koha::Reporting::Report::Grouping::Collection');
    $self->addGrouping('Koha::Reporting::Report::Grouping::LocationType');
    $self->addGrouping('Koha::Reporting::Report::Grouping::LocationAge');


    $self->addFilter('branch_category', 'Koha::Reporting::Report::Filter::BranchGroup');
    $self->addFilter('branch_category_forced', 'Koha::Reporting::Report::Filter::BranchGroupForced');
    $self->addFilter('branch', 'Koha::Reporting::Report::Filter::Branch');
    $self->addFilter('location', 'Koha::Reporting::Report::Filter::Location');
    $self->addFilter('cn_class', 'Koha::Reporting::Report::Filter::CnClass::Primary');
    $self->addFilter('cn_class_fict', 'Koha::Reporting::Report::Filter::CnClass::Fictive');
    $self->addFilter('itemtype_okm', 'Koha::Reporting::Report::Filter::Itemtype');
    $self->addFilter('language', 'Koha::Reporting::Report::Filter::LanguageAll');
    $self->addFilter('is_yle', 'Koha::Reporting::Report::Filter::IsYle');
    $self->addFilter('collection_code', 'Koha::Reporting::Report::Filter::CollectionCode');
    $self->addFilter('published_start', 'Koha::Reporting::Report::Filter::PublishedStart');
    $self->addFilter('published_end', 'Koha::Reporting::Report::Filter::PublishedEnd');
    $self->addFilter('location_type', 'Koha::Reporting::Report::Filter::Location::Type');
    $self->addFilter('location_age', 'Koha::Reporting::Report::Filter::Location::Age');
    $self->addFilter('is_first', 'Koha::Reporting::Report::Filter::AcquisitionIsFirst');


 #   $self->addOrdering('amount', {name => 'loaned_amount', 'dimension' => 'fact', 'field' => 'loaned_amount', 'alias'=> 'loaned_amount', default_ordering => 'desc'});
 #   $self->setDefaultOrdering('amount');
    $self->setHasTopLimit(1);
    $self->setDefaultLimit(500);
}

sub formatSumValue{
    my $self = shift;
    my $value = $_[0];
    $value = sprintf("%.2f", $value);
    $value =~ s/\./,/;
    return $value;
}

sub initSelectFieldsBefore{
    my $self = shift;
    $self->addFieldToSelect('item', 'title', 'Title');
}


1;
