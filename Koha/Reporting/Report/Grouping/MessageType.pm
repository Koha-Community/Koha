#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::MessageType;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('message_type');
    $self->setAlias('Message type');
    $self->setDescription('Message type');
    $self->setDimension('fact');
    $self->setField('message_type');
}

1;
