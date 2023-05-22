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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 11;

use Test::Exception;
use Test::MockModule;

use t::lib::Mocks;
use t::lib::TestBuilder;
use t::lib::Mocks;

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

subtest 'fill() tests' => sub {

    plan tests => 14;

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
                priority       => 10,
            }
        }
    );

    t::lib::Mocks::mock_preference( 'HoldFeeMode', 'any_time_is_collected' );
    t::lib::Mocks::mock_preference( 'HoldsLog',    1 );
    t::lib::Mocks::mock_userenv(
        { patron => $manager, branchcode => $manager->branchcode } );

    my $interface = 'api';
    C4::Context->interface($interface);

    my $ret = $hold->fill;

    is( ref($ret), 'Koha::Hold', '->fill returns the object type' );
    is( $ret->id, $hold->id, '->fill returns the object' );

    is( Koha::Holds->find($hold->id), undef, 'Hold no longer current' );
    my $old_hold = Koha::Old::Holds->find( $hold->id );

    is( $old_hold->id, $hold->id, 'reserve_id retained' );
    is( $old_hold->priority, 0, 'priority set to 0' );
    is( $old_hold->found, 'F', 'found set to F' );

    subtest 'itemnumber parameter' => sub {
        plan tests => 1;
        $category->reservefee(0)->store; # do not disturb later accounts
        $hold = $builder->build_object({ class => 'Koha::Holds', value => { biblionumber => $biblio->id, borrowernumber => $patron->id, itemnumber => undef, priority => 1 } });
        # Simulating checkout without confirming hold
        $hold->fill({ itemnumber => $item->id });
        $old_hold = Koha::Old::Holds->find($hold->id);
        is( $old_hold->itemnumber, $item->itemnumber, 'The itemnumber has been saved in old_reserves by fill' );
        $old_hold->delete;
        $category->reservefee($fee)->store; # restore
    };

    subtest 'fee applied tests' => sub {

        plan tests => 9;

        my $account = $patron->account;
        is( $account->balance, $fee, 'Charge applied correctly' );

        my $debits = $account->outstanding_debits;
        is( $debits->count, 1, 'Only one fee charged' );

        my $fee_debit = $debits->next;
        is( $fee_debit->amount * 1, $fee, 'Fee amount stored correctly' );
        is( $fee_debit->description, $title,
            'Fee description stored correctly' );
        is( $fee_debit->manager_id, $manager->id,
            'Fee manager_id stored correctly' );
        is( $fee_debit->branchcode, $manager->branchcode,
            'Fee branchcode stored correctly' );
        is( $fee_debit->interface, $interface,
            'Fee interface stored correctly' );
        is( $fee_debit->debit_type_code,
            'RESERVE', 'Fee debit_type_code stored correctly' );
        is( $fee_debit->itemnumber, $item->id,
            'Fee itemnumber stored correctly' );
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
    t::lib::Mocks::mock_preference( 'HoldsLog',    0 );

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
        is( Koha::Old::Holds->find( $hold->id )->borrowernumber,
            $patron->borrowernumber, 'Patron link is kept' );

        # 1 == "default", meaning it is not protected from removal
        $patron->privacy(1)->store;
        $hold = $builder->build_object(
            {
                class => 'Koha::Holds',
                value => { borrowernumber => $patron->id, found => undef }
            }
        );
        $hold->fill();
        is( Koha::Old::Holds->find( $hold->id )->borrowernumber,
            $patron->borrowernumber, 'Patron link is kept' );

        my $anonymous_patron = $builder->build_object({ class => 'Koha::Patrons' });
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

        throws_ok
            { $hold->fill(); }
            'Koha::Exception',
            'AnonymousPatron not set, exception thrown';

        $hold->discard_changes; # refresh from DB

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

        plan tests => 1;

        my $biblio = $builder->build_sample_biblio;

        my $mock = Test::MockModule->new('Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue');
        $mock->mock( 'enqueue', sub {
            my ( $self, $args ) = @_;
            is_deeply(
                $args->{biblio_ids},
                [ $biblio->id ],
                '->fill triggers a holds queue update for the related biblio'
            );
        } );

        t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 1 );

        $builder->build_object(
            {
                class => 'Koha::Holds',
                value => {
                    biblionumber   => $biblio->id,
                }
            }
        )->fill;

        t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 0 );
        # this call shouldn't add a new test
        $builder->build_object(
            {
                class => 'Koha::Holds',
                value => {
                    biblionumber   => $biblio->id,
                }
            }
        )->fill;
    };

    $schema->storage->txn_rollback;
};

