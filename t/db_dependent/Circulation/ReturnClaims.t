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

use Test::More tests => 2;
use Test::MockModule;
use Test::Warn;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Circulation;

# Mock userenv, used by AddIssue
my $branch;
my $manager_id;
my $context = Test::MockModule->new('C4::Context');
$context->mock(
    'userenv',
    sub {
        return {
            branch    => $branch,
            number    => $manager_id,
            firstname => "Adam",
            surname   => "Smaith"
        };
    }
);

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new();
Koha::CirculationRules->set_rule(
    {
        branchcode   => undef,
        categorycode => undef,
        itemtype     => undef,
        rule_name    => 'issuelength',
        rule_value   => 1
    }
);

$branch = $builder->build( { source => 'Branch' } )->{branchcode};

subtest 'Test Koha::Checkout::claim_returned' => sub {
    plan tests => 6;

    t::lib::Mocks::mock_preference( 'ClaimReturnedLostValue', 1 );
    my $biblio = $builder->build_object( { class => 'Koha::Biblios' } );
    my $item   = $builder->build_object(
        {
            class => 'Koha::Items',
            value => {
                biblionumber => $biblio->biblionumber,
                notforloan   => 0,
                itemlost     => 0,
                withdrawn    => 0,
            }
        }
    );
    my $patron   = $builder->build_object( { class => 'Koha::Patrons' } );
    my $checkout = AddIssue( $patron->unblessed, $item->barcode );

    my $claim = $checkout->claim_returned(
        {
            created_by => $patron->id,
            notes      => "Test note",
        }
    );

    is( $claim->issue_id, $checkout->id, "Claim issue id matches" );
    is( $claim->itemnumber, $item->id, "Claim itemnumber matches" );
    is( $claim->borrowernumber, $patron->id, "Claim borrowernumber matches" );
    is( $claim->notes, "Test note", "Claim notes match" );
    is( $claim->created_by, $patron->id, "Claim created_by matches" );
    ok( $claim->created_on, "Claim created_on is set" );
};

subtest 'Test Koha::Patronn::return_claims' => sub {
    plan tests => 7;

    t::lib::Mocks::mock_preference( 'ClaimReturnedLostValue', 1 );
    my $biblio = $builder->build_object( { class => 'Koha::Biblios' } );
    my $item   = $builder->build_object(
        {
            class => 'Koha::Items',
            value => {
                biblionumber => $biblio->biblionumber,
                notforloan   => 0,
                itemlost     => 0,
                withdrawn    => 0,
            }
        }
    );
    my $patron   = $builder->build_object( { class => 'Koha::Patrons' } );
    my $checkout = AddIssue( $patron->unblessed, $item->barcode );

    $checkout->claim_returned(
        {
            created_by => $patron->id,
            notes      => "Test note",
        }
    );

    my $claims = $patron->return_claims;

    is( $claims->count, 1, "Got back correct number of claims" );

    my $claim = $claims->next;

    is( $claim->issue_id, $checkout->id, "Claim issue id matches" );
    is( $claim->itemnumber, $item->id, "Claim itemnumber matches" );
    is( $claim->borrowernumber, $patron->id, "Claim borrowernumber matches" );
    is( $claim->notes, "Test note", "Claim notes match" );
    is( $claim->created_by, $patron->id, "Claim created_by matches" );
    ok( $claim->created_on, "Claim created_on is set" );
};

$schema->storage->txn_rollback;
