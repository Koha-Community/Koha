#!/usr/bin/env perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Test::More tests => 6;
use Test::Mojo;

use C4::Context;

use Koha::Database;
use Koha::Borrower;

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

my $t = Test::Mojo->new('Koha::REST::V1');

my $categorycode = Koha::Database->new()->schema()->resultset('Category')->first()->categorycode();
my $branchcode = Koha::Database->new()->schema()->resultset('Branch')->first()->branchcode();

my $borrower = Koha::Borrower->new;
$borrower->categorycode( $categorycode );
$borrower->branchcode( $branchcode );
$borrower->surname("Test Surname");
$borrower->store;
my $borrowernumber = $borrower->borrowernumber;

$t->get_ok('/api/v1/borrowers')
  ->status_is(200);

$t->get_ok("/api/v1/borrowers/$borrowernumber")
  ->status_is(200)
  ->json_is('/borrowernumber' => $borrowernumber)
  ->json_is('/surname' => "Test Surname");

$dbh->rollback;
