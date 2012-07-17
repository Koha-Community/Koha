#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 42;

use C4::Acquisition;

# Avoid "redefined subroutine" warnings
local $SIG{__WARN__} = sub { warn $_[0] unless $_[0] =~ /redefined/ };

*C4::Acquisition::GetBasketUsers = \&Mock_GetBasketUsers;
*C4::Context::preference = \&Mock_preference;

my $AcqViewBaskets;
my %basketusers = (
    1 => [],
    2 => [1, 2],
    3 => [],
    4 => [1, 2],
);

# Borrowers
my $borrower1 = {
    borrowernumber => 1,
    branchcode => 'B1',
};

my $borrower2 = {
    borrowernumber => 2,
    branchcode => 'B2',
};

# Baskets
my $basket1 = {
    basketno => 1,
    authorisedby => 1
};

my $basket2 = {
    basketno => 2,
    authorisedby => 2,
};

my $basket3 = {
    basketno => 3,
    authorisedby => 3,
    branch => 'B1'
};

my $basket4 = {
    basketno => 4,
    authorisedby => 4,
    branch => 'B1'
};


my $flags = {
    acquisition => {
        order_manage => 1
    }
};

#################
# Start testing #
#################

# ----------------------
# AcqViewBaskets = 'all'
# ----------------------

$AcqViewBaskets = 'all';

# Simple cases where user can't manage basket
ok( not CanUserManageBasket($borrower1, $basket1, {}) );
ok( not CanUserManageBasket($borrower1, $basket1, {
    acquisition => 0
}) );
ok( not CanUserManageBasket($borrower1, $basket1, {
    acquisition => {
        order_manage => 0
    }
}) );

# Simple cases where user can manage basket
ok( CanUserManageBasket($borrower1, $basket1, {
    superlibrarian => 1
}) );
ok( CanUserManageBasket($borrower1, $basket1, {
    acquisition => 1
}) );
ok( CanUserManageBasket($borrower1, $basket1, {
    acquisition => {
        order_manage_all => 1
    }
}) );

ok( CanUserManageBasket($borrower1, $basket1, $flags) );
ok( CanUserManageBasket($borrower1, $basket2, $flags) );
ok( CanUserManageBasket($borrower1, $basket3, $flags) );
ok( CanUserManageBasket($borrower1, $basket4, $flags) );
ok( CanUserManageBasket($borrower2, $basket1, $flags) );
ok( CanUserManageBasket($borrower2, $basket2, $flags) );
ok( CanUserManageBasket($borrower2, $basket3, $flags) );
ok( CanUserManageBasket($borrower2, $basket4, $flags) );

# -------------------------
# AcqViewBaskets = 'branch'
# -------------------------

$AcqViewBaskets = 'branch';

# Simple cases where user can't manage basket
ok( not CanUserManageBasket($borrower1, $basket1, {}) );
ok( not CanUserManageBasket($borrower1, $basket1, {
    acquisition => 0
}) );
ok( not CanUserManageBasket($borrower1, $basket1, {
    acquisition => {
        order_manage => 0
    }
}) );

# Simple cases where user can manage basket
ok( CanUserManageBasket($borrower1, $basket1, {
    superlibrarian => 1
}) );
ok( CanUserManageBasket($borrower1, $basket1, {
    acquisition => 1
}) );
ok( CanUserManageBasket($borrower1, $basket1, {
    acquisition => {
        order_manage_all => 1
    }
}) );

ok( CanUserManageBasket($borrower1, $basket1, $flags) );
ok( CanUserManageBasket($borrower1, $basket2, $flags) );
ok( CanUserManageBasket($borrower1, $basket3, $flags) );
ok( CanUserManageBasket($borrower1, $basket4, $flags) );
ok( CanUserManageBasket($borrower2, $basket1, $flags) );
ok( CanUserManageBasket($borrower2, $basket2, $flags) );
# borrower2 is not on the same branch as basket3 and basket4
ok( not CanUserManageBasket($borrower2, $basket3, $flags) );
ok( not CanUserManageBasket($borrower2, $basket4, $flags) );

# -----------------------
# AcqViewBaskets = 'user'
# -----------------------

$AcqViewBaskets = 'user';

# Simple cases where user can't manage basket
ok( not CanUserManageBasket($borrower1, $basket1, {}) );
ok( not CanUserManageBasket($borrower1, $basket1, {
    acquisition => 0
}) );
ok( not CanUserManageBasket($borrower1, $basket1, {
    acquisition => {
        order_manage => 0
    }
}) );

# Simple cases where user can manage basket
ok( CanUserManageBasket($borrower1, $basket1, {
    superlibrarian => 1
}) );
ok( CanUserManageBasket($borrower1, $basket1, {
    acquisition => 1
}) );
ok( CanUserManageBasket($borrower1, $basket1, {
    acquisition => {
        order_manage_all => 1
    }
}) );

ok( CanUserManageBasket($borrower1, $basket1, $flags) );
ok( CanUserManageBasket($borrower1, $basket2, $flags) );
# basket3 is not managed or created by borrower1
ok( not CanUserManageBasket($borrower1, $basket3, $flags) );
ok( CanUserManageBasket($borrower1, $basket4, $flags) );
# basket 1 is not managed or created by borrower2
ok( not CanUserManageBasket($borrower2, $basket1, $flags) );
ok( CanUserManageBasket($borrower2, $basket2, $flags) );
# basket 3 is not managed or created by borrower2
ok( not CanUserManageBasket($borrower2, $basket3, $flags) );
ok( CanUserManageBasket($borrower2, $basket4, $flags) );


# Mocked subs

# C4::Acquisition::GetBasketUsers
sub Mock_GetBasketUsers {
    my ($basketno) = @_;

    return @{ $basketusers{$basketno} };
}

# C4::Context->preference
sub Mock_preference {
    my ($self, $variable) = @_;
    if (lc($variable) eq 'acqviewbaskets') {
        return $AcqViewBaskets;
    }
}
