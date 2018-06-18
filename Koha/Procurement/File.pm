#!/usr/bin/perl
package Koha::Procurement::File;

use Modern::Perl;
use Moose;
use Data::Dumper;
use Digest::SHA qw(sha256_base64);
use File::Slurp;
use File::Copy;
use File::Basename;
use XML::LibXML;

use C4::Context;
use Koha::Procurement::Logger;
use Koha::Procurement::Config;

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

has 'config' => (
    is      => 'rw',
    isa => 'Koha::Procurement::Config',
    reader => 'getConfig',
    writer => 'setConfig',
);

has 'tmp_path' => (
    is      => 'rw',
    reader => 'getTmpPath',
    writer => 'setTmpPath',
);

has 'load_path' => (
    is      => 'rw',
    reader => 'getLoadPath',
    writer => 'setLoadPath',
);

has 'archive_path' => (
    is      => 'rw',
    reader => 'getArchivePath',
    writer => 'setArchivePath',
);

has 'fail_path' => (
    is      => 'rw',
    reader => 'getFailPath',
    writer => 'setFailPath',
);

my @filteredFileNames = ( '.', '..' );
my %filteredFileNamesHash;

sub BUILD {
    my $self = shift;
    my ($tmpPath, $loadPath, $archivePath, $failPath);
    $self->setLogger(new Koha::Procurement::Logger);
    $self->setConfig(new Koha::Procurement::Config);
    %filteredFileNamesHash = map { $_ => 1 } @filteredFileNames;

    my $settings = $self->getConfig()->getSettings();
    if(defined $settings->{'settings'}->{'import_tmp_path'}){
        $tmpPath = $settings->{'settings'}->{'import_tmp_path'};
        $tmpPath = $self->normalizePath($tmpPath);
        $self->setTmpPath($tmpPath);
    }
    if(defined $settings->{'settings'}->{'import_load_path'}){
        $loadPath = $settings->{'settings'}->{'import_load_path'};
        $loadPath = $self->normalizePath($loadPath);
        $self->setLoadPath($loadPath);
    }
    if(defined $settings->{'settings'}->{'import_archive_path'}){
        $archivePath = $settings->{'settings'}->{'import_archive_path'};
        $archivePath = $self->normalizePath($archivePath);
        $self->setArchivePath($archivePath);
    }
    if(defined $settings->{'settings'}->{'import_failed_path'}){
        $failPath = $settings->{'settings'}->{'import_failed_path'};
        $failPath = $self->normalizePath($failPath);
        $self->setFailPath($failPath);
    }

    if(! defined $tmpPath || ! -d $tmpPath){
        die('import_tmp_path not set. Or it is not a directory.');
    }

    if(! defined $loadPath || ! -d $loadPath){
        die('import_load_path not set. Or it is not a directory.');
    }

    if(! defined $archivePath || ! -d $archivePath){
        die('import_archive_path not set. Or it is not a directory.');
    }

    if(! defined $failPath || ! -d $failPath){
        die('import_fail_path not set. Or it is not a directory.');
    }
}

sub fileAlreadyImported {
    my $self = shift;
    my $fileName = $_[0];
    my $filePath = $self->getTmpPath() . $fileName;
    my ($fileData, $fileDbHashCount);
    my $hash = 0;
    my $result = 0;
    if(-f $filePath ){
        eval {$fileData = read_file($filePath)};
        if($fileData){
            $hash = $self->hashFile($fileData);
        }
        if($hash){
            $fileDbHashCount = $self->loadFileHash($fileName, $hash);
            if($fileDbHashCount == 1){
                $result = 1;
            }
        }
    }
    return $result;
}

sub hashFile {
    my $self = shift;
    my $fileData = $_[0];
    my $hash = 0;
    if($fileData){
        $hash = sha256_base64($fileData);;
    }
    return $hash;
}

