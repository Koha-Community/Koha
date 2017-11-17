#!/usr/bin/perl
package Koha::Reporting::Report::Grouping::CnClass;

use Modern::Perl;
use Moose;
use Data::Dumper;
use C4::Context;

extends 'Koha::Reporting::Report::Grouping::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('cn_class');
    $self->setAlias('cn_class');
    $self->setNoFullSelectColumn(1);
    $self->setShowOptions(1);
    $self->setDescription('Class');
    $self->setDimension('item');
    $self->setField('cn_class_primary');
}

sub optionModifier{
    my $self = shift;
    my $options = $_[0];
    my $field;
    if($options eq '0'){
        $field = 'cn_class_primary';
    }
    elsif($options eq '1'){
        $field = "CONCAT(cn_class_primary, IF(cn_class_1_dec is not null,'.', '') , IFNULL(cn_class_1_dec,'') )";
    }
    elsif($options eq '2'){
        $field = "CONCAT(cn_class_primary, IF(cn_class_1_dec is not null,'.', '') , IFNULL(cn_class_1_dec,''), IFNULL(cn_class_2_dec,'') )";
    }
    elsif($options eq '3'){
        $field = "CONCAT(cn_class_primary, IF(cn_class_1_dec is not null,'.', '') , IFNULL(cn_class_1_dec,''), IFNULL(cn_class_2_dec,''), IFNULL(cn_class_3_dec,'') )";
    }

    if(defined $field){
       $self->setField($field);
    }
}


1;
