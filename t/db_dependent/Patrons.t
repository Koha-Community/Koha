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

use Test::More tests => 18;
use Test::Warn;

use C4::Context;
use Koha::Database;
use Koha::DateUtils;

use t::lib::Dates;
use t::lib::TestBuilder;

BEGIN {
    use_ok('Koha::Objects');
    use_ok('Koha::Patrons');
}

# Start transaction
my $database = Koha::Database->new();
my $schema = $database->schema();
$schema->storage->txn_begin();
my $builder = t::lib::TestBuilder->new;

my $categorycode = $builder->build({ source => 'Category' })->{categorycode};
my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};

my $b1 = Koha::Patron->new(
    {
        surname      => 'Test 1',
        branchcode   => $branchcode,
        categorycode => $categorycode
    }
);
$b1->store();
my $now = dt_from_string;
my $b2 = Koha::Patron->new(
    {
        surname      => 'Test 2',
        branchcode   => $branchcode,
        categorycode => $categorycode
    }
);
$b2->store();
my $three_days_ago = dt_from_string->add( days => -3 );
my $b3 = Koha::Patron->new(
    {
        surname      => 'Test 3',
        branchcode   => $branchcode,
        categorycode => $categorycode,
        updated_on   => $three_days_ago,
    }
);
$b3->store();

my $b1_new = Koha::Patrons->find( $b1->borrowernumber() );
is( $b1->surname(), $b1_new->surname(), "Found matching patron" );
isnt( $b1_new->updated_on, undef, "borrowers.updated_on should be set" );
is( t::lib::Dates::compare( $b1_new->updated_on, $now), 0, "borrowers.updated_on should have been set to now on creating" );

my $b3_new = Koha::Patrons->find( $b3->borrowernumber() );
is( t::lib::Dates::compare( $b3_new->updated_on, $three_days_ago), 0, "borrowers.updated_on should have been kept to what we set on creating" );
$b3_new->set({ firstname => 'Some first name for Test 3' })->store();
$b3_new = Koha::Patrons->find( $b3->borrowernumber() );
is( t::lib::Dates::compare( $b3_new->updated_on, $now), 0, "borrowers.updated_on should have been set to now on updating" );

my @patrons = Koha::Patrons->search( { branchcode => $branchcode } );
is( @patrons, 3, "Found 3 patrons with Search" );

my $unexistent = Koha::Patrons->find( '1234567890' );
is( $unexistent, undef, 'Koha::Objects->Find should return undef if the record does not exist' );

my $patrons = Koha::Patrons->search( { branchcode => $branchcode } );
is( $patrons->count( { branchcode => $branchcode } ), 3, "Counted 3 patrons with Count" );

my $b = $patrons->next();
is( $b->surname(), 'Test 1', "Next returns first patron" );
$b = $patrons->next();
is( $b->surname(), 'Test 2', "Next returns second patron" );
$b = $patrons->next();
is( $b->surname(), 'Test 3', "Next returns third patron" );
$b = $patrons->next();
is( $b, undef, "Next returns undef" );

# Test Reset and iteration in concert
$patrons->reset();
foreach my $b ( $patrons->as_list() ) {
    is( $b->categorycode(), $categorycode, "Iteration returns a patron object" );
}

subtest 'Test Koha::Patrons::merge' => sub {
    plan tests => 98;

    my $schema = Koha::Database->new()->schema();

    my $resultsets = $Koha::Patrons::RESULTSET_PATRON_ID_MAPPING;

    my $keeper  = $builder->build( { source => 'Borrower' } )->{borrowernumber};
    my $loser_1 = $builder->build( { source => 'Borrower' } )->{borrowernumber};
    my $loser_2 = $builder->build( { source => 'Borrower' } )->{borrowernumber};

    while (my ($r, $field) = each(%$resultsets)) {
        $builder->build( { source => $r, value => { $field => $keeper } } );
        $builder->build( { source => $r, value => { $field => $loser_1 } } );
        $builder->build( { source => $r, value => { $field => $loser_2 } } );

        my $keeper_rs =
          $schema->resultset($r)->search( { $field => $keeper } );
        is( $keeper_rs->count(), 1, "Found 1 $r rows for keeper" );

        my $loser_1_rs =
          $schema->resultset($r)->search( { $field => $loser_1 } );
        is( $loser_1_rs->count(), 1, "Found 1 $r rows for loser_1" );

        my $loser_2_rs =
          $schema->resultset($r)->search( { $field => $loser_2 } );
        is( $loser_2_rs->count(), 1, "Found 1 $r rows for loser_2" );
    }

    my $results = Koha::Patrons->merge(
        {
            keeper  => $keeper,
            patrons => [ $loser_1, $loser_2 ],
        }
    );

    while (my ($r, $field) = each(%$resultsets)) {
        my $keeper_rs =
          $schema->resultset($r)->search( {$field => $keeper } );
        is( $keeper_rs->count(), 3, "Found 2 $r rows for keeper" );
    }

    is( Koha::Patrons->find($loser_1), undef, 'Loser 1 has been deleted' );
    is( Koha::Patrons->find($loser_2), undef, 'Loser 2 has been deleted' );
};

$schema->storage->txn_rollback();

