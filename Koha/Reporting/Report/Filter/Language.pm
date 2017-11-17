#!/usr/bin/perl
package Koha::Reporting::Report::Filter::Language;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('language');
    $self->setDescription('Language');
    $self->setType('multiselect');
    $self->setDimension('item');
    $self->setField('language');
    $self->setRule('in');
}

sub loadOptions{
   my $self = shift;
   my $languages = [
       {'name' =>'fin', 'description' => 'suomi'},
       {'name' =>'swe', 'description' => 'ruotsi'},
       {'name' =>'other', 'description' => 'muunkieliset'},
   ];
   return $languages;
}

1;
