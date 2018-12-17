#!/usr/bin/perl
package Koha::Reporting::Report::Filter::TransportType;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('transport_type');
    $self->setDescription('Transport type');
    $self->setType('multiselect');
    $self->setDimension('fact');
    $self->setField('transport_type');
    $self->setRule('in');
    $self->setAddNotSetOption(0);
}

sub loadOptions{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $options = [];

    my $stmnt = $dbh->prepare("select distinct transport_type from reporting_messages_fact order by transport_type ASC");
    $stmnt->execute();
    if ($stmnt->rows >= 1){
        while ( my $row = $stmnt->fetchrow_hashref ) {
            my $option = {'name' => $row->{'transport_type'}, 'description' => $row->{'transport_type'}};
            push $options, $option;
        }
    }

    return $options;
}

1;
