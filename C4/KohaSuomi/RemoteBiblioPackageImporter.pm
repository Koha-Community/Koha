#!/bin/bash/perl

# Copyright (C) 2016 KohaSuomi
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=NAME

RemoteBiblioPackageImporter

=SYNOPSIS

1. Connects to a remote target to pull new bibliographic record packages
2. Validates them
3. Stages them
4. Optionally pushes them to the catalogue.

=cut

package C4::KohaSuomi::RemoteBiblioPackageImporter;

use Modern::Perl;
use Try::Tiny;
use Scalar::Util qw(blessed);

use DateTime;
use File::Basename;
use File::Fu::File;
use File::Fu::Dir;

use Koha::Logger;
use Data::Dumper;

use C4::Context;
use C4::KohaSuomi::AcquisitionIntegration;
use C4::Matcher;

use Koha::Exception::BadParameter;
use Koha::Exception::File;
use Koha::Exception::UnknownProgramState;
use Koha::Exception::Parse;
use Koha::Exception::BadSystemPreference;

our $logger = Koha::Logger->get();

=head2 new

    my $importer = C4::KohaSuomi::RemoteBiblioPackageImporter->new({
            remoteId => 'BTJBiblios', #The name of the remote bibliographic package source in syspref <<TODO>>
            packageMaxAge => 356 #in days. Stop looking for packages older than
                                 #this when staging MARC for the Koha reservoir
        });

=cut

sub new {
    my ($class, $params) = _validateNew(@_);
    my $self = {};
    $self->{_params} = $params;
    bless($self, $class);
    Log::Log4perl::MDC->put('remote', $params->{remoteId});

    $self->setRemote($params->{remoteId});
    $self->loadImportedPackages();

    $logger->trace("Object instantiated with params") if $logger->is_trace();
    return $self;
}
sub _validateNew {
    my ($class, $params) = @_;
    unless ($params->{remoteId}) {
        Koha::Exception::BadParameter->throw(error => "Param 'remoteId' is missing");
    }
    unless ($params->{packageMaxAge}) {
        $params->{packageMaxAge} = 365;
    }
    return @_;
}

sub setRemote {
    my ($self, $remoteId) = @_;
    $self->{remote} = C4::KohaSuomi::AcquisitionIntegration::getVendorConfig($remoteId);
}
sub getRemote {
    return shift->{remote};
}
sub getRemoteId {
    return shift->{_params}->{remoteId};
}
sub getPackageMaxAge {
    return shift->{_params}->{packageMaxAge};
}

=head2 getLocalStorageDir

@RETURNS File::Fu::Dir, where the files from the current vendor are stored locally

=cut

sub getLocalStorageDir {
    my ($self) = @_;
    return File::Fu::Dir->new( $self->getRemote()->localStorageDir , $self->getRemoteId() )
}

=head2 importFromRemote

Pulls bibliographic records from the given remote.

@param {String} $remoteId, Name of the remote target configuration in the <TODO<sysprefname>>
@returns {ArrayRef of File::Fu::File} objects depicting the marc package file, enhanced with reporting about executed steps

=cut

sub importFromRemote {
    my ($self) = @_;
    $logger->trace("Importing") if $logger->is_trace();

    my $remote = $self->getRemote();
    my $newLocalPackages = $self->getNewPackages();

    if ($remote->stageFiles) {
        $self->stageLocalPackages($newLocalPackages, $remote->encoding, $remote->matcher, $remote->format);

        if ($remote->commitFiles) {
            $self->commitStagedPackages($newLocalPackages);
        }
    }
    return $newLocalPackages;
}

=head2 getNewPackages

    my $files = $importer->getNewPackages();

@returns {ArrayRef of Files} new marc package files not yet imported to our Koha;

=cut

sub getNewPackages {
    my ($self) = @_;
    my $importePackages = $self->loadImportedPackages();
    my $ftpcon = Koha::FTP->new(  Koha::FTP::connect($self->getRemote(), $self->getRemoteId())  );
    $ftpcon->changeFtpDirectory($self->getRemote()->basedir);

    my $newRemoteFilePaths = $self->_listNewFiles($ftpcon);
    my $newLocalPackages = $self->_getPackages($ftpcon, $newRemoteFilePaths);

    $ftpcon->quit();
    return $newLocalPackages;
}

=head2 _listNewFiles

@returns {ArrayRef of String}, absolute filePaths in the remote system

=cut

