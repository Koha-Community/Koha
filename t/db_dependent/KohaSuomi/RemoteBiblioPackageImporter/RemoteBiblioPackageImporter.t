#!/usr/bin/perl
#
# Copyright 2016 KohaSuomi
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

use Modern::Perl;
use Test::More;

use File::Fu::File;

use C4::ImportBatch;
use C4::KohaSuomi::RemoteBiblioPackageImporter;
use t::db_dependent::KohaSuomi::RemoteBiblioPackageImporter::Context;
use t::lib::TestObjects::ObjectFactory;

#C4::Context->setCommandlineEnvironment();
Koha::Logger->setConsoleVerbosity(undef); #Put this to 4 to log all levels

my $testContext = {};
my $matchers = t::db_dependent::KohaSuomi::RemoteBiblioPackageImporter::Context->prepareContext($testContext);



subtest "Connect to test ftp and verify test context is set", \&connectAndVerify;
sub connectAndVerify {
    my ($importer, $ftpcon, $newFilePaths);
    eval {

    $importer = C4::KohaSuomi::RemoteBiblioPackageImporter->new({remoteId => 'BTJBiblios'});

    $ftpcon = Koha::FTP->new(  Koha::FTP::connect($importer->getRemote(), $importer->getRemoteId())  );
    $ftpcon->changeFtpDirectory($importer->getRemote()->{basedir});

    ##Firstly push test packages upstream.
    my $B20160419xma = File::Fu::File->new($ENV{KOHA_PATH}.'/t/db_dependent/KohaSuomi/RemoteBiblioPackageImporter/B20160419xma');
    my $B20160419xmk = File::Fu::File->new($ENV{KOHA_PATH}.'/t/db_dependent/KohaSuomi/RemoteBiblioPackageImporter/B20160419xmk');
    my $B20160420xmk = File::Fu::File->new($ENV{KOHA_PATH}.'/t/db_dependent/KohaSuomi/RemoteBiblioPackageImporter/B20160420xmk');
    ok (-e $B20160419xma, 'B20160419xma available');
    ok (-e $B20160419xmk, 'B20160419xmk available');
    ok (-e $B20160420xmk, 'B20160420xmk available');
    $ftpcon->put($B20160419xma->stringify(), $B20160419xma->basename());
    $ftpcon->put($B20160419xmk->stringify(), $B20160419xmk->basename());
    $ftpcon->put($B20160420xmk->stringify(), $B20160420xmk->basename());

    ##Check if we can list them
    $newFilePaths = $importer->_listNewFiles($ftpcon);
    is($newFilePaths->[0], 'B20160419xma', 'Got a nice biblio filePath 0');
    is($newFilePaths->[1], 'B20160419xmk', 'Got a nice biblio filePath 1');
    is($newFilePaths->[2], 'B20160420xmk', 'Got a nice biblio filePath 2');
    is(scalar(@$newFilePaths), 3, 'Got 3 nice biblio filePaths');

    $ftpcon->quit();

    };
    if ($@) {
        ok(0, $@);
    }
}



