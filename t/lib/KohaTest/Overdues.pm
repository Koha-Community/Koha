package KohaTest::Overdues;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::Overdues;
sub testing_class { 'C4::Overdues' };


sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw( Getoverdues 
                       checkoverdues 
                       CalcFine 
                       GetSpecialHolidays 
                       GetRepeatableHolidays
                       GetWdayFromItemnumber
                       GetIssuesIteminfo
                       UpdateFine 
                       BorType 
                       ReplacementCost 
                       GetFine 
                       GetIssuingRules 
                       ReplacementCost2 
                       GetNextIdNotify 
                       NumberNotifyId
                       AmountNotify
                       UpdateAccountLines 
                       GetItems 
                       GetOverdueDelays 
                       CheckAccountLineLevelInfo 
                       GetOverduerules
                       CheckBorrowerDebarred
                       UpdateBorrowerDebarred
                       CheckExistantNotifyid 
                       CheckAccountLineItemInfo 
                       CheckItemNotify 
                       GetOverduesForBranch 
                       AddNotifyLine 
                       RemoveNotifyLine 
                );
    
    can_ok( $self->testing_class, @methods );    
}

1;

