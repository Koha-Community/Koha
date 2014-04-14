#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 133;

use C4::Budgets;

# Avoid "redefined subroutine" warnings
local $SIG{__WARN__} = sub { warn $_[0] unless $_[0] =~ /redefined/ };
*C4::Budgets::GetBudgetUsers = \&Mock_GetBudgetUsers;
*C4::Context::userenv = \&Mock_userenv;

my %budgetusers = (
    1 => [],
    2 => [1],
    3 => [2],
    4 => [3],
    5 => [],
    6 => [1],
    7 => [2],
    8 => [3],
    9 => [],
    10 => [1],
    11 => [2],
    12 => [3],
    13 => [],
    14 => [1],
    15 => [2],
    16 => [3],
);

my $borrower1 = {
    borrowernumber => 1
};
my $borrower2 = {
    borrowernumber => 2
};

my $budget1 = {
    budget_id => 1,
    budget_permission => 0,
    budget_owner_id => undef,
    budget_branchcode => undef,
};
my $budget2 = {
    budget_id => 2,
    budget_permission => 0,
    budget_owner_id => undef,
    budget_branchcode => 'B1',
};
my $budget3 = {
    budget_id => 3,
    budget_permission => 0,
    budget_owner_id => 1,
    budget_branchcode => undef,
};
my $budget4 = {
    budget_id => 4,
    budget_permission => 0,
    budget_owner_id => 1,
    budget_branchcode => 'B1',
};
my $budget5 = {
    budget_id => 5,
    budget_permission => 1,
    budget_owner_id => undef,
    budget_branchcode => undef,
};
my $budget6 = {
    budget_id => 6,
    budget_permission => 1,
    budget_owner_id => undef,
    budget_branchcode => 'B1',
};
my $budget7 = {
    budget_id => 7,
    budget_permission => 1,
    budget_owner_id => 1,
    budget_branchcode => undef,
};
my $budget8 = {
    budget_id => 8,
    budget_permission => 1,
    budget_owner_id => 1,
    budget_branchcode => 'B1',
};
my $budget9 = {
    budget_id => 9,
    budget_permission => 2,
    budget_owner_id => undef,
    budget_branchcode => undef,
};
my $budget10 = {
    budget_id => 10,
    budget_permission => 2,
    budget_owner_id => undef,
    budget_branchcode => 'B1',
};
my $budget11 = {
    budget_id => 11,
    budget_permission => 2,
    budget_owner_id => 1,
    budget_branchcode => undef,
};
my $budget12 = {
    budget_id => 12,
    budget_permission => 2,
    budget_owner_id => 1,
    budget_branchcode => 'B1',
};
my $budget13 = {
    budget_id => 13,
    budget_permission => 3,
    budget_owner_id => undef,
    budget_branchcode => undef,
};
my $budget14 = {
    budget_id => 14,
    budget_permission => 3,
    budget_owner_id => undef,
    budget_branchcode => 'B1',
};
my $budget15 = {
    budget_id => 15,
    budget_permission => 3,
    budget_owner_id => 1,
    budget_branchcode => undef,
};
my $budget16 = {
    budget_id => 16,
    budget_permission => 3,
    budget_owner_id => 1,
    budget_branchcode => 'B1',
};

my $userenv = {};


ok (CanUserModifyBudget($borrower1, $budget1, {superlibrarian => 1}));
ok (CanUserModifyBudget($borrower1, $budget1, {
    acquisition => {
        budget_manage_all => 1
    }
}));
ok (CanUserModifyBudget($borrower1, $budget1, {acquisition => 1}));

ok (!CanUserModifyBudget($borrower1, $budget1, {}));
ok (!CanUserModifyBudget($borrower1, $budget1, {acquisition => 0}));

my $flags = {acquisition => {budget_modify => 1}};

$userenv->{branch} = 'B1';

# Restriction is 'none'
ok (CanUserModifyBudget($borrower1, $budget1, $flags));
ok (CanUserModifyBudget($borrower1, $budget2, $flags));
ok (CanUserModifyBudget($borrower1, $budget3, $flags));
ok (CanUserModifyBudget($borrower1, $budget4, $flags));
ok (CanUserModifyBudget($borrower2, $budget1, $flags));
ok (CanUserModifyBudget($borrower2, $budget2, $flags));
ok (CanUserModifyBudget($borrower2, $budget3, $flags));
ok (CanUserModifyBudget($borrower2, $budget4, $flags));

# Restriction is 'owner'
ok (CanUserModifyBudget($borrower1, $budget5, $flags));
ok (CanUserModifyBudget($borrower1, $budget6, $flags));
ok (CanUserModifyBudget($borrower1, $budget7, $flags));
ok (CanUserModifyBudget($borrower1, $budget8, $flags));
ok (CanUserModifyBudget($borrower2, $budget5, $flags));
ok (CanUserModifyBudget($borrower2, $budget6, $flags));
ok (!CanUserModifyBudget($borrower2, $budget7, $flags));
ok (!CanUserModifyBudget($borrower2, $budget8, $flags));

