#!/usr/bin/perl

# Copyright 2020 Koha Development team
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

use Test::NoWarnings;
use Test::More tests => 17;

use Test::Exception;
use Test::MockModule;

use t::lib::Mocks;
use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Reserves qw(AddReserve);

use Koha::ActionLogs;
use Koha::DateUtils qw(dt_from_string);
use Koha::Holds;
use Koha::Libraries;
use Koha::Old::Holds;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'store() tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item   = $builder->build_sample_item;
    throws_ok {
        Koha::Hold->new(
            {
                borrowernumber => $patron->borrowernumber,
                biblionumber   => $item->biblionumber,
                priority       => 1,
                itemnumber     => $item->itemnumber,
            }
        )->store
    }
    'Koha::Exceptions::Hold::MissingPickupLocation',
        'Exception thrown because branchcode was not passed';

    my $hold = $builder->build_object( { class => 'Koha::Holds' } );
    throws_ok {
        $hold->branchcode(undef)->store;
    }
    'Koha::Exceptions::Hold::MissingPickupLocation',
        'Exception thrown if one tries to set branchcode to null';

    $schema->storage->txn_rollback;
};

subtest 'biblio() tests' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $hold = $builder->build_object(
        {
            class => 'Koha::Holds',
        }
    );

    local $SIG{__WARN__} = sub { warn $_[0] unless $_[0] =~ /cannot be null/ };
    throws_ok { $hold->biblionumber(undef)->store; }
    'DBIx::Class::Exception',
        'reserves.biblionumber cannot be null, exception thrown';

    $schema->storage->txn_rollback;
};

subtest 'pickup_library/branch tests' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $hold = $builder->build_object(
        {
            class => 'Koha::Holds',
        }
    );

    is( ref( $hold->pickup_library ), 'Koha::Library', '->pickup_library should return a Koha::Library object' );

    $schema->storage->txn_rollback;
};

