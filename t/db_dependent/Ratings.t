#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 12;
use C4::Members;

BEGIN {

    use FindBin;
    use C4::Ratings;
    use_ok('C4::Ratings');

    DelRating( 1, 901 );
    DelRating( 1, 902 );

    my $rating5 = GetRating( 1, undef );
    ok( defined $rating5, 'get a rating, without borrowernumber' );

    my $borrower102 = GetMember( borrowernumber => 102);
    my $borrower103 = GetMember( borrowernumber => 103);
    SKIP: {
        skip 'Missing test borrowers, skipping specific tests', 10 unless ( defined $borrower102 && defined $borrower103 );
        my $rating1 = AddRating( 1, 102, 3 );
        my $rating2 = AddRating( 1, 103, 4 );
        my $rating3 = ModRating( 1, 102, 5 );
        my $rating4 = GetRating( 1, 103 );
        my $rating6 = DelRating( 1, 102 );
        my $rating7 = DelRating( 1, 103 );

        ok( defined $rating1, 'add a rating' );
        ok( defined $rating2, 'add another rating' );
        ok( defined $rating3, 'update a rating' );
        ok( defined $rating4, 'get a rating, with borrowernumber' );
        ok( defined $rating6,                'delete a rating' );
        ok( defined $rating7,                'delete another rating' );

        ok( $rating3->{'rating_avg'} == '4', "get a bib's average(float) rating" );
        ok( $rating3->{'rating_avg_int'} == 4.5, "get a bib's average(int) rating" );
        ok( $rating3->{'rating_total'} == 2, "get a bib's total number of ratings" );
        ok( $rating3->{'rating_value'} == 5, "verify user's bib rating" );
    }

}

=c

mason@xen1:~/g/head$ perl t/db_dependent/Ratings.t
1..12
ok 1 - use C4::Ratings;
ok 2 - add a rating
ok 3 - add another rating
ok 4 - update a rating
ok 5 - get a rating, with borrowernumber
ok 6 - get a rating, without borrowernumber
ok 7 - get a bib's average(float) rating
ok 8 - get a bib's average(int) rating
ok 9 - get a bib's total number of ratings
ok 10 - verify user's bib rating
ok 11 - delete a rating
ok 12 - delete another rating

=cut
