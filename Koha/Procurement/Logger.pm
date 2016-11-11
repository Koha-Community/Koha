#!/usr/bin/perl
package Koha::Procurement::Logger;

use C4::Context;
use Data::Dumper;
use POSIX qw(strftime);

my $singleton;
my $logFolder = 0;
my $errorLogPath;
my $transactionLogPath;

sub new {
    my $class = shift;
    if(! $logFolder){
        $logFolder = $_[0];
        if(-d $logFolder){
            $logFolder = $1 if($logFolder=~/(.*)\/$/);
            $logFolder = $logFolder . '/';
            $transactionLogPath = $logFolder . "transaction.log";
            $errorLogPath = $logFolder . "error.log";

            unless(open FILE, '>>'. $transactionLogPath) {
                die "\nUnable to create $transactionLogPath\n";
            }

            unless(open FILE, '>>'. $errorLogPath) {
                die "\nUnable to create $errorLogPath\n";
            }
        }
    }

    $singleton ||= bless {}, $class;
}

sub log{
    $self = shift;
    my $message = $_[0];
    my $useEcho = $_[1];
    $self->writeToFile($transactionLogPath, $message);

    if($useEcho){
        print "$message\n";
    }
}

sub logError{
    $self = shift;
    my $message = $_[0];
    my $useEcho = $_[1];
    $self->writeToFile($errorLogPath, $message);

    if($useEcho){
        warn  "$message\n";
    }
}

sub writeToFile{
    $self = shift;
    my $filePath = $_[0];
    my $message = $_[1];

    if(-f $filePath && $message ){
        open(my $fh, '>>', $filePath);
        $message = $self->getTimeStamp() . " -- " . $message . "\n";
        print $fh "$message";
        close $fh;
    }
}

sub getTimeStamp {
    my $self = shift;
    return strftime("%Y-%m-%d %H.%M.%S", localtime);
}

1;
