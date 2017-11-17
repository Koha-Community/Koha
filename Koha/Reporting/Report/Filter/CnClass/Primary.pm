#!/usr/bin/perl
package Koha::Reporting::Report::Filter::CnClass::Primary;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('cn_class_primary');
    $self->setDescription('Class');
    $self->setType('multiselect');
    $self->setDimension('item');
    $self->setField('cn_class_primary');
    $self->setRule('in');
}

sub loadOptions{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $options = [];

    my $stmnt = $dbh->prepare("select distinct cn_class_primary from reporting_item_dim order by cn_class_primary");
    $stmnt->execute();
    if ($stmnt->rows >= 1){
        while ( my $row = $stmnt->fetchrow_hashref ) {
            my $option = {'name' => $row->{'cn_class_primary'}, 'description' => $row->{'cn_class_primary'}};
            push $options, $option;
        }
    }
    return $options;
}

1;
