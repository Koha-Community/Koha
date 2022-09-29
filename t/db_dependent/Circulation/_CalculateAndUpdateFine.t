#!/usr/bin/perl

# Copyright University of Helsinki 2020
#
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

use Test::More tests => 1;

use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::CirculationRules;

use C4::Circulation;

use t::lib::TestBuilder;
use t::lib::Mocks;


my $schema = Koha::Database->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new();

my $branch = $builder->build({
    source => 'Branch',
});

my $branch2 = $builder->build({
     source => 'Branch',
});

my $category = $builder->build({
    source => 'Category',
});

my $patron = $builder->build_object({
    class => 'Koha::Patrons',
    value => {
        categorycode => $category->{categorycode},
        branchcode => $branch->{branchcode},
    },
});

my $biblio = $builder->build_sample_biblio({ branchcode => $branch->{branchcode} });

my $item = $builder->build_sample_item({
    biblionumber => $biblio->biblionumber,
    homebranch => $branch->{branchcode},
    holdingbranch => $branch2->{branchcode},
});

Koha::CirculationRules->search()->delete();

subtest 'HomeOrHoldingBranch is used' => sub {
    plan tests => 2;

    # Homebranch rule with fine
    Koha::CirculationRules->set_rules(
        {
            itemtype     => undef,
            categorycode => undef,
            branchcode   => $branch->{branchcode},
            rules        => {
                fine                          => '1.00',
                lengthunit                    => 'days',
                finedays                      => 0,
                chargeperiod                  => 1,
            }
        }
    );

    # Holdingbranch rule without fine
    Koha::CirculationRules->set_rules(
        {
            itemtype     => undef,
            categorycode => undef,
            branchcode   => $branch2->{branchcode},
            rules        => {
                fine                          => '0.00',
                lengthunit                    => 'days',
                finedays                      => 0,
                chargeperiod                  => 1,
            }
        }
    );

    t::lib::Mocks::mock_preference('finesMode', 'production');
    t::lib::Mocks::mock_preference('CircControl', 'ItemHomeLibrary');
    t::lib::Mocks::mock_preference('HomeOrHoldingBranch', 'holdingbranch');
    t::lib::Mocks::mock_userenv({ branchcode => $branch->{branchcode} });

    my $issue = C4::Circulation::AddIssue( $patron, $item->barcode, dt_from_string() );

    # Returning loan 1 day after due date
    my $return_date = dt_from_string()->add( days => 1 )->set( hour => 23, minute => 59, second => 0 );
    C4::Circulation::_CalculateAndUpdateFine(
       {
            borrower => $patron->unblessed,
            issue => $issue,
            item => $item->unblessed,
            return_date => $return_date,
        }
    );

    my $fines = Koha::Account::Lines->search({ borrowernumber => $patron->borrowernumber });
    is($fines->total_outstanding, 0, "Fine is not accrued for holdingbranch");

    t::lib::Mocks::mock_preference('HomeOrHoldingBranch', 'homebranch');
    C4::Circulation::_CalculateAndUpdateFine(
        {
            borrower => $patron->unblessed,
            issue => $issue,
            item => $item->unblessed,
            return_date => $return_date,
        }
    );
    $fines = Koha::Account::Lines->search({ borrowernumber => $patron->borrowernumber });
    is($fines->total_outstanding, 1, "Fine is accrued for homebranch");

};

$schema->storage->txn_rollback;