# Restriction is 'owner, users and library'
ok (CanUserModifyBudget($borrower1, $budget9, $flags));
ok (CanUserModifyBudget($borrower1, $budget10, $flags));
ok (CanUserModifyBudget($borrower1, $budget11, $flags));
ok (CanUserModifyBudget($borrower1, $budget12, $flags));
ok (CanUserModifyBudget($borrower2, $budget9, $flags));
ok (CanUserModifyBudget($borrower2, $budget10, $flags));
ok (CanUserModifyBudget($borrower2, $budget11, $flags));
ok (CanUserModifyBudget($borrower2, $budget12, $flags));

# Restriction is 'owner and users'
ok (!CanUserModifyBudget($borrower1, $budget13, $flags)); # no owner, no user
ok (CanUserModifyBudget($borrower1, $budget14, $flags));
ok (CanUserModifyBudget($borrower1, $budget15, $flags));
ok (CanUserModifyBudget($borrower1, $budget16, $flags));
ok (!CanUserModifyBudget($borrower2, $budget13, $flags)); # no owner, no user
ok (!CanUserModifyBudget($borrower2, $budget14, $flags)); # No owner and user list contains borrower1
ok (CanUserModifyBudget($borrower2, $budget15, $flags));
ok (!CanUserModifyBudget($borrower2, $budget16, $flags));


$userenv->{branch} = 'B2';

# Restriction is 'none'
ok (CanUserModifyBudget($borrower1, $budget1, $flags));
ok (CanUserModifyBudget($borrower1, $budget2, $flags));
ok (CanUserModifyBudget($borrower1, $budget3, $flags));
ok (CanUserModifyBudget($borrower1, $budget4, $flags));
ok (CanUserModifyBudget($borrower2, $budget1, $flags));
ok (CanUserModifyBudget($borrower2, $budget2, $flags));
ok (CanUserModifyBudget($borrower2, $budget3, $flags));
ok (CanUserModifyBudget($borrower2, $budget4, $flags));

# Restriction is 'owner'
ok (CanUserModifyBudget($borrower1, $budget5, $flags));
ok (CanUserModifyBudget($borrower1, $budget6, $flags));
ok (CanUserModifyBudget($borrower1, $budget7, $flags));
ok (CanUserModifyBudget($borrower1, $budget8, $flags));
ok (CanUserModifyBudget($borrower2, $budget5, $flags));
ok (CanUserModifyBudget($borrower2, $budget6, $flags));
ok (!CanUserModifyBudget($borrower2, $budget7, $flags));
ok (!CanUserModifyBudget($borrower2, $budget8, $flags));

# Restriction is 'owner, users and library'
ok (CanUserModifyBudget($borrower1, $budget9, $flags));
ok (CanUserModifyBudget($borrower1, $budget10, $flags));
ok (CanUserModifyBudget($borrower1, $budget11, $flags));
ok (CanUserModifyBudget($borrower1, $budget12, $flags));
ok (CanUserModifyBudget($borrower2, $budget9, $flags));
ok (!CanUserModifyBudget($borrower2, $budget10, $flags)); # Limited to library B1
ok (CanUserModifyBudget($borrower2, $budget11, $flags));
ok (!CanUserModifyBudget($borrower2, $budget12, $flags));

# Restriction is 'owner and users'
ok (!CanUserModifyBudget($borrower1, $budget13, $flags)); # No owner, no user
ok (CanUserModifyBudget($borrower1, $budget14, $flags));
ok (CanUserModifyBudget($borrower1, $budget15, $flags));
ok (CanUserModifyBudget($borrower1, $budget16, $flags));
ok (!CanUserModifyBudget($borrower2, $budget13, $flags)); # No owner, no user
ok (!CanUserModifyBudget($borrower2, $budget14, $flags)); # No owner and user list contains borrower1
ok (CanUserModifyBudget($borrower2, $budget15, $flags));
ok (!CanUserModifyBudget($borrower2, $budget16, $flags));


# Same tests as above, without budget_modify permission
# All tests should failed
$flags = {acquisition => {order_manage => 1}};

$userenv->{branch} = 'B1';

# Restriction is 'none'
ok (!CanUserModifyBudget($borrower1, $budget1, $flags));
ok (!CanUserModifyBudget($borrower1, $budget2, $flags));
ok (!CanUserModifyBudget($borrower1, $budget3, $flags));
ok (!CanUserModifyBudget($borrower1, $budget4, $flags));
ok (!CanUserModifyBudget($borrower2, $budget1, $flags));
ok (!CanUserModifyBudget($borrower2, $budget2, $flags));
ok (!CanUserModifyBudget($borrower2, $budget3, $flags));
ok (!CanUserModifyBudget($borrower2, $budget4, $flags));

