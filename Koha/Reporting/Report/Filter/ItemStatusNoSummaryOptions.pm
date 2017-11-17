#!/usr/bin/perl
package Koha::Reporting::Report::Filter::ItemStatusNoSummaryOptions;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('item_status_no_summary_options');
    $self->setDescription('Item status options');
    $self->setType('multiselect');
    $self->setDimension('fact');
    $self->setField('transport_type');
    $self->setRule('in');
    $self->setUseCustomLogic(1);
}

sub loadOptions{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $options = [];

    my $stmnt = $dbh->prepare("select lib, category, authorised_value from authorised_values where category in ('DAMAGED', 'NOT_LOAN', 'LOST') order by lib");
    $stmnt->execute();
    if ($stmnt->rows >= 1){
        while ( my $row = $stmnt->fetchrow_hashref ) {
            my $name;
            if($row->{category} eq 'DAMAGED'){
                $name  = 'damaged-' . $row->{authorised_value};
            }
            elsif($row->{category} eq 'NOT_LOAN'){
                $name  = 'notforloan-' . $row->{authorised_value};
            }
            elsif($row->{category} eq 'LOST'){
                $name  = 'lost-' . $row->{authorised_value};
            }

            if(defined $name){
                my $option = {'name' => $name, 'description' => $row->{'lib'}};
                push $options, $option;
            }
        }
    }
    return $options;
}

1;
