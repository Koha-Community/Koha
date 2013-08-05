#!/usr/bin/perl

use Modern::Perl;

use DateTime;
use C4::Biblio;
use C4::Branch;
use C4::Items;
use C4::Members;
use C4::Reserves;

use Test::More tests => 20;

BEGIN {
    use_ok('C4::Circulation');
}

my $dbh = C4::Context->dbh;

# Start transaction
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

my $CircControl = C4::Context->preference('CircControl');
my $HomeOrHoldingBranch = C4::Context->preference('HomeOrHoldingBranch');

my $item = {
    homebranch => 'MPL',
    holdingbranch => 'MPL'
};

my $borrower = {
    branchcode => 'MPL'
};

# No userenv, PickupLibrary
C4::Context->set_preference('CircControl', 'PickupLibrary');
is(
    C4::Context->preference('CircControl'),
    'PickupLibrary',
    'CircControl changed to PickupLibrary'
);
is(
    C4::Circulation::_GetCircControlBranch($item, $borrower),
    $item->{$HomeOrHoldingBranch},
    '_GetCircControlBranch returned item branch (no userenv defined)'
);

# No userenv, PatronLibrary
C4::Context->set_preference('CircControl', 'PatronLibrary');
is(
    C4::Context->preference('CircControl'),
    'PatronLibrary',
    'CircControl changed to PatronLibrary'
);
is(
    C4::Circulation::_GetCircControlBranch($item, $borrower),
    $borrower->{branchcode},
    '_GetCircControlBranch returned borrower branch'
);

# No userenv, ItemHomeLibrary
C4::Context->set_preference('CircControl', 'ItemHomeLibrary');
is(
    C4::Context->preference('CircControl'),
    'ItemHomeLibrary',
    'CircControl changed to ItemHomeLibrary'
);
is(
    $item->{$HomeOrHoldingBranch},
    C4::Circulation::_GetCircControlBranch($item, $borrower),
    '_GetCircControlBranch returned item branch'
);

diag('Now, set a userenv');
C4::Context->_new_userenv('xxx');
C4::Context::set_userenv(0,0,0,'firstname','surname', 'MPL', 'Midway Public Library', '', '', '');
is(C4::Context->userenv->{branch}, 'MPL', 'userenv set');

# Userenv set, PickupLibrary
C4::Context->set_preference('CircControl', 'PickupLibrary');
is(
    C4::Context->preference('CircControl'),
    'PickupLibrary',
    'CircControl changed to PickupLibrary'
);
is(
    C4::Circulation::_GetCircControlBranch($item, $borrower),
    'MPL',
    '_GetCircControlBranch returned current branch'
);

# Userenv set, PatronLibrary
C4::Context->set_preference('CircControl', 'PatronLibrary');
is(
    C4::Context->preference('CircControl'),
    'PatronLibrary',
    'CircControl changed to PatronLibrary'
);
is(
    C4::Circulation::_GetCircControlBranch($item, $borrower),
    $borrower->{branchcode},
    '_GetCircControlBranch returned borrower branch'
);

# Userenv set, ItemHomeLibrary
C4::Context->set_preference('CircControl', 'ItemHomeLibrary');
is(
    C4::Context->preference('CircControl'),
    'ItemHomeLibrary',
    'CircControl changed to ItemHomeLibrary'
);
is(
    C4::Circulation::_GetCircControlBranch($item, $borrower),
    $item->{$HomeOrHoldingBranch},
    '_GetCircControlBranch returned item branch'
);

# Reset initial configuration
C4::Context->set_preference('CircControl', $CircControl);
is(
    C4::Context->preference('CircControl'),
    $CircControl,
    'CircControl reset to its initial value'
);

# Test C4::Circulation::ProcessOfflinePayment
my $sth = C4::Context->dbh->prepare("SELECT COUNT(*) FROM accountlines WHERE amount = '-123.45' AND accounttype = 'Pay'");
$sth->execute();
my ( $original_count ) = $sth->fetchrow_array();

