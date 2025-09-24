#!/usr/bin/perl

# Copyright 2018 Rijksmuseum
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use Data::Dumper qw/Dumper/;
use Test::NoWarnings;
use Test::More tests => 3;
use Test::MockModule;
use Test::MockObject;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::Database;
use Koha::DateUtils qw/dt_from_string/;
use Koha::Patron::Consents;

our $builder = t::lib::TestBuilder->new;
our $schema  = Koha::Database->new->schema;

subtest 'Basic tests for Koha::Patron::Consent' => sub {
    plan tests => 2;
    $schema->storage->txn_begin;

    my $patron1  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $consent1 = Koha::Patron::Consent->new(
        {
            borrowernumber => $patron1->borrowernumber,
            type           => 'GDPR_PROCESSING',
            given_on       => dt_from_string,
        }
    )->store;
    is(
        Koha::Patron::Consents->search( { borrowernumber => $patron1->borrowernumber } )->count, 1,
        'One consent for new borrower'
    );
    $consent1->delete;
    is(
        Koha::Patron::Consents->search( { borrowernumber => $patron1->borrowernumber } )->count, 0,
        'No consents left for new borrower'
    );

    $schema->storage->txn_rollback;
};

subtest 'Method available_types' => sub {
    plan tests => 7;
    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'PrivacyPolicyConsent', q{} );
    my $types        = Koha::Patron::Consents->available_types;
    my $count_before = scalar keys %$types;
    t::lib::Mocks::mock_preference( 'PrivacyPolicyConsent', 'Enforced' );
    $types = Koha::Patron::Consents->available_types;
    is( keys %$types, $count_before + 1, 'Expect one type more for privacy policy' );

    # Mock get_enabled_plugins
    my $plugins        = [];
    my $plugins_module = Test::MockModule->new('Koha::Plugins');
    $plugins_module->mock( 'get_enabled_plugins', sub { return @$plugins } );
    my $plugin_1 = Test::MockObject->new;
    my $data_1   = [ 'plugin_1', { title => { en => 'Title1' }, description => { en => 'Desc1' } } ];
    $plugin_1->mock( 'patron_consent_type', sub { return $data_1; } );
    my $plugin_2 = Test::MockObject->new;
    my $data_2   = [ 'plugin_2', { title => { en => 'Title2' }, description => { en => 'Desc2' } } ];
    $plugin_2->mock( 'patron_consent_type', sub { return $data_2; } );
    $plugins = [ $plugin_1, $plugin_2 ];

    $types = Koha::Patron::Consents->available_types;
    is( keys %$types, 3, 'Expect three types when plugins installed and enabled' );
    t::lib::Mocks::mock_preference( 'PrivacyPolicyConsent', '' );
    $types = Koha::Patron::Consents->available_types;
    is( keys %$types,              2,     'Expect two types, when plugins enabled but PrivacyPolicyConsent disabled' );
    is( $types->{GDPR_PROCESSING}, undef, 'GDPR key should not be found' );
    is_deeply( $types->{plugin_2}, $data_2->[1], 'Check type hash' );

    # Let plugin_2 return bad data (hashref)
    $data_2 = { not_expected => 1 };
    $types  = Koha::Patron::Consents->available_types;
    is( keys %$types, 1, 'Expect one plugin, when plugin_2 fails' );
    is_deeply( $types->{plugin_1}, $data_1->[1], 'Check type hash' );

    $schema->storage->txn_rollback;
};
