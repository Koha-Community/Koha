#!/usr/bin/perl

use Modern::Perl;
use Try::Tiny;
use Data::Dumper;

use Koha::Procurement::Config;
use Koha::Procurement::EditX::Xml::Parser;
use Koha::Procurement::EditX::Xml::ObjectFactory::LibraryShipNotice;
use Koha::Procurement::OrderProcessor;
use Koha::Procurement::BranchLocationYear::Parser;
use Koha::Procurement::Logger;
use Koha::Procurement::File;

my $config = new Koha::Procurement::Config;
my $settings = $config->getSettings();
my $logPath;

if(defined $settings->{'settings'}->{'log_directory'}){
    $logPath = $settings->{'settings'}->{'log_directory'};
}
else{
    die('The log_directory not set in config.');
}

my $fileManager = new Koha::Procurement::File;
my $logger = new Koha::Procurement::Logger($logPath);
my $orderProcessor = new Koha::Procurement::OrderProcessor;

$logger->log("Started Koha::Procurement",1);
my $parser = new Koha::Procurement::EditX::Xml::Parser((
    'objectFactory', new Koha::Procurement::EditX::Xml::ObjectFactory::LibraryShipNotice((
            'schemaPath','/home/koha/kohaclone/Koha/Procurement/EditX/XmlSchema/'
        ))
    ));

my %orders;
my $libraryShipNoticePath;

if(defined $settings->{'settings'}->{'import_load_path'}){
    $libraryShipNoticePath = $settings->{'settings'}->{'import_load_path'};
}

$fileManager->fillLoadFolder();
%orders = $parser->parseFiles($libraryShipNoticePath);

my $fileName;
my $order;
if(%orders){
    while ( ($fileName, $order) = each %orders )
    {
       try{
            $logger->log("Started processing order from file $fileName");
            $orderProcessor->startProcessing();
            $orderProcessor->process($order);
            $orderProcessor->endProcessing();
            $fileManager->archiveFile($fileName);
            $logger->log("Ended processing order from file $fileName");
        }
        catch{
            $orderProcessor->rollBack();
            $fileManager->moveToFailFolder($fileName);
            my $failMsq = "Order processing failed for file  $fileName. Rolling back.";
            $logger->log($failMsq);
            $logger->logError($failMsq);
            $logger->logError("Error was: $_");
        }
    }
}
$logger->log("Ended Koha::Procurement",1);
