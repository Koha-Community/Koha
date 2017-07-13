#!/usr/bin/perl

use strict;
use warnings;
#use diagnostics;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
    eval { use lib $FindBin::Bin; };
}

use open qw( :std :encoding(UTF-8) );
binmode( STDOUT, ":encoding(UTF-8)" );

use Getopt::Long;
use C4::Items;
use C4::Members;
use C4::Accounts;
use ConversionTable::BorrowernumberConversionTable;
use ConversionTable::ItemnumberConversionTable;

binmode( STDOUT, ":encoding(UTF-8)" );
my ( $inputfile, $number) = ('',undef);
my $borrowernumberConversionTable = 'borrowernumberConversionTable';
my $itemnumberConversionTable = 'itemnumberConversionTable';

$|=1;

GetOptions(
    'file:s'    => \$inputfile,
    'n:f' => \$number,
    'b|bnConversionTable:s'    => \$borrowernumberConversionTable,
    'i|inConversionTable:s'    => \$itemnumberConversionTable,
);


my $help = <<HELP;

perl ./bulkFinesImport.pl --file /home/koha/pielinen/fines.migrateme -n 750

Migrates the Perl-serialized MMT-processed fines to Koha.

  --file               The perl-serialized HASH of Fines.
  -n                   How many fines to migrate? Defaults to ALL.
  --bnConversionTable  From which key-value -file to read the converted borrowernumber.
                       We are adding Patrons to a database with existing Patrons, so we need to convert
                       borrowernumbers so they won't overlap with existing ones.
                       borrowernumberConversionTable has the following format, where first column is the original
                       customer id and the second column is the mapped Koha borrowernumber:

                           1001003 12001003
                           1001004 12001004
                           1001006 12001005
                           1001007 12001006
                           ...

                       Defaults to 'borrowernumberConversionTable'
  --inConversionTable  From which key-value -file to read the converted itemnumber.

HELP

unless ($inputfile) {
    die "$help\n\nYou must give the Fines-file.";
}

my $fh = IO::File->new( $inputfile, "<:encoding(utf-8)" ) or die $!;

$borrowernumberConversionTable = ConversionTable::BorrowernumberConversionTable->new($borrowernumberConversionTable, 'read');
$itemnumberConversionTable = ConversionTable::ItemnumberConversionTable->new($itemnumberConversionTable, 'read');


my $dbh = C4::Context->dbh;
my $fineStatement = $dbh->prepare(
            'INSERT INTO  accountlines
                        (borrowernumber, itemnumber, accountno, date, amount, description, accounttype, amountoutstanding, notify_id, manager_id)
        VALUES (?, ?, ?, ?, ?,?, ?,?,?,?)');

sub newFromRow {
    no strict 'vars';
    eval shift;
    my $s = $VAR1;
    use strict 'vars';
    warn $@ if $@;
    return %$s;
}


sub finesImport {
    my ( $borrowernumber, $itemnumber, $desc, $accounttype, $amount, $date ) = @_;

    #Make sure the borrowerexists!
    my $testingBorrower = C4::Members::GetMember(borrowernumber => $borrowernumber);
    unless (defined $testingBorrower) {
        warn "Patron $borrowernumber doesn't exist in Koha!\n";
        return;
    }

    my $accountno  = C4::Accounts::getnextacctno( $borrowernumber );
    my $amountleft = $amount;
    my $notifyid = 0;
    my $manager_id = C4::Context->userenv ? C4::Context->userenv->{'number'} : 1;

    $fineStatement->execute($borrowernumber, $itemnumber, $accountno, $date, $amount, $desc, $accounttype, $amountleft, $notifyid, $manager_id);

    if ($fineStatement->errstr) {
        println $fineStatement->errstr;
    }
}


my $i = 0;
while (<$fh>) {
    $i++;
    print ".";
    print "\n$i" unless $i % 100;

    my %fine = newFromRow($_);

    my $borrowernumber = $borrowernumberConversionTable->fetch( $fine{borrowernumber} );
    unless ($borrowernumber) {
        warn "\nFine for borrowernumber ".$fine{borrowernumber}." has no Borrower in conversion table!\n";
        next();
    }
    my $itemnumber = $fine{itemnumber};
    if ($itemnumber) {
        $itemnumber = $itemnumberConversionTable->fetch( $itemnumber );
        unless ($itemnumber) {
#            warn "\nFine for borrowernumber ".$fine{borrowernumber}." has no Item in conversion table!\n";
#            next();
             $itemnumber = undef;
        }
    }


    my $err = finesImport (
        $borrowernumber,
        $itemnumber,
        $fine{description},
        $fine{accounttype},
        $fine{amount},
        $fine{date}
    );

    last if $number && $i == $number;
}
