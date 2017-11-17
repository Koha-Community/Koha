#!/usr/bin/perl
package Koha::Reporting::Report::Filter::LanguageAll;

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
    $self->setField('language_all');
    $self->setRule('in');
}

sub loadOptions{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $options = [];

    my $stmnt = $dbh->prepare("select distinct language_all from reporting_item_dim order by FIELD(language_all, 'eng', 'swe', 'fin') DESC, language_all ASC");
    $stmnt->execute();
    if ($stmnt->rows >= 1){
        while ( my $row = $stmnt->fetchrow_hashref ) {
            my $option = {'name' => $row->{'language_all'}, 'description' => $row->{'language_all'}};
            push $options, $option;
        }
    }
    return $options;
}

1;
