#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::Abstract;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

has 'name' => (
    is => 'rw',
    reader => 'getName',
    writer => 'setName'
);

has 'description' => (
    is => 'rw',
    reader => 'getDescription',
    writer => 'setDescription'
);

has 'field' => (
    is => 'rw',
    reader => 'getField',
    writer => 'setField'
);

has 'dimension' => (
    is => 'rw',
    reader => 'getDimension',
    writer => 'setDimension'
);

has 'options' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    reader => 'getOptions',
    writer => 'setOptions'
);

has 'use_always' => (
    is => 'rw',
    reader => 'getUseAlways',
    writer => 'setUseAlways'
);

has 'no_display' => (
    is => 'rw',
    reader => 'getNoDisplay',
    writer => 'setNoDisplay'
);

has 'alias' => (
    is => 'rw',
    reader => 'getAlias',
    writer => 'setAlias'
);

has 'no_full_select_column' => (
    is => 'rw',
    reader => 'getNoFullSelectColumn',
    writer => 'setNoFullSelectColumn'
);

has 'show_options' => (
    is => 'rw',
    reader => 'getShowOptions',
    writer => 'setShowOptions'
);


sub BUILD {
    my $self = shift;
}

sub loadOptions{
    my $self = shift;
    return $self->{options};
}

sub toHash{
    my $self = shift;
    my $hash = {};

    if($self->getName() && $self->getDimension() && $self->getField()){
        $hash->{name} = $self->getName();
        $hash->{description} = $self->getDescription();
        if($self->getShowOptions()){
            $hash->{show_options} = $self->getShowOptions();
        }

        if($self->getOptions()){
            $hash->{options} = $self->getOptions();
        }
    }
    return $hash;
}

sub modifyOptions{
    my $self = shift;
    my $options = $_[0];
    return $options;
}

sub optionModifier{}

1;
