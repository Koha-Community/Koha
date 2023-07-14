#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 7;
use Test::Warn;

use C4::Context;
use C4::Overdues qw( CalcFine );

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

my $itemtype = $builder->build(
    {
        source => 'Itemtype',
        value => {
            defaultreplacecost => 6,
        },
    }
);

my $item = $builder->build_sample_item(
    {
        library          => $branch->{branchcode},
        replacementprice => '5.00',
        itype            => $itemtype->{itemtype},
    }
);

subtest 'Test basic functionality' => sub {
    plan tests => 1;

    Koha::CirculationRules->set_rules(
        {
            branchcode   => undef,
            categorycode => undef,
            itemtype     => undef,
            rules        => {
                fine                          => '1.00',
                lengthunit                    => 'days',
                finedays                      => 0,
                firstremind                   => 0,
                chargeperiod                  => 1,
                overduefinescap               => undef,
                cap_fine_to_replacement_price => 0,
            }
        },
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

    my ($amount) = CalcFine( $item->unblessed, $patron->{categorycode}, $branch->{branchcode}, $start_dt, $end_dt );

    is( $amount, 29, 'Amount is calculated correctly' );

    teardown();
};

subtest 'Overdue fines cap should be disabled when value is 0' => sub {
    plan tests => 1;

    Koha::CirculationRules->set_rules(
        {
            branchcode   => undef,
            categorycode => undef,
            itemtype     => undef,
            rules        => {
                fine                          => '1.00',
                lengthunit                    => 'days',
                finedays                      => 0,
                firstremind                   => 0,
                chargeperiod                  => 1,
                overduefinescap               => "0",
                cap_fine_to_replacement_price => 0,
            }
        },
    );

    my $start_dt = DateTime->new(
        year  => 2000,
        month => 1,
        day   => 1,
    );

    my $end_dt = DateTime->new(
        year  => 2000,
        month => 1,
        day   => 30,
    );

    my ($amount) = CalcFine( $item->unblessed, $patron->{categorycode}, $branch->{branchcode}, $start_dt, $end_dt );

    is( $amount, 29, 'Amount is calculated correctly' );

    teardown();
};

subtest 'Overdue fines cap should be disabled when value is 0.00' => sub {
    plan tests => 1;

    Koha::CirculationRules->set_rules(
        {
            branchcode   => undef,
            categorycode => undef,
            itemtype     => undef,
            rules        => {
                fine                          => '1.00',
                lengthunit                    => 'days',
                finedays                      => 0,
                firstremind                   => 0,
                chargeperiod                  => 1,
                overduefinescap               => "0.00",
                cap_fine_to_replacement_price => 0,
            }
        },
    );

    my $start_dt = DateTime->new(
        year  => 2000,
        month => 1,
        day   => 1,
    );

    my $end_dt = DateTime->new(
        year  => 2000,
        month => 1,
        day   => 30,
    );

    my ($amount) = CalcFine( $item->unblessed, $patron->{categorycode}, $branch->{branchcode}, $start_dt, $end_dt );

    is( $amount, 29, 'Amount is calculated correctly' );

    teardown();
};


subtest 'Test with fine amount empty' => sub {
    plan tests => 1;

    Koha::CirculationRules->set_rules(
        {
            branchcode   => undef,
            categorycode => undef,
            itemtype     => undef,
            rules        => {
                fine                          => '',
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

    warning_is {
    my ($amount) = CalcFine( $item->unblessed, $patron->{categorycode}, $branch->{branchcode}, $start_dt, $end_dt );
    }
    undef, "No warning when fine amount is ''";

    teardown();
};

subtest 'Test cap_fine_to_replacement_price' => sub {
    plan tests => 2;

    t::lib::Mocks::mock_preference('useDefaultReplacementCost', '1');
    Koha::CirculationRules->set_rules(
        {
            branchcode   => undef,
            categorycode => undef,
            itemtype     => undef,
            rules        => {
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

    my $item = $builder->build_sample_item(
        {
            library          => $branch->{branchcode},
            replacementprice => 5,
            itype            => $itemtype->{itemtype},
        }
    );

    my ($amount) = CalcFine( $item->unblessed, $patron->{categorycode}, $branch->{branchcode}, $start_dt, $end_dt );

    is( int($amount), 5, 'Amount is calculated correctly' );

    # Use default replacement cost (useDefaultReplacementCost) is item's replacement price is 0
    $item->replacementprice(0)->store;
    ($amount) = CalcFine( $item->unblessed, $patron->{categorycode}, $branch->{branchcode}, $start_dt, $end_dt );
    is( int($amount), 6, 'Amount is calculated correctly' );

    teardown();
};

subtest 'Test cap_fine_to_replacement_pricew with overduefinescap' => sub {
    plan tests => 2;

    t::lib::Mocks::mock_preference('useDefaultReplacementCost', '1');
    Koha::CirculationRules->set_rules(
        {
            branchcode   => undef,
            categorycode => undef,
            itemtype     => undef,
            rules        => {
                fine                          => '1.00',
                lengthunit                    => 'days',
                finedays                      => 0,
                firstremind                   => 0,
                chargeperiod                  => 1,
                overduefinescap               => 3,
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

    my ($amount) = CalcFine( $item->unblessed, $patron->{categorycode}, $branch->{branchcode}, $start_dt, $end_dt );
    is( int($amount), 3, 'Got the lesser of overduefinescap and replacement price where overduefinescap < replacement price' );

    Koha::CirculationRules->set_rule({ rule_name => 'overduefinescap', rule_value => 6, branchcode => undef, categorycode => undef, itemtype => undef });
    ($amount) = CalcFine( $item->unblessed, $patron->{categorycode}, $branch->{branchcode}, $start_dt, $end_dt );
    is( int($amount), 5, 'Get the lesser of overduefinescap and replacement price where overduefinescap > replacement price' );

    teardown();
};

subtest 'Recall overdue fines' => sub {
    plan tests => 2;

    Koha::CirculationRules->set_rules(
        {
            branchcode   => undef,
            categorycode => undef,
            itemtype     => undef,
            rules        => {
                fine                          => '1.00',
                lengthunit                    => 'days',
                finedays                      => 0,
                firstremind                   => 0,
                chargeperiod                  => 1,
                recall_overdue_fine           => '5.00',
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
        day        => 6,
    );

    my $recall = Koha::Recall->new({
        patron_id => $patron->{borrowernumber},
        created_date => dt_from_string,
        biblio_id => $item->biblionumber,
        pickup_library_id => $branch->{branchcode},
        item_id => $item->itemnumber,
        expiration_date => undef,
        item_level => 1
    })->store;
    $recall->set_overdue;

    my ($amount) = CalcFine( $item->unblessed, $patron->{categorycode}, $branch->{branchcode}, $start_dt, $end_dt );
    is( int($amount), 25, 'Use recall fine amount specified in circulation rules' );

    $recall->set_fulfilled;
    ($amount) = CalcFine( $item->unblessed, $patron->{categorycode}, $branch->{branchcode}, $start_dt, $end_dt );
    is( int($amount), 5, 'With no recall, use normal fine amount' );


    teardown();
};

sub teardown {
    $dbh->do(q|DELETE FROM circulation_rules|);
}
