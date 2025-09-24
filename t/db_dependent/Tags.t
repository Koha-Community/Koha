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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use utf8;

use Test::NoWarnings;
use Test::More tests => 35;

use t::lib::TestBuilder;

use List::MoreUtils qw(any);

use Koha::Database;
use Koha::Tags;
use Koha::Tags::Approvals;
use Koha::Tags::Indexes;

use C4::Tags qw( add_tag_approval add_tag add_tag_index get_tag_rows stratify_tags );

# So any output is readable :-D
binmode STDOUT, ':encoding(utf8)';

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'add_tag_approval() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    # Make sure there's no pollution on the DB
    Koha::Tags::Approvals->search->delete;

    my $terms = {

        # term => count
        '🐋a' => 3,    # added an ASCII char to make it differ from just emojis
        '🌮'  => 2,
        '👍'  => 1,
    };

    for my $term ( keys %{$terms} ) {
        for ( my $i = 1 ; $i <= $terms->{$term} ; $i++ ) {
            C4::Tags::add_tag_approval($term);
        }
    }

    my $approvals = Koha::Tags::Approvals->search;
    is( $approvals->count, scalar keys %{$terms}, 'All terms got their approval row' );

    while ( my $approval = $approvals->next ) {
        ok( exists $terms->{ $approval->term }, 'The returned term is in our list' );
        is( $approval->weight_total, $terms->{ $approval->term } );
    }

    $schema->storage->txn_rollback;
};

subtest 'add_tag_index() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    # Make sure there's no pollution on the DB
    Koha::Tags::Indexes->search->delete;

    my $biblio = $builder->build_object( { class => 'Koha::Biblios' } );

    my $terms = {

        # term => count
        '🐋a' => 3,    # added an ASCII char to make it differ from just emojis
        '🌮'  => 2,
        '👍'  => 1,
    };

    while ( my ( $term, $count ) = each %$terms ) {
        for ( 1 .. $count ) {
            C4::Tags::add_tag_approval($term);
            C4::Tags::add_tag_index( $term, $biblio->biblionumber );
        }
    }

    my $indexes = Koha::Tags::Indexes->search( { biblionumber => $biblio->biblionumber } );
    is( $indexes->count, scalar keys %{$terms}, 'All terms got their index row' );

    while ( my $index = $indexes->next ) {
        ok( exists $terms->{ $index->term }, 'The returned term is in our list' );
        is( $index->weight, $terms->{ $index->term } );
    }

    $schema->storage->txn_rollback;
};

subtest 'get_tag_rows() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    # Make sure there's no pollution on the DB
    Koha::Tags->search->delete;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    my $biblio = $builder->build_object( { class => 'Koha::Biblios' } );

    my @terms = ( '🐋a', '🌮', '👍' );

    for my $term (@terms) {
        $builder->build_object(
            {
                class => 'Koha::Tags',
                value => {
                    borrowernumber => $patron->id,
                    biblionumber   => $biblio->id,
                    term           => $term,
                }
            }
        );
    }

    my $tags = Koha::Tags->search( { borrowernumber => $patron->id } );
    is( $tags->count, scalar @terms, 'All terms got their row' );

    while ( my $tag = $tags->next ) {
        ok( any { $_ eq $tag->term } @terms, 'The returned term is in our list' );
    }

    for my $term (@terms) {
        my @result = @{ C4::Tags::get_tag_rows( { term => $term } ) };

        is( scalar @result, 1, 'Only one row matches each' );
    }

    $schema->storage->txn_rollback;
};

# Check no tags case.
my @tagsarray;
my $tags = \@tagsarray;
my ( $min, $max ) = C4::Tags::stratify_tags( 0, $tags );
is( $min, 0, 'Empty array min' );
is( $max, 0, 'Empty array max' );

# Simple 'sequential 5' test
$tags = make_tags( 1, 2, 3, 4, 5 );
my @strata = ( 0, 1, 2, 3, 4 );
( $min, $max ) = C4::Tags::stratify_tags( 5, $tags );
check_tag_strata( $tags, \@strata, 'Sequential 5' );
is( $min, 0, 'Sequential 5 min' );
is( $max, 4, 'Sequential 5 max' );

# Reverse test - should have the same results as previous
$tags   = make_tags( 5, 4, 3, 2, 1 );
@strata = ( 4, 3, 2, 1, 0 );
( $min, $max ) = C4::Tags::stratify_tags( 5, $tags );
check_tag_strata( $tags, \@strata, 'Reverse Sequential 5' );
is( $min, 0, 'Sequential 5 min' );
is( $max, 4, 'Sequential 5 max' );

# All the same test - should all have the same results
$tags   = make_tags( 4, 4, 4, 4, 4 );
@strata = ( 0, 0, 0, 0, 0 );
( $min, $max ) = C4::Tags::stratify_tags( 5, $tags );
check_tag_strata( $tags, \@strata, 'All The Same' );
is( $min, 0, 'Sequential 5 min' );
is( $max, 0, 'Sequential 5 max' );

# Some the same, some different
$tags   = make_tags( 1, 2, 2, 3, 3, 8 );
@strata = ( 0, 0, 0, 1, 1, 4 );
( $min, $max ) = C4::Tags::stratify_tags( 5, $tags );
check_tag_strata( $tags, \@strata, 'All The Same' );
is( $min, 0, 'Sequential 5 min' );
is( $max, 7, 'Sequential 5 max' );

# Runs tests against the results
sub check_tag_strata {
    my ( $tags, $expected, $name ) = @_;

    foreach my $t (@$tags) {
        my $w = $t->{weight_total};
        my $s = $t->{stratum};
        is( $s, shift @$expected, $name . " - $w ($s)" );
    }
}

# Makes some tags with just enough info to test
sub make_tags {
    my @res;
    while (@_) {
        push @res, { weight_total => shift @_ };
    }
    return \@res;
}
