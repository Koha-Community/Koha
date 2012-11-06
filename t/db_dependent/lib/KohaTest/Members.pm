package KohaTest::Members;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::Members;
sub testing_class { 'C4::Members' };


sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw( Search
                      GetMemberDetails 
                      patronflags 
                      GetMember 
                      GetMemberIssuesAndFines 
                      ModMember 
                      AddMember 
                      Check_Userid 
                      changepassword 
                      fixup_cardnumber
                      GetGuarantees 
                      UpdateGuarantees 
                      GetPendingIssues 
                      GetAllIssues 
                      GetMemberAccountRecords 
                      GetMemberAccountBalance
                      GetBorNotifyAcctRecord 
                      checkuniquemember 
                      checkcardnumber 
                      getzipnamecity 
                      getidcity 
                      GetExpiryDate 
                      checkuserpassword 
                      GetborCatFromCatType 
                      GetBorrowercategory 
                      ethnicitycategories 
                      fixEthnicity 
                      GetAge
                      get_institutions 
                      add_member_orgs 
                      MoveMemberToDeleted 
                      DelMember 
                      ExtendMemberSubscriptionTo 
                      GetTitles 
                      GetPatronImage 
                      PutPatronImage 
                      RmPatronImage 
                      GetBorrowersToExpunge
                      GetBorrowersWhoHaveNeverBorrowed 
                      GetBorrowersWithIssuesHistoryOlderThan 
                      GetBorrowersNamesAndLatestIssue 
                      IssueSlip
                );
    
    can_ok( $self->testing_class, @methods );    
}

1;

