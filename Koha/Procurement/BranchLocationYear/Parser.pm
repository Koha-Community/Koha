#!/usr/bin/perl
package Koha::Procurement::BranchLocationYear::Parser;

use Moose;
use Data::Dumper;
use Scalar::Util qw(looks_like_number);
use C4::Context;
use Koha::Procurement::Config;

has 'branchCode' => (
    is => 'rw',
    reader => 'getBranchCode',
    writer => 'setBranchCode'
);

has 'location' => (
    is => 'rw',
    reader => 'getLocation',
    writer => 'setLocation'
);

has 'year' => (
    is => 'rw',
    reader => 'getYear',
    writer => 'setYear'
);

has 'config' => (
    is      => 'rw',
    isa => 'Koha::Procurement::Config',
    reader => 'getConfig',
    writer => 'setConfig'
);

sub BUILD {
    my $self = shift;
    $self->setConfig(new Koha::Procurement::Config);
}

sub getBranchCodeList {
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $stmnt = $dbh->prepare("select branchcode from branches");
    my @branches = @{$dbh->selectcol_arrayref($stmnt)};

    my @sortedBranches = sort { length $a <=> length $b } @branches;
    return @sortedBranches;
}

sub getLocationList {
    my $self = shift;
    my $allowedLocationsList;
    my $settings = $self->getConfig()->getSettings();
    if(defined $settings->{settings}->{allowed_locations} ){
        $allowedLocationsList = $settings->{settings}->{allowed_locations};
    }
    my @locations = split(',', $allowedLocationsList);
    my @sortedLocations = sort { length $b <=> length $a } @locations;
    return @sortedLocations;
}

sub extract {
    my $self = shift;
    my $branchLocationYear = $_[0];
    my ($branchLocation, $year) = $self->extractYear($branchLocationYear);
    my ($branch, $location) = $self->extractLocation($branchLocation);

    if(looks_like_number($year) && ( $year > 1000 && $year < 9999 ) && $branch && $location){
        $self->setYear($year);
        $self->setBranchCode($branch);
        $self->setLocation($location);
    }
}

sub extractYear {
    my $self = shift;
    my $branchLocationYear = $_[0];
    my ($year, $branchLocation);

    $year =  substr($branchLocationYear, -4, 4);
    $branchLocation = substr($branchLocationYear, 0, -4);
    return ($branchLocation, $year );
}

sub extractLocation {
    my $self = shift;
    my $branchLocation = $_[0];
    my ($branch, $location, $validBranch, $validLocation, $branchPortion);
    my $strLen = 0;

    my @validLocations = $self->getLocationList();
    my @validBranchCodes = $self->getBranchCodeList();

    foreach(@validLocations){
        $validLocation = $_;
        if( $branchLocation =~ /$validLocation$/){
            $strLen = length $validLocation;
            $branchPortion = substr($branchLocation,0,-$strLen);
            foreach(@validBranchCodes){
                $validBranch = $_;
                if($branchPortion eq $validBranch){
                    $location = $validLocation;
                    $branch =  $validBranch;
                    last;
                }
            }
            if($branch && $location){
                last;
            }
        }
    }
    return($branch, $location);
}

1;
