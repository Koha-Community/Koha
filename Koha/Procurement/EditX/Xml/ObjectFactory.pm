#!/usr/bin/perl
package Koha::Procurement::EditX::Xml::ObjectFactory;

use Modern::Perl;
use Moose;
use XML::Simple;
use Koha::Procurement::Config;
use Class::Load ':all';
use Data::Dumper;

has 'schemaPath' => (
    is => 'ro',
    reader => 'getSchemaPath'
);

has 'schemaName' => (
    is => 'rw',
    reader => 'getSchemaName',
    writer => 'setSchemaName'
);

has 'objectName' => (
    is => 'rw',
    reader => 'getObjectName',
    writer => 'setObjectName',
    default => 0
);

my @objectCandidates = ();

sub getSchema {
    my $self = shift;
    my $schemaFile = $self->getSchemaPath() . $self->getSchemaName();
}

sub createFromXml{
    my $self = shift;
    my $xmlObject = $_[0];
    my $parser = $_[1];
    my $object;

    $self->determineObjectClass($xmlObject, $parser);
    $object = $self->createObject($self->getObjectName());
    $self->fillValues($object, $xmlObject, $parser);

    return $object;
}

sub createObject{
    my $self = shift;
    my $className = $_[0];
    my $object = 0;

    if(!is_class_loaded($className)){
        try_load_class($className);
    }

    if(is_class_loaded($className)){
        $object = $className->new;
    }
    return $object;
}

sub determineObjectClass{
    my $self = shift;
    my $xmlObject = $_[0];
    my $parser = $_[1];
    my @objectCandidates = $self->getObjectCandidates();
    my $className;
    my $result = 0;

    foreach(@objectCandidates){
        $className = $_;
        $result = 0;

        if(!is_class_loaded($className)){
            try_load_class($className);
        }

        if(is_class_loaded($className) && $className->can('determineObjectClass')){
            $result = $className->determineObjectClass($xmlObject, $parser);

            if($result == 1){
                $self->setObjectName($className);
                last;
            }
        }
    }
}

sub fillValues{} #a placeholder

sub addObjectCandidate{
    my $self = shift;
    my $candidate = $_[0];
    my @candidates;
    push @objectCandidates, $candidate;
}

sub getObjectCandidates{
    return @objectCandidates;
}

sub setObjectCandidates{
    my $self = shift;
    @objectCandidates = $_[0];
}

sub createItemObject{
    my $self = shift;
    my ($object) = @_;

    my $itemObject = 0;
    my $itemObjectName = 0;
    if($object && $object->can('getItemObjectName')){
        $itemObjectName = $object->getItemObjectName();
    }

    if($itemObjectName){
        $itemObject = $self->createObject($itemObjectName);
        if($itemObject && $itemObject->can('setParent')){
           $itemObject->setParent($object);
        }
    }
    return $itemObject;
}

sub createItemObjects{
    my $self = shift;
    my ($object, $xmlObject, $documentXmlObject, $parser, $items) = @_;
    my $itemObject = 0;
    my $item;

    my $itemCount = $items->size();
    if($items && $itemCount >= 1){
        for(my $i = 1; $itemCount >= $i ; $i++){
            $item = $items->get_node($i);

            if($item && $item->isa('XML::LibXML::Element')){
                $itemObject = $self->createItemObject($object);
                if($itemObject){
                    $itemObject->setXmlData($item);
                    $itemObject->setParser($xmlObject);
                    $itemObject->setDocumentXmlData($documentXmlObject);
                    $object->addItem($itemObject);
                }
            }
        }
    }
}

1;
