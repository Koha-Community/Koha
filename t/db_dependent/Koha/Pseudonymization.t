#!/usr/bin/perl

# Copyright 2019 Koha Development team
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

use Test::More tests => 2;
use Try::Tiny;

use C4::Circulation;
use C4::Stats;

use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Patrons;
use Koha::PseudonymizedTransactions;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'Config does not exist' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_config( 'key', '' );
    t::lib::Mocks::mock_preference( 'Pseudonymization', 1 );
    t::lib::Mocks::mock_preference( 'PseudonymizationPatronFields', 'branchcode,categorycode,sort1' );

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item    = $builder->build_sample_item;
    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );

    try{
        C4::Stats::UpdateStats(
            {
                type           => 'issue',
                branch         => 'BBB',
                itemnumber     => $item->itemnumber,
                borrowernumber => $patron->borrowernumber,
                itemtype       => $item->effective_itemtype,
                location       => $item->location,
            }
        );

    } catch {
        ok($_->isa('Koha::Exceptions::Config::MissingEntry'), "Koha::Patron->store should raise a Koha::Exceptions::Config::MissingEntry if 'key' is not defined in the config");
        is( $_->message, "Missing 'key' entry in config file");
    };

    $schema->storage->txn_rollback;
};

subtest 'Koha::Anonymized::Transactions tests' => sub {

    plan tests => 11;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_config( 'key', '$2a$08$9lmorEKnwQloheaCLFIfje' );

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    t::lib::Mocks::mock_preference( 'Pseudonymization', 0 );
    my $item = $builder->build_sample_item;
    t::lib::Mocks::mock_userenv({ branchcode => $item->homebranch });
    AddIssue( $patron->unblessed, $item->barcode, dt_from_string );
    AddReturn( $item->barcode, $item->homebranch, undef, dt_from_string );
    my $pseudonymized= Koha::PseudonymizedTransactions->search(
        { itemnumber => $item->itemnumber } )->next;
    is( $pseudonymized, undef,
        'No pseudonymized transaction if Pseudonymization is off' );

    t::lib::Mocks::mock_preference( 'Pseudonymization', 1 );
    t::lib::Mocks::mock_preference( 'PseudonymizationTransactionFields', 'datetime,transaction_branchcode,transaction_type,itemnumber,itemtype,holdingbranch,location,itemcallnumber,ccode'
    );
    $item = $builder->build_sample_item;
    t::lib::Mocks::mock_userenv({ branchcode => $item->homebranch });
    AddIssue( $patron->unblessed, $item->barcode, dt_from_string );
    AddReturn( $item->barcode, $item->homebranch, undef, dt_from_string );
    my $statistic = Koha::Statistics->search( { itemnumber => $item->itemnumber } )->next;
    $pseudonymized = Koha::PseudonymizedTransactions->search( { itemnumber => $item->itemnumber } )->next;
    like( $pseudonymized->hashed_borrowernumber,
        qr{^\$2a\$08\$}, "The hashed_borrowernumber must be a bcrypt hash" );
    is( $pseudonymized->datetime,               $statistic->datetime );
    is( $pseudonymized->transaction_branchcode, $statistic->branch );
    is( $pseudonymized->transaction_type,       $statistic->type );
    is( $pseudonymized->itemnumber,             $item->itemnumber );
    is( $pseudonymized->itemtype,               $item->effective_itemtype );
    is( $pseudonymized->holdingbranch,          $item->holdingbranch );
    is( $pseudonymized->location,               $item->location );
    is( $pseudonymized->itemcallnumber,         $item->itemcallnumber );
    is( $pseudonymized->ccode,                  $item->ccode );

    $schema->storage->txn_rollback;
};
