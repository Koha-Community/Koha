#!/usr/bin/perl

## EXTRACTED USING THIS:
# grep -Pnir "'notforloan' => '6'" 01_items0* | grep -Po "'id' => '-?(\d+)'" | grep -Po "\d+" > itemnumbers_notforloan_6.txt

use Modern::Perl;

use C4::Context;
use utf8;

use Koha::Patrons;

print "\nTHE FOLLOWING STATISTIC ENTRIES HAVE BEEN UPDATED\n------------------------------------------------\n";

##Caches all the loaded Borrowers
my $borrowers = {};
my $deletedBorrowers = {};

my $dbh = C4::Context->dbh;

my $sthDelBor   = $dbh->prepare("SELECT * FROM deletedborrowers WHERE borrowernumber = ? ");
my $sthUpdateStat   = $dbh->prepare("UPDATE statistics SET categorycode = ? WHERE datetime = ? AND branch = ? AND type = ? AND itemnumber = ? ");

my $query2 = "SELECT * FROM statistics WHERE type = 'issue' OR type = 'renew' OR type = 'localuse'";
my $sth2   = $dbh->prepare($query2);
$sth2->execute();
my $stats =  $sth2->fetchall_arrayref({});

foreach my $stat (@$stats) {
  my $borrower = getCachedBorrower( $stat->{borrowernumber} );

  $borrower = getCachedDeletedBorrower( $stat->{borrowernumber} ) unless $borrower;

  if ($borrower) {
    $borrower = $borrower->unblessed;
    $stat->{categorycode} = $borrower->{categorycode};
    $sthUpdateStat->execute( $stat->{categorycode},
                             $stat->{datetime},
                             $stat->{branch},
                             $stat->{type},
                             $stat->{itemnumber},
                           );
    print(  $stat->{categorycode} . " " .
            $stat->{datetime} . " " .
            $stat->{branch} . " " .
            $stat->{type} . " " .
            $stat->{itemnumber} . " "
          );
    print "\n";
  }
}



##Members are repeatedly loaded in various parts of this code. Better to cache them.
sub getCachedBorrower {
    my $borrowernumber = shift; #The hash to store all branches by branchcode

    if (exists $borrowers->{$borrowernumber}) {
        return $borrowers->{$borrowernumber};
    }
    my $borrower = Koha::Patrons->find({ borrowernumber => $borrowernumber });
    $borrowers->{$borrowernumber} = $borrower;
    return $borrower;
}
##Deleted members are repeatedly loaded in various parts of this code. Better to cache them.
sub getCachedDeletedBorrower {
    my $borrowernumber = shift; #The hash to store all branches by branchcode

    if (exists $deletedBorrowers->{$borrowernumber}) {
        return $deletedBorrowers->{$borrowernumber};
    }
    $sthDelBor->execute( $borrowernumber );

    my $borrower = $sthDelBor->fetchrow_hashref();
    $borrowers->{$borrowernumber} = $borrower;
    return $borrower;
}
