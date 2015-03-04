#!/usr/bin/env perl

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
