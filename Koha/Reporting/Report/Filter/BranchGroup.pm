#!/usr/bin/perl
package Koha::Reporting::Report::Filter::BranchGroup;

use Modern::Perl;
use Moose;
use Data::Dumper;
use Koha::Reporting::Table::Abstract;

extends 'Koha::Reporting::Report::Filter::Abstract';

has 'linked_filter' => (
    is => 'rw',
    reader => 'getLinkedFilter',
    writer => 'setLinkedFilter'
);

has 'branchgroups_hash' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} },
    reader => 'getBranchGroupsHash',
    writer => 'setBranchGroupsHash'
);

sub BUILD {
    my $self = shift;
    $self->setName('branch_category');
    $self->setDescription('Branch Group');
    $self->setType('multiselect');
    $self->setDimension('location');
    $self->setField('branch');
    $self->setRule('in');
    $self->setLinkedFilter('branch');
}

sub loadOptions{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $branchGroups = [];
    my $branchGroupOrder = [];
    my $select = 'select branchcategories.categorycode, branchcategories.categoryname, branchrelations.branchcode from branchcategories ';
    $select .= 'left join branchrelations on branchcategories.categorycode = branchrelations.categorycode ';
    $select .= 'where branchcategories.categorycode like "%STATS" ';
    $select .= 'order by branchcategories.categoryname';

    my $stmnt = $dbh->prepare($select);
    $stmnt->execute();

    if ($stmnt->rows >= 1){
        while ( my $row = $stmnt->fetchrow_hashref ) {
            my $option = $self->getBranchGroupOption($row->{'categorycode'});
            if(!defined $option){
                $option = {'name' => $row->{'categorycode'}, 'description' => $row->{'categoryname'}};
                if($self->getLinkedFilter()){
                    $option->{'linked_filter'} = $self->getLinkedFilter();
                }
                $self->{branchgroups_hash}->{$option->{name}} = $option;
                push @{$branchGroupOrder}, $option->{name};
            }

            if(!defined $option->{linked_options}){
                $option->{linked_options} = [];
            }

            if(defined $row->{'branchcode'}){
                push @{$option->{linked_options}}, $row->{'branchcode'};
            }

        }

        foreach my $branchName (@$branchGroupOrder){
            my $bOption = $self->getBranchGroupOption($branchName);
            if(defined $bOption){
                push @{$branchGroups}, $bOption;
            }
        }
    }

    return $branchGroups;
}

sub getBranchGroupOption{
    my $self = shift;
    my $name = $_[0];
    my $option;
    my $branchGroupsHash = $self->getBranchGroupsHash();

    if(defined $branchGroupsHash->{$name}){
        $option = $branchGroupsHash->{$name};
    }
    return $option;
}

sub modifyOptions{
    my $self = shift;
    my $options = $_[0];
    my $dbh = C4::Context->dbh;
    my $result = [];
    if(@$options){
        my $query = 'select branchcode from branchrelations where categorycode in ( ' . $self->getArrayCondition($options) . ' )';
        my $stmnt = $dbh->prepare($query);
        $stmnt->execute();
        if ($stmnt->rows >= 1){
            while ( my $row = $stmnt->fetchrow_hashref ) {
                push @{$result}, $row->{branchcode};
            }
            $options = $result;
        }
    }
    return $options;
}


1;
