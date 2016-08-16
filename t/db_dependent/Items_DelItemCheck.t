#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use C4::Circulation;
use Koha::Database;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Test::More tests => 9;
use Test::MockModule;

BEGIN {
    use_ok('C4::Items');
}

my $builder = t::lib::TestBuilder->new();
my $schema = Koha::Database->new->schema;
# Begin transaction
$schema->storage->txn_begin;

my $branch = $builder->build(
    {
        source => 'Branch',
    }
);

my $module = new Test::MockModule('C4::Context');
$module->mock('userenv', sub {
    {  flags  => 0,
       branch => $branch->{branchcode}
    }
});

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
    ItemSafeToDelete( $biblio->{biblionumber}, $item->{itemnumber} ),
    'book_on_loan',
    'ItemSafeToDelete reports item on loan',
);

is(
    DelItemCheck( $biblio->{biblionumber}, $item->{itemnumber} ),
    'book_on_loan',
    'item that is on loan cannot be deleted',
);

AddReturn( $item->{barcode}, $branch->{branchcode} );

# book_reserved is tested in t/db_dependent/Reserves.t

# not_same_branch
t::lib::Mocks::mock_preference('IndependentBranches', 1);
ModItem( { homebranch => $branch2->{branchcode}, holdingbranch => $branch2->{branchcode} }, $biblio->{biblionumber}, $item->{itemnumber} );

is(
    ItemSafeToDelete( $biblio->{biblionumber}, $item->{itemnumber} ),
    'not_same_branch',
    'ItemSafeToDelete reports IndependentBranches restriction',
);

is(
    DelItemCheck( $biblio->{biblionumber}, $item->{itemnumber} ),
    'not_same_branch',
    'IndependentBranches prevents deletion at another branch',
);

ModItem( { homebranch => $branch->{branchcode}, holdingbranch => $branch->{branchcode} }, $biblio->{biblionumber}, $item->{itemnumber} );

# linked_analytics

{ # codeblock to limit scope of $module->mock

    my $module = Test::MockModule->new('C4::Items');
    $module->mock( GetAnalyticsCount => sub { return 1 } );

    is(
        ItemSafeToDelete( $biblio->{biblionumber}, $item->{itemnumber} ),
        'linked_analytics',
        'ItemSafeToDelete reports linked analytics',
    );

    is(
        DelItemCheck( $biblio->{biblionumber}, $item->{itemnumber} ),
        'linked_analytics',
        'Linked analytics prevents deletion of item',
    );

}

is(
    ItemSafeToDelete( $biblio->{biblionumber}, $item->{itemnumber} ),
    1,
    'ItemSafeToDelete shows item safe to delete'
);

DelItemCheck( $biblio->{biblionumber}, $item->{itemnumber} );

my $test_item = GetItem( $item->{itemnumber} );

is( $test_item->{itemnumber}, undef,
    "DelItemCheck should delete item if ItemSafeToDelete returns true"
);

$schema->storage->txn_rollback;

1;
