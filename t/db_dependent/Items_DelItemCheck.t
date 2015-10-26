use Modern::Perl;

use C4::Circulation;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Test::More tests => 9;

*C4::Context::userenv = \&Mock_userenv;

BEGIN {
    use_ok('C4::Items');
}

my $dbh = C4::Context->dbh;

my $builder = t::lib::TestBuilder->new();

my $branch = $builder->build(
    {
        source => 'Branch',
    }
);

my $branch2 = $builder->build(
    {
        source => 'Branch',
    }
);

my $category = $builder->build(
    {
        source => 'Category',
    }
);

my $patron = $builder->build(
    {
        source => 'Borrower',
        value  => {
            categorycode => $category->{categorycode},
            branchcode   => $branch->{branchcode},
        },
    }
);

my $biblio = $builder->build(
    {
        source => 'Biblio',
        value  => {
            branchcode => $branch->{branchcode},
        },
    }
);

my $item = $builder->build(
    {
        source => 'Item',
        value  => {
            biblionumber  => $biblio->{biblionumber},
            homebranch    => $branch->{branchcode},
            holdingbranch => $branch->{branchcode},
            withdrawn    => 0,       # randomly assigned value may block return.
            withdrawn_on => undef,
        },
    }
);

# book_on_loan

AddIssue( $patron, $item->{barcode} );

is(
    ItemSafeToDelete($dbh, $biblio->{biblionumber}, $item->{itemnumber} ),
    'book_on_loan',
    'ItemSafeToDelete reports item on loan',
);

is(
    DelItemCheck($dbh, $biblio->{biblionumber}, $item->{itemnumber} ),
    'book_on_loan',
    'item that is on loan cannot be deleted',
);

AddReturn( $item->{barcode}, $branch->{branchcode} );

# book_reserved is tested in t/db_dependent/Reserves.t

# not_same_branch
t::lib::Mocks::mock_preference('IndependentBranches', 1);
ModItem( { homebranch => $branch2->{branchcode}, holdingbranch => $branch2->{branchcode} }, $biblio->{biblionumber}, $item->{itemnumber} );

is(
    ItemSafeToDelete($dbh, $biblio->{biblionumber}, $item->{itemnumber} ),
    'not_same_branch',
    'ItemSafeToDelete reports IndependentBranches restriction',
);

is(
    DelItemCheck($dbh, $biblio->{biblionumber}, $item->{itemnumber} ),
    'not_same_branch',
    'IndependentBranches prevents deletion at another branch',
);

ModItem( { homebranch => $branch->{branchcode}, holdingbranch => $branch->{branchcode} }, $biblio->{biblionumber}, $item->{itemnumber} );

# linked_analytics

{ # codeblock to limit scope of $module->mock

    my $module = Test::MockModule->new('C4::Items');
    $module->mock( GetAnalyticsCount => sub { return 1 } );

    is(
        ItemSafeToDelete($dbh, $biblio->{biblionumber}, $item->{itemnumber} ),
        'linked_analytics',
        'ItemSafeToDelete reports linked analytics',
    );

    is(
        DelItemCheck($dbh, $biblio->{biblionumber}, $item->{itemnumber} ),
        'linked_analytics',
        'Linked analytics prevents deletion of item',
    );

}

is(
    ItemSafeToDelete($dbh, $biblio->{biblionumber}, $item->{itemnumber} ),
    1,
    'ItemSafeToDelete shows item safe to delete'
);

DelItemCheck( $dbh, $biblio->{biblionumber}, $item->{itemnumber} );

my $test_item = GetItem( $item->{itemnumber} );

is( $test_item->{itemnumber}, undef,
    "DelItemCheck should delete item if 'do_not_commit' not set"
);

# End of testing

# C4::Context->userenv
sub Mock_userenv {
    return { flags => 0, branch => $branch->{branchcode} };
}