subtest 'patron() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object({ class => 'Koha::Patrons' });
    my $hold   = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                borrowernumber => $patron->borrowernumber
            }
        }
    );

    my $hold_patron = $hold->patron;
    is( ref($hold_patron), 'Koha::Patron', 'Right type' );
    is( $hold_patron->id, $patron->id, 'Right object' );

    $schema->storage->txn_rollback;
};

subtest 'set_pickup_location() tests' => sub {

    plan tests => 11;

    $schema->storage->txn_begin;

    my $mock_biblio = Test::MockModule->new('Koha::Biblio');
    my $mock_item   = Test::MockModule->new('Koha::Item');

    my $library_1 = $builder->build_object({ class => 'Koha::Libraries' });
    my $library_2 = $builder->build_object({ class => 'Koha::Libraries' });
    my $library_3 = $builder->build_object({ class => 'Koha::Libraries' });

    # let's control what Koha::Biblio->pickup_locations returns, for testing
    $mock_biblio->mock( 'pickup_locations', sub {
        return Koha::Libraries->search( { branchcode => [ $library_2->branchcode, $library_3->branchcode ] } );
    });
    # let's mock what Koha::Item->pickup_locations returns, for testing
    $mock_item->mock( 'pickup_locations', sub {
        return Koha::Libraries->search( { branchcode => [ $library_2->branchcode, $library_3->branchcode ] } );
    });

    my $biblio = $builder->build_sample_biblio;
    my $item   = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });

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

    throws_ok
        { $biblio_hold->set_pickup_location({ library_id => $library_1->branchcode }); }
        'Koha::Exceptions::Hold::InvalidPickupLocation',
        'Exception thrown on invalid pickup location';

    $biblio_hold->discard_changes;
    is( $biblio_hold->branchcode, $library_3->branchcode, 'branchcode remains untouched' );

    my $ret = $biblio_hold->set_pickup_location({ library_id => $library_2->id });
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

    throws_ok
        { $item_hold->set_pickup_location({ library_id => $library_1->branchcode }); }
        'Koha::Exceptions::Hold::InvalidPickupLocation',
        'Exception thrown on invalid pickup location';

    $item_hold->discard_changes;
    is( $item_hold->branchcode, $library_3->branchcode, 'branchcode remains untouched' );

    $item_hold->set_pickup_location({ library_id => $library_1->branchcode, force => 1 });
    $item_hold->discard_changes;
    is( $item_hold->branchcode, $library_1->branchcode, 'branchcode changed because of \'force\'' );

    $ret = $item_hold->set_pickup_location({ library_id => $library_2->id });
    is( ref($ret), 'Koha::Hold', 'self is returned' );

    $item_hold->discard_changes;
    is( $item_hold->branchcode, $library_2->id, 'Pickup location changed correctly' );

    throws_ok
        { $item_hold->set_pickup_location({ library_id => undef }); }
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

    my $library_1 = $builder->build_object({ class => 'Koha::Libraries' });
    my $library_2 = $builder->build_object({ class => 'Koha::Libraries' });
    my $library_3 = $builder->build_object({ class => 'Koha::Libraries' });

    # let's control what Koha::Biblio->pickup_locations returns, for testing
    $mock_biblio->mock( 'pickup_locations', sub {
        return Koha::Libraries->search( { branchcode => [ $library_2->branchcode, $library_3->branchcode ] } );
    });
    # let's mock what Koha::Item->pickup_locations returns, for testing
    $mock_item->mock( 'pickup_locations', sub {
        return Koha::Libraries->search( { branchcode => [ $library_2->branchcode, $library_3->branchcode ] } );
    });

    my $biblio = $builder->build_sample_biblio;
    my $item   = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });

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

    ok( !$biblio_hold->is_pickup_location_valid({ library_id => $library_1->branchcode }), 'Pickup location invalid');
    ok( $biblio_hold->is_pickup_location_valid({ library_id => $library_2->id }), 'Pickup location valid');

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

    ok( !$item_hold->is_pickup_location_valid({ library_id => $library_1->branchcode }), 'Pickup location invalid');
    ok( $item_hold->is_pickup_location_valid({ library_id => $library_2->id }), 'Pickup location valid' );

    subtest 'pickup_locations() returning ->empty' => sub {

        plan tests => 2;

        $schema->storage->txn_begin;

        my $library = $builder->build_object({ class => 'Koha::Libraries' });

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

        ok( !$biblio_hold->is_pickup_location_valid({ library_id => $library->branchcode }), 'Pickup location invalid');

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

        ok( !$item_hold->is_pickup_location_valid({ library_id => $library->branchcode }), 'Pickup location invalid');

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
    t::lib::Mocks::mock_preference( 'ExpireReservesMaxPickUpDelayCharge',
        undef );

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
    is( Koha::Old::Holds->find( $hold->id )->borrowernumber,
        $patron->borrowernumber, 'Patron link is kept' );

    # 1 == "default", meaning it is not protected from removal
    $patron->privacy(1)->store;
    $hold = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => { borrowernumber => $patron->id, found => undef }
        }
    );
    $hold->cancel();
    is( Koha::Old::Holds->find( $hold->id )->borrowernumber,
        $patron->borrowernumber, 'Patron link is kept' );

    my $anonymous_patron = $builder->build_object({ class => 'Koha::Patrons' });
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
    throws_ok
        { $hold->cancel(); }
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
        $mock->mock( 'enqueue', sub {
            my ( $self, $args ) = @_;
            is_deeply(
                $args->{biblio_ids},
                [ $biblio->id ],
                '->cancel triggers a holds queue update for the related biblio'
            );
        } );

        $builder->build_object(
            {
                class => 'Koha::Holds',
                value => {
                    biblionumber   => $biblio->id,
                }
            }
        )->cancel;

        # If the skip_holds_queue param is not honoured, then test count will fail.
        $builder->build_object(
            {
                class => 'Koha::Holds',
                value => {
                    biblionumber   => $biblio->id,
                }
            }
        )->cancel({ skip_holds_queue => 1 });

        t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 0 );

        $builder->build_object(
            {
                class => 'Koha::Holds',
                value => {
                    biblionumber   => $biblio->id,
                }
            }
        )->cancel({ skip_holds_queue => 0 });
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
    $mock->mock( 'enqueue', sub {
        my ( $self, $args ) = @_;
        is_deeply(
            $args->{biblio_ids},
            [ $biblio->id ],
            "->$action triggers a holds queue update for the related biblio"
        );
    } );

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

