#!/usr/bin/env perl

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

use Test::NoWarnings;
use Test::More tests => 3;
use Test::Exception;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Mojo::JSON;

use Koha::Database;

BEGIN {
    use_ok('Koha::Module::Policy::Checkin');
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'Koha::Module::Policy::Checkin tests' => sub {

    plan tests => 2;

    subtest 'to_hashref() tests' => sub {

        plan tests => 27;

        $schema->storage->txn_begin;

        my $patron  = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );
        my $library = $builder->build_object( { class => 'Koha::Libraries' } );

        # Mock all relevant prefs to known values
        t::lib::Mocks::mock_preference( 'finesMode',                          'production' );
        t::lib::Mocks::mock_preference( 'FineNotifyAtCheckin',                1 );
        t::lib::Mocks::mock_preference( 'ExpireReservesMaxPickUpDelayCharge', 1 );
        t::lib::Mocks::mock_preference( 'SpecifyReturnDate',                  1 );
        t::lib::Mocks::mock_preference( 'CircConfirmItemParts',               1 );
        t::lib::Mocks::mock_preference( 'HoldsAutoFill',                      1 );
        t::lib::Mocks::mock_preference( 'HoldsAutoFillPrintSlip',             1 );
        t::lib::Mocks::mock_preference( 'WaitingNotifyAtCheckin',             1 );
        t::lib::Mocks::mock_preference( 'DisplayAddHoldGroups',               1 );
        t::lib::Mocks::mock_preference( 'UseRecalls',                         'opac_and_staff' );
        t::lib::Mocks::mock_preference( 'AnonymousPatron',                    $patron->borrowernumber );
        t::lib::Mocks::mock_preference( 'TransfersBlockCirc',                 1 );
        t::lib::Mocks::mock_preference( 'AutomaticConfirmTransfer',           1 );
        t::lib::Mocks::mock_preference( 'ShowAllCheckins',                    1 );
        t::lib::Mocks::mock_preference( 'numReturnedItemsToShow',             12 );
        t::lib::Mocks::mock_preference( 'AudioAlerts',                        1 );
        t::lib::Mocks::mock_preference( 'CatalogConcerns',                    1 );
        t::lib::Mocks::mock_preference( 'BlockReturnOfWithdrawnItems',        1 );
        t::lib::Mocks::mock_preference( 'BlockReturnOfLostItems',             1 );

        my $policy = Koha::Module::Policy::Checkin->new(
            {
                user    => $patron,
                library => $library->branchcode,
            }
        );

        my $policy_hashref = $policy->to_hashref;

        is( $policy_hashref->{module}, 'checkin', 'The envelope is for the checkin module' );
        is_deeply(
            [ sort keys %{$policy_hashref} ], [qw( checkin global module )],
            'The envelope carries the global and checkin namespaces'
        );

        my $hashref = $policy_hashref->{checkin};

        my @flags = grep { $_ !~ /^(dropbox_date|max_returned_items|anonymous_patron_id)$/ } keys %{$hashref};
        is(
            scalar( grep { ref( $hashref->{$_} ) ne 'JSON::PP::Boolean' } @flags ), 0,
            'All flags are JSON booleans'
        );

        # User without writeoff permission - exempt_fine and forgive_hold_fees should be 0
        is( $hashref->{exempt_fine},       0, 'exempt_fine is 0 without writeoff perm' );
        is( $hashref->{forgive_hold_fees}, 0, 'forgive_hold_fees is 0 without writeoff perm' );

        # Prefs that are purely pref-driven
        is( $hashref->{fine_notify_at_checkin},          1,  'fine_notify_at_checkin reflects pref' );
        is( $hashref->{specify_return_date},             1,  'specify_return_date reflects pref' );
        is( $hashref->{dropbox_mode},                    1,  'dropbox_mode always available' );
        is( $hashref->{confirm_item_parts},              1,  'confirm_item_parts reflects pref' );
        is( $hashref->{holds_auto_fill},                 1,  'holds_auto_fill reflects pref' );
        is( $hashref->{holds_auto_fill_print_slip},      1,  'holds_auto_fill_print_slip reflects pref' );
        is( $hashref->{waiting_notify_at_checkin},       1,  'waiting_notify_at_checkin reflects pref' );
        is( $hashref->{display_hold_groups},             1,  'display_hold_groups reflects pref' );
        is( $hashref->{recalls_enabled},                 1,  'recalls_enabled reflects pref' );
        is( $hashref->{transfers_block},                 1,  'transfers_block reflects pref' );
        is( $hashref->{auto_confirm_transfer},           1,  'auto_confirm_transfer reflects pref' );
        is( $hashref->{show_all_checkins},               1,  'show_all_checkins reflects pref' );
        is( $hashref->{max_returned_items},              12, 'max_returned_items reflects pref' );
        is( $policy_hashref->{global}{audio_alerts},     1,  'audio_alerts reflects pref' );
        is( $policy_hashref->{global}{catalog_concerns}, 1,  'catalog_concerns reflects pref' );
        is( $hashref->{block_return_withdrawn},          1,  'block_return_withdrawn reflects pref' );
        is( $hashref->{block_return_lost},               1,  'block_return_lost reflects pref' );
        is( $hashref->{anonymous_patron_id},             $patron->borrowernumber, 'anonymous_patron_id reflects pref' );
        like( $hashref->{dropbox_date}, qr/^\d{4}-\d{2}-\d{2}$/, 'dropbox_date is a date' );
        is(
            Mojo::JSON::encode_json( { id => $hashref->{anonymous_patron_id} } ),
            '{"id":' . $patron->borrowernumber . '}',
            'anonymous_patron_id is a number'
        );

        t::lib::Mocks::mock_preference( 'UseRecalls',      'off' );
        t::lib::Mocks::mock_preference( 'AnonymousPatron', '' );
        $hashref =
            Koha::Module::Policy::Checkin->new( { user => $patron, library => $library->branchcode } )
            ->to_hashref->{checkin};
        is( $hashref->{recalls_enabled},     0,     q{recalls_enabled is 0 when UseRecalls is 'off'} );
        is( $hashref->{anonymous_patron_id}, undef, 'anonymous_patron_id is undef when AnonymousPatron is not set' );

        $schema->storage->txn_rollback;
    };

    subtest 'Permission-gated capabilities tests' => sub {

        plan tests => 2;

        $schema->storage->txn_begin;

        # Superlibrarian has all permissions
        my $superlibrarian = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 1 } } );
        my $library        = $builder->build_object( { class => 'Koha::Libraries' } );

        t::lib::Mocks::mock_preference( 'finesMode',                          'production' );
        t::lib::Mocks::mock_preference( 'ExpireReservesMaxPickUpDelayCharge', 1 );

        my $policy = Koha::Module::Policy::Checkin->new(
            {
                user    => $superlibrarian,
                library => $library->branchcode,
            }
        );

        my $hashref = $policy->to_hashref->{checkin};

        is( $hashref->{exempt_fine},       1, 'exempt_fine is 1 for superlibrarian' );
        is( $hashref->{forgive_hold_fees}, 1, 'forgive_hold_fees is 1 for superlibrarian' );

        $schema->storage->txn_rollback;
    };
};