sub _listNewFiles {
    my ($self, $ftpcon) = @_;

    my $now = DateTime->now();
    my $regexpValidator = $self->getRemote()->fileRegexp;
    my $ftpfiles = $ftpcon->listFtpDirectory();
    my @newFilePaths;
    foreach my $file (@$ftpfiles) {
        $logger->debug("Looking at package '$file'") if $logger->is_debug();
        if ($file =~ qr($regexpValidator)) { #Pick only files of specific format
            my $difference_days = _getDateDiff($1, $2, $3, $now->year(), $now->month(), $now->day());

            unless ( $difference_days >= 0 &&
                     $difference_days < $self->getPackageMaxAge()) { #if the package is too old, skip trying to stage it.
                $logger->trace("Package '$file' is stale") if $logger->is_trace();
                next;
            }
            if ($self->_isPackageImported($file)) {
                $logger->trace("Package '$file' is already imported") if $logger->is_trace();
                next;
            }

            $logger->info("Accepted package '$file'") if $logger->is_info();
            push(@newFilePaths, $file);
        }
        else {
            $logger->trace("Package '$file' doesn't match the regexp '$regexpValidator'") if $logger->is_trace();
        }
    }
    return \@newFilePaths;
}

sub _getPackages {
    my ($self, $ftpcon, $filePaths) = @_;

    my $packagesDir = $self->getLocalStorageDir();
    $logger->debug("Getting packages to '".$packagesDir->stringify()."'") if $logger->is_debug();
    unless($packagesDir->e()) {
        $packagesDir->create();
        unless($packagesDir->e()) {
            Koha::Exception::File->throw(error => "Couldn't create a directory for marc packages for \$remoteId '".$self->getRemoteId()."'");
        }
    }

    my @newPackages;
    foreach my $filePath (@$filePaths) {
        my $newPackage = $packagesDir->file($filePath);
        $newPackage->touch();
        unless($newPackage->e()) {
            Koha::Exception::File->throw(error => "Couldn't create a marc package file '".$newPackage->stringify."' for \$remoteId '".$self->getRemoteId()."'");
        }
        $ftpcon->get($filePath, $newPackage->stringify);
        push(@newPackages, $newPackage);
        $logger->trace("Package '".$newPackage->stringify."' fetched") if $logger->is_debug();
    }

    return \@newPackages;
}

sub _getDateDiff {
    my ($y1, $m1, $d1, $y2, $m2, $d2) = @_;
    my $dt1 = DateTime->new(year => ($y1 || 2000), month => $m1, day => $d1, time_zone => C4::Context->tz());
    my $dt2 = DateTime->new(year => ($y2 || 2000), month => $m2, day => $d2, time_zone => C4::Context->tz());
    my $duration = $dt1->subtract_datetime($dt2);
    my $days = $duration->in_units('days');
    return ($days > 0)  ?  $days  :  -1 * $days;
}

sub loadImportedPackages {
    my ($self) = @_;
    my $dbh = C4::Context->dbh();

    my $sth = $dbh->prepare('SELECT * FROM import_batches WHERE (TO_DAYS(curdate())-TO_DAYS(upload_timestamp)) < ? ORDER BY file_name;');
    $sth->execute( $self->getPackageMaxAge() );
    my $ary = $sth->fetchall_arrayref({});

    #Get the filename from the path for all SELECTed filenames/paths
    my $fns = {}; #hash of filenames!
    foreach my $ib (@$ary) {
        my $basename = File::Basename::basename($ib->{file_name});
        $fns->{ $basename } = $ib;
        $logger->trace('Found existing import batch '.$basename) if $logger->is_trace();
    }
    $self->{importedBatches} = $fns;
}
sub _isPackageImported {
    my ($self, $fileName) = @_;
    if (exists $self->{importedBatches}->{$fileName}) {
        return 1;
    }
    return undef;
}

=head stageLocalPackages

    C4::KohaSuomi::RemoteBiblioPackageImporter->stageLocalPackages($localPackages, $encoding, $matcher, $format);

=cut

sub stageLocalPackages {
    my ($class, $localPackages, $encoding, $matcher, $format) = @_;

    foreach my $package (@$localPackages) {
        $class->stageLocalPackage($package, $encoding, $matcher, $format);
    }
}

=head2 stageLocalPackage

    C4::KohaSuomi::RemoteBiblioPackageImporter->stageLocalPackages($localPackages, $encoding, $matcher, $format);

=cut

