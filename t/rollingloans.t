
use strict;
use warnings;
use 5.010;
use C4::Context;
use C4::Circulation;
use C4::Members;

use Test::More tests => 6;
C4::Context->_new_userenv(1234567);
C4::Context->set_userenv(91, 'CLIstaff', '23529001223661', 'CPL',
                         'CPL', 'CPL', '', 'cc@cscnet.co.uk');


my $test_patron = '23529001223651';
my $test_item_fic = '502326000402';
my $test_item_24 = '502326000404';
my $test_item_48 = '502326000403';

for my $item_barcode ( $test_item_fic, $test_item_24, $test_item_48) {
    my $duedate = try_issue($test_patron, $item_barcode);
    isa_ok($duedate, 'DateTime');
    my $ret_ok = try_return($item_barcode);
    is($ret_ok, 1, 'Return succeeded');
}


sub try_issue {
    my ($cardnumber, $item ) = @_;
    my $issuedate = '2011-05-16';
    my $borrower = GetMemberDetails(0, $cardnumber);
    my ($issuingimpossible,$needsconfirmation) = CanBookBeIssued( $borrower, $item );
	my $due_date = AddIssue($borrower, $item, undef, 0, $issuedate);
    return $due_date;
}

sub try_return {
    my $barcode = shift;
    my ($ret, $messages, $iteminformation, $borrower) = AddReturn($barcode);
    return $ret;
}
