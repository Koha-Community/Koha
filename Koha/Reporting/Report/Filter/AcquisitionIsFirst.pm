#!/usr/bin/perl
package Koha::Reporting::Report::Filter::AcquisitionIsFirst;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

has 'linked_filter' => (
    is => 'rw',
    reader => 'getLinkedFilter',
    writer => 'setLinkedFilter'
);


sub BUILD {
    my $self = shift;
    $self->setName('is_first_acquisition');
    $self->setDescription('First Acquisition');
    $self->setType('select');
    $self->setDimension('item');
    $self->setField('is_first_acquisition');
    $self->setRule('in');

    $self->setUseCustomLogic(1);
    $self->setAddSelectAllOption(0);
    $self->setAddNotSetOption(0);

    $self->setLinkedFilter('branch_category_forced');
}

sub loadOptions{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $options = [];

    push $options, { 'name' => 'no', 'description' => 'No', 'linked_filter' => 'branch_category_forced' };
    push $options, { 'name' => 'yes', 'description' => 'Yes', 'linked_filter' => 'branch_category_forced' };
    return $options;
}

sub customLogic{
    my $self = shift;
    my $report = $_[0];
    my $requestFilter = $_[1];
    my $linkedFilter;
    my $dbh = C4::Context->dbh;
    if(defined $requestFilter->{selectedOptions}){
        my $selectedValue = $requestFilter->{selectedOptions};
        if(ref $selectedValue eq 'ARRAY' && defined @$selectedValue[0] && defined @$selectedValue[0]->{name}){
            if(defined @$selectedValue[0]->{linkedFilter}){
                $linkedFilter = @$selectedValue[0]->{linkedFilter};
            }
            $selectedValue = @$selectedValue[0]->{name};
        }

        if($selectedValue eq 'yes'){
           if(defined $linkedFilter && defined $linkedFilter->{selectedOptions}){
                my $linkedOptionsTmp = $linkedFilter->{selectedOptions};
                my $option;
                if(@$linkedOptionsTmp){
                    foreach my $linkedOption (@$linkedOptionsTmp){
                        if(defined $linkedOption->{name}){
                           $option = $linkedOption->{name};
                        }
                    }
                }
                my $fact = $report->getFactTable();
                if(defined $fact && defined $option){
                    my $join = 'INNER JOIN reporting_acquisitions_isfirst on ' . $fact->getFullColumn('item_id');
                    $join .= ' = reporting_acquisitions_isfirst.item_id and reporting_acquisitions_isfirst.branch_group = ' . $dbh->quote($option) . ' ';
                    $fact->addExtraJoin($join);
                }
            }
        }
    }
}

1;
