#!/usr/bin/perl
package Koha::Reporting::Report::DeletedItems;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends "Koha::Reporting::Report::Abstract";

sub BUILD {
    my $self = shift;
    $self->initFactTable('reporting_deleteditems');

    $self->getFactTable()->setUseRollup(0);
    $self->getFactTable()->setUseCount(1);
    $self->getFactTable()->setCountColumn('item_id');
    $self->getFactTable()->setUseDistinct(1);

    $self->setDescription('Deleted Items');
    $self->setGroup('okm');

    $self->addGrouping('Koha::Reporting::Report::Grouping::Branch');
    $self->addGrouping('Koha::Reporting::Report::Grouping::CnClass');
    $self->addGrouping('Koha::Reporting::Report::Grouping::LocationType');
    $self->addGrouping('Koha::Reporting::Report::Grouping::LocationAge');

    $self->addFilter('branch', 'Koha::Reporting::Report::Filter::Branch');
    $self->addFilter('branch_category', 'Koha::Reporting::Report::Filter::BranchGroup');
    $self->addFilter('location', 'Koha::Reporting::Report::Filter::Location');
    $self->addFilter('language', 'Koha::Reporting::Report::Filter::Language');
    $self->addFilter('location_type', 'Koha::Reporting::Report::Filter::Location::Type');
    $self->addFilter('location_age', 'Koha::Reporting::Report::Filter::Location::Age');
    $self->addFilter('itemtype', 'Koha::Reporting::Report::Filter::Itemtype');
    $self->addFilter('itemtype_okm', 'Koha::Reporting::Report::Filter::ItemtypeOkm');
    $self->addFilter('cn_class', 'Koha::Reporting::Report::Filter::CnClass::Primary');

}

1;
