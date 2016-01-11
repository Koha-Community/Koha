#!/usr/bin/perl

# Copyright 2015 BibLibre
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 117;
use t::lib::TestBuilder;

use Koha::Database;
use Time::Piece;

BEGIN {
    use_ok('C4::Biblio');
    use_ok('C4::Review');
    use_ok('Koha::Patron');
    use_ok('MARC::Record');
}

can_ok(
    'C4::Review', qw(
      getreview
      savereview
      updatereview
      numberofreviews
      numberofreviewsbybiblionumber
      getreviews
      getallreviews
      approvereview
      unapprovereview
      deletereview )
);

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
our $dbh = C4::Context->dbh;

$dbh->do('DELETE FROM reviews');
$dbh->do('DELETE FROM issues');
$dbh->do('DELETE FROM borrowers');

my $builder = t::lib::TestBuilder->new;

# ---------- Some borrowers for testing -------------------
my $categorycode = $builder->build({ source => 'Category' })->{ categorycode };
my $branchcode   = $builder->build({ source => 'Branch' })->{ branchcode };

my $b1 = Koha::Patron->new(
    {   surname      => 'Borrower 1',
        branchcode   => $branchcode,
        categorycode => $categorycode
    }
);
$b1->store();

my $b2 = Koha::Patron->new(
    {   surname      => 'Borrower 2',
        branchcode   => $branchcode,
        categorycode => $categorycode
    }
);
$b2->store();

my $b3 = Koha::Patron->new(
    {   surname      => 'Borrower 3',
        branchcode   => $branchcode,
        categorycode => $categorycode
    }
);
$b3->store();

# ---------- Some biblios for testing -------------------
my ($biblionumber1) = AddBiblio( MARC::Record->new, '' );
my ($biblionumber2) = AddBiblio( MARC::Record->new, '' );
my ($biblionumber3) = AddBiblio( MARC::Record->new, '' );

# ---------- Some reviews for testing -------------------
my $rev1 = 'Review 1';
my $rev2 = 'Review 2';
my $rev3 = 'Review 3';

# ---------- Testing savereview ---------------------------
my $date = Time::Piece::localtime->strftime('%F %T');

savereview( $biblionumber1, $b1->borrowernumber, $rev1 );

my $query = '
  SELECT count(*)
  FROM reviews
';
my $count = $dbh->selectrow_array($query);
is( $count, 1, 'There is 1 review' );

$query = '
  SELECT reviewid, borrowernumber, biblionumber, review, approved, datereviewed
  FROM reviews
';
my ( $reviewid, $borrowernumber, $biblionumber, $review, $approved, $datereviewed ) = $dbh->selectrow_array($query);
is( $borrowernumber, $b1->borrowernumber, 'borrowernumber field is good' );
is( $biblionumber,   $biblionumber1,      'biblionumber field is good' );
is( $review,         $rev1,               'review field is good' );
is( $approved,       0,                   'approved field is 0 by default' );
is( $datereviewed,   $date,               'datereviewed field is good' );

# We add some others reviews
savereview( $biblionumber1, $b2->borrowernumber, $rev2 );
savereview( $biblionumber3, $b2->borrowernumber, $rev3 );

# ---------- Testing getreview ----------------------------
my $review1 = getreview( $biblionumber1, $b1->borrowernumber );
my $review2 = getreview( $biblionumber1, $b2->borrowernumber );
my $review3 = getreview( $biblionumber3, $b2->borrowernumber );

$query = '
  SELECT count(*)
  FROM reviews
';
$count = $dbh->selectrow_array($query);
is( $count, 3, 'There are 3 reviews' );

isa_ok( $review1, 'HASH', '$review1 is defined as a hash' );
is( $review1->{borrowernumber}, $b1->borrowernumber, 'borrowernumber field is good' );
is( $review1->{biblionumber},   $biblionumber1,      'biblionumber field is good' );
is( $review1->{review},         $rev1,               'review field is good' );
is( $review1->{approved},       0,                   'approved field is 0 by default' );
cmp_ok( $review1->{datereviewed}, 'ge', $date, 'datereviewed field is good' );