sub stageLocalPackage {
    my ($class, $package, $encoding, $matcher, $format) = @_;

    $package->{stagingReport} = {};
    try {
        my @args = ($ENV{KOHA_PATH}.'/misc/stage_file.pl',
                    '--file',     $package,
                    '--encoding', $encoding,
                    '--match',   ($matcher->{id} || 1),
                    '--comment',  '',
                    '--format',   $format);
        open(my $OUT, "@args 2>&1 |") or Koha::Exception::SystemCall->throw(error => "system @args failed: $!");
        my $output = join("", <$OUT>);
        $package->{stagingReport}->{plaintext} = $output;
        close($OUT);

        if (my $m = _parseString(\$output, 'Batch number assigned:\s+(\d+)')) {
            $package->{batchNumber} = $m->[0];
        }
        if (my $m = _parseString(\$output, 'Number of input records:\s+(\d+)')) {
            $package->{stagingReport}->{inputRecords} = $m->[0];
        }
        if (my $m = _parseString(\$output, 'Number of valid records:\s+(\d+)')) {
            $package->{stagingReport}->{validRecords} = $m->[0];
        }
        if (my $m = _parseString(\$output, 'Number of invalid records:\s+(\d+)')) {
            $package->{stagingReport}->{invalidRecords} = $m->[0];
        }
        if (my $m = _parseString(\$output, 'Number of records matched:\s+(\d+)')) {
            $package->{stagingReport}->{recordsMatched} = $m->[0];
        }
        $logger->info("Package '$package', batch number ".$package->{batchNumber}." staged with ".
                      "input:'".$package->{stagingReport}->{inputRecords}."' ".
                      "valid:'".$package->{stagingReport}->{validRecords}."' ".
                      "invalid:'".$package->{stagingReport}->{invalidRecords}."' ".
                      "matched:'".$package->{stagingReport}->{recordsMatched}."' ".
                      "") if $logger->is_info();
    } catch {
        $package->{stagingReport}->{error} = (blessed($_)) ? $_ : Koha::Exception->newFromDie($_);
        $logger->error( $package->{stagingReport}->{error} ) if $logger->is_error();
    };
}

=head2 commitStagedPackages

Warning, this function actually pushes the imported batch into the live DB instead of the reservoir.

=cut

sub commitStagedPackages {
    my ($class, $stagedPackages) = @_;

    foreach my $package (@$stagedPackages) {
        commitStagedPackage($package);
    }
}

sub commitStagedPackage {
    my ($package) = @_;
    next if $package->{stagingReport}->{error};

    $package->{commitReport} = {};
    try {
        my @args = ($ENV{KOHA_PATH}.'/misc/commit_file.pl',
                    '--batch-number', $package->{batchNumber},
                    );
        open(my $OUT, "@args 2>&1 |") or Koha::Exception::SystemCall->throw(error => "system @args failed: $!");
        my $output = join("", <$OUT>);
        $package->{commitReport}->{plaintext} = $output;
        close($OUT);

        if (my $m = _parseString(\$output, 'Batch number:\s+(\d+)')) {
            if ($m->[0] != $package->{batchNumber}) {
                Koha::Exception::UnknownProgramState->throw(error => "Staged batchNumber '".$package->{batchNumber}."' is different from the committed batchNumber '$1' for \$package '$package'");
            }
        }
        if (my $m = _parseString(\$output, 'Number of new records added:\s+(\d+)')) {
            $package->{commitReport}->{recordsAdded} = $m->[0];
        }
        if (my $m = _parseString(\$output, 'Number of records replaced:\s+(\d+)')) {
            $package->{commitReport}->{recordsReplaced} = $m->[0];
        }
        if (my $m = _parseString(\$output, 'Number of records ignored:\s+(\d+)')) {
            $package->{commitReport}->{recordsIgnored} = $m->[0];
        }
        $logger->info("Package '$package', batch number ".$package->{batchNumber}." committed with ".
                      "added:'".$package->{commitReport}->{recordsAdded}."' ".
                      "replaced:'".$package->{commitReport}->{recordsReplaced}."' ".
                      "ignored:'".$package->{commitReport}->{recordsIgnored}."' ".
                      "") if $logger->is_info();
    } catch {
        $package->{commitReport}->{error} = (blessed($_)) ? $_ : Koha::Exception->newFromDie($_);
        $logger->error( $package->{commitReport}->{error} ) if $logger->is_error();
    }
}

sub _parseString {
    my ($haystackPtr, $needle) = @_;
    my @matches = $$haystackPtr =~ /$needle/s;
    unless (@matches) {
        my @cc = caller(1);
        Koha::Exception::Parse->throw(error => $cc[3]."():> Couldn't find \$needle '$needle' from \$haystack '$$haystackPtr'");
    }
    return \@matches;
}

1;
