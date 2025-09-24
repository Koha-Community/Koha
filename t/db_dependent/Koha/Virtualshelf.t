#!/usr/bin/perl

# Copyright 2022 Koha Development team
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
use Test::More tests => 2;
use Test::Exception;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'transfer_ownership() tests' => sub {

    plan tests => 13;

    $schema->storage->txn_begin;

    my $patron_1 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron_2 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron_3 = $builder->build_object( { class => 'Koha::Patrons' } );

    my $public_list = $builder->build_object(
        {
            class => "Koha::Virtualshelves",
            value => { owner => $patron_1->id, public => 1 }
        }
    );

    my $private_list = $builder->build_object(
        {
            class => "Koha::Virtualshelves",
            value => { owner => $patron_1->id, public => 0 }
        }
    );

    throws_ok { $public_list->transfer_ownership }
    'Koha::Exceptions::MissingParameter',
        'Exception thrown if missing parameter';

    like( "$@", qr/Mandatory parameter 'patron' missing/, 'Exception string as expected' );

    # add shares
    $builder->build_object(
        {
            class => 'Koha::Virtualshelfshares',
            value => { shelfnumber => $public_list->id, invitekey => undef, borrowernumber => $patron_2->id }
        }
    );
    $builder->build_object(
        {
            class => 'Koha::Virtualshelfshares',
            value => { shelfnumber => $private_list->id, invitekey => undef, borrowernumber => $patron_2->id }
        }
    );
    $builder->build_object(
        {
            class => 'Koha::Virtualshelfshares',
            value => { shelfnumber => $private_list->id, invitekey => undef, borrowernumber => $patron_3->id }
        }
    );

    $public_list->transfer_ownership( $patron_2->id );
    $public_list->discard_changes;

    is( $public_list->owner, $patron_2->id, 'Owner changed correctly' );
    my $public_list_shares = $public_list->get_shares;
    is( $public_list_shares->count,                1,             'Count is correct' );
    is( $public_list_shares->next->borrowernumber, $patron_2->id, "Public lists don't get the share removed" );

    $private_list->transfer_ownership( $patron_2->id );
    $private_list->discard_changes;

    is( $private_list->owner, $patron_2->id );
    my $private_list_shares = $private_list->get_shares;
    is( $private_list_shares->count, 1, 'Count is correct' );
    is(
        $private_list_shares->next->borrowernumber, $patron_3->id,
        "Private lists get the share for the new owner removed"
    );

    my %params;
    my $mocked_letters = Test::MockModule->new('C4::Letters');
    $mocked_letters->mock(
        'GetPreparedLetter',
        sub {
            %params = @_;
            return 1;
        }
    );
    $mocked_letters->mock(
        'EnqueueLetter',
        sub {
            return 1;
        }
    );

    $public_list->transfer_ownership( $patron_1->id );
    $public_list->discard_changes;

    is( $params{module},      "lists",              "Enqueued letter with module lists correctly" );
    is( $params{letter_code}, "TRANSFER_OWNERSHIP", "Enqueued letter with code TRANSFER_OWNERSHIP correctly" );
    is(
        $params{objects}->{old_owner}->borrowernumber, $patron_2->borrowernumber,
        "old_owner passed to enqueue letter correctly"
    );
    is(
        $params{objects}->{owner}->borrowernumber, $patron_1->borrowernumber,
        "owner passed to enqueue letter correctly"
    );
    is( $params{objects}->{shelf}->shelfnumber, $public_list->shelfnumber, "shelf passed to enqueue letter correctly" );

    $schema->storage->txn_rollback;
};
