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

use Test::More tests => 13;
use Test::Warn;

use C4::Context;
use Koha::Database;

BEGIN {
    use_ok('Koha::Objects');
    use_ok('Koha::Patrons');
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

my $b1 = Koha::Patron->new(
    {
        surname      => 'Test 1',
        branchcode   => $branchcode,
        categorycode => $categorycode
    }
);
$b1->store();
my $b2 = Koha::Patron->new(
    {
        surname      => 'Test 2',
        branchcode   => $branchcode,
        categorycode => $categorycode
    }
);
$b2->store();
my $b3 = Koha::Patron->new(
    {
        surname      => 'Test 3',
        branchcode   => $branchcode,
        categorycode => $categorycode
    }
);
$b3->store();

my $b1_new = Koha::Patrons->find( $b1->borrowernumber() );
is( $b1->surname(), $b1_new->surname(), "Found matching patron" );

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

1;