isa_ok( $review2, 'HASH', '$review2 is defined as a hash' );
is( $review2->{borrowernumber}, $b2->borrowernumber, 'borrowernumber field is good' );
is( $review2->{biblionumber},   $biblionumber1,      'biblionumber field is good' );
is( $review2->{review},         $rev2,               'review field is good' );
is( $review2->{approved},       0,                   'approved field is 0 by default' );
cmp_ok( $review2->{datereviewed}, 'ge', $date, 'datereviewed field is good' );

isa_ok( $review3, 'HASH', '$review3 is defined as a hash' );
is( $review3->{borrowernumber}, $b2->borrowernumber, 'borrowernumber field is good' );
is( $review3->{biblionumber},   $biblionumber3,      'biblionumber field is good' );
is( $review3->{review},         $rev3,               'review field is good' );
is( $review3->{approved},       0,                   'approved field is 0 by default' );
cmp_ok( $review3->{datereviewed}, 'ge', $date, 'datereviewed field is good' );

# ---------- Testing getreviews ---------------------------
my $status = 0;
my $reviews = getreviews( $biblionumber1, $status );

$query = '
  SELECT count(*)
  FROM reviews
  WHERE biblionumber = ?
    AND approved = ?
';
$count = $dbh->selectrow_array( $query, {}, $biblionumber1, $status );
is( $count, 2, 'There are 2 reviews corresponding' );

isa_ok( $reviews, 'ARRAY', '$reviews is defined as an array' );

isa_ok( $reviews->[0], 'HASH', '$reviews->[0] is defined as a hash' );
is( $reviews->[0]->{reviewid},       $review1->{reviewid},       'reviewid field is good' );
is( $reviews->[0]->{borrowernumber}, $review1->{borrowernumber}, 'borrowernumber field is good' );
is( $reviews->[0]->{biblionumber},   $review1->{biblionumber},   'biblionumber field is good' );
is( $reviews->[0]->{review},         $review1->{review},         'review field is good' );
is( $reviews->[0]->{approved},       $review1->{approved},       'approved field is 0 by default' );
cmp_ok( $reviews->[0]->{datereviewed}, 'ge', $date, 'datereviewed field is good' );

isa_ok( $reviews->[1], 'HASH', '$reviews->[1] is defined as a hash' );
is( $reviews->[1]->{reviewid},       $review2->{reviewid},       'reviewid field is good' );
is( $reviews->[1]->{borrowernumber}, $review2->{borrowernumber}, 'borrowernumber field is good' );
is( $reviews->[1]->{biblionumber},   $review2->{biblionumber},   'biblionumber field is good' );
is( $reviews->[1]->{review},         $review2->{review},         'review field is good' );
is( $reviews->[1]->{approved},       $review2->{approved},       'approved field is 0 by default' );
cmp_ok( $reviews->[1]->{datereviewed}, 'ge', $date, 'datereviewed field is good' );

$status = 1;
$reviews = getreviews( $biblionumber1, $status );
isa_ok( $reviews, 'ARRAY', '$reviews is defined as an array' );
is_deeply( $reviews, [], '$reviews is empty, there is no approved review' );

# ---------- Testing getallreviews ------------------------
$status  = 1;
$reviews = getallreviews($status);
isa_ok( $reviews, 'ARRAY', '$reviews is defined as an array' );
is_deeply( $reviews, [], '$reviews is empty, there is no approved review' );

$status  = 0;
$reviews = getallreviews($status);

$query = '
  SELECT count(*)
  FROM reviews
  WHERE approved = ?
';
$count = $dbh->selectrow_array( $query, {}, $status );
is( $count, 3, 'There are 3 reviews corresponding' );

my $count2 = numberofreviews($status);
is( $count2, $count, 'number of reviews returned is good' );

isa_ok( $reviews, 'ARRAY', '$reviews is defined as an array' );

isa_ok( $reviews->[0], 'HASH', '$reviews->[0] is defined as a hash' );
is( $reviews->[0]->{reviewid},       $review1->{reviewid},       'reviewid field is good' );
is( $reviews->[0]->{borrowernumber}, $review1->{borrowernumber}, 'borrowernumber field is good' );
is( $reviews->[0]->{biblionumber},   $review1->{biblionumber},   'biblionumber field is good' );
is( $reviews->[0]->{review},         $review1->{review},         'review field is good' );
is( $reviews->[0]->{approved},       $review1->{approved},       'approved field is 0 by default' );
cmp_ok( $reviews->[0]->{datereviewed}, 'ge', $date, 'datereviewed field is good' );

