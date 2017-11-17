#!/usr/bin/perl
package Koha::Reporting::Table::Dimension::DateZero;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Table::Dimension::Abstract';

has 'skip_from_date' => (
    is => 'rw',
    default => 0,
    reader => 'getSkipFromDate',
    writer => 'setSkipFromDate'
);

sub BUILD {
    my $self = shift;
    $self->setPrimaryId('date_id');
    $self->setBusinessKey(['date_id']);
    $self->setTableName('reporting_date_dim');
}

sub initDefaultImportColumns{
    my $self = shift;
    my $allColumns = $self->getColumns();
    foreach my $column (@$allColumns){
        $self->addImportColumn($column);
    }
}

sub getFilterFragment{
    my $self = shift;
    my $where = $_[0];
    if($self->getFilters()){
        my $filters = $self->getFilters();
        foreach my $filter (@$filters){
            if($self->skipFilter($filter)){
                next;
            }

            if($filter->{type} eq 'filter'){
                if($where eq ''){
                    $where = '';
                }
                elsif($filter->{logic} eq 'AND'){
                    $where .= 'AND '
                }
                elsif($filter->{logic} eq 'OR'){
                    $where = '('. $where .') OR '
                }
                $where .= $filter->{condition} . ' ';
            }
        }
    }
    return $where;
}

sub skipFilter{
    my $self = shift;
    my $filter = $_[0];
    my $result = 0;
    if(defined $filter && defined $filter->{'name'} && $filter->{'name'} eq 'date_from' && $self->getSkipFromDate()){
        $result = 1;
    }
    return $result;
}

1;