subtest "Block importing same packages many times", \&blockDuplicateImports;
sub blockDuplicateImports {
    my ($importer, $ftpcon, $newFilePaths);
    eval {

    $importer = C4::KohaSuomi::RemoteBiblioPackageImporter->new({remoteId => 'BTJBiblios'});
    $ftpcon = Koha::FTP->new(  Koha::FTP::connect($importer->getRemote(), $importer->getRemoteId())  );
    $ftpcon->changeFtpDirectory($importer->getRemote()->{basedir});

    $importer->{importedBatches} = { #Overload import_batches from DB with our imaginary packages
        'B20160419xma' => {},
        'B20160419xmk' => {},
        'B20160420xmk' => {},
    };
    $newFilePaths = $importer->_listNewFiles($ftpcon);
    is(scalar(@$newFilePaths), 0, 'Got 0 nice biblio filePaths');

    $importer->{importedBatches} = { #Overload import_batches from DB with our imaginary packages
        'B20160419xma' => {},
        'B20160419xmk' => {},
    };
    $newFilePaths = $importer->_listNewFiles($ftpcon);
    is(scalar(@$newFilePaths), 1, 'Got 1 nice biblio filePath');
    is($newFilePaths->[0], 'B20160420xmk', 'Got a nice biblio filePath 0');

    $importer->{importedBatches} = { #Overload import_batches from DB with our imaginary packages
        'B20160419xma' => {},
    };
    $newFilePaths = $importer->_listNewFiles($ftpcon);
    is(scalar(@$newFilePaths), 2, 'Got 2 nice biblio filePath');
    is($newFilePaths->[0], 'B20160419xmk', 'Got a nice biblio filePath 0');
    is($newFilePaths->[1], 'B20160420xmk', 'Got a nice biblio filePath 1');

    $importer->{importedBatches} = { #Overload import_batches from DB with our imaginary packages
    };
    $newFilePaths = $importer->_listNewFiles($ftpcon);
    is(scalar(@$newFilePaths), 3, 'Got 3 nice biblio filePath');
    is($newFilePaths->[0], 'B20160419xma', 'Got a nice biblio filePath 0');
    is($newFilePaths->[1], 'B20160419xmk', 'Got a nice biblio filePath 1');
    is($newFilePaths->[2], 'B20160420xmk', 'Got a nice biblio filePath 2');

    $ftpcon->quit();

    };
    if ($@) {
        ok(0, $@);
    }
}



subtest "Get new packages", \&getNewPackages;
sub getNewPackages {
    my ($importer, $ftpcon, $packages);
    eval {

    $importer = C4::KohaSuomi::RemoteBiblioPackageImporter->new({remoteId => 'BTJBiblios'});

    $packages = $importer->getNewPackages();
    is(scalar(@$packages), 3, 'Got 3 nice biblio packages');
    is($packages->[0]->stringify(), '/tmp/testImportedMARC/BTJBiblios/B20160419xma', 'Got a nice biblio package 0');
    is($packages->[1]->stringify(), '/tmp/testImportedMARC/BTJBiblios/B20160419xmk', 'Got a nice biblio package 1');
    is($packages->[2]->stringify(), '/tmp/testImportedMARC/BTJBiblios/B20160420xmk', 'Got a nice biblio package 2');

    };
    if ($@) {
        ok(0, $@);
    }
}