subtest 'fill() tests' => sub {

    plan tests => 15;

    $schema->storage->txn_begin;

    my $fee = 15;

    my $category = $builder->build_object(
        {
            class => 'Koha::Patron::Categories',
            value => { reservefee => $fee }
        }
    );
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { categorycode => $category->id }
        }
    );
    my $manager = $builder->build_object( { class => 'Koha::Patrons' } );

    my $title  = 'Do what you want';
    my $biblio = $builder->build_sample_biblio( { title => $title } );
    my $item   = $builder->build_sample_item( { biblionumber => $biblio->id } );
    my $hold   = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                biblionumber   => $biblio->id,
                borrowernumber => $patron->id,
                itemnumber     => $item->id,
                timestamp      => dt_from_string('2021-06-25 14:05:35'),
                priority       => 10,
            }
        }
    );

    t::lib::Mocks::mock_preference( 'HoldFeeMode', 'any_time_is_collected' );
    t::lib::Mocks::mock_preference( 'HoldsLog',    1 );
    t::lib::Mocks::mock_userenv( { patron => $manager, branchcode => $manager->branchcode } );

    my $interface = 'api';
    C4::Context->interface($interface);
    my $hold_timestamp = $hold->timestamp;
    my $ret            = $hold->fill;

    is( ref($ret), 'Koha::Hold', '->fill returns the object type' );
    is( $ret->id,  $hold->id,    '->fill returns the object' );

    is( Koha::Holds->find( $hold->id ), undef, 'Hold no longer current' );
    my $old_hold = Koha::Old::Holds->find( $hold->id );

    is( $old_hold->id,       $hold->id, 'reserve_id retained' );
    is( $old_hold->priority, 0,         'priority set to 0' );
    isnt( $old_hold->timestamp, $hold_timestamp, 'timestamp updated' );
    is( $old_hold->found, 'F', 'found set to F' );

    subtest 'item_id parameter' => sub {
        plan tests => 1;
        $category->reservefee(0)->store;    # do not disturb later accounts
        $hold = $builder->build_object(
            {
                class => 'Koha::Holds',
                value =>
                    { biblionumber => $biblio->id, borrowernumber => $patron->id, itemnumber => undef, priority => 1 }
            }
        );

        # Simulating checkout without confirming hold
        $hold->fill( { item_id => $item->id } );
        $old_hold = Koha::Old::Holds->find( $hold->id );
        is( $old_hold->itemnumber, $item->itemnumber, 'The itemnumber has been saved in old_reserves by fill' );
        $old_hold->delete;
        $category->reservefee($fee)->store;    # restore
    };

    subtest 'fee applied tests' => sub {

        plan tests => 9;

        my $account = $patron->account;
        is( $account->balance, $fee, 'Charge applied correctly' );

        my $debits = $account->outstanding_debits;
        is( $debits->count, 1, 'Only one fee charged' );

        my $fee_debit = $debits->next;
        is( $fee_debit->amount * 1, $fee, 'Fee amount stored correctly' );
        is(
            $fee_debit->description, $title,
            'Fee description stored correctly'
        );
        is(
            $fee_debit->manager_id, $manager->id,
            'Fee manager_id stored correctly'
        );
        is(
            $fee_debit->branchcode, $manager->branchcode,
            'Fee branchcode stored correctly'
        );
        is(
            $fee_debit->interface, $interface,
            'Fee interface stored correctly'
        );
        is(
            $fee_debit->debit_type_code,
            'RESERVE', 'Fee debit_type_code stored correctly'
        );
        is(
            $fee_debit->itemnumber, $item->id,
            'Fee itemnumber stored correctly'
        );
    };

    my $logs = Koha::ActionLogs->search(
        {
            action => 'FILL',
            module => 'HOLDS',
            object => $hold->id
        }
    );

    is( $logs->count, 1, '1 log line added' );

    # Set HoldFeeMode to something other than any_time_is_collected
    t::lib::Mocks::mock_preference( 'HoldFeeMode', 'not_always' );

    # Disable logging
    t::lib::Mocks::mock_preference( 'HoldsLog', 0 );

    $hold = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                biblionumber   => $biblio->id,
                borrowernumber => $patron->id,
                itemnumber     => $item->id,
                priority       => 10,
            }
        }
    );

    $hold->fill;

    my $account = $patron->account;
    is( $account->balance, $fee, 'No new charge applied' );

    my $debits = $account->outstanding_debits;
    is( $debits->count, 1, 'Only one fee charged, because of HoldFeeMode' );

    $logs = Koha::ActionLogs->search(
        {
            action => 'FILL',
            module => 'HOLDS',
            object => $hold->id
        }
    );

    is( $logs->count, 0, 'HoldsLog disabled, no logs added' );

    subtest 'anonymization behavior tests' => sub {

        plan tests => 5;

        # reduce the tests noise
        t::lib::Mocks::mock_preference( 'HoldsLog',    0 );
        t::lib::Mocks::mock_preference( 'HoldFeeMode', 'not_always' );

        # unset AnonymousPatron
        t::lib::Mocks::mock_preference( 'AnonymousPatron', undef );

        # 0 == keep forever
        $patron->privacy(0)->store;
        my $hold = $builder->build_object(
            {
                class => 'Koha::Holds',
                value => { borrowernumber => $patron->id, found => undef }
            }
        );
        $hold->fill();
        is(
            Koha::Old::Holds->find( $hold->id )->borrowernumber,
            $patron->borrowernumber, 'Patron link is kept'
        );

        # 1 == "default", meaning it is not protected from removal
        $patron->privacy(1)->store;
        $hold = $builder->build_object(
            {
                class => 'Koha::Holds',
                value => { borrowernumber => $patron->id, found => undef }
            }
        );
        $hold->fill();
        is(
            Koha::Old::Holds->find( $hold->id )->borrowernumber,
            $patron->borrowernumber, 'Patron link is kept'
        );

        my $anonymous_patron = $builder->build_object( { class => 'Koha::Patrons' } );
        t::lib::Mocks::mock_preference( 'AnonymousPatron', $anonymous_patron->id );

        # We need anonymous patron set to change patron privacy to never
        # (2 == delete immediately)
        # then we can undef for further tests
        $patron->privacy(2)->store;
        t::lib::Mocks::mock_preference( 'AnonymousPatron', undef );
        $hold = $builder->build_object(
            {
                class => 'Koha::Holds',
                value => { borrowernumber => $patron->id, found => undef }
            }
        );

        throws_ok { $hold->fill(); }
        'Koha::Exception',
            'AnonymousPatron not set, exception thrown';

        $hold->discard_changes;    # refresh from DB

        ok( !$hold->is_found, 'Hold is not filled' );

        t::lib::Mocks::mock_preference( 'AnonymousPatron', $anonymous_patron->id );

        $hold = $builder->build_object(
            {
                class => 'Koha::Holds',
                value => { borrowernumber => $patron->id, found => undef }
            }
        );
        $hold->fill();
        is(
            Koha::Old::Holds->find( $hold->id )->borrowernumber,
            $anonymous_patron->id,
            'Patron link is set to the configured anonymous patron immediately'
        );
    };

    subtest 'holds_queue update tests' => sub {

        plan tests => 2;

        my $biblio = $builder->build_sample_biblio;

        # The check of the pref is in the Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue
        # so we mock the base enqueue method here to see if it is called
        my $mock = Test::MockModule->new('Koha::BackgroundJob');
        $mock->mock(
            'enqueue',
            sub {
                my ( $self, $args ) = @_;
                is_deeply(
                    $args->{job_args}->{biblio_ids},
                    [ $biblio->id ],
                    'when pref enabled the previous action triggers a holds queue update for the related biblio'
                );
            }
        );

        t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 1 );

        # Filling a hold when pref enabled should trigger a test
        $builder->build_object(
            {
                class => 'Koha::Holds',
                value => {
                    biblionumber => $biblio->id,
                }
            }
        )->fill;

        t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 0 );

        # Filling a hold when pref disabled should not trigger a test
        $builder->build_object(
            {
                class => 'Koha::Holds',
                value => {
                    biblionumber => $biblio->id,
                }
            }
        )->fill;

        my $library_1 = $builder->build_object(
            {
                class => 'Koha::Libraries',
            }
        )->store;
        my $library_2 = $builder->build_object(
            {
                class => 'Koha::Libraries',
            }
        )->store;

        my $hold = $builder->build_object(
            {
                class => 'Koha::Holds',
                value => {
                    biblionumber => $biblio->id,
                    branchcode   => $library_1->branchcode,
                }
            }
        )->store;

        # Pref is off, no test triggered
        # Updating a hold location when pref disabled should not trigger a test
        $hold->branchcode( $library_2->branchcode )->store;

        t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 1 );

        # Updating a hold location when pref enabled should trigger a test

        # Pref is on, test triggered
        $hold->branchcode( $library_1->branchcode )->store;

        # Update with no change to pickup location should not trigger a test
        $hold->branchcode( $library_1->branchcode )->store;

    };

    $schema->storage->txn_rollback;
};

subtest 'patron() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    my $hold   = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => { borrowernumber => $patron->borrowernumber }
        }
    );

    my $hold_patron = $hold->patron;
    is( ref($hold_patron), 'Koha::Patron', 'Right type' );
    is( $hold_patron->id,  $patron->id,    'Right object' );

    $schema->storage->txn_rollback;
};

