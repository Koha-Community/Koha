
use strict;
use warnings;
use 5.010;
use C4::Context;
use C4::Circulation;
use C4::Members;
use C4::Items;
use Koha::DateUtils;

use Test::More tests => 8;
C4::Context->_new_userenv(1234567);
C4::Context->set_userenv(91, 'CLIstaff', '23529001223661', 'CPL',
                         'CPL', 'CPL', '', 'cc@cscnet.co.uk');


my $test_patron = '23529001223651';
my $test_item_fic = '502326000402';
my $test_item_24 = '502326000404';
my $test_item_48 = '502326000403';

my $borrower1 =  GetMember(cardnumber => $test_patron);
my $item1 = GetItem (undef,$test_item_fic);

SKIP: {
    skip 'Missing test borrower or item, skipping tests', 8
      unless ( defined $borrower1 && defined $item1 );

    for my $item_barcode ( $test_item_fic, $test_item_24, $test_item_48 ) {
        my $duedate = try_issue( $test_patron, $item_barcode );
        isa_ok( $duedate, 'DateTime' );
        if ( $item_barcode eq $test_item_fic ) {
            is( $duedate->hour(),   23, "daily loan hours = 23" );
            is( $duedate->minute(), 59, "daily loan mins = 59" );
        }
        my $ret_ok = try_return($item_barcode);
        is( $ret_ok, 1, 'Return succeeded' );
    }
}

sub try_issue {
    my ($cardnumber, $item ) = @_;
    my $issuedate = '2011-05-16';
    my $borrower = GetMemberDetails(0, $cardnumber);
    my ($issuingimpossible,$needsconfirmation) = CanBookBeIssued( $borrower, $item );
    my $issue = AddIssue($borrower, $item, undef, 0, $issuedate);
    return dt_from_string( $issue->due_date() );
}

sub try_return {
    my $barcode = shift;
    my ($ret, $messages, $iteminformation, $borrower) = AddReturn($barcode);
    return $ret;
}
