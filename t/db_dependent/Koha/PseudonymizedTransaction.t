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

use Test::NoWarnings;
use Test::More tests => 3;

use Test::Exception;

use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Patrons;
use Koha::PseudonymizedTransactions;

use Crypt::Eksblowfish::Bcrypt qw( bcrypt );

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $bcrypt_settings = '$2a$10$f.3Kc8Ofrvad4nI2muehEOACmgw6MgwJLxfhyFYmCwRlAHOYQrhCu';

subtest 'get_hash() tests' => sub {

    plan tests => 2;

    t::lib::Mocks::mock_config( 'bcrypt_settings', '' );

    my $string = "foo";

    throws_ok { Koha::PseudonymizedTransaction->get_hash($string) }
    'Koha::Exceptions::Config::MissingEntry';

    t::lib::Mocks::mock_config( 'bcrypt_settings', $bcrypt_settings );
    is(
        Koha::PseudonymizedTransaction->get_hash($string), bcrypt( $string, $bcrypt_settings ),
        "get_hash() returns the output of the bcrypt method using the bcrypt_settings' config entry"
    );
};

subtest 'create_from_statistic() tests' => sub {

    plan tests => 15;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_config( 'bcrypt_settings', $bcrypt_settings );

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item    = $builder->build_sample_item;

    my @fields = qw(
        ccode
        datetime
        holdingbranch
        homebranch
        itemcallnumber
        itemnumber
        itemtype
        location
        transaction_branchcode
        transaction_type
    );

    t::lib::Mocks::mock_preference(
        'PseudonymizationTransactionFields',
        join( ',', @fields )
    );

    my $statistic = $builder->build_object(
        {
            class => 'Koha::Statistics',
            value => {
                borrowernumber => $patron->id,
                branch         => $library->id,
                ccode          => $item->ccode,
                itemnumber     => $item->id,
                itemtype       => $item->itype,
                location       => $item->location,
            }
        }
    );

    my $pseudonymized = Koha::PseudonymizedTransaction->create_from_statistic($statistic);

    is(
        $pseudonymized->hashed_borrowernumber,
        Koha::PseudonymizedTransaction->get_hash( $patron->id ), "The hashed_borrowernumber must be a bcrypt hash"
    );
    is( $pseudonymized->datetime,               $statistic->datetime,  'datetime attribute copied correctly' );
    is( $pseudonymized->transaction_branchcode, $statistic->branch,    'transaction_branchcode copied correctly' );
    is( $pseudonymized->transaction_type,       $statistic->type,      'transacttion_type copied correctly' );
    is( $pseudonymized->itemnumber,             $item->itemnumber,     'itemnumber copied correctly' );
    is( $pseudonymized->itemtype,               $item->itype,          'itype copied correctly' );
    is( $pseudonymized->holdingbranch,          $item->holdingbranch,  'holdingbranch copied correctly' );
    is( $pseudonymized->homebranch,             $item->homebranch,     'homebranch copied correctly' );
    is( $pseudonymized->location,               $item->location,       'location copied correctly' );
    is( $pseudonymized->itemcallnumber,         $item->itemcallnumber, 'itemcallnumber copied correctly' );
    is( $pseudonymized->ccode,                  $item->ccode,          'ccode copied correctly' );
    is( $pseudonymized->branchcode,             $patron->branchcode,   'branchcode set correctly' );
    is( $pseudonymized->categorycode,           $patron->categorycode, 'categorycode set correctly' );
    ok( $pseudonymized->has_cardnumber, 'has_cardnumber set correctly' );

    $patron->cardnumber(undef)->store;

    ok(
        !Koha::PseudonymizedTransaction->create_from_statistic($statistic)->has_cardnumber,
        'has_cardnumber set to false'
    );

    $schema->storage->txn_rollback;
};
