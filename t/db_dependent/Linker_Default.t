#!/usr/bin/perl
#
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
use Test::NoWarnings;
use Test::More tests => 3;

use MARC::Record;
use MARC::Field;
use MARC::File::XML;
use C4::Heading qw( authorities field new_from_field auth_type search_form );
use C4::Linker::Default;
use Test::MockModule;
use t::lib::Mocks qw( mock_preference );
use t::lib::TestBuilder;

BEGIN {
    use_ok('C4::Linker');
}

# Mock C4::Heading->authorities() so tests will all pass.
# This completely bypasses any search engine calls.
my $authid       = 0;
my $mock_heading = Test::MockModule->new('C4::Heading');
$mock_heading->mock( authorities => sub { return [ { authid => $authid++ } ]; } );

my $builder = t::lib::TestBuilder->new();
my $schema  = $builder->schema();
$schema->storage->txn_begin;

subtest 'Test caching in get_link and update_cache' => sub {
    plan tests => 18;

    my @tags = C4::Context->preference('marcflavour') eq 'UNIMARC' ? ( 601, 'j', 602, 'a' ) : ( 650, 'a', 655, 'a' );

    my $subject_field  = MARC::Field->new( $tags[0], 0, 2, $tags[1] => 'Science fiction' );
    my $subject_field2 = MARC::Field->new( $tags[0], 0, 2, $tags[1] => 'Science fiction' );
    my $subject_field3 = MARC::Field->new( $tags[0], 0, 0, $tags[1] => 'Science fiction' );
    my $subject_field4 = MARC::Field->new( $tags[0], 0, 7, $tags[1] => 'Science fiction', '2' => 'bnb' );
    my $subject_field5 = MARC::Field->new( $tags[0], 0, 7, $tags[1] => 'Science fiction', '2' => 'sao' );
    my $subject_field6 = MARC::Field->new( $tags[0], 0, 7, $tags[1] => 'Science fiction', '2' => 'sao' );
    my $subject_field7 = MARC::Field->new( $tags[0], 0, 4, $tags[1] => 'Science fiction' );
    my $subject_field8 = MARC::Field->new( $tags[0], 0, 7, $tags[1] => 'Science fiction', '2' => 'oth' );
    my $subject_field9 = MARC::Field->new( $tags[0], 0, 3, $tags[1] => 'Science fiction' );
    my $genre_field    = MARC::Field->new( $tags[2], 0, 2, $tags[3] => 'Science fiction' );

    # Can we build a heading from it?
    my $subject_heading  = C4::Heading->new_from_field( $subject_field,  q{} );
    my $subject_heading2 = C4::Heading->new_from_field( $subject_field2, q{} );
    my $subject_heading3 = C4::Heading->new_from_field( $subject_field3, q{} );
    my $subject_heading4 = C4::Heading->new_from_field( $subject_field4, q{} );
    my $subject_heading5 = C4::Heading->new_from_field( $subject_field5, q{} );
    my $subject_heading6 = C4::Heading->new_from_field( $subject_field6, q{} );
    my $subject_heading7 = C4::Heading->new_from_field( $subject_field7, q{} );
    my $subject_heading8 = C4::Heading->new_from_field( $subject_field8, q{} );
    my $subject_heading9 = C4::Heading->new_from_field( $subject_field9, q{} );
    my $genre_heading    = C4::Heading->new_from_field( $genre_field,    q{} );

    t::lib::Mocks::mock_preference( 'LinkerConsiderThesaurus', 1 );

    # Now test to see if C4::Linker can find it.
    my $linker = C4::Linker::Default->new();

    $linker->get_link($subject_heading);
    is( keys %{ $linker->{cache} }, 1, "First term added to cache" );

    $linker->get_link($genre_heading);
    is( keys %{ $linker->{cache} }, 2, "Second (matching) term added to cache because of different type" );

    $linker->get_link($subject_heading2);
    is( keys %{ $linker->{cache} }, 2, "Third (matching) term not added to cache because of matching type" );

    $linker->get_link($subject_heading3);
    is( keys %{ $linker->{cache} }, 3, "Fourth (matching) term added to cache because of different thesaurus (lcsh)" );

    $linker->get_link($subject_heading4);
    is( keys %{ $linker->{cache} }, 4, "Fifth (matching) term added to cache because of different thesaurus (bnb)" );

    $linker->get_link($subject_heading5);
    is( keys %{ $linker->{cache} }, 5, "Sixth (matching) term added to cache because of different thesaurus (sao)" );

    $linker->get_link($subject_heading6);
    is(
        keys %{ $linker->{cache} }, 5,
        "Seventh (matching) term not added to cache because of matching type and thesaurus (sao)"
    );

    $linker->get_link($subject_heading7);
    is(
        keys %{ $linker->{cache} }, 6,
        "Eighth (matching) term added to cache because of thesaurus source not specified (2nd indicator is 4)"
    );

    t::lib::Mocks::mock_preference( 'LinkerConsiderThesaurus', 0 );

    $linker->get_link($subject_heading);
    is(
        keys %{ $linker->{cache} }, 7,
        "First term added to cache because cache key now has 'notconsidered' for thesaurus"
    );

    $linker->get_link($subject_heading8);
    is(
        keys %{ $linker->{cache} }, 7,
        "Ninth (matching) term not added to cache because thesaurus differs but is not considered"
    );

    $linker->get_link($subject_heading9);
    is(
        keys %{ $linker->{cache} }, 7,
        "Tenth (matching) term not added to cache because thesaurus differs but is not considered"
    );

    t::lib::Mocks::mock_preference( 'LinkerConsiderThesaurus', 1 );

    $linker->update_cache( $subject_heading, 32 );
    is( $linker->{cache}
            ->{ $subject_heading->search_form . $subject_heading->auth_type . $subject_heading->{'thesaurus'} }
            ->{authid}, 32, "Linker cache is correctly updated by 'update_cache'" );
    my ( $authid, undef ) = $linker->get_link($subject_heading);
    is( $authid, 32, "Correct id is retrieved from the cache" );
    ( $authid, undef ) = $linker->get_link($genre_heading);
    isnt( $authid, 32, "Genre term is not updated by update_cache" );
    ( $authid, undef ) = $linker->get_link($subject_heading5);
    is( $authid, 4, "Correct id for sao term is retrieved from the cache" );
    $linker->update_cache( $subject_heading4, 78 );
    is( $linker->{cache}
            ->{ $subject_heading4->search_form . $subject_heading4->auth_type . $subject_heading4->{'thesaurus'} }
            ->{authid}, 78, "Linker cache for the bnb record is correctly updated by 'update_cache'" );

    t::lib::Mocks::mock_preference( 'LinkerConsiderThesaurus', 0 );
    $linker->update_cache( $subject_heading, 32 );
    is(
        $linker->{cache}->{ $subject_heading->search_form . $subject_heading->auth_type . 'notconsidered' }->{authid},
        32, "Linker cache is correctly updated by 'update_cache'"
    );
    ( $authid, undef ) = $linker->get_link($subject_heading);
    is( $authid, 32, "Correct id is retrieved from the cache" );

};

$schema->storage->txn_rollback;
