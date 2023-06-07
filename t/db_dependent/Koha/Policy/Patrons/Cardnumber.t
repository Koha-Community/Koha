#!/usr/bin/perl

# Copyright 2023 Koha Development team
#
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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 3;

use Koha::Database;
use Koha::Policy::Patrons::Cardnumber;
use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'is_valid' => sub {

    plan tests => 21;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    t::lib::Mocks::mock_preference( 'CardnumberLength', '' );

    my $policy = Koha::Policy::Patrons::Cardnumber->new;

    my $is_valid = $policy->is_valid( $patron->cardnumber );
    ok( !$is_valid, "Cardnumber in use, cannot be reused" );

    $is_valid = $policy->is_valid( $patron->cardnumber, $patron );
    ok( $is_valid, "Cardnumber in use but can be used by the same patron" );

    my $tmp_patron           = $builder->build_object( { class => 'Koha::Patrons' } );
    my $available_cardnumber = $tmp_patron->cardnumber;
    $tmp_patron->delete;
    $is_valid = $policy->is_valid($available_cardnumber);
    ok( $is_valid, "Cardnumber not in use" );

    t::lib::Mocks::mock_preference( 'CardnumberLength', '4' );

    $is_valid = $policy->is_valid("12345");
    ok( !$is_valid, "Invalid cardnumber length" );

    $is_valid = $policy->is_valid("123");
    ok( !$is_valid, "Invalid cardnumber length" );

    my $pref = "10";
    t::lib::Mocks::mock_preference( 'CardnumberLength', $pref );
    ok( !$policy->is_valid(q{123456789}),        "123456789 is shorter than $pref" );
    ok( !$policy->is_valid(q{1234567890123456}), "1234567890123456 is longer than $pref" );
    ok( $policy->is_valid(q{1234567890}),        "1234567890 is equal to $pref" );

    $pref = q|10,10|;    # Same as before !
    t::lib::Mocks::mock_preference( 'CardnumberLength', $pref );
    ok( !$policy->is_valid(q{123456789}),        "123456789 is shorter than $pref" );
    ok( !$policy->is_valid(q{1234567890123456}), "1234567890123456 is longer than $pref" );
    ok( $policy->is_valid(q{1234567890}),        "1234567890 is equal to $pref" );

    $pref = q|8,10|;     # between 8 and 10 chars
    t::lib::Mocks::mock_preference( 'CardnumberLength', $pref );
    ok( $policy->is_valid(q{12345678}),          "12345678 matches $pref" );
    ok( !$policy->is_valid(q{1234567890123456}), "1234567890123456 is longer than $pref" );
    ok( !$policy->is_valid(q{1234567}),          "1234567 is shorter than $pref" );
    ok( $policy->is_valid(q{1234567890}),        "1234567890 matches $pref" );

    $pref = q|8,|;       # At least 8 chars
    t::lib::Mocks::mock_preference( 'CardnumberLength', $pref );
    ok( !$policy->is_valid(q{1234567}),         "1234567 is shorter than $pref" );
    ok( $policy->is_valid(q{1234567890123456}), "1234567890123456 matches $pref" );
    ok( $policy->is_valid(q{1234567890}),       "1234567890 matches $pref" );

    $pref = q|,8|;       # max 8 chars
    t::lib::Mocks::mock_preference( 'CardnumberLength', $pref );
    ok( $policy->is_valid(q{1234567}),           "1234567 matches $pref" );
    ok( !$policy->is_valid(q{1234567890123456}), "1234567890123456 is longer than $pref" );
    ok( !$policy->is_valid(q{1234567890}),       "1234567890 is longer than $pref" );

    $schema->storage->txn_rollback;
};

subtest 'get_valid_length' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $policy = Koha::Policy::Patrons::Cardnumber->new;

    t::lib::Mocks::mock_preference( 'BorrowerMandatoryField', '' );

    my $pref = "10";
    t::lib::Mocks::mock_preference( 'CardnumberLength', $pref );
    is_deeply( [ $policy->get_valid_length() ], [ 10, 10 ], '10 => min=10 and max=10' );

    $pref = q|10,10|;    # Same as before !
    t::lib::Mocks::mock_preference( 'CardnumberLength', $pref );
    is_deeply( [ $policy->get_valid_length() ], [ 10, 10 ], '10,10 => min=10 and max=10' );

    $pref = q|8,10|;     # between 8 and 10 chars
    t::lib::Mocks::mock_preference( 'CardnumberLength', $pref );
    is_deeply( [ $policy->get_valid_length() ], [ 8, 10 ], '8,10 => min=8 and max=10' );

    $pref = q|,8|;       # max 8 chars
    t::lib::Mocks::mock_preference( 'CardnumberLength', $pref );
    is_deeply( [ $policy->get_valid_length() ], [ 0, 8 ], ',8 => min=0 and max=8' );

    $pref = q|,8|;       # max 8 chars
    t::lib::Mocks::mock_preference( 'CardnumberLength',       $pref );
    t::lib::Mocks::mock_preference( 'BorrowerMandatoryField', 'cardnumber' );
    is_deeply( [ $policy->get_valid_length() ], [ 1, 8 ], ',8 => min=1 and max=8 if cardnumber is mandatory' );

    $schema->storage->txn_rollback;

};

subtest 'compare with DB data size' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $policy          = Koha::Policy::Patrons::Cardnumber->new;
    my $borrower        = Koha::Schema->resultset('Borrower');
    my $cardnumber_size = $borrower->result_source->column_info('cardnumber')->{size};
    t::lib::Mocks::mock_preference( 'BorrowerMandatoryField', '' );

    my $pref = q|8,|;    # At least 8 chars
    t::lib::Mocks::mock_preference( 'CardnumberLength', $pref );
    is_deeply( [ $policy->get_valid_length() ], [ 8, $cardnumber_size ], "8, => min=8 and max=$cardnumber_size" );

    $pref = sprintf( ',%d', $cardnumber_size + 1 );
    t::lib::Mocks::mock_preference( 'CardnumberLength', $pref );
    is_deeply(
        [ $policy->get_valid_length() ], [ 0, $cardnumber_size ],
        sprintf( ",%d => min=0 and max=%d", $cardnumber_size + 1, $cardnumber_size )
    );

    my $generated_cardnumber = sprintf( "%s1234567890", q|9| x $cardnumber_size );
    ok(
        !$policy->is_valid($generated_cardnumber),
        "$generated_cardnumber is longer than $pref => $cardnumber_size is max!"
    );

    $schema->storage->txn_rollback;

};
