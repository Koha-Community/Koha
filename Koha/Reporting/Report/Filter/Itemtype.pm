#!/usr/bin/perl
package Koha::Reporting::Report::Filter::Itemtype;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('itemtype');
    $self->setDescription('Item type');
    $self->setType('multiselect');
    $self->setDimension('item');
    $self->setField('itemtype');
    $self->setRule('in');
}

sub loadOptions{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $branches = [];

    my $stmnt = $dbh->prepare("select itemtype, description from itemtypes order by FIELD(description,'Kirja') DESC, Description ASC");
    $stmnt->execute();
    if ($stmnt->rows >= 1){
        while ( my $row = $stmnt->fetchrow_hashref ) {
            my $option = {'name' => $row->{'itemtype'}, 'description' => $row->{'description'}};
            push $branches, $option;
        }
    }

    return $branches;
}

1;
