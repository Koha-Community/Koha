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

use Test::More tests => 3;
use Try::Tiny;

use C4::Circulation qw( AddIssue AddReturn );
use C4::Stats qw( UpdateStats );

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

    t::lib::Mocks::mock_config( 'bcrypt_settings', '' );
    t::lib::Mocks::mock_preference( 'Pseudonymization', 1 );
    t::lib::Mocks::mock_preference( 'PseudonymizationPatronFields', 'branchcode,categorycode,sort1' );

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item    = $builder->build_sample_item;
    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );

    try{
        C4::Stats::UpdateStats(
            {
                type           => 'issue',
                branch         => $library->branchcode,
                itemnumber     => $item->itemnumber,
                borrowernumber => $patron->borrowernumber,
                itemtype       => $item->effective_itemtype,
                location       => $item->location,
                ccode          => $item->ccode,
            }
        );

    } catch {
        ok($_->isa('Koha::Exceptions::Config::MissingEntry'), "Koha::Patron->store should raise a Koha::Exceptions::Config::MissingEntry if 'bcrypt_settings' is not defined in the config");
        is( $_->message, "Missing 'bcrypt_settings' entry in config file");
    };

    $schema->storage->txn_rollback;
};

subtest 'Koha::Anonymized::Transactions tests' => sub {

    plan tests => 12;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_config( 'bcrypt_settings', '$2a$08$9lmorEKnwQloheaCLFIfje' );

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    t::lib::Mocks::mock_preference( 'Pseudonymization', 0 );
    my $item = $builder->build_sample_item;
    t::lib::Mocks::mock_userenv({ branchcode => $item->homebranch });
    AddIssue( $patron, $item->barcode, dt_from_string );
    AddReturn( $item->barcode, $item->homebranch, undef, dt_from_string );
    my $pseudonymized= Koha::PseudonymizedTransactions->search(
        { itemnumber => $item->itemnumber } )->next;
    is( $pseudonymized, undef,
        'No pseudonymized transaction if Pseudonymization is off' );

    t::lib::Mocks::mock_preference( 'Pseudonymization', 1 );
    t::lib::Mocks::mock_preference( 'PseudonymizationTransactionFields', 'datetime,transaction_branchcode,transaction_type,itemnumber,itemtype,holdingbranch,homebranch,location,itemcallnumber,ccode'
    );
    $item = $builder->build_sample_item;
    t::lib::Mocks::mock_userenv({ branchcode => $item->homebranch });
    AddIssue( $patron, $item->barcode, dt_from_string );
    AddReturn( $item->barcode, $item->homebranch, undef, dt_from_string );
    my $statistic = Koha::Statistics->search( { itemnumber => $item->itemnumber } )->next;
    $pseudonymized = Koha::PseudonymizedTransactions->search( { itemnumber => $item->itemnumber } )->next;
    like( $pseudonymized->hashed_borrowernumber,
        qr{^\$2a\$08\$}, "The hashed_borrowernumber must be a bcrypt hash" );
    is( $pseudonymized->datetime,               $statistic->datetime,      'datetime attribute copied correctly' );
    is( $pseudonymized->transaction_branchcode, $statistic->branch,        'transaction_branchcode copied correctly' );
    is( $pseudonymized->transaction_type,       $statistic->type,          'transacttion_type copied correctly' );
    is( $pseudonymized->itemnumber,             $item->itemnumber,         'itemnumber copied correctly' );
    is( $pseudonymized->itemtype,               $item->effective_itemtype, 'itemtype copied correctly' );
    is( $pseudonymized->holdingbranch,          $item->holdingbranch,      'holdingbranch copied correctly' );
    is( $pseudonymized->homebranch,             $item->homebranch,         'homebranch copied correctly' );
    is( $pseudonymized->location,               $item->location,           'location copied correctly' );
    is( $pseudonymized->itemcallnumber,         $item->itemcallnumber,     'itemcallnumber copied correctly' );
    is( $pseudonymized->ccode,                  $item->ccode,              'ccode copied correctly' );

    $schema->storage->txn_rollback;
};

subtest 'PseudonymizedBorrowerAttributes tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_config( 'bcrypt_settings', '$2a$08$9lmorEKnwQloheaCLFIfje' );
    t::lib::Mocks::mock_preference( 'Pseudonymization', 1 );
    t::lib::Mocks::mock_preference( 'PseudonymizationPatronFields',
        'branchcode,categorycode,sort1' );

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron_info = $patron->unblessed;
    delete $patron_info->{borrowernumber};
    $patron->delete;

    my $attribute_type1 = $builder->build_object(
        {
            class => 'Koha::Patron::Attribute::Types',
            value => {
                repeatable                => 1,
                keep_for_pseudonymization => 1,
            }
        }
    );
    my $attribute_type2 = $builder->build_object(
        {
            class => 'Koha::Patron::Attribute::Types',
            value => {
                keep_for_pseudonymization => 0,
            }
        }
    );
    my $attribute_type3 = $builder->build_object(
        {
            class => 'Koha::Patron::Attribute::Types',
            value => {
                keep_for_pseudonymization => 1,
            }
        }
    );

    $patron = Koha::Patron->new($patron_info)->store->get_from_storage;
    my $attribute_values = [
        {
            attribute => 'attribute for code1',
            code      => $attribute_type1->code,
        },
        {
            attribute => 'attribute for code2',
            code      => $attribute_type2->code
        },
        {
            attribute => 'attribute for code3',
            code      => $attribute_type3->code
        },
    ];

    $patron->extended_attributes($attribute_values);


    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item    = $builder->build_sample_item;

    C4::Stats::UpdateStats(
        {
            type           => 'issue',
            branch         => $library->branchcode,
            itemnumber     => $item->itemnumber,
            borrowernumber => $patron->borrowernumber,
            itemtype       => $item->effective_itemtype,
            location       => $item->location,
            ccode          => $item->ccode,
        }
    );

    my $p = Koha::PseudonymizedTransactions->search({itemnumber => $item->itemnumber})->next;
    my $attributes =
      Koha::Database->new->schema->resultset('PseudonymizedBorrowerAttribute')
      ->search( { transaction_id => $p->id }, { order_by => 'attribute' } );
    is( $attributes->count, 2,
        'Only the 2 attributes that have a type with keep_for_pseudonymization set should be kept'
    );
    my $attribute_1 = $attributes->next;
    is_deeply(
        { attribute => $attribute_1->attribute, code => $attribute_1->code->code },
        $attribute_values->[0],
        'Attribute 1 should be retrieved correctly'
    );
    my $attribute_2 = $attributes->next;
    is_deeply(
        { attribute => $attribute_2->attribute, code => $attribute_2->code->code },
        $attribute_values->[2],
        'Attribute 2 should be retrieved correctly'
    );

    $schema->storage->txn_rollback;
};