# Restriction is 'owner'
ok (!CanUserModifyBudget($borrower1, $budget5, $flags));
ok (!CanUserModifyBudget($borrower1, $budget6, $flags));
ok (!CanUserModifyBudget($borrower1, $budget7, $flags));
ok (!CanUserModifyBudget($borrower1, $budget8, $flags));
ok (!CanUserModifyBudget($borrower2, $budget5, $flags));
ok (!CanUserModifyBudget($borrower2, $budget6, $flags));
ok (!CanUserModifyBudget($borrower2, $budget7, $flags));
ok (!CanUserModifyBudget($borrower2, $budget8, $flags));

# Restriction is 'owner, users and library'
ok (!CanUserModifyBudget($borrower1, $budget9, $flags));
ok (!CanUserModifyBudget($borrower1, $budget10, $flags));
ok (!CanUserModifyBudget($borrower1, $budget11, $flags));
ok (!CanUserModifyBudget($borrower1, $budget12, $flags));
ok (!CanUserModifyBudget($borrower2, $budget9, $flags));
ok (!CanUserModifyBudget($borrower2, $budget10, $flags));
ok (!CanUserModifyBudget($borrower2, $budget11, $flags));
ok (!CanUserModifyBudget($borrower2, $budget12, $flags));

# Restriction is 'owner and users'
ok (!CanUserModifyBudget($borrower1, $budget13, $flags));
ok (!CanUserModifyBudget($borrower1, $budget14, $flags));
ok (!CanUserModifyBudget($borrower1, $budget15, $flags));
ok (!CanUserModifyBudget($borrower1, $budget16, $flags));
ok (!CanUserModifyBudget($borrower2, $budget13, $flags));
ok (!CanUserModifyBudget($borrower2, $budget14, $flags));
ok (!CanUserModifyBudget($borrower2, $budget15, $flags));
ok (!CanUserModifyBudget($borrower2, $budget16, $flags));


$userenv->{branch} = 'B2';

# Restriction is 'none'
ok (!CanUserModifyBudget($borrower1, $budget1, $flags));
ok (!CanUserModifyBudget($borrower1, $budget2, $flags));
ok (!CanUserModifyBudget($borrower1, $budget3, $flags));
ok (!CanUserModifyBudget($borrower1, $budget4, $flags));
ok (!CanUserModifyBudget($borrower2, $budget1, $flags));
ok (!CanUserModifyBudget($borrower2, $budget2, $flags));
ok (!CanUserModifyBudget($borrower2, $budget3, $flags));
ok (!CanUserModifyBudget($borrower2, $budget4, $flags));

# Restriction is 'owner'
ok (!CanUserModifyBudget($borrower1, $budget5, $flags));
ok (!CanUserModifyBudget($borrower1, $budget6, $flags));
ok (!CanUserModifyBudget($borrower1, $budget7, $flags));
ok (!CanUserModifyBudget($borrower1, $budget8, $flags));
ok (!CanUserModifyBudget($borrower2, $budget5, $flags));
ok (!CanUserModifyBudget($borrower2, $budget6, $flags));
ok (!CanUserModifyBudget($borrower2, $budget7, $flags));
ok (!CanUserModifyBudget($borrower2, $budget8, $flags));

# Restriction is 'owner, users and library'
ok (!CanUserModifyBudget($borrower1, $budget9, $flags));
ok (!CanUserModifyBudget($borrower1, $budget10, $flags));
ok (!CanUserModifyBudget($borrower1, $budget11, $flags));
ok (!CanUserModifyBudget($borrower1, $budget12, $flags));
ok (!CanUserModifyBudget($borrower2, $budget9, $flags));
ok (!CanUserModifyBudget($borrower2, $budget10, $flags));
ok (!CanUserModifyBudget($borrower2, $budget11, $flags));
ok (!CanUserModifyBudget($borrower2, $budget12, $flags));

# Restriction is 'owner and users'
ok (!CanUserModifyBudget($borrower1, $budget13, $flags));
ok (!CanUserModifyBudget($borrower1, $budget14, $flags));
ok (!CanUserModifyBudget($borrower1, $budget15, $flags));
ok (!CanUserModifyBudget($borrower1, $budget16, $flags));
ok (!CanUserModifyBudget($borrower2, $budget13, $flags));
ok (!CanUserModifyBudget($borrower2, $budget14, $flags));
ok (!CanUserModifyBudget($borrower2, $budget15, $flags));
ok (!CanUserModifyBudget($borrower2, $budget16, $flags));


# Mocked subs

# C4::Acquisition::GetBudgetUsers
sub Mock_GetBudgetUsers {
    my ($budget_id) = @_;

    return @{ $budgetusers{$budget_id} };
}

# C4::Context->userenv
sub Mock_userenv {
    return $userenv;
}
