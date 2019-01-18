#!/usr/bin/perl
package Koha::Reporting::Report::Filter::ItemtypeOkm;

use Modern::Perl;
use Moose;
use Data::Dumper;
use utf8;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('itemtype_okm');
    $self->setDescription('Item type');
    $self->setType('multiselect');
    $self->setDimension('item');
    $self->setField('itemtype_okm');
    $self->setRule('in');
}

sub loadOptions{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $itemTypes = [
        {'name' => 'Kirjat', 'description' => 'Kirjat'},
        {'name' => 'Nuotit ja partituurit', 'description' => 'Nuotit ja partituurit'},
        {'name' => 'Musiikkiäänitteet', 'description' => 'Musiikkiäänitteet'},
        {'name' => 'Muut äänitteet', 'description' => 'Muut äänitteet'},
        {'name' => 'Videot', 'description' => 'Videot'},
        {'name' => 'DVD ja Blu-ray -levyt', 'description' => 'DVD ja Blu-ray -levyt'},
        {'name' => 'CD-ROM-levyt', 'description' => 'CD-ROM-levyt'},
        {'name' => 'Muut aineistot', 'description' => 'Muut aineistot'},
        {'name' => 'Celian cd-levy', 'description' => 'Celian cd-levy'},
        {'name' => 'E-kirja', 'description' => 'E-kirja'},
        {'name' => 'Verkkoaineisto', 'description' => 'Verkkoaineisto'},
        {'name' => 'Lehdet', 'description' => 'Lehdet'}
    ];

    return $itemTypes;
}

1;
