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

use Test::More tests => 12;
use Test::Warn;

use C4::Context;
use Koha::Database;

BEGIN {
    use_ok('Koha::Objects');
    use_ok('Koha::Borrowers');
}

# Start transaction
my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;
$dbh->do("DELETE FROM issues");
$dbh->do("DELETE FROM borrowers");

my $categorycode =
  Koha::Database->new()->schema()->resultset('Category')->first()
  ->categorycode();
my $branchcode =
  Koha::Database->new()->schema()->resultset('Branch')->first()->branchcode();

my $b1 = Koha::Borrower->new(
    {
        surname      => 'Test 1',
        branchcode   => $branchcode,
        categorycode => $categorycode
    }
);
$b1->store();
my $b2 = Koha::Borrower->new(
    {
        surname      => 'Test 2',
        branchcode   => $branchcode,
        categorycode => $categorycode
    }
);
$b2->store();
my $b3 = Koha::Borrower->new(
    {
        surname      => 'Test 3',
        branchcode   => $branchcode,
        categorycode => $categorycode
    }
);
$b3->store();

my $b1_new = Koha::Borrowers->find( $b1->borrowernumber() );
is( $b1->surname(), $b1_new->surname(), "Found matching borrower" );

my @borrowers = Koha::Borrowers->search( { branchcode => $branchcode } );
is( @borrowers, 3, "Found 3 borrowers with Search" );

my $borrowers = Koha::Borrowers->search( { branchcode => $branchcode } );
is( $borrowers->count( { branchcode => $branchcode } ), 3, "Counted 3 borrowers with Count" );

my $b = $borrowers->next();
is( $b->surname(), 'Test 1', "Next returns first borrower" );
$b = $borrowers->next();
is( $b->surname(), 'Test 2', "Next returns second borrower" );
$b = $borrowers->next();
is( $b->surname(), 'Test 3', "Next returns third borrower" );
$b = $borrowers->next();
is( $b, undef, "Next returns undef" );

# Test Reset and iteration in concert
$borrowers->reset();
foreach my $b ( $borrowers->as_list() ) {
    is( $b->categorycode(), $categorycode, "Iteration returns a borrower object" );
}

1;
