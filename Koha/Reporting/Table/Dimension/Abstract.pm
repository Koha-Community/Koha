#!/usr/bin/perl
package Koha::Reporting::Table::Dimension::Abstract;

use Modern::Perl;
use Moose;
use Data::Dumper;
use Scalar::Util qw(looks_like_number);
use List::MoreUtils qw(uniq);
use MARC::Record;
use MARC::File::XML ( BinaryEncoding => 'utf8', RecordFormat => 'MARC21' );
use Encode;
use utf8;
#use MARC::Field;

extends 'Koha::Reporting::Table::Abstract';

has 'business_key' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    reader => 'getBusinessKey',
    writer => 'setBusinessKey'
);

has 'import_business_key_ids' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    reader => 'getImportBusinesKeyIds',
    writer => 'setImportBusinesKeyIds'
);

has 'import_key_mapping' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} },
    reader => 'getImportKeyMapping',
    writer => 'setImportKeyMapping'
);


sub initDefaultImportColumns{
    my $self = shift;
    my $allColumns = $self->getColumns();
    foreach my $column (@$allColumns){
        if($column ne $self->getPrimaryId()){
            $self->addImportColumn($column);
        }
    }
}

sub addImportBusinesKeyId{
    my $self = shift;
    my $id = $_[0];
    if($id){
        push @{$self->{import_business_key_ids}}, $id;
    }
}

sub getPrimaryIdByBusinessKey{
    my $self = shift;
    my $businessKeys = $_[0];
    my $primaryId;
    my $mapping = $self->getImportKeyMapping();
    while (my ($index, $businessKey) = each @$businessKeys) {
        if(defined $mapping->{$businessKey}){
            $mapping = $mapping->{$businessKey};
        }
    }
    if(looks_like_number($mapping)){
         $primaryId = $mapping;
    }
    return $primaryId;
}

sub loadKeyMapping{
    my $self = shift;
    my $ids = $self->getImportBusinesKeyIds();
    my $dbh = C4::Context->dbh;
    my $select = '';
    my $where = '';
    $self->{import_key_mapping} = {};
    if(@$ids){
        print Dumper $self->getTableName();
        print Dumper "import bkey count: " . @$ids;
        my $bussinesKeys = $self->getBusinessKey();
        my $lastKeyI = $#$bussinesKeys;
        my $columnsSelect = '';
        while (my ($index, $businessKey) = each @$bussinesKeys) {
            $columnsSelect .= $businessKey;
            if($index != $lastKeyI){
                $columnsSelect .= ', ';
            }
        }
        my @bKeyCount;
        $select = 'SELECT '. $self->getPrimaryId() . ', ' .$columnsSelect. ' FROM ' . $self->getTableName();
        my $stmnt = $dbh->prepare($select);
        $stmnt->execute() or die($DBI::errstr);
        if($stmnt->rows >= 1){
        my @unique = uniq @bKeyCount;

        print Dumper "import key count: " . $stmnt->rows;
            my $row;
            my $keyValue;
            while($row = $stmnt->fetchrow_hashref) {
                my $hash = $self->{import_key_mapping};
                my $lastKey = $#$bussinesKeys;
                while (my ($index, $businessKey) = each @$bussinesKeys) {
                    if(defined $row->{$businessKey}){
                         $keyValue = $row->{$businessKey};
                        if($lastKey != $index){
                            if(!defined $hash->{$keyValue}){
                                $hash->{$keyValue} = {};
                            }
                            $hash = $hash->{$keyValue};
                        }
                    }
                }
                my $primaryKey = $self->getPrimaryId();
                if(defined $row->{$primaryKey}){
                    $hash->{$keyValue} = $row->{$primaryKey};
                }
            }
        }
        else{
            print Dumper $select;
        }
    }
    else{
        die Dumper "No ids!";
    }
}

sub addImportRow{
    my $self = shift;
    my $row = $_[0];
    my ($key, $lastKey, $lastKeyValue);
    my $keys = $self->getRowBusinessKey($row);
    if($row && $keys){
        $self->addImportBusinesKeyId($keys);
        my $keyHash = $self->{import_rows_by_business_key};
        my @keyArray = sort keys %{$keys};
        $lastKey = $keyArray[-1];
        foreach my $keyName (@keyArray) {
            $key = $keys->{$keyName};
            if($keyName ne $lastKey){
                if(!defined $keyHash->{$key}){
                    $keyHash->{$key} = {};
                }
                $keyHash = $keyHash->{$key};
            }
            else{
                $lastKeyValue = $key;
            }
        }

        if(!defined $keyHash->{$lastKeyValue}){
            push @{$self->{import_rows}}, $row;
            my $ref = $self->{import_rows};
            $keyHash->{$lastKeyValue} = $#$ref;
        }
        else{
            my $rowKey = $keyHash->{$lastKeyValue};
            if(defined $self->{import_rows}[$rowKey]){
                $self->{import_rows}[$rowKey] = $row;
            }
        }
    }
    return {%$keys};
}

sub initMarcXml{
    my $self = shift;
    my $xml = $_[0];
    my $record;
    if($xml){
        $xml = encode('UTF-8', $xml, Encode::FB_CROAK);
        $record = MARC::Record->new_from_xml($xml);
    }
    return $record;
}

sub skipFilter{
    my $self = shift;
    my $filter = $_[0];
    return 0;
}


1;
