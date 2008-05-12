package KohaTest::Branch;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::Branch;
sub testing_class { 'C4::Branch' };


sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw( GetBranches
                      GetBranchName
                      ModBranch
                      GetBranchCategory
                      GetBranchCategories
                      GetCategoryTypes
                      GetBranch
                      GetBranchDetail
                      get_branchinfos_of
                      GetBranchesInCategory
                      GetBranchInfo
                      DelBranch
                      ModBranchCategoryInfo
                      DelBranchCategory
                      CheckBranchCategorycode
                );
    
    can_ok( $self->testing_class, @methods );    
}

1;