subtest 'cancellation_requests() and add_cancellation_request() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 0 );

    my $hold = $builder->build_object( { class => 'Koha::Holds', } );

    is( $hold->cancellation_requests->count, 0 );

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

    $schema->storage->txn_rollback;
};

subtest 'cancellation_requestable_from_opac() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $category =
      $builder->build_object( { class => 'Koha::Patron::Categories' } );
    my $item_home_library =
      $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron_home_library =
      $builder->build_object( { class => 'Koha::Libraries' } );

    my $item =
      $builder->build_sample_item( { library => $item_home_library->id } );
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

    t::lib::Mocks::mock_preference( 'ReservesControlBranch',
        'ItemHomeLibrary' );

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
        {   class => 'Koha::Holds',
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

    $hold->suspend_hold( $dt );
    is( $hold->can_update_pickup_location_opac, 0, "Suspended hold pickup can't be changed (No change allowed)" );
    $hold->resume();

    t::lib::Mocks::mock_preference( 'OPACAllowUserToChangeBranch', 'pending,intransit,suspended' );
    $hold->found(undef);
    is( $hold->can_update_pickup_location_opac, 1, "Pending hold pickup can be changed (pending,intransit,suspended allowed)" );

    $hold->found('T');
    is( $hold->can_update_pickup_location_opac, 1, "In transit hold pickup can be changed (pending,intransit,suspended allowed)" );

    $hold->found('W');
    is( $hold->can_update_pickup_location_opac, 0, "Waiting hold pickup can't be changed (pending,intransit,suspended allowed)" );

    $hold->found(undef);
    $dt = dt_from_string();
    $hold->suspend_hold( $dt );
    is( $hold->can_update_pickup_location_opac, 1, "Suspended hold pickup can be changed (pending,intransit,suspended allowed)" );

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