subtest 'set_pickup_location() tests' => sub {

    plan tests => 11;

    $schema->storage->txn_begin;

    my $mock_biblio = Test::MockModule->new('Koha::Biblio');
    my $mock_item   = Test::MockModule->new('Koha::Item');

    my $library_1 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_2 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_3 = $builder->build_object( { class => 'Koha::Libraries' } );

    # let's control what Koha::Biblio->pickup_locations returns, for testing
    $mock_biblio->mock(
        'pickup_locations',
        sub {
            return Koha::Libraries->search( { branchcode => [ $library_2->branchcode, $library_3->branchcode ] } );
        }
    );

    # let's mock what Koha::Item->pickup_locations returns, for testing
    $mock_item->mock(
        'pickup_locations',
        sub {
            return Koha::Libraries->search( { branchcode => [ $library_2->branchcode, $library_3->branchcode ] } );
        }
    );

    my $biblio = $builder->build_sample_biblio;
    my $item   = $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );

    # Test biblio-level holds
    my $biblio_hold = $builder->build_object(
        {
            class => "Koha::Holds",
            value => {
                biblionumber => $biblio->biblionumber,
                branchcode   => $library_3->branchcode,
                itemnumber   => undef,
            }
        }
    );

    throws_ok { $biblio_hold->set_pickup_location( { library_id => $library_1->branchcode } ); }
    'Koha::Exceptions::Hold::InvalidPickupLocation',
        'Exception thrown on invalid pickup location';

    $biblio_hold->discard_changes;
    is( $biblio_hold->branchcode, $library_3->branchcode, 'branchcode remains untouched' );

    my $ret = $biblio_hold->set_pickup_location( { library_id => $library_2->id } );
    is( ref($ret), 'Koha::Hold', 'self is returned' );

    $biblio_hold->discard_changes;
    is( $biblio_hold->branchcode, $library_2->id, 'Pickup location changed correctly' );

    # Test item-level holds
    my $item_hold = $builder->build_object(
        {
            class => "Koha::Holds",
            value => {
                biblionumber => $biblio->biblionumber,
                branchcode   => $library_3->branchcode,
                itemnumber   => $item->itemnumber,
            }
        }
    );

    throws_ok { $item_hold->set_pickup_location( { library_id => $library_1->branchcode } ); }
    'Koha::Exceptions::Hold::InvalidPickupLocation',
        'Exception thrown on invalid pickup location';

    $item_hold->discard_changes;
    is( $item_hold->branchcode, $library_3->branchcode, 'branchcode remains untouched' );

    $item_hold->set_pickup_location( { library_id => $library_1->branchcode, force => 1 } );
    $item_hold->discard_changes;
    is( $item_hold->branchcode, $library_1->branchcode, 'branchcode changed because of \'force\'' );

    $ret = $item_hold->set_pickup_location( { library_id => $library_2->id } );
    is( ref($ret), 'Koha::Hold', 'self is returned' );

    $item_hold->discard_changes;
    is( $item_hold->branchcode, $library_2->id, 'Pickup location changed correctly' );

    throws_ok { $item_hold->set_pickup_location( { library_id => undef } ); }
    'Koha::Exceptions::MissingParameter',
        'Exception thrown if missing parameter';

    like( "$@", qr/The library_id parameter is mandatory/, 'Exception message is clear' );

    $schema->storage->txn_rollback;
};

subtest 'is_pickup_location_valid() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $mock_biblio = Test::MockModule->new('Koha::Biblio');
    my $mock_item   = Test::MockModule->new('Koha::Item');

    my $library_1 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_2 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_3 = $builder->build_object( { class => 'Koha::Libraries' } );

    # let's control what Koha::Biblio->pickup_locations returns, for testing
    $mock_biblio->mock(
        'pickup_locations',
        sub {
            return Koha::Libraries->search( { branchcode => [ $library_2->branchcode, $library_3->branchcode ] } );
        }
    );

    # let's mock what Koha::Item->pickup_locations returns, for testing
    $mock_item->mock(
        'pickup_locations',
        sub {
            return Koha::Libraries->search( { branchcode => [ $library_2->branchcode, $library_3->branchcode ] } );
        }
    );

    my $biblio = $builder->build_sample_biblio;
    my $item   = $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );

    # Test biblio-level holds
    my $biblio_hold = $builder->build_object(
        {
            class => "Koha::Holds",
            value => {
                biblionumber => $biblio->biblionumber,
                branchcode   => $library_3->branchcode,
                itemnumber   => undef,
            }
        }
    );

    ok(
        !$biblio_hold->is_pickup_location_valid( { library_id => $library_1->branchcode } ),
        'Pickup location invalid'
    );
    ok( $biblio_hold->is_pickup_location_valid( { library_id => $library_2->id } ), 'Pickup location valid' );

    # Test item-level holds
    my $item_hold = $builder->build_object(
        {
            class => "Koha::Holds",
            value => {
                biblionumber => $biblio->biblionumber,
                branchcode   => $library_3->branchcode,
                itemnumber   => $item->itemnumber,
            }
        }
    );

    ok( !$item_hold->is_pickup_location_valid( { library_id => $library_1->branchcode } ), 'Pickup location invalid' );
    ok( $item_hold->is_pickup_location_valid( { library_id  => $library_2->id } ),         'Pickup location valid' );

    subtest 'pickup_locations() returning ->empty' => sub {

        plan tests => 2;

        $schema->storage->txn_begin;

        my $library = $builder->build_object( { class => 'Koha::Libraries' } );

        my $mock_item = Test::MockModule->new('Koha::Item');
        $mock_item->mock( 'pickup_locations', sub { return Koha::Libraries->new->empty; } );

        my $mock_biblio = Test::MockModule->new('Koha::Biblio');
        $mock_biblio->mock( 'pickup_locations', sub { return Koha::Libraries->new->empty; } );

        my $item   = $builder->build_sample_item();
        my $biblio = $item->biblio;

        # Test biblio-level holds
        my $biblio_hold = $builder->build_object(
            {
                class => "Koha::Holds",
                value => {
                    biblionumber => $biblio->biblionumber,
                    itemnumber   => undef,
                }
            }
        );

        ok(
            !$biblio_hold->is_pickup_location_valid( { library_id => $library->branchcode } ),
            'Pickup location invalid'
        );

        # Test item-level holds
        my $item_hold = $builder->build_object(
            {
                class => "Koha::Holds",
                value => {
                    biblionumber => $biblio->biblionumber,
                    itemnumber   => $item->itemnumber,
                }
            }
        );

        ok(
            !$item_hold->is_pickup_location_valid( { library_id => $library->branchcode } ),
            'Pickup location invalid'
        );

        $schema->storage->txn_rollback;
    };

    $schema->storage->txn_rollback;
};

