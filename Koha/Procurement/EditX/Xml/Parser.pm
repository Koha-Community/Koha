#!/usr/bin/perl
package Koha::Procurement::EditX::Xml::Parser;

use Modern::Perl;
use Moose;
use XML::Simple;
use XML::LibXML;
use XML::LibXML::XPathContext;
use File::Slurp;
use Encode;
use Koha::Procurement::Logger;
#use utf8;
use Unicode::Normalize;
use Data::Dumper;

my @filteredFileNames = ( '.', '..' );
my %filteredFileNamesHash;
my $objectFactory;

has 'objectFactory' => (
    is      => 'rw',
    isa => 'Koha::Procurement::EditX::Xml::ObjectFactory'
);

has 'logger' => (
    is      => 'rw',
    isa => 'Koha::Procurement::Logger',
    reader => 'getLogger',
    writer => 'setLogger',
);

sub BUILD {
    my $self = shift;
    $self->setLogger(new Koha::Procurement::Logger);
    %filteredFileNamesHash = map { $_ => 1 } @filteredFileNames;
}

sub parseFiles{
    my $self = shift;
    my $dirPath = $_[0];
    my @fileNames;
    my %parsedFiles;
    my $fileName;
    my $fullFilePath;
    my $object;

    $dirPath = $1 if($dirPath=~/(.*)\/$/);
    $dirPath = $dirPath . '/';

    @fileNames = $self->getFileNamesInDirectory($dirPath);

    if(@fileNames){
        foreach (@fileNames){
            $fileName = $_;
            $self->getLogger()->log("Started parsing file: $fileName");
            if($self->filterFile($fileName)){
                $self->getLogger()->log("The file $fileName was filtered and will not be parsed.");
                next;
            }
            $fullFilePath = $dirPath . $fileName;
            $object = $self->parseFile($fullFilePath);
            if($object){
                $self->getLogger()->log("The file $fileName was parsed successfully.");
                $object->setFileName($fileName);
                if(%parsedFiles){
                    $parsedFiles{$fullFilePath} = $object;
                }
                else{
                    $parsedFiles{$fullFilePath} = $object;
                }
            }
        }
    }

    return %parsedFiles;
}

sub parseFile{
    my $self = shift;
    my $filePath = $_[0];
    my $object = 0;

    if(! -f $filePath){
        $self->getLogger()->log("The file $filePath does not exist.");
        return 0;
    }

    my $parser = XML::LibXML->new(no_blanks => 1);
    my $fileData = read_file($filePath);
    if(!$fileData){
        $self->getLogger()->logError("Could not read file $filePath");
        return 0;
    }
   # $fileData = NFC($fileData);
    $fileData = encode('UTF-8', $fileData, Encode::FB_CROAK);
    $parser = eval { $parser->load_xml('string' => $fileData) };

    my $xml = XML::LibXML::XPathContext->new;

    if($parser){
        $object = $self->objectFactory->createFromXml($xml, $parser);
    }
    else{
        $self->getLogger()->log("The file " . $filePath . " is not a valid xmlfile.");
        $self->getLogger()->log("Errors: $@");
    }

    return $object;
}

sub getFileNamesInDirectory{
    my $self = shift;
    my $dirPath = $_[0];
    my @fileNames;

    if( -d $dirPath ){
        opendir(my $dh, $dirPath);
        while(readdir $dh) {
            push @fileNames, $_;
        }
        closedir $dh;
    }

    return @fileNames;
}

sub filterFile{
    my $self = shift;
    my $fileName = $_[0];
    my $result = 0;
    if(exists($filteredFileNamesHash{$fileName})){
        $result = 1;
    }
    return $result;
}

sub validateSchema{
    my $self = shift;
    my $xml = $_[0];
    my $schema = $self->objectFactory->getSchema();
    my $result;

    if(-f $schema){
        my $xmlschema = XML::LibXML::Schema->new( location => $schema );
        $result = eval { $xmlschema->validate($xml) };
    }
    else{
        $self->getLogger()->logError("The Xml Schema was not found in $schema. Can not validate files.");
    }

    if(defined $result && $result == 0){
        return 1;
    }
    else{
        return 0;
    }
}


1;
