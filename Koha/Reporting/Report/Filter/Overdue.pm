#!/usr/bin/perl
package Koha::Reporting::Report::Filter::Overdue;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('overdue');
    $self->setDescription('Valid / Outdated');
    $self->setType('multiselect');
    $self->setDimension('fact');
    $self->setField('is_overdue');
    $self->setRule('in');
    $self->setAddNotSetOption(0);
}

sub loadOptions{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $options = [
        {'name' => 'Valid', 'description' => 'Valid'},
        {'name' => 'Outdated', 'description' => 'Outdated'}
    ];

    return $options;
}

1;