subtest 'cancel() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    # reduce the tests noise
    t::lib::Mocks::mock_preference( 'HoldsLog', 0 );
    t::lib::Mocks::mock_preference(
        'ExpireReservesMaxPickUpDelayCharge',
        undef
    );

    t::lib::Mocks::mock_preference( 'AnonymousPatron', undef );

    # 0 == keep forever
    $patron->privacy(0)->store;
    my $hold = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => { borrowernumber => $patron->id, found => undef }
        }
    );
    $hold->cancel();
    is(
        Koha::Old::Holds->find( $hold->id )->borrowernumber,
        $patron->borrowernumber, 'Patron link is kept'
    );

    # 1 == "default", meaning it is not protected from removal
    $patron->privacy(1)->store;
    $hold = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => { borrowernumber => $patron->id, found => undef }
        }
    );
    $hold->cancel();
    is(
        Koha::Old::Holds->find( $hold->id )->borrowernumber,
        $patron->borrowernumber, 'Patron link is kept'
    );

    my $anonymous_patron = $builder->build_object( { class => 'Koha::Patrons' } );
    t::lib::Mocks::mock_preference( 'AnonymousPatron', $anonymous_patron->id );

    # We need anonymous patron set to change patron privacy to never
    # (2 == delete immediately)
    # then we can undef for further tests
    $patron->privacy(2)->store;
    t::lib::Mocks::mock_preference( 'AnonymousPatron', undef );
    $hold = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => { borrowernumber => $patron->id, found => undef }
        }
    );
    throws_ok { $hold->cancel(); }
    'Koha::Exception',
        'AnonymousPatron not set, exception thrown';

    $hold->discard_changes;

    ok( !$hold->is_found, 'Hold is not cancelled' );

    t::lib::Mocks::mock_preference( 'AnonymousPatron', $anonymous_patron->id );

    $hold = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => { borrowernumber => $patron->id, found => undef }
        }
    );
    $hold->cancel();
    is(
        Koha::Old::Holds->find( $hold->id )->borrowernumber,
        $anonymous_patron->id,
        'Patron link is set to the configured anonymous patron immediately'
    );

    subtest 'holds_queue update tests' => sub {

        plan tests => 1;

        my $biblio = $builder->build_sample_biblio;

        t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 1 );

        my $mock = Test::MockModule->new('Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue');
        $mock->mock(
            'enqueue',
            sub {
                my ( $self, $args ) = @_;
                is_deeply(
                    $args->{biblio_ids},
                    [ $biblio->id ],
                    '->cancel triggers a holds queue update for the related biblio'
                );
            }
        );

        $builder->build_object(
            {
                class => 'Koha::Holds',
                value => {
                    biblionumber => $biblio->id,
                }
            }
        )->cancel;

        # If the skip_holds_queue param is not honoured, then test count will fail.
        $builder->build_object(
            {
                class => 'Koha::Holds',
                value => {
                    biblionumber => $biblio->id,
                }
            }
        )->cancel( { skip_holds_queue => 1 } );

        t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 0 );

        $builder->build_object(
            {
                class => 'Koha::Holds',
                value => {
                    biblionumber => $biblio->id,
                }
            }
        )->cancel( { skip_holds_queue => 0 } );
    };

    $schema->storage->txn_rollback;
};

subtest 'suspend_hold() and resume() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio;
    my $action;

    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 1 );

    my $mock = Test::MockModule->new('Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue');
    $mock->mock(
        'enqueue',
        sub {
            my ( $self, $args ) = @_;
            is_deeply(
                $args->{biblio_ids},
                [ $biblio->id ],
                "->$action triggers a holds queue update for the related biblio"
            );
        }
    );

    my $hold = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                biblionumber => $biblio->id,
                found        => undef,
            }
        }
    );

    $action = 'suspend_hold';
    $hold->suspend_hold;

    $action = 'resume';
    $hold->resume;

    $schema->storage->txn_rollback;
};

subtest 'cancellation_requests(), add_cancellation_request() and cancellation_requested() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 0 );

    my $hold = $builder->build_object( { class => 'Koha::Holds', } );

    is( $hold->cancellation_requests->count, 0 );
    ok( !$hold->cancellation_requested );

    # Add two cancellation requests
    my $request_1 = $hold->add_cancellation_request;
    isnt( $request_1->creation_date, undef, 'creation_date is set' );

    my $requester     = $builder->build_object( { class => 'Koha::Patrons' } );
    my $creation_date = '2021-06-25 14:05:35';

    my $request_2 = $hold->add_cancellation_request(
        {
            creation_date => $creation_date,
        }
    );

    is( $request_2->creation_date, $creation_date, 'Passed creation_date set' );

    is( $hold->cancellation_requests->count, 2 );
    ok( $hold->cancellation_requested );

    $schema->storage->txn_rollback;
};

