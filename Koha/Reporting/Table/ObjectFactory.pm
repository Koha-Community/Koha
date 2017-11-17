#!/usr/bin/perl
package Koha::Reporting::Table::ObjectFactory;

use Modern::Perl;
use Moose;
use Data::Dumper;
use Class::Load ':all';

sub createObject{
    my $self = shift;
    my $className = $_[0];
    my $object = 0;
    if($className){
        if(!is_class_loaded($className)){
            try_load_class($className);
        }

        if(is_class_loaded($className)){
            $object = $className->new;
        }
    }
    return $object;
}

1;