sub archiveFile {
    my $self = shift;
    my $filePath = $_[0];
    my $fileName = $self->getFilenaMeFromPath($filePath);
    my $archivePath = $self->getArchivePath() . $fileName;

    $self->saveFileHash($filePath, $fileName);
    if(move($filePath, $archivePath)){
        $self->getLogger()->log("File: $filePath moved to $archivePath for archive.");
    }
    else{
        $self->getLogger()->logError("File: $filePath could not be moved!");
    }
}

sub getFilenaMeFromPath {
    my $self = shift;
    my $filePath = $_[0];
    my $fileName = fileparse($filePath);
    return $fileName;
}

sub moveToFailFolder{
    my $self = shift;
    my $filePath = $_[0];
    my $fileName = $self->getFilenaMeFromPath($filePath);
    my $failPath = $self->getFailPath() . $fileName;

    if(move($filePath, $failPath)){
        $self->getLogger()->log("File: $filePath moved to $failPath.");
    }
    else{
        $self->getLogger()->logError("File: $filePath could not be moved!");
    }
}

sub fillLoadFolder {
    my $self = shift;
    my $tmpPath = $self->getTmpPath();
    my $loadPath = $self->getLoadPath();
    my @tmpFiles = $self->getFileNamesInDirectory($tmpPath);

    my ($tmpFile, $fullPath, $fullLoadPath);
    if(@tmpFiles > 2){
        foreach(@tmpFiles){
            $tmpFile = $_;
            $fullPath = $tmpPath . $tmpFile;
            $fullLoadPath = $loadPath . $tmpFile;
            if($self->filterFile($tmpFile)){
                next;
            }
            if(!eval{XML::LibXML->new()->parse_file($fullPath)}) {
                $self->getLogger()->log("File: $fullPath is not valid XML, processing postponed.");
                next;
            }
            if(!$self->fileAlreadyImported($tmpFile)){
                if(move($fullPath, $fullLoadPath)){
                    $self->getLogger()->log("File: $fullPath moved to $fullLoadPath for import.");
                }
                else{
                    $self->getLogger()->logError("File: $fullPath could not be moved!");
                }
            }
            else{
                if(unlink $fullPath){
                    $self->getLogger()->log("File: $fullPath already imported. Removing it.");
                }
                else{
                    $self->getLogger()->logError("File: $fullPath could not be unlinked!");
                }
            }
        }
    }
    else{
        $self->getLogger()->log("No new files found in $tmpPath for import.");
    }
}

sub normalizePath {
    my $self = shift;
    my $path = $_[0];
    $path = $1 if($path=~/(.*)\/$/);
    $path = $path . '/';
    return $path;
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
    my @exts = ('.xml');
    my ($name, $dir, $ext) = fileparse($fileName, @exts);

    if(!$ext || $ext ne '.xml'){
        $result = 1;
    }

    if(exists($filteredFileNamesHash{$fileName})){
        $result = 1;
    }
    
    return $result;
}

sub loadFileHash{
    my $self = shift;
    my $fileName = $_[0];
    my $fileHash = $_[1];
    my $result;

    if($fileName && $fileHash){
        my $dbh = C4::Context->dbh;
        my $stmnt = $dbh->prepare("SELECT file_id FROM procurement_file where file_name = ? and file_hash = ?");
        $stmnt->execute($fileName, $fileHash);
        $result = $stmnt->rows;
    }
    return $result;
}

sub saveFileHash{
    my $self = shift;
    my $filePath = $_[0];
    my $fileName = $_[1];
    my $hash;

    if(-f $filePath ){
        my $fileData = read_file($filePath);
        if($fileData){
            $hash = $self->hashFile($fileData);
            if($hash){
                my $dbh = C4::Context->dbh;
                my $stmnt = $dbh->prepare("INSERT INTO procurement_file (file_name, file_hash) VALUES (?,?)");
                if(!$stmnt->execute($fileName, $hash)){
                    $self->getLogger()->logError("Saving file hash failed! Error was: $DBI::errstr");
                }
            }
        }
    }
}


1;
