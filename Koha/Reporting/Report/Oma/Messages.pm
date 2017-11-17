#!/usr/bin/perl
package Koha::Reporting::Report::Oma::Messages;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends "Koha::Reporting::Report::Abstract";

sub BUILD {
    my $self = shift;
    $self->initFactTable('reporting_messages');
    $self->setDescription('Messages');
    $self->setGroup('oma');

    $self->addGrouping('Koha::Reporting::Report::Grouping::Branch');
    $self->addGrouping('Koha::Reporting::Report::Grouping::Categorycode');
    $self->addGrouping('Koha::Reporting::Report::Grouping::TransportType');
    $self->addGrouping('Koha::Reporting::Report::Grouping::MessageType');

    $self->addFilter('branch_category', 'Koha::Reporting::Report::Filter::BranchGroup');
    $self->addFilter('branch', 'Koha::Reporting::Report::Filter::Branch');
    $self->addFilter('borrower_category', 'Koha::Reporting::Report::Filter::BorrowerCategory');
    $self->addFilter('message_type', 'Koha::Reporting::Report::Filter::MessageType');
    $self->addFilter('transport_type', 'Koha::Reporting::Report::Filter::TransportType');

}



1;
