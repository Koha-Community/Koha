#!/usr/bin/perl

# This file is part of Koha
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

use Test::NoWarnings;
use Test::More tests => 6;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::Caches;
use Koha::MarcSubfieldStructures;

BEGIN {
    use_ok( 'C4::Heading', qw( new_from_field ) );
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'marcflavour',                 'MARC21' );
t::lib::Mocks::mock_preference( 'LinkerUseFrameworkAuthTypes', 0 );

subtest 'Display and search forms' => sub {
    plan tests => 3;

    my $field   = MARC::Field->new( '650', ' ', '2', a => 'Uncles', x => 'Fiction' );
    my $heading = C4::Heading->new_from_field($field);
    is( $heading->display_form(), 'Uncles--Fiction',              'Display form generation' );
    is( $heading->search_form(),  'Uncles generalsubdiv Fiction', 'Search form generation' );
    is( $heading->{thesaurus},    'mesh',                         'Thesaurus generation' );
};

subtest 'Uniform titles' => sub {
    plan tests => 3;

    my $field   = MARC::Field->new( '830', ' ', '4', a => 'The dark is rising ;', v => '3' );
    my $heading = C4::Heading->new_from_field($field);
    is( $heading->display_form(), 'The dark is rising ;', 'Display form generation' );
    is( $heading->search_form(),  'The dark is rising',   'Search form generation' );
    ok( !defined $heading->{thesaurus}, 'Thesaurus is not generated outside of 6XX fields' );
};

subtest 'Personal names' => sub {
    plan tests => 3;

    my $field   = MARC::Field->new( '100', '1', '', a => 'Yankovic, Al', d => '1959-' );
    my $heading = C4::Heading->new_from_field($field);
    is( $heading->display_form(), 'Yankovic, Al 1959-', 'Display form generation' );
    is( $heading->search_form(),  'Yankovic, Al 1959',  'Search form generation' );
    ok( !defined $heading->{thesaurus}, 'Thesaurus is not generated outside of 6XX fields' );
};

subtest 'LinkerUseFrameworkAuthTypes' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    # Test 1: Preference disabled uses hardcoded
    t::lib::Mocks::mock_preference( 'LinkerUseFrameworkAuthTypes', 0 );
    my $field   = MARC::Field->new( '650', ' ', '0', a => 'Test' );
    my $heading = C4::Heading->new_from_field($field);
    is( $heading->auth_type(), 'TOPIC_TERM', 'Uses hardcoded TOPIC_TERM when preference disabled' );

    # Test 2: Preference enabled with framework override
    t::lib::Mocks::mock_preference( 'LinkerUseFrameworkAuthTypes', 1 );

    my $custom_auth_type = $builder->build_object(
        {
            class => 'Koha::Authority::Types',
            value => { auth_tag_to_report => '150' }
        }
    );

    # Delete any existing 650$a in default framework to avoid unique constraint violation
    Koha::MarcSubfieldStructures->search(
        {
            frameworkcode => '',
            tagfield      => '650',
            tagsubfield   => 'a',
        }
    )->delete;

    # Create marc_subfield_structure entry linking 650$a to our custom auth type
    my $mss = $builder->build_object(
        {
            class => 'Koha::MarcSubfieldStructures',
            value => {
                frameworkcode => '',
                tagfield      => '650',
                tagsubfield   => 'a',
                authtypecode  => $custom_auth_type->authtypecode,
            }
        }
    );

    no warnings 'once';
    %C4::Heading::authority_type_cache = ();
    Koha::Caches->get_instance->flush_all;

    $field   = MARC::Field->new( '650', ' ', '0', a => 'Test' );
    $heading = C4::Heading->new_from_field($field);
    is( $heading->auth_type(), $custom_auth_type->authtypecode, 'Uses framework override when preference enabled' );

    # Test 3: Falls back to hardcoded for unconfigured tags
    $field   = MARC::Field->new( '600', ' ', '0', a => 'Person' );
    $heading = C4::Heading->new_from_field($field);
    is( $heading->auth_type(), 'PERSO_NAME', 'Falls back to hardcoded for unconfigured tags' );

    $schema->storage->txn_rollback;
};
