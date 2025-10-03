#!/usr/bin/perl

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

use Test::More tests => 2;
use Test::NoWarnings;
use Test::MockModule;

use C4::Circulation qw( AddIssue AddReturn transferbook );
use C4::SIP::ILS;
use C4::SIP::ILS::Transaction::Checkin;

use Koha::Checkouts;
use Koha::Database;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'Real-time holds queue tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $library   = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library1  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron    = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item      = $builder->build_sample_item( { library => $library->id } );
    my $item_type = $item->item_type;
    $item_type->automatic_checkin(1)->store();

    t::lib::Mocks::mock_userenv( { branchcode => $library->id } );
    t::lib::Mocks::mock_preference( 'UpdateTotalIssuesOnCirc', 1 );
    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue',      1 );

    my $action;

    my $mock = Test::MockModule->new('Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue');
    $mock->mock(
        'enqueue',
        sub {
            my ( $self, $args ) = @_;
            my ( $package, $filename, $line ) = caller;
            is_deeply(
                $args->{biblio_ids},
                [ $item->biblionumber ],
                "$action triggers a holds queue update for the related biblio from $package at line $line"
            );
        }
    );

    # Test 1
    $action = 'AddIssue';
    AddIssue( $patron, $item->barcode, );

    # Called to remove item from the queue

    $action = 'AddReturn';
    AddReturn( $item->barcode );

    # Not called

    # Test 2
    $action = 'transferbook';
    transferbook(
        {
            barcode     => $item->barcode,
            to_branch   => $library1->branchcode,
            from_branch => $library->branchcode,
            trigger     => 'Manual',
        }
    );

    # Test 3 + 4
    $action = 'do_checkin';
    my $mockILS        = Test::MockObject->new;
    my $server         = { ils => $mockILS };
    my $sip_patron     = C4::SIP::ILS::Patron->new( $patron->cardnumber );
    my $sip_item       = C4::SIP::ILS::Item->new( $item->barcode );
    my $co_transaction = C4::SIP::ILS::Transaction::Checkout->new();
    $co_transaction->patron($sip_patron);
    $co_transaction->item($sip_item);

    # Queue rebuilt by checkout
    my $checkout       = $co_transaction->do_checkout();
    my $ci_transaction = C4::SIP::ILS::Transaction::Checkin->new();
    $ci_transaction->patron($sip_patron);
    $ci_transaction->item($sip_item);

    # Queue rebuilt on checkin
    my $checkin = $ci_transaction->do_checkin( $library->branchcode, C4::SIP::Sip::timestamp );

    # Test 5+6
    $action = 'automatic_checkin';
    AddIssue( $patron, $item->barcode, );

    # Called to remove item from the queue
    my $checkouts = Koha::Checkouts->search( { 'me.itemnumber' => $item->itemnumber } );
    $checkouts->automatic_checkin;

    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 0 );

    # Below should not generate any tests as queue is deactivated

    $action = 'AddIssue';
    AddIssue( $patron, $item->barcode, );

    # Not called

    $action = 'AddReturn';
    AddReturn( $item->barcode );

    # Not called

    $schema->storage->txn_rollback;
};
