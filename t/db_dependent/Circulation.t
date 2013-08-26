#!/usr/bin/perl

use Modern::Perl;

use DateTime;
use C4::Biblio;
use C4::Branch;
use C4::Items;
use C4::Members;
use C4::Reserves;

use Test::More tests => 36;

BEGIN {
    use_ok('C4::Circulation');
}

my $dbh = C4::Context->dbh;

# Start transaction
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

# Start with a clean slate
$dbh->do('DELETE FROM issues');

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

# Set a simple circ policy
$dbh->do('DELETE FROM issuingrules');
$dbh->do(
    q{INSERT INTO issuingrules (categorycode, branchcode, itemtype, reservesallowed,
                                maxissueqty, issuelength, lengthunit,
                                renewalsallowed, renewalperiod)
      VALUES (?, ?, ?, ?,
              ?, ?, ?,
              ?, ?
             )
    },
    {},
    '*', '*', '*', 25,
    20, 14, 'days',
    1, 7
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

    my ($biblionumber, $biblioitemnumber) = AddBiblio($biblio, '');

    my $barcode = 'R00000342';
    my $branch = 'MPL';

    my ($item_bibnum, $item_bibitemnum, $itemnumber) =
        AddItem({ homebranch => $branch,
                  holdingbranch => $branch,
                  barcode => $barcode, } , $biblionumber);

    my $barcode2 = 'R00000343';
    my ($item_bibnum2, $item_bibitemnum2, $itemnumber2) =
        AddItem({ homebranch => $branch,
                  holdingbranch => $branch,
                  barcode => $barcode2, } , $biblionumber);

    # Create 2 borrowers
    my %renewing_borrower_data = (
        firstname =>  'John',
        surname => 'Renewal',
        categorycode => 'S',
        branchcode => $branch,
    );

    my %reserving_borrower_data = (
        firstname =>  'Katrin',
        surname => 'Reservation',
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

    my $datedue = AddIssue( $renewing_borrower, $barcode);
    is (defined $datedue, 1, "Item 1 checked out, due date: $datedue");

    my $datedue2 = AddIssue( $renewing_borrower, $barcode2);
    is (defined $datedue2, 1, "Item 2 checked out, due date: $datedue2");

    my $borrowing_borrowernumber = GetItemIssue($itemnumber)->{borrowernumber};
    is ($borrowing_borrowernumber, $renewing_borrowernumber, "Item checked out to $renewing_borrower->{firstname} $renewing_borrower->{surname}");

    my ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber, 1);
    is( $renewokay, 1, 'Can renew, no holds for this title or item');


    diag("Biblio-level hold, renewal test");
    AddReserve(
        $branch, $reserving_borrowernumber, $biblionumber,
        $constraint, $bibitems,  $priority, $resdate, $expdate, $notes,
        $title, $checkitem, $found
    );

    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber);
    is( $renewokay, 0, '(Bug 10663) Cannot renew, reserved');
    is( $error, 'on_reserve', '(Bug 10663) Cannot renew, reserved (returned error is on_reserve)');

    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber2);
    is( $renewokay, 0, '(Bug 10663) Cannot renew, reserved');
    is( $error, 'on_reserve', '(Bug 10663) Cannot renew, reserved (returned error is on_reserve)');

    my $reserveid = C4::Reserves::GetReserveId({ biblionumber => $biblionumber, borrowernumber => $reserving_borrowernumber});
    CancelReserve({ reserve_id => $reserveid });


    diag("Item-level hold, renewal test");
    AddReserve(
        $branch, $reserving_borrowernumber, $biblionumber,
        $constraint, $bibitems,  $priority, $resdate, $expdate, $notes,
        $title, $itemnumber, $found
    );

    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber, 1);
    is( $renewokay, 0, '(Bug 10663) Cannot renew, item reserved');
    is( $error, 'on_reserve', '(Bug 10663) Cannot renew, item reserved (returned error is on_reserve)');

    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber2, 1);
    is( $renewokay, 1, 'Can renew item 2, item-level hold is on item 1');


    diag("Items can't fill hold for reasons");
    ModItem({ notforloan => 1 }, $biblionumber, $itemnumber);
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber, 1);
    is( $renewokay, 1, 'Can renew, item is marked not for loan, hold does not block');
    ModItem({ notforloan => 0, itype => '' }, $biblionumber, $itemnumber,1);

    # FIXME: Add more for itemtype not for loan etc.

    $reserveid = C4::Reserves::GetReserveId({ biblionumber => $biblionumber, itemnumber => $itemnumber, borrowernumber => $reserving_borrowernumber});
    CancelReserve({ reserve_id => $reserveid });

    diag("Too many renewals");

    # set policy to forbid renewals
    $dbh->do('UPDATE issuingrules SET renewalsallowed = 0');

    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber);
    is( $renewokay, 0, 'Cannot renew, 0 renewals allowed');
    is( $error, 'too_many', 'Cannot renew, 0 renewals allowed (returned code is too_many)');

}

{
    # GetUpcomingDueIssues tests
    my $barcode  = 'R00000342';
    my $barcode2 = 'R00000343';
    my $branch   = 'MPL';

    # Create a borrower
    my %a_borrower_data = (
        firstname =>  'Fridolyn',
        surname => 'SOMERS',
        categorycode => 'S',
        branchcode => $branch,
    );

    my $a_borrower_borrowernumber = AddMember(%a_borrower_data);
    my $a_borrower = GetMember( borrowernumber => $a_borrower_borrowernumber );

    my $yesterday = DateTime->today(time_zone => C4::Context->tz())->add( days => -1 );
    my $two_days_ahead = DateTime->today(time_zone => C4::Context->tz())->add( days => 2 );

    my $datedue  = AddIssue( $a_borrower, $barcode, $yesterday );
    my $datedue2 = AddIssue( $a_borrower, $barcode2, $two_days_ahead );

    diag( "GetUpcomingDueIssues tests" );

    for my $i(0..2) {
        my $upcoming_dues = C4::Circulation::GetUpcomingDueIssues( { days_in_advance => $i } );
        is ( scalar( @$upcoming_dues ), 0, "No items due in less than two days ($i days in advance)" );
    }

    for my $i(3..5) {
        my $upcoming_dues = C4::Circulation::GetUpcomingDueIssues( { days_in_advance => $i } );
        is ( scalar( @$upcoming_dues ), 1,
            "Bug 9362: Only one item due in more than 2 days ($i days in advance)" );
    }

}

$dbh->rollback;