subtest 'cancellation_requestable_from_opac() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $category            = $builder->build_object( { class => 'Koha::Patron::Categories' } );
    my $item_home_library   = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron_home_library = $builder->build_object( { class => 'Koha::Libraries' } );

    my $item   = $builder->build_sample_item( { library => $item_home_library->id } );
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $patron_home_library->id }
        }
    );

    subtest 'Exception cases' => sub {

        plan tests => 4;

        my $hold = $builder->build_object(
            {
                class => 'Koha::Holds',
                value => {
                    itemnumber     => undef,
                    found          => undef,
                    borrowernumber => $patron->id
                }
            }
        );

        throws_ok { $hold->cancellation_requestable_from_opac; }
        'Koha::Exceptions::InvalidStatus',
            'Exception thrown because hold is not waiting';

        is( $@->invalid_status, 'hold_not_waiting' );

        $hold = $builder->build_object(
            {
                class => 'Koha::Holds',
                value => {
                    itemnumber     => undef,
                    found          => 'W',
                    borrowernumber => $patron->id
                }
            }
        );

        throws_ok { $hold->cancellation_requestable_from_opac; }
        'Koha::Exceptions::InvalidStatus',
            'Exception thrown because waiting hold has no item linked';

        is( $@->invalid_status, 'no_item_linked' );
    };

    # set default rule to enabled
    Koha::CirculationRules->set_rule(
        {
            categorycode => '*',
            itemtype     => '*',
            branchcode   => '*',
            rule_name    => 'waiting_hold_cancellation',
            rule_value   => 1,
        }
    );

    my $hold = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                itemnumber     => $item->id,
                found          => 'W',
                borrowernumber => $patron->id
            }
        }
    );

    t::lib::Mocks::mock_preference(
        'ReservesControlBranch',
        'ItemHomeLibrary'
    );

    Koha::CirculationRules->set_rule(
        {
            categorycode => $patron->categorycode,
            itemtype     => $item->itype,
            branchcode   => $item->homebranch,
            rule_name    => 'waiting_hold_cancellation',
            rule_value   => 0,
        }
    );

    ok( !$hold->cancellation_requestable_from_opac );

    Koha::CirculationRules->set_rule(
        {
            categorycode => $patron->categorycode,
            itemtype     => $item->itype,
            branchcode   => $item->homebranch,
            rule_name    => 'waiting_hold_cancellation',
            rule_value   => 1,
        }
    );

    ok(
        $hold->cancellation_requestable_from_opac,
        'Make sure it is picking the right circulation rule'
    );

    t::lib::Mocks::mock_preference( 'ReservesControlBranch', 'PatronLibrary' );

    Koha::CirculationRules->set_rule(
        {
            categorycode => $patron->categorycode,
            itemtype     => $item->itype,
            branchcode   => $patron->branchcode,
            rule_name    => 'waiting_hold_cancellation',
            rule_value   => 0,
        }
    );

    ok( !$hold->cancellation_requestable_from_opac );

    Koha::CirculationRules->set_rule(
        {
            categorycode => $patron->categorycode,
            itemtype     => $item->itype,
            branchcode   => $patron->branchcode,
            rule_name    => 'waiting_hold_cancellation',
            rule_value   => 1,
        }
    );

    ok(
        $hold->cancellation_requestable_from_opac,
        'Make sure it is picking the right circulation rule'
    );

    $schema->storage->txn_rollback;
};

subtest 'can_update_pickup_location_opac() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $hold = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => { found => undef, suspend => 0, suspend_until => undef, waitingdate => undef }
        }
    );

    t::lib::Mocks::mock_preference( 'OPACAllowUserToChangeBranch', '' );
    $hold->found(undef);
    is( $hold->can_update_pickup_location_opac, 0, "Pending hold pickup can't be changed (No change allowed)" );

    $hold->found('T');
    is( $hold->can_update_pickup_location_opac, 0, "In transit hold pickup can't be changed (No change allowed)" );

    $hold->found('W');
    is( $hold->can_update_pickup_location_opac, 0, "Waiting hold pickup can't be changed (No change allowed)" );

    $hold->found(undef);
    my $dt = dt_from_string();

    $hold->suspend_hold($dt);
    is( $hold->can_update_pickup_location_opac, 0, "Suspended hold pickup can't be changed (No change allowed)" );
    $hold->resume();

    t::lib::Mocks::mock_preference( 'OPACAllowUserToChangeBranch', 'pending,intransit,suspended' );
    $hold->found(undef);
    is(
        $hold->can_update_pickup_location_opac, 1,
        "Pending hold pickup can be changed (pending,intransit,suspended allowed)"
    );

    $hold->found('T');
    is(
        $hold->can_update_pickup_location_opac, 1,
        "In transit hold pickup can be changed (pending,intransit,suspended allowed)"
    );

    $hold->found('W');
    is(
        $hold->can_update_pickup_location_opac, 0,
        "Waiting hold pickup can't be changed (pending,intransit,suspended allowed)"
    );

    $hold->found(undef);
    $dt = dt_from_string();
    $hold->suspend_hold($dt);
    is(
        $hold->can_update_pickup_location_opac, 1,
        "Suspended hold pickup can be changed (pending,intransit,suspended allowed)"
    );

    $schema->storage->txn_rollback;
};

