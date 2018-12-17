#!/usr/bin/perl
package Koha::Reporting::Report::Filter::Borrower::AgeGroup;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('age_group');
    $self->setDescription('Age Group');
    $self->setType('multiselect');
    $self->setDimension('borrower');
    $self->setField('age_group');
    $self->setRule('in');
}

sub loadOptions{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $options = [];
    push $options, {'name' => '0-6', 'description' => '0-6'};
    push $options, {'name' => '07-12', 'description' => '07-12'};
    push $options, {'name' => '13-15', 'description' => '13-15'};
    push $options, {'name' => '16-18', 'description' => '16-18'};
    push $options, {'name' => '19-24', 'description' => '19-24'};
    push $options, {'name' => '25-44', 'description' => '25-44'};
    push $options, {'name' => '45-64', 'description' => '45-64'};
    push $options, {'name' => '65-74', 'description' => '65-74'};
    push $options, {'name' => '75-84', 'description' => '75-84'};
    push $options, {'name' => '85-', 'description' => '85-'};

    return $options;
}

1;
