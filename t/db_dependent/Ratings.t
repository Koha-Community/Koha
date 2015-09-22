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

use Test::More tests => 14;

use C4::Biblio qw/AddBiblio/;
use C4::Members;
use C4::Context;
use C4::Category;
use Koha::Database;

use t::lib::TestBuilder;

use_ok('C4::Ratings');

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

my $library = $builder->build({
    source => 'Branch',
});

my ($biblionumber) = AddBiblio( MARC::Record->new, '' );

my @categories   = C4::Category->all;
my $categorycode = $categories[0]->categorycode;
my $branchcode   = $library->{branchcode};

my %john_doe = (
    cardnumber   => '123456',
    firstname    => 'John',
    surname      => 'Doe',
    categorycode => $categorycode,
    branchcode   => $branchcode,
    dateofbirth  => '',
    dateexpiry   => '9999-12-31',
    userid       => 'john.doe'
);

my %jane_doe = (
    cardnumber   => '345678',
    firstname    => 'Jane',
    surname      => 'Doe',
    categorycode => $categorycode,
    branchcode   => $branchcode,
    dateofbirth  => '',
    dateexpiry   => '9999-12-31',
    userid       => 'jane.doe'
);

my $borrowernumber1 = AddMember(%john_doe);
my $borrowernumber2 = AddMember(%jane_doe);

my $rating1 = AddRating( $biblionumber, $borrowernumber1, 3 );
my $rating2 = AddRating( $biblionumber, $borrowernumber2, 4 );
my $rating3 = ModRating( $biblionumber, $borrowernumber1, 5 );
my $rating4 = GetRating( $biblionumber, $borrowernumber2 );
my $rating5 = GetRating( $biblionumber );

ok( defined $rating1, 'add a rating' );
ok( defined $rating2, 'add another rating' );
ok( defined $rating3, 'update a rating' );
ok( defined $rating4, 'get a rating, with borrowernumber' );

ok( $rating3->{'rating_avg'} == '4',     "get a bib's average(float) rating" );
ok( $rating3->{'rating_avg_int'} == 4.5, "get a bib's average(int) rating" );
ok( $rating3->{'rating_total'} == 2, "get a bib's total number of ratings" );
ok( $rating3->{'rating_value'} == 5, "verify user's bib rating" );

my $rating_1   = GetRating( $biblionumber );
my $rating_1_1 = GetRating( $biblionumber, $borrowernumber1 );
is_deeply(
    $rating_1,
    {
        rating_avg_int => 4.5,
        rating_total   => 2,
        rating_avg     => 4,
        rating_value   => undef,
    },
    'GetRating should return total, avg_int and avg if  biblionumber is given'
);
is_deeply(
    $rating_1_1,
    {
        rating_avg_int => 4.5,
        rating_total   => 2,
        rating_avg     => 4,
        rating_value   => 5,
    },
'GetRating should return total, avg_int, avg and value if biblionumber is given'
);

my $rating6 = DelRating( $biblionumber, $borrowernumber1 );
my $rating7 = DelRating( $biblionumber, $borrowernumber2 );

ok( defined $rating6, 'delete a rating' );
ok( defined $rating7, 'delete another rating' );

is( GetRating( $biblionumber, $borrowernumber1 ),
    undef, 'GetRating should return undef if no rating exist' );

1;
