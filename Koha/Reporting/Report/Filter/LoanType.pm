#!/usr/bin/perl
package Koha::Reporting::Report::Filter::LoanType;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('loan_type');
    $self->setDescription('Loan type');
    $self->setType('multiselect');
    $self->setDimension('fact');
    $self->setField('loan_type');
    $self->setRule('in');
    $self->setAddNotSetOption(0);
}

sub loadOptions{
   my $self = shift;
   my $options = [
       {'name' =>'Issue', 'description' => 'First Issue'},
       {'name' =>'Renew', 'description' => 'Renew'}
   ];
   return $options;
}

1;