isa_ok( $reviews->[1], 'HASH', '$reviews->[1] is defined as a hash' );
is( $reviews->[1]->{reviewid},       $review2->{reviewid},       'reviewid field is good' );
is( $reviews->[1]->{borrowernumber}, $review2->{borrowernumber}, 'borrowernumber field is good' );
is( $reviews->[1]->{biblionumber},   $review2->{biblionumber},   'biblionumber field is good' );
is( $reviews->[1]->{review},         $review2->{review},         'review field is good' );
is( $reviews->[1]->{approved},       $review2->{approved},       'approved field is 0 by default' );
cmp_ok( $reviews->[1]->{datereviewed}, 'ge', $date, 'datereviewed field is good' );

isa_ok( $reviews->[2], 'HASH', '$reviews->[2] is defined as a hash' );
is( $reviews->[2]->{reviewid},       $review3->{reviewid},       'reviewid field is good' );
is( $reviews->[2]->{borrowernumber}, $review3->{borrowernumber}, 'borrowernumber field is good' );
is( $reviews->[2]->{biblionumber},   $review3->{biblionumber},   'biblionumber field is good' );
is( $reviews->[2]->{review},         $review3->{review},         'review field is good' );
is( $reviews->[2]->{approved},       $review3->{approved},       'approved field is 0 by default' );
cmp_ok( $reviews->[2]->{datereviewed}, 'ge', $date, 'datereviewed field is good' );

my $offset    = 1;
my $row_count = 1;
$reviews = getallreviews( $status, $offset );
is( @$reviews, 2, 'There are only 2 Reviews here' );
is_deeply( $reviews->[0], $review2, 'We have Review2...' );
is_deeply( $reviews->[1], $review3, '...and Review3' );

$reviews = getallreviews( $status, $offset, $row_count );
is( @$reviews, 1, 'There is only 1 Review here' );
is_deeply( $reviews->[0], $review2, 'We have only Review2' );

# ---------- Testing numberofreviews ----------------------
$status = 0;
$count  = numberofreviews($status);
is( $count, 3, 'There are 3 reviews where approved = 0' );

$status = 1;
$count  = numberofreviews($status);
is( $count, 0, 'There is no review where approved = 0' );

$count = numberofreviews();
is( $count, 0, 'There is no review where approved = 0 (Default)' );

# ---------- Testing approvereview ------------------------
is( $review1->{approved}, 0, 'review1 is not approved' );
approvereview( $review1->{reviewid} );
$review1 = getreview( $biblionumber1, $b1->borrowernumber );
is( $review1->{approved}, 1, 'review1 is approved' );

is( $review2->{approved}, 0, 'review2 is not approved' );
approvereview( $review2->{reviewid} );
$review2 = getreview( $biblionumber1, $b2->borrowernumber );
is( $review2->{approved}, 1, 'review2 is approved' );

is( $review3->{approved}, 0, 'review3 is not approved' );
approvereview( $review3->{reviewid} );
$review3 = getreview( $biblionumber3, $b2->borrowernumber );
is( $review3->{approved}, 1, 'review3 is approved' );

$status  = 1;
$reviews = getallreviews($status);

$count = numberofreviews($status);
is( $count, 3, '3 reviews are approved' );

$status = 0;
$count  = numberofreviews($status);
is( $count, 0, 'No review are not approved' );

# ---------- Testing unapprovereview ----------------------
is( $review1->{approved}, 1, 'review1 is approved' );
unapprovereview( $review1->{reviewid} );
$review1 = getreview( $biblionumber1, $b1->borrowernumber );
is( $review1->{approved}, 0, 'review1 is not approved' );

is( $review2->{approved}, 1, 'review2 is approved' );
unapprovereview( $review2->{reviewid} );
$review2 = getreview( $biblionumber1, $b2->borrowernumber );
is( $review2->{approved}, 0, 'review2 is not approved' );

