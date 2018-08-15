#!/usr/bin/perl
package Koha::Reporting::Report::Filter::MessageType;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('message_type');
    $self->setDescription('Message type');
    $self->setType('multiselect');
    $self->setDimension('fact');
    $self->setField('message_type');
    $self->setRule('in');
}

sub loadOptions{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $options = [];

    my $stmnt = $dbh->prepare("select distinct message_type from reporting_messages_fact order by message_type ASC");
    $stmnt->execute();
    if ($stmnt->rows >= 1){
        while ( my $row = $stmnt->fetchrow_hashref ) {
            my $option = {'name' => $row->{'message_type'}, 'description' => $row->{'message_type'}};
            push @{$options}, $option;
        }
    }

    return $options;
}

1;
