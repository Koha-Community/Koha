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

1;

