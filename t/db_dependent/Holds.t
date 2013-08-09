#!/usr/bin/perl

use Modern::Perl;

use C4::Context;
use C4::Branch;

use Test::More tests => 4;
use MARC::Record;
use C4::Biblio;
use C4::Items;
use C4::Members;

BEGIN {
    use FindBin;
    use lib $FindBin::Bin;
    use_ok('C4::Reserves');
}

my $dbh = C4::Context->dbh;

# Start transaction
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

my $borrowers_count = 5;

my $bibnum;
my $bibitemnum;

# Create some borrowers
my @borrowernumbers;
foreach (1..$borrowers_count) {
    my $borrowernumber = AddMember(
        firstname =>  'my firstname',
        surname => 'my surname ' . $_,
        categorycode => 'S',
        branchcode => 'CPL',
    );
    push @borrowernumbers, $borrowernumber;
}

# Regression test for bug 2394
#
# If IndependentBranches is ON and canreservefromotherbranches is OFF,
# a patron is not permittedo to request an item whose homebranch (i.e.,
# owner of the item) is different from the patron's own library.
# However, if canreservefromotherbranches is turned ON, the patron can
# create such hold requests.
#
# Note that canreservefromotherbranches has no effect if
# IndependentBranches is OFF.

my ($foreign_bibnum, $foreign_title, $foreign_bibitemnum) = create_helper_biblio();
my ($foreign_item_bibnum, $foreign_item_bibitemnum, $foreign_itemnumber)
  = AddItem({ homebranch => 'MPL', holdingbranch => 'MPL' } , $foreign_bibnum);
$dbh->do('DELETE FROM issuingrules');
$dbh->do(
    q{INSERT INTO issuingrules (categorycode, branchcode, itemtype, reservesallowed)
      VALUES (?, ?, ?, ?)}, 
    {},
    '*', '*', '*', 25
);

# make sure some basic sysprefs are set
C4::Context->set_preference('ReservesControlBranch', 'homebranch');
C4::Context->set_preference('item-level_itypes', 1);

# if IndependentBranches is OFF, a CPL patron can reserve an MPL item
C4::Context->set_preference('IndependentBranches', 0);
ok(
    CanItemBeReserved($borrowernumbers[0], $foreign_itemnumber),
    'CPL patron allowed to reserve MPL item with IndependentBranches OFF (bug 2394)'
);

# if IndependentBranches is OFF, a CPL patron cannot reserve an MPL item
C4::Context->set_preference('IndependentBranches', 1);
C4::Context->set_preference('canreservefromotherbranches', 0);
ok(
    ! CanItemBeReserved($borrowernumbers[0], $foreign_itemnumber),
    'CPL patron NOT allowed to reserve MPL item with IndependentBranches ON ... (bug 2394)'
);

# ... unless canreservefromotherbranches is ON
C4::Context->set_preference('canreservefromotherbranches', 1);
ok(
    CanItemBeReserved($borrowernumbers[0], $foreign_itemnumber),
    '... unless canreservefromotherbranches is ON (bug 2394)'
);

# Rollback
$dbh->rollback;

# Helper method to set up a Biblio.
sub create_helper_biblio {
    my $bib = MARC::Record->new();
    my $title = 'Silence in the library';
    $bib->append_fields(
        MARC::Field->new('100', ' ', ' ', a => 'Moffat, Steven'),
        MARC::Field->new('245', ' ', ' ', a => $title),
    );
    return ($bibnum, $title, $bibitemnum) = AddBiblio($bib, '');
}
