package KohaTest::Circulation;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::Circulation;
sub testing_class { 'C4::Circulation' };


sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw( barcodedecode 
                      decode 
                      transferbook 
                      TooMany 
                      itemissues 
                      CanBookBeIssued 
                      AddIssue 
                      GetLoanLength 
                      GetIssuingRule 
                      GetBranchBorrowerCircRule
                      AddReturn 
                      MarkIssueReturned 
                      FixOverduesOnReturn 
                      FixAccountForLostAndReturned 
                      GetItemIssue 
                      GetItemIssues 
                      GetBiblioIssues 
                      GetUpcomingDueIssues
                      CanBookBeRenewed 
                      AddRenewal 
                      GetRenewCount 
                      GetIssuingCharges 
                      AddIssuingCharge 
                      GetTransfers 
                      GetTransfersFromTo 
                      DeleteTransfer 
                      AnonymiseIssueHistory 
                      updateWrongTransfer 
                      UpdateHoldingbranch 
                      CalcDateDue  
                      CheckValidDatedue 
                      CheckRepeatableHolidays
                      CheckSpecialHolidays
                      CheckRepeatableSpecialHolidays
                      CheckValidBarcode
                );
    
    can_ok( $self->testing_class, @methods );    
}

=head3 setup_add_biblios

everything in the C4::Circulation really requires items, so let's do this in the setup phase.

=cut

sub setup_add_biblios : Tests( setup => 8 ) {
    my $self = shift;

    # we want to use a fresh batch of items, so clear these lists:
    delete $self->{'items'};
    delete $self->{'biblios'};

    $self->add_biblios( add_items => 1 );
}


=head3 checkout_first_item

named parameters:
  borrower  => borrower hashref, computed from $self->{'memberid'} if not given
  barcode   => item barcode, barcode of $self->{'items'}[0] if not given
  issuedate => YYYY-MM-DD of date to mark issue checked out. defaults to today.

=cut

sub checkout_first_item {
    my $self   = shift;
    my $params = shift;

    # get passed in borrower, or default to the one in $self.
    my $borrower = $params->{'borrower'};
    if ( ! defined $borrower ) {
        my $borrowernumber = $self->{'memberid'};
        $borrower = C4::Members::GetMemberDetails( $borrowernumber );
    }

    # get the barcode passed in, or default to the first one in the items list
    my $barcode = $params->{'barcode'};
    if ( ! defined $barcode ) {
        return unless $self->{'items'}[0]{'itemnumber'};
        $barcode = $self->get_barcode_from_itemnumber( $self->{'items'}[0]{'itemnumber'} );
    }

    # get issuedate from parameters. Default to undef, which will be interpreted as today
    my $issuedate = $params->{'issuedate'};

    my ( $issuingimpossible, $needsconfirmation ) = C4::Circulation::CanBookBeIssued( $borrower, $barcode );

    my $datedue = C4::Circulation::AddIssue(
        $borrower,    # borrower
        $barcode,     # barcode
        undef,        # datedue
        undef,        # cancelreserve
        $issuedate    # issuedate
    );

    my $issues = C4::Circulation::GetItemIssue( $self->{'items'}[0]{'itemnumber'} );

    return $issues->{'date_due'};
}

=head3 get_barcode_from_itemnumber

pass in an itemnumber, returns a barcode.

Should this get moved up to KohaTest.pm? Or, is there a better alternative in C4?

=cut

sub get_barcode_from_itemnumber {
    my $self       = shift;
    my $itemnumber = shift;

    my $sql = <<END_SQL;
SELECT barcode
  FROM items
  WHERE itemnumber = ?
END_SQL
    my $dbh = C4::Context->dbh()  or return;
    my $sth = $dbh->prepare($sql) or return;
    $sth->execute($itemnumber) or return;
    my ($barcode) = $sth->fetchrow_array;
    return $barcode;
}

1;