subtest 'Koha::Hold::item_group tests' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $category = $builder->build_object(
        {
            class => 'Koha::Patron::Categories',
            value => { exclude_from_local_holds_priority => 0 }
        }
    );
    my $patron = $builder->build_object(
        {
            class => "Koha::Patrons",
            value => {
                branchcode   => $library->branchcode,
                categorycode => $category->categorycode
            }
        }
    );
    my $biblio = $builder->build_sample_biblio();

    my $item_group =
        Koha::Biblio::ItemGroup->new( { biblio_id => $biblio->id } )->store();

    my $hold = $builder->build_object(
        {
            class => "Koha::Holds",
            value => {
                borrowernumber => $patron->borrowernumber,
                biblionumber   => $biblio->biblionumber,
                priority       => 1,
                item_group_id  => $item_group->id,
            }
        }
    );

    is( $hold->item_group->id, $item_group->id, "Got correct item group" );

    $schema->storage->txn_rollback;
};

subtest 'change_type() tests' => sub {

    plan tests => 13;

    $schema->storage->txn_begin;

    my $item = $builder->build_object( { class => 'Koha::Items', } );
    my $hold = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                itemnumber      => undef,
                item_level_hold => 0,
            }
        }
    );

    my $hold2 = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                borrowernumber => $hold->borrowernumber,
            }
        }
    );

    ok( $hold->change_type );

    $hold->discard_changes;

    is( $hold->itemnumber, undef, 'record hold to record hold, no changes' );

    is( $hold->item_level_hold, 0, 'item_level_hold=0' );

    ok( $hold->change_type( $item->itemnumber ) );

    $hold->discard_changes;

    is( $hold->itemnumber, $item->itemnumber, 'record hold to item hold' );

    is( $hold->item_level_hold, 1, 'item_level_hold=1' );

    ok( $hold->change_type( $item->itemnumber ) );

    $hold->discard_changes;

    is( $hold->itemnumber, $item->itemnumber, 'item hold to item hold, no changes' );

    is( $hold->item_level_hold, 1, 'item_level_hold=1' );

    ok( $hold->change_type );

    $hold->discard_changes;

    is( $hold->itemnumber, undef, 'item hold to record hold' );

    is( $hold->item_level_hold, 0, 'item_level_hold=0' );

    my $hold3 = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                biblionumber   => $hold->biblionumber,
                borrowernumber => $hold->borrowernumber,
            }
        }
    );

    throws_ok { $hold->change_type }
    'Koha::Exceptions::Hold::CannotChangeHoldType',
        'Exception thrown because more than one hold per record';

    $schema->storage->txn_rollback;
};

subtest 'strings_map() tests' => sub {

    plan tests => 3;

    $schema->txn_begin;

    my $av = Koha::AuthorisedValue->new(
        {
            category         => 'HOLD_CANCELLATION',
            authorised_value => 'JUST_BECAUSE',
            lib              => 'Just because',
            lib_opac         => 'Serious reasons',
        }
    )->store;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );

    my $hold = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => { cancellation_reason => $av->authorised_value, branchcode => $library->id }
        }
    );

    my $strings_map = $hold->strings_map( { public => 0 } );
    is_deeply(
        $strings_map,
        {
            pickup_library_id   => { str => $library->branchname, type => 'library' },
            cancellation_reason => { str => $av->lib, type => 'av', category => 'HOLD_CANCELLATION' },
        },
        'Strings map is correct'
    );

    $strings_map = $hold->strings_map( { public => 1 } );
    is_deeply(
        $strings_map,
        {
            pickup_library_id   => { str => $library->branchname, type => 'library' },
            cancellation_reason => { str => $av->lib_opac, type => 'av', category => 'HOLD_CANCELLATION' },
        },
        'Strings map is correct (OPAC)'
    );

    $av->delete();

    $strings_map = $hold->strings_map( { public => 1 } );
    is_deeply(
        $strings_map,
        {
            pickup_library_id   => { str => $library->branchname, type => 'library' },
            cancellation_reason => { str => $hold->cancellation_reason, type => 'av', category => 'HOLD_CANCELLATION' },
        },
        'Strings map shows the cancellation_value when AV not present'
    );

    $schema->txn_rollback;
};

