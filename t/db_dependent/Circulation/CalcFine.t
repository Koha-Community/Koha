#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 2;

use C4::Context;
use C4::Overdues;

use Koha::DateUtils qw( dt_from_string );

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;

our $dbh = C4::Context->dbh;
$dbh->do(q|DELETE FROM issues|);

t::lib::Mocks::mock_preference('item-level_itypes', '1');

my $builder = t::lib::TestBuilder->new();

my $branch = $builder->build(
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

my $itemtype = $builder->build(
    {
        source => 'Itemtype',
        value => {
            defaultreplacecost => 6,
        },
    }
);

my $item = $builder->build(
    {
        source => 'Item',
        value  => {
            biblionumber     => $biblio->{biblionumber},
            homebranch       => $branch->{branchcode},
            holdingbranch    => $branch->{branchcode},
            replacementprice => '5.00',
            itype            => $itemtype->{itemtype},
        },
    }
);

subtest 'Test basic functionality' => sub {
    plan tests => 1;

    my $rule = $builder->schema->resultset('Issuingrule')->find({
        branchcode                    => '*',
        categorycode                  => '*',
        itemtype                      => '*',
    });
    $rule->delete if $rule;
    my $issuingrule = $builder->build(
        {
            source => 'Issuingrule',
            value  => {
                branchcode                    => '*',
                categorycode                  => '*',
                itemtype                      => '*',
                fine                          => '1.00',
                lengthunit                    => 'days',
                finedays                      => 0,
                firstremind                   => 0,
                chargeperiod                  => 1,
                overduefinescap               => undef,
                cap_fine_to_replacement_price => 0,
            },
        }
    );

    my $start_dt = DateTime->new(
        year       => 2000,
        month      => 1,
        day        => 1,
    );

    my $end_dt = DateTime->new(
        year       => 2000,
        month      => 1,
        day        => 30,
    );

    my ($amount) = CalcFine( $item, $patron->{categorycode}, $branch->{branchcode}, $start_dt, $end_dt );

    is( $amount, 29, 'Amount is calculated correctly' );

    teardown();
};

subtest 'Test cap_fine_to_replacement_price' => sub {
    plan tests => 2;

    t::lib::Mocks::mock_preference('useDefaultReplacementCost', '1');
    my $issuingrule = $builder->build(
        {
            source => 'Issuingrule',
            value  => {
                branchcode                    => '*',
                categorycode                  => '*',
                itemtype                      => '*',
                fine                          => '1.00',
                lengthunit                    => 'days',
                finedays                      => 0,
                firstremind                   => 0,
                chargeperiod                  => 1,
                overduefinescap               => undef,
                cap_fine_to_replacement_price => 1,
            },
        }
    );

    my $start_dt = DateTime->new(
        year       => 2000,
        month      => 1,
        day        => 1,
    );

    my $end_dt = DateTime->new(
        year       => 2000,
        month      => 1,
        day        => 30,
    );

    my ($amount) = CalcFine( $item, $patron->{categorycode}, $branch->{branchcode}, $start_dt, $end_dt );

    is( int($amount), 5, 'Amount is calculated correctly' );


    # Use default replacement cost (useDefaultReplacementCost) is item's replacement price is 0
    my $item_obj = Koha::Items->find($item->{itemnumber});
    $item_obj->replacementprice(0)->store;
    ($amount) = CalcFine( $item_obj->unblessed, $patron->{categorycode}, $branch->{branchcode}, $start_dt, $end_dt );
    is( int($amount), 6, 'Amount is calculated correctly' );

    teardown();
};

sub teardown {
    $dbh->do(q|DELETE FROM issuingrules|);
}