is( $review3->{approved}, 1, 'review3 is approved' );
unapprovereview( $review3->{reviewid} );
$review3 = getreview( $biblionumber3, $b2->borrowernumber );
is( $review3->{approved}, 0, 'review3 is not approved' );

$status  = 0;
$reviews = getallreviews($status);

$count = numberofreviews($status);
is( $count, 3, '3 reviews are not approved' );

$status = 1;
$count  = numberofreviews($status);
is( $count, 0, 'No review are approved' );

# ---------- Testing numberofreviewsbybiblionumber --------
approvereview( $review1->{reviewid} );
approvereview( $review2->{reviewid} );
approvereview( $review3->{reviewid} );

$biblionumber = $biblionumber1;
$count        = numberofreviewsbybiblionumber($biblionumber);
is( $count, 2, 'There are 2 reviews for biblionumber1 and approved = 1' );

$biblionumber = $biblionumber2;
$count        = numberofreviewsbybiblionumber($biblionumber);
is( $count, 0, 'There is no review for biblionumber2 and  approved = 1' );

$biblionumber = $biblionumber3;
$count        = numberofreviewsbybiblionumber($biblionumber);
is( $count, 1, 'There 1 review for biblionumber3 and approved = 1' );

unapprovereview( $review1->{reviewid} );
unapprovereview( $review3->{reviewid} );

$biblionumber = $biblionumber1;
$count        = numberofreviewsbybiblionumber($biblionumber);
is( $count, 1, 'There is 1 review for biblionumber1 and approved = 1' );

$biblionumber = $biblionumber2;
$count        = numberofreviewsbybiblionumber($biblionumber);
is( $count, 0, 'There is no review for biblionumber2 and  approved = 1' );

$biblionumber = $biblionumber3;
$count        = numberofreviewsbybiblionumber($biblionumber);
is( $count, 0, 'There is no review for biblionumber3 and approved = 1' );

# ---------- Testing updatereview -------------------------
my $rev1b = 'Review 1 bis';
my $rev2b = 'Review 2 bis';
my $rev3b = 'Review 3 bis';

is( $review1->{review}, $rev1, 'review field is "Review 1"' );
updatereview( $biblionumber1, $b1->borrowernumber, $rev1b );
$review1 = getreview( $biblionumber1, $b1->borrowernumber );
is( $review1->{review}, $rev1b, 'review field is "Review 1 bis"' );

is( $review2->{review}, $rev2, 'review field is "Review 2"' );
updatereview( $biblionumber1, $b2->borrowernumber, $rev2b );
$review2 = getreview( $biblionumber1, $b2->borrowernumber );
is( $review2->{review}, $rev2b, 'review field is "Review 2 bis"' );

is( $review3->{review}, $rev3, 'review field is "Review 3"' );
updatereview( $biblionumber3, $b2->borrowernumber, $rev3b );
$review3 = getreview( $biblionumber3, $b2->borrowernumber );
is( $review3->{review}, $rev3b, 'review field is "Review 3 bis"' );

# ---------- Testing deletereview -------------------------
my $status0 = 0;
my $status1 = 1;

my $numberOfReviews = numberofreviews($status0) + numberofreviews($status1);
is( $numberOfReviews, 3, 'There are 3 reviews in database' );

deletereview( $review1->{reviewid} );
$review1 = getreview( $biblionumber1, $b3->borrowernumber );
ok( !defined($review1), 'Review1 is no longer defined' );

$numberOfReviews = numberofreviews($status0) + numberofreviews($status1);
is( $numberOfReviews, 2, 'There are 2 reviews left in database' );

deletereview( $review2->{reviewid} );
$review2 = getreview( $biblionumber2, $b2->borrowernumber );
ok( !defined($review2), 'Review2 is no longer defined' );

$numberOfReviews = numberofreviews($status0) + numberofreviews($status1);
is( $numberOfReviews, 1, 'There is 1 review left in database' );

deletereview( $review3->{reviewid} );
$review3 = getreview( $biblionumber3, $b2->borrowernumber );
ok( !defined($review3), 'Review3 is no longer defined' );

$numberOfReviews = numberofreviews($status0) + numberofreviews($status1);
is( $numberOfReviews, 0, 'There is no review left in database' );

$schema->storage->txn_rollback;

1;
