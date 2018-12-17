#!/usr/bin/perl

use warnings;
use strict;

use C4::Context;
use Data::Dumper;
use Koha::Reporting::Import::Loans;
use Koha::Reporting::Import::FinesOverdue;
use Koha::Reporting::Import::FinesPaid;
use Koha::Reporting::Import::Borrowers::New;
use Koha::Reporting::Import::Borrowers::Deleted;
use Koha::Reporting::Import::Acquisitions;
use Koha::Reporting::Import::Items;
use Koha::Reporting::Import::DeletedItems;
use Koha::Reporting::Import::UpdateItems;
use Koha::Reporting::Import::Returns;
use Koha::Reporting::Import::Reserves;
use Koha::Reporting::Import::OldReserves;
use Koha::Reporting::Import::UpdateReserves;
use Koha::Reporting::Import::Messages;
use Koha::Reporting::Import::UpdateAcquisitionsIsFirst;
use Koha::Reporting::Import::Abstract;

sub changeWaitTimeOut{
    my $dbh = C4::Context->dbh;
    my $stmnt = $dbh->prepare('set wait_timeout = 49');
    $stmnt->execute();
}

changeWaitTimeOut();

my $config = Koha::Reporting::Import::Abstract->loadConfiguration();
unless ($config->{blockStatisticsGeneration}) {

	print "Starting imports\n";
	my $importFinesOverdue = new Koha::Reporting::Import::FinesOverdue;
	my $importFinesPaid = new Koha::Reporting::Import::FinesPaid;
	my $importLoans = new Koha::Reporting::Import::Loans;
	my $importBorrowersNew = new Koha::Reporting::Import::Borrowers::New;
	my $importBorrowersDeleted = new Koha::Reporting::Import::Borrowers::Deleted;
	my $importAcquisitions = new Koha::Reporting::Import::Acquisitions;
	my $importItems = new Koha::Reporting::Import::Items;
	my $importDeletedItems = new Koha::Reporting::Import::DeletedItems;
	my $importUpdateItems = new Koha::Reporting::Import::UpdateItems;
	my $importReturns = new Koha::Reporting::Import::Returns;
	my $importReserves = new Koha::Reporting::Import::Reserves;
	my $importOldReserves = new Koha::Reporting::Import::OldReserves;
	my $importMessages = new Koha::Reporting::Import::Messages;
	my $updateAcquisitionsIsFirst = new Koha::Reporting::Import::UpdateAcquisitionsIsFirst;
	#$importUpdateItems->truncateUpdateTable();

	print "Fines Overdue\n";
	$importFinesOverdue->massImport();
	print "Fines Paid\n";
	$importFinesPaid->massImport();
	print "Messages\n";
	$importMessages->massImport();
	print "Loans\n";
	$importLoans->massImport();
	print "Returns\n";
	$importReturns->massImport();
	print "Borrowers New\n";
	$importBorrowersNew->massImport();
	print "Borrowers Deleted\n";
	$importBorrowersDeleted->massImport();
	print "Acquisitions\n";
	$importAcquisitions->massImport();

	print "Update Acquisitions is_first \n";
	$updateAcquisitionsIsFirst->update();

	print "Items\n";
	$importItems->massImport();
	print "Deleted Items\n";
	$importDeletedItems->massImport();
	print "Reserves \n";
	$importReserves->massImport();
        print "Old Reserves \n";
	$importOldReserves->massImport();

	print "Update Items\n";
	$importUpdateItems->massImport();

	print "Imports Done.\n"
} else {
	print "Not importing, check the settings!\n";
}
