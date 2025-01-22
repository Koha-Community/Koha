#!/usr/bin/perl

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 2;

use Koha::Database;
use Koha::Acquisition::Budget;
use Koha::Acquisition::Fund;

use C4::Budgets qw(AddBudget CloneBudgetHierarchy GetBudgetHierarchy);

use t::lib::TestBuilder;

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'CloneBudgetHierarchy should clone budget users too' => sub {
    plan tests => 1;
    $schema->txn_begin;

    my $aqbudgetperiod_rs = $schema->resultset('Aqbudgetperiod');
    my $budget_1          = Koha::Acquisition::Budget->new(
        {
            budget_period_startdate => '2000-01-01',
            budget_period_enddate   => '2999-12-31',
        }
    )->store;

    my $budget_1_fund_1 = Koha::Acquisition::Fund->new(
        {
            budget_period_id => $budget_1->id,
        }
    )->store;

    my $patron_1 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron_2 = $builder->build_object( { class => 'Koha::Patrons' } );

    C4::Budgets::ModBudgetUsers( $budget_1_fund_1->id, $patron_1->id, $patron_2->id );

    my $budget_2 = Koha::Acquisition::Budget->new(
        {
            budget_period_startdate => '2000-01-01',
            budget_period_enddate   => '2999-12-31',
        }
    )->store;

    CloneBudgetHierarchy(
        {
            budgets              => C4::Budgets::GetBudgetHierarchy( $budget_1->id ),
            new_budget_period_id => $budget_2->id,
        }
    );

    my @funds           = Koha::Acquisition::Funds->search( { budget_period_id => $budget_2->id } )->as_list;
    my @borrowernumbers = C4::Budgets::GetBudgetUsers( $funds[0]->id );
    is_deeply(
        \@borrowernumbers, [ $patron_1->id, $patron_2->id ],
        'cloned budget has the same users as the original'
    );

    $schema->txn_rollback;
};
