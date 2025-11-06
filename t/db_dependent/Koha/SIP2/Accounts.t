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
use Test::More tests => 9;

use Koha::SIP2::Accounts;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'institution' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $account = $builder->build_object( { class => 'Koha::SIP2::Accounts' } );
    is( ref( $account->institution ), 'Koha::SIP2::Institution' );

    is( $account, $account, "account is fine before institution is deleted" );
    $account->institution->delete;
    is( $account->get_from_storage, undef, "account is gone when institution is deleted" );

    $schema->storage->txn_rollback;
};

subtest 'custom_item_fields' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $account = $builder->build_object( { class => 'Koha::SIP2::Accounts' } );
    is( $account->custom_item_fields->count, 0, "no custom item fields yet" );

    my $custom_item_fields = [
        {
            field    => 'IN',
            template => '[% item.itemnumber %]',
        },
    ];
    $account->custom_item_fields($custom_item_fields);

    my $retrieved_custom_item_fields = $account->custom_item_fields;
    is( ref($retrieved_custom_item_fields), 'Koha::SIP2::Account::CustomItemFields' );
    $retrieved_custom_item_fields =
        [ map { delete $_->{sip_account_custom_item_field_id}; delete $_->{sip_account_id}; $_ }
            @{ $retrieved_custom_item_fields->unblessed } ];
    is_deeply( $retrieved_custom_item_fields, $custom_item_fields );
    $account->custom_item_fields( [] );
    is( $account->custom_item_fields->count, 0 );

    $schema->storage->txn_rollback;
};

subtest 'item_fields' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $account = $builder->build_object( { class => 'Koha::SIP2::Accounts' } );
    is( $account->item_fields->count, 0, "no item fields yet" );

    my $item_fields = [
        {
            field => 'ZY',
            code  => 'permanent_location',
        },
    ];
    $account->item_fields($item_fields);

    my $retrieved_item_fields = $account->item_fields;
    is( ref($retrieved_item_fields), 'Koha::SIP2::Account::ItemFields' );
    $retrieved_item_fields =
        [ map { delete $_->{sip_account_item_field_id}; delete $_->{sip_account_id}; $_ }
            @{ $retrieved_item_fields->unblessed } ];
    is_deeply( $retrieved_item_fields, $item_fields );
    $account->item_fields( [] );
    is( $account->item_fields->count, 0 );

    $schema->storage->txn_rollback;
};

subtest 'custom_patron_fields' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $account = $builder->build_object( { class => 'Koha::SIP2::Accounts' } );
    is( $account->custom_patron_fields->count, 0, "no custom patron fields yet" );

    my $custom_patron_fields = [
        {
            field    => 'DE',
            template => '[% patron.dateexpiry %]',
        },
    ];
    $account->custom_patron_fields($custom_patron_fields);

    my $retrieved_custom_patron_fields = $account->custom_patron_fields;
    is( ref($retrieved_custom_patron_fields), 'Koha::SIP2::Account::CustomPatronFields' );
    $retrieved_custom_patron_fields =
        [ map { delete $_->{sip_account_custom_patron_field_id}; delete $_->{sip_account_id}; $_ }
            @{ $retrieved_custom_patron_fields->unblessed } ];
    is_deeply( $retrieved_custom_patron_fields, $custom_patron_fields );
    $account->custom_patron_fields( [] );
    is( $account->custom_patron_fields->count, 0 );

    $schema->storage->txn_rollback;
};

subtest 'patron_attributes' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $account = $builder->build_object( { class => 'Koha::SIP2::Accounts' } );
    is( $account->patron_attributes->count, 0, "no custom patron fields yet" );

    my $patron_attributes = [
        {
            field => 'XY',
            code  => 'CODE',
        },
    ];
    $account->patron_attributes($patron_attributes);

    my $retrieved_patron_attributes = $account->patron_attributes;
    is( ref($retrieved_patron_attributes), 'Koha::SIP2::Account::PatronAttributes' );
    $retrieved_patron_attributes =
        [ map { delete $_->{sip_account_patron_attribute_id}; delete $_->{sip_account_id}; $_ }
            @{ $retrieved_patron_attributes->unblessed } ];
    is_deeply( $retrieved_patron_attributes, $patron_attributes );
    $account->patron_attributes( [] );
    is( $account->patron_attributes->count, 0 );

    $schema->storage->txn_rollback;
};

subtest 'screen_msg_regexs' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $account = $builder->build_object( { class => 'Koha::SIP2::Accounts' } );
    is( $account->screen_msg_regexs->count, 0, "no custom patron fields yet" );

    my $screen_msg_regexs = [
        {
            find    => 'Greetings from Koha.',
            replace => 'Welcome to your library!',
        },
    ];
    $account->screen_msg_regexs($screen_msg_regexs);

    my $retrieved_screen_msg_regexs = $account->screen_msg_regexs;
    is( ref($retrieved_screen_msg_regexs), 'Koha::SIP2::Account::ScreenMsgRegexs' );
    $retrieved_screen_msg_regexs =
        [ map { delete $_->{sip_account_screen_msg_regex_id}; delete $_->{sip_account_id}; $_ }
            @{ $retrieved_screen_msg_regexs->unblessed } ];
    is_deeply( $retrieved_screen_msg_regexs, $screen_msg_regexs );
    $account->screen_msg_regexs( [] );
    is( $account->screen_msg_regexs->count, 0 );

    $schema->storage->txn_rollback;
};

subtest 'sort_bin_mappings' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $account = $builder->build_object( { class => 'Koha::SIP2::Accounts' } );
    is( $account->sort_bin_mappings->count, 0, "no custom patron fields yet" );

    my $sort_bin_mappings = [
        {
            mapping => 'CPL:itype:eq:BK:1',
        },
    ];
    $account->sort_bin_mappings($sort_bin_mappings);

    my $retrieved_sort_bin_mappings = $account->sort_bin_mappings;
    is( ref($retrieved_sort_bin_mappings), 'Koha::SIP2::Account::SortBinMappings' );
    $retrieved_sort_bin_mappings =
        [ map { delete $_->{sip_account_sort_bin_mapping_id}; delete $_->{sip_account_id}; $_ }
            @{ $retrieved_sort_bin_mappings->unblessed } ];
    is_deeply( $retrieved_sort_bin_mappings, $sort_bin_mappings );
    $account->sort_bin_mappings( [] );
    is( $account->sort_bin_mappings->count, 0 );

    $schema->storage->txn_rollback;
};

subtest 'system_preference_overrides' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $account = $builder->build_object( { class => 'Koha::SIP2::Accounts' } );
    is( $account->system_preference_overrides->count, 0, "no custom patron fields yet" );

    my $system_preference_overrides = [
        {
            variable => 'AllFinesNeedOverride',
            value    => 0,
        },
    ];
    $account->system_preference_overrides($system_preference_overrides);

    my $retrieved_system_preference_overrides = $account->system_preference_overrides;
    is( ref($retrieved_system_preference_overrides), 'Koha::SIP2::Account::SystemPreferenceOverrides' );
    $retrieved_system_preference_overrides =
        [ map { delete $_->{sip_account_system_preference_override_id}; delete $_->{sip_account_id}; $_ }
            @{ $retrieved_system_preference_overrides->unblessed } ];
    is_deeply( $retrieved_system_preference_overrides, $system_preference_overrides );
    $account->system_preference_overrides( [] );
    is( $account->system_preference_overrides->count, 0 );

    $schema->storage->txn_rollback;
};