subtest 'revert_found() tests' => sub {

    plan tests => 6;

    subtest 'item-level holds tests' => sub {

        plan tests => 13;

        $schema->storage->txn_begin;

        my $item   = $builder->build_sample_item;
        my $patron = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { branchcode => $item->homebranch }
            }
        );

        # Create item-level hold
        my $hold = Koha::Holds->find(
            AddReserve(
                {
                    branchcode     => $item->homebranch,
                    borrowernumber => $patron->borrowernumber,
                    biblionumber   => $item->biblionumber,
                    priority       => 1,
                    itemnumber     => $item->itemnumber,
                }
            )
        );

        is( $hold->item_level_hold, 1, 'item_level_hold should be set when AddReserve is called with a specific item' );

        my $mock = Test::MockModule->new('Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue');
        $mock->mock(
            'enqueue',
            sub {
                my ( $self, $args ) = @_;
                is_deeply(
                    $args->{biblio_ids},
                    [ $hold->biblionumber ],
                    "AlterPriority triggers a holds queue update for the related biblio"
                );
            }
        );

        t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 1 );
        t::lib::Mocks::mock_preference( 'HoldsLog',           1 );

        # Mark it waiting
        $hold->set_waiting();

        isnt( $hold->waitingdate, undef, "'waitingdate' set" );
        is( $hold->priority, 0, "'priority' set to 0" );
        ok( $hold->is_waiting, 'Hold set to waiting' );

        # Revert the found status
        $hold->revert_found();

        is( $hold->waitingdate, undef, "'waitingdate' reset" );
        ok( !$hold->is_waiting, 'Hold no longer set to waiting' );
        is( $hold->priority, 1, "'priority' set to 1" );

        is(
            $hold->itemnumber, $item->itemnumber,
            'Itemnumber should not be removed when the waiting status is revert'
        );

        my $log =
            Koha::ActionLogs->search( { module => 'HOLDS', action => 'MODIFY', object => $hold->reserve_id } )->next;
        my $expected = sprintf q{'timestamp' => '%s'}, $hold->timestamp;
        like( $log->info, qr{$expected}, 'Timestamp logged is the current one' );
        my $log_count =
            Koha::ActionLogs->search( { module => 'HOLDS', action => 'MODIFY', object => $hold->reserve_id } )->count;

        t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 0 );
        t::lib::Mocks::mock_preference( 'HoldsLog',           0 );

        $hold->set_waiting();

        # Revert the found status, RealTimeHoldsQueue => shouldn't add a test
        $hold->revert_found();

        my $log_count_after =
            Koha::ActionLogs->search( { module => 'HOLDS', action => 'MODIFY', object => $hold->reserve_id } )->count;
        is( $log_count, $log_count_after, "No logging is added for ->revert_found() when HoldsLog is disabled" );

        # Set as regular hold (not found) to test the exception behavior
        $hold->found(undef);
        throws_ok { $hold->revert_found() }
        'Koha::Exceptions::InvalidStatus',
            "Hold is not in 'found' status, exception thrown";

        is( $@->invalid_status, 'hold_not_found', "'invalid_status' set the right value" );

        $schema->storage->txn_rollback;
    };

    subtest 'biblio-level hold tests' => sub {

        plan tests => 8;

        $schema->storage->txn_begin;

        my $item   = $builder->build_sample_item;
        my $patron = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { branchcode => $item->homebranch }
            }
        );

        # Create biblio-level hold
        my $hold = Koha::Holds->find(
            AddReserve(
                {
                    branchcode     => $item->homebranch,
                    borrowernumber => $patron->borrowernumber,
                    biblionumber   => $item->biblionumber,
                    priority       => 1,
                }
            )
        );

        is(
            $hold->item_level_hold, 0,
            'item_level_hold should not be set when AddReserve is called without a specific item'
        );

        # Mark it waiting
        $hold->set( { itemnumber => $item->itemnumber } )->set_waiting();
        $hold->set_waiting();

        isnt( $hold->waitingdate, undef, "'waitingdate' set" );
        is( $hold->priority, 0, "'priority' set to 0" );
        ok( $hold->is_waiting, 'Hold set to waiting' );

        # Revert the found status
        $hold->revert_found();

        is( $hold->waitingdate, undef, "'waitingdate' reset" );
        ok( !$hold->is_waiting, 'Hold no longer set to waiting' );
        is( $hold->priority,   1,     "'priority' set to 1" );
        is( $hold->itemnumber, undef, "'itemnumber' unset" );

        $schema->storage->txn_rollback;
    };

    subtest 'priority shift tests' => sub {

        plan tests => 4;

        $schema->storage->txn_begin;

        # Create the items and patrons we need
        my $library = $builder->build_object( { class => 'Koha::Libraries' } );
        my $itype   = $builder->build_object( { class => "Koha::ItemTypes", value => { notforloan => 0 } } );
        my $item    = $builder->build_sample_item(
            {
                itype   => $itype->itemtype,
                library => $library->branchcode
            }
        );
        my $patron_1 = $builder->build_object( { class => "Koha::Patrons" } );
        my $patron_2 = $builder->build_object( { class => "Koha::Patrons" } );
        my $patron_3 = $builder->build_object( { class => "Koha::Patrons" } );
        my $patron_4 = $builder->build_object( { class => "Koha::Patrons" } );

        # Place a hold on the title for both patrons
        my $hold = Koha::Holds->find(
            C4::Reserves::AddReserve(
                {
                    branchcode     => $library->branchcode,
                    borrowernumber => $patron_1->borrowernumber,
                    biblionumber   => $item->biblionumber,
                    priority       => 1,
                    itemnumber     => $item->itemnumber,
                }
            )
        );

        C4::Reserves::AddReserve(
            {
                branchcode     => $library->branchcode,
                borrowernumber => $patron_2->borrowernumber,
                biblionumber   => $item->biblionumber,
                priority       => 1,
                itemnumber     => $item->itemnumber,
            }
        );

        C4::Reserves::AddReserve(
            {
                branchcode     => $library->branchcode,
                borrowernumber => $patron_3->borrowernumber,
                biblionumber   => $item->biblionumber,
                priority       => 1,
                itemnumber     => $item->itemnumber,
            }
        );

        C4::Reserves::AddReserve(
            {
                branchcode     => $library->branchcode,
                borrowernumber => $patron_4->borrowernumber,
                biblionumber   => $item->biblionumber,
                priority       => 1,
                itemnumber     => $item->itemnumber,
            }
        );

        is( $item->biblio->holds->count, 4, '4 holds on the biblio' );

        $hold->set_waiting()->discard_changes();
        is( $hold->priority, 0, "'priority' set to 0" );

        $hold->revert_found()->discard_changes();
        is( $hold->priority, 1, "'priority' set to 1" );

        my $holds = $item->biblio->holds;
        is_deeply(
            [
                $holds->next->priority, $holds->next->priority,
                $holds->next->priority, $holds->next->priority,
            ],
            [ 1, 2, 3, 4 ],
            'priorities have been reordered'
        );

        $schema->storage->txn_rollback;
    };

    subtest 'in transit holds tests' => sub {

        plan tests => 8;

        $schema->storage->txn_begin;

        my $item   = $builder->build_sample_item;
        my $patron = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { branchcode => $item->homebranch }
            }
        );

        # Create item-level hold
        my $hold = Koha::Holds->find(
            AddReserve(
                {
                    branchcode     => $item->homebranch,
                    borrowernumber => $patron->borrowernumber,
                    biblionumber   => $item->biblionumber,
                    priority       => 1,
                    itemnumber     => $item->itemnumber,
                }
            )
        );

        # Mark it in transit
        $hold->set_transfer();

        is( $hold->priority, 0, "'priority' set to 0" );
        ok( $hold->is_in_transit, 'Hold set to in transit' );
        is( $hold->found, 'T', "'found' set to 'T'" );

        # Revert the found status
        $hold->revert_found();

        ok( !$hold->is_in_transit, 'Hold no longer set to in transit' );
        ok( !$hold->is_found,      'Hold no longer has found status' );
        is( $hold->found,    undef, "'found' reset to undef" );
        is( $hold->priority, 1,     "'priority' set to 1" );
        is(
            $hold->itemnumber, $item->itemnumber,
            'Itemnumber should not be removed when the found status is reverted'
        );

        $schema->storage->txn_rollback;
    };

    subtest 'in processing holds tests' => sub {

        plan tests => 8;

        $schema->storage->txn_begin;

        my $item   = $builder->build_sample_item;
        my $patron = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { branchcode => $item->homebranch }
            }
        );

        # Create item-level hold
        my $hold = Koha::Holds->find(
            AddReserve(
                {
                    branchcode     => $item->homebranch,
                    borrowernumber => $patron->borrowernumber,
                    biblionumber   => $item->biblionumber,
                    priority       => 1,
                    itemnumber     => $item->itemnumber,
                }
            )
        );

        # Mark it in processing
        $hold->set_processing();

        is( $hold->priority, 0, "'priority' set to 0" );
        ok( $hold->is_in_processing, 'Hold set to in processing' );
        is( $hold->found, 'P', "'found' set to 'P'" );

        # Revert the found status
        $hold->revert_found();

        ok( !$hold->is_in_processing, 'Hold no longer set to in processing' );
        ok( !$hold->is_found,         'Hold no longer has found status' );
        is( $hold->found,    undef, "'found' reset to undef" );
        is( $hold->priority, 1,     "'priority' set to 1" );
        is(
            $hold->itemnumber, $item->itemnumber,
            'Itemnumber should not be removed when the found status is reverted'
        );

        $schema->storage->txn_rollback;
    };

    subtest 'desk_id handling tests' => sub {

        plan tests => 12;

        $schema->storage->txn_begin;

        my $library = $builder->build_object( { class => 'Koha::Libraries' } );
        my $desk    = $builder->build_object(
            {
                class => 'Koha::Desks',
                value => { branchcode => $library->branchcode }
            }
        );
        my $patron = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { branchcode => $library->branchcode }
            }
        );
        my $item = $builder->build_sample_item( { library => $library->branchcode } );

        my $hold = $builder->build_object(
            {
                class => 'Koha::Holds',
                value => {
                    borrowernumber => $patron->borrowernumber,
                    biblionumber   => $item->biblionumber,
                    itemnumber     => $item->itemnumber,
                    branchcode     => $library->branchcode,
                    priority       => 1,
                    found          => undef,
                }
            }
        );

        # Test 1: Waiting hold - desk_id should be cleared
        $hold->set_waiting( $desk->desk_id );
        $hold->discard_changes;
        is( $hold->desk_id, $desk->desk_id, 'desk_id set for waiting hold' );
        ok( $hold->is_waiting, 'Hold is in waiting status' );

        $hold->revert_found();
        $hold->discard_changes;
        is( $hold->desk_id, undef, 'desk_id cleared when reverting waiting hold' );
        ok( !$hold->is_found, 'Hold is no longer in found status' );

        # Test 2: In transit hold with desk_id - desk_id should be preserved
        $hold->set_transfer();
        $hold->desk_id( $desk->desk_id )->store();    # Manually set desk_id
        $hold->discard_changes;
        is( $hold->desk_id, $desk->desk_id, 'desk_id manually set for transit hold' );
        ok( $hold->is_in_transit, 'Hold is in transit status' );

        $hold->revert_found();
        $hold->discard_changes;
        is( $hold->desk_id, $desk->desk_id, 'desk_id preserved when reverting transit hold' );

        # Test 3: In processing hold with desk_id - desk_id should be preserved
        $hold->set_processing();
        $hold->desk_id( $desk->desk_id )->store();    # Manually set desk_id
        $hold->discard_changes;
        is( $hold->desk_id, $desk->desk_id, 'desk_id manually set for processing hold' );
        ok( $hold->is_in_processing, 'Hold is in processing status' );

        $hold->revert_found();
        $hold->discard_changes;
        is( $hold->desk_id, $desk->desk_id, 'desk_id preserved when reverting processing hold' );

        # Test 4: In transit hold without desk_id - desk_id should remain NULL
        $hold->set_transfer();
        $hold->desk_id(undef)->store();               # Ensure desk_id is NULL
        $hold->discard_changes;
        is( $hold->desk_id, undef, 'desk_id is NULL for transit hold without desk_id' );

        $hold->revert_found();
        $hold->discard_changes;
        is( $hold->desk_id, undef, 'desk_id remains NULL after reverting transit hold without desk_id' );

        $schema->storage->txn_rollback;
    };
};
