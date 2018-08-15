#!/usr/bin/perl
package Koha::Reporting::View;

use Modern::Perl;
use Moose;
use Data::Dumper;
use Koha::Reporting::Report::Factory;

has 'report_factory' => (
    is => 'rw',
    reader => 'getReportFactory',
    writer => 'setReportFactory'
);

sub BUILD {
    my $self = shift;
    my $reportFactory = new Koha::Reporting::Report::Factory();
    $self->setReportFactory($reportFactory);
}

sub createReportsViewJson{
    my $self = shift;
    my $reports = $self->getReportFactory()->getReportsList();
    my $jsonDatas = [];
    foreach my $report (@$reports){
        my $jsonData = {};
        my $reportGroup = $report->getGroup();
        $jsonData->{'name'} = $report->getName();
        $jsonData->{'description'} = $report->getDescription();
        $jsonData->{'group'} = $report->getGroup();

        $jsonData->{'use_date_from'} = $report->getUseDateFrom();
        $jsonData->{'use_date_to'} = $report->getUseDateTo();

        $jsonData->{'orderings'} = $report->getOrderings();

        my $groupings = $report->getGroupings();
        $jsonData->{'groupings'} = [];
        foreach my $grouping (@$groupings){
            if(!defined $grouping->getNoDisplay()){
                my $groupingHash = $grouping->toHash();
                if($groupingHash){
                    push @{$jsonData->{'groupings'}}, $groupingHash;
                }
            }
        }

        my $filters = $report->getFilters();
        $jsonData->{'filters'} = [];
        foreach my $filter (@$filters){
            my $filterHash = $filter->toHash();
            if($filterHash){
                push @{$jsonData->{'filters'}}, $filterHash;
            }
        }
        my $hasTopLimit = $report->getHasTopLimit();
        if(defined $hasTopLimit){
            $jsonData->{'has_top_limit'} = $hasTopLimit;
            if($report->getDefaultLimit()){
                $jsonData->{'default_limit'} = $report->getDefaultLimit();
            }
        }

        push @{$jsonDatas}, $jsonData;
    }
    return $jsonDatas;
}

1;