C4::Context->dbh->do("INSERT INTO borrowers ( cardnumber, surname, firstname, categorycode, branchcode ) VALUES ( '99999999999', 'Hall', 'Kyle', 'S', 'MPL' )");

C4::Circulation::ProcessOfflinePayment({ cardnumber => '99999999999', amount => '123.45' });

$sth->execute();
my ( $new_count ) = $sth->fetchrow_array();

ok( $new_count == $original_count  + 1, 'ProcessOfflinePayment makes payment correctly' );

C4::Context->dbh->do("DELETE FROM accountlines WHERE borrowernumber IN ( SELECT borrowernumber FROM borrowers WHERE cardnumber = '99999999999' )");
C4::Context->dbh->do("DELETE FROM borrowers WHERE cardnumber = '99999999999'");

{
    # CanBookBeRenewed tests

    # Generate test biblio
    my $biblio = MARC::Record->new();
    my $title = 'Silence in the library';
    $biblio->append_fields(
        MARC::Field->new('100', ' ', ' ', a => 'Moffat, Steven'),
        MARC::Field->new('245', ' ', ' ', a => $title),
    );

    my ($biblionumber, $biblioitemnumber);
    ($biblionumber, $biblioitemnumber) = AddBiblio($biblio, '');

    my $barcode = 'R00000342';
    my $branch = 'MPL';

    my ($item_bibnum, $item_bibitemnum, $itemnumber) =
        AddItem({ homebranch => $branch,
                  holdingbranch => $branch,
                  barcode => $barcode } , $biblionumber);

    # Create a borrower
    my %renewing_borrower_data = (
        firstname =>  'Renewal',
        surname => 'John',
        categorycode => 'S',
        branchcode => $branch,
    );

    my %reserving_borrower_data = (
        firstname =>  'Reservation',
        surname => 'Katrin',
        categorycode => 'S',
        branchcode => $branch,
    );

    my $renewing_borrowernumber = AddMember(%renewing_borrower_data);
    my $reserving_borrowernumber = AddMember(%reserving_borrower_data);

    my $renewing_borrower = GetMember( borrowernumber => $renewing_borrowernumber );

    my $constraint     = 'a';
    my $bibitems       = '';
    my $priority       = '1';
    my $resdate        = undef;
    my $expdate        = undef;
    my $notes          = '';
    my $checkitem      = undef;
    my $found          = undef;

    my $now = DateTime->now();
    my $cancelreserve = 1;

    AddIssue( $renewing_borrower, $barcode, $now, $cancelreserve, $now );

#    my ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber);
#    is( $renewokay, 1, 'Can renew, book not reserved');

    diag("Biblio-level reserve, renewal test");
    AddReserve(
        $branch, $reserving_borrowernumber, $biblionumber,
        $constraint, $bibitems,  $priority, $resdate, $expdate, $notes,
        $title, $checkitem, $found
    );

    my ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber);

    is( $renewokay, 0, '(Bug 10663) Cannot renew, item reserved');
    is( $error, 'on_reserve', '(Bug 10663) Cannot renew, item reserved (returned error is on_reserve');

    CancelReserve({
        biblionumber => $biblionumber,
        borrowernumber => $reserving_borrowernumber,
    });


    diag("Item-level reserve, renewal test");
    AddReserve(
        $branch, $reserving_borrowernumber, $biblionumber,
        $constraint, $bibitems,  $priority, $resdate, $expdate, $notes,
        $title, $itemnumber, $found
    );

    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber);

    is( $renewokay, 0, '(Bug 10663) Cannot renew, item reserved');
    is( $error, 'on_reserve', '(Bug 10663) Cannot renew, item reserved (returned error is on_reserve');

    CancelReserve({
        biblionumber => $biblionumber,
        borrowernumber => $reserving_borrowernumber,
        itemnumber => $itemnumber
    });

}


$dbh->rollback;
