#!/usr/bin/perl
package Koha::Reporting::Report::Oma::Borrowers;

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
    $self->setGroup('oma');

    $self->addGrouping('Koha::Reporting::Report::Grouping::Postcode');
    $self->addGrouping('Koha::Reporting::Report::Grouping::AgeGroup');
    $self->addGrouping('Koha::Reporting::Report::Grouping::Branch');
    $self->addGrouping('Koha::Reporting::Report::Grouping::Categorycode');
    $self->addGrouping('Koha::Reporting::Report::Grouping::BorrowerActivity');


    $self->addFilter('branch_category', 'Koha::Reporting::Report::Filter::BranchGroup');
    $self->addFilter('branch', 'Koha::Reporting::Report::Filter::Branch');
    $self->addFilter('borrower_action_type', 'Koha::Reporting::Report::Filter::Borrower::ActionType');
    $self->addFilter('postcode_from', 'Koha::Reporting::Report::Filter::PostcodeStart');
    $self->addFilter('postcode_to', 'Koha::Reporting::Report::Filter::PostcodeEnd');
    $self->addFilter('borrower_category', 'Koha::Reporting::Report::Filter::BorrowerCategory');
    $self->addFilter('borrower_agegroup', 'Koha::Reporting::Report::Filter::Borrower::AgeGroup');

}

sub modifyDataRows{
    my $self = shift;
    my $dataRows = $_[0];
    if(@$dataRows){
        foreach my $row (@$dataRows){
            if(defined $row->{'Borrower activity'}){
                if($row->{'Borrower activity'} eq '1'){
                    $row->{'Borrower activity'} = 'loaned';
                }
                elsif($row->{'Borrower activity'} eq '2'){
                    $row->{'Borrower activity'} = 'new';
                }
                elsif($row->{'Borrower activity'} eq '3'){
                    $row->{'Borrower activity'} = 'deleted';
                }
            }
        }
    }
    return $dataRows;
}

1;
