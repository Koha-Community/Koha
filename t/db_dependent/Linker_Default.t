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
use Test::More tests => 2;

use MARC::Record;
use MARC::Field;
use MARC::File::XML;
use C4::Heading;
use C4::Linker::FirstMatch;
use Test::MockModule;
use t::lib::Mocks qw( mock_preference );
use t::lib::TestBuilder;

BEGIN {
    use_ok('C4::Linker');
}

# Mock C4::Heading->authorities() so tests will all pass.
# This completely bypasses any search engine calls.
my $authid=0;
my $mock_heading = Test::MockModule->new('C4::Heading');
$mock_heading->mock( authorities => sub { return [ { authid => $authid++ } ]; } );

my $builder = t::lib::TestBuilder->new();
my $schema  = $builder->schema();
$schema->storage->txn_begin;

subtest 'Test caching in get_link and update_cache' => sub {
    plan tests => 6;

    my @tags = C4::Context->preference('marcflavour') eq 'UNIMARC' ? (601,'j',602,'a') : (650,'a',655,'a');

    my $subject_field = MARC::Field->new($tags[0],0,2,$tags[1]=>'Science fiction');
    my $subject_field2 = MARC::Field->new($tags[0],0,2,$tags[1]=>'Science fiction');
    my $genre_field = MARC::Field->new($tags[2],0,2,$tags[3]=>'Science fiction');
    # Can we build a heading from it?
    my $subject_heading = C4::Heading->new_from_bib_field( $subject_field, q{} );
    my $subject_heading2 = C4::Heading->new_from_bib_field( $subject_field, q{} );
    my $genre_heading = C4::Heading->new_from_bib_field( $genre_field, q{} );


    # Now test to see if C4::Linker can find it.
    my $linker = C4::Linker::Default->new();

    $linker->get_link($subject_heading);
    is( keys %{$linker->{cache}},1, "First term added to cache");

    $linker->get_link($genre_heading);
    is( keys %{$linker->{cache}},2, "Second (matching) term added to cache because of different type");

    $linker->get_link($subject_heading2);
    is( keys %{$linker->{cache}},2, "Third (matching) term not added to cache because of matching type");


    $linker->update_cache($subject_heading,32);
    is( $linker->{cache}->{$subject_heading->search_form.$subject_heading->auth_type}->{authid}, 32, "Linker cache is correctly updated by 'update_cache'");
    my ( $authid, undef ) = $linker->get_link($subject_heading);
    is( $authid, 32, "Correct id is retrieved from the cache" );
    ( $authid, undef ) = $linker->get_link($genre_heading);
    isnt( $authid, 32, "Genre term is not updated by update_cache");
};

$schema->storage->txn_rollback;