subtest "Stage packages", \&stagePackages;
sub stagePackages {
    my ($importer, $remote, $localPackages, $ib, $irs, $stagedCount);
    eval {

    $importer = C4::KohaSuomi::RemoteBiblioPackageImporter->new({remoteId => 'BTJBiblios'});
    $remote = $importer->getRemote();
    $localPackages = $importer->getNewPackages();
    $importer->stageLocalPackages($localPackages, $remote->{encoding}, $remote->{matcher}, $remote->{format});

    ##Disect first package
    $ib = C4::ImportBatch::GetImportBatch($localPackages->[0]->{batchNumber});
    $irs = C4::ImportBatch::GetImportRecordsRange($localPackages->[0]->{batchNumber});
    $stagedCount = 4;
    is(scalar(@$irs), $stagedCount,                                        "Staged batch 0: Real input records count matches");
    is($localPackages->[0]->{stagingReport}->{inputRecords}, $stagedCount, "Staged batch 0: Reported input records count matches");
    is($ib->{num_records}, $stagedCount,                                   "Staged batch 0: Stored input records count matches");
    is($irs->[0]->{author}, 'Lamar, Kendrick,', "Staged batch 0: Record 0");
    is($irs->[1]->{title},  'Untitled 01.',     "Staged batch 0: Record 1");
    is($irs->[2]->{title},  'Untitled 02.',     "Staged batch 0: Record 2");
    is($irs->[3]->{title},  'Untitled 03.',     "Staged batch 0: Record 3");
    is($ib->{matcher_id}, $matchers->{ALLFONS}->{id}, "Staged batch 0: Correct matcher");

    ##Disect second package
    $ib = C4::ImportBatch::GetImportBatch($localPackages->[1]->{batchNumber});
    $irs = C4::ImportBatch::GetImportRecordsRange($localPackages->[1]->{batchNumber});
    $stagedCount = 3;
    is(scalar(@$irs), $stagedCount,                                        "Staged batch 1: Real input records count matches");
    is($localPackages->[1]->{stagingReport}->{inputRecords}, $stagedCount, "Staged batch 1: Reported input records count matches");
    is($ib->{num_records}, $stagedCount,                                   "Staged batch 1: Stored input records count matches");
    is($irs->[0]->{isbn},   '9520112626',             "Staged batch 1: Record 0");
    is($irs->[1]->{isbn},   '1743218605',             "Staged batch 1: Record 1");
    is($irs->[2]->{author}, 'Matikainen, Anna-Mari,', "Staged batch 1: Record 2");
    is($ib->{matcher_id}, $matchers->{ALLFONS}->{id}, "Staged batch 1: Correct matcher");

    ##Disect third package
    $ib = C4::ImportBatch::GetImportBatch($localPackages->[2]->{batchNumber});
    $irs = C4::ImportBatch::GetImportRecordsRange($localPackages->[2]->{batchNumber});
    $stagedCount = 3;
    is(scalar(@$irs), $stagedCount,                                        "Staged batch 2: Real input records count matches");
    is($localPackages->[2]->{stagingReport}->{inputRecords}, $stagedCount, "Staged batch 2: Reported input records count matches");
    is($ib->{num_records}, $stagedCount,                                   "Staged batch 2: Stored input records count matches");
    is($irs->[0]->{isbn},   '952680077X', "Staged batch 2: Record 0");
    is($irs->[1]->{title},  'ICF :',      "Staged batch 2: Record 1");
    is($irs->[2]->{isbn},   '951236123X', "Staged batch 2: Record 2");
    is($ib->{matcher_id}, $matchers->{ALLFONS}->{id}, "Staged batch 2: Correct matcher");

    };
    if ($@) {
        ok(0, $@);
    }
    C4::ImportBatch::DeleteImportBatches( DateTime->now( time_zone => C4::Context->tz()) );
}



subtest "Import packages", \&importPackages;
sub importPackages {
    my ($importer, $localPackages, @irs, @bibs, $biblio);
    eval {

    $importer = C4::KohaSuomi::RemoteBiblioPackageImporter->new({remoteId => 'BTJBiblios'});
    $localPackages = $importer->importFromRemote();

    @irs = @{C4::ImportBatch::GetImportRecordsRange($localPackages->[0]->{batchNumber})};
    is(@irs, 4, "Commit batch 0: Record count matches");
    @bibs = map {C4::Biblio::GetBiblio($_->{matched_biblionumber})} @irs;
    for (my $i=0 ; $i<scalar(@irs) ; $i++) {
        is($irs[$i]->{title}, $bibs[$i]->{title}, "Commit batch 0: Record $i");
    }

    @irs = @{C4::ImportBatch::GetImportRecordsRange($localPackages->[1]->{batchNumber})};
    is(@irs, 3, "Commit batch 1: Record count matches");
    @bibs = map {C4::Biblio::GetBiblio($_->{matched_biblionumber})} @irs;
    for (my $i=0 ; $i<scalar(@irs) ; $i++) {
        is($irs[$i]->{title}, $bibs[$i]->{title}, "Commit batch 1: Record $i");
    }

    @irs = @{C4::ImportBatch::GetImportRecordsRange($localPackages->[2]->{batchNumber})};
    is(@irs, 3, "Commit batch 2: Record count matches");
    @bibs = map {C4::Biblio::GetBiblio($_->{matched_biblionumber})} @irs;
    for (my $i=0 ; $i<scalar(@irs) ; $i++) {
        is($irs[$i]->{title}, $bibs[$i]->{title}, "Commit batch 2: Record $i");
    }

    };
    if ($@) {
        ok(0, $@);
    }
    C4::ImportBatch::DeleteImportBatches( DateTime->now( time_zone => C4::Context->tz()) );
}



tearDown($testContext);
sub tearDown {
    my ($testContext) = @_;
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);
    C4::ImportBatch::DeleteImportBatches( DateTime->now( time_zone => C4::Context->tz()) );
}


done_testing;
