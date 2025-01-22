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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 2;
use Test::Exception;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'disown_or_delete() tests' => sub {

    plan tests => 3;

    subtest 'All set cases' => sub {

        plan tests => 6;

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

        my $private_list_shared = $builder->build_object(
            {
                class => "Koha::Virtualshelves",
                value => { owner => $patron_1->id, public => 0 }
            }
        );

        # add share
        $builder->build_object(
            {
                class => 'Koha::Virtualshelfshares',
                value =>
                    { shelfnumber => $private_list_shared->id, invitekey => undef, borrowernumber => $patron_3->id }
            }
        );

        t::lib::Mocks::mock_preference( 'ListOwnershipUponPatronDeletion', 'transfer' );
        t::lib::Mocks::mock_preference( 'ListOwnerDesignated',             $patron_2->id );

        my $rs = Koha::Virtualshelves->search(
            { shelfnumber => [ $public_list->id, $private_list->id, $private_list_shared->id ] } );

        my $result = $rs->disown_or_delete;
        is( ref($result), 'Koha::Virtualshelves', 'Return type is correct' );
        $rs->reset;

        is( $rs->count, 2, 'The private/non-shared list was deleted' );
        my $first = $rs->next;
        is( $first->id,    $public_list->id );
        is( $first->owner, $patron_2->id );

        my $second = $rs->next;
        is( $second->id,    $private_list_shared->id );
        is( $second->owner, $patron_2->id );

        $schema->storage->txn_rollback;
    };

    subtest 'Fallback to userenv' => sub {

        plan tests => 7;

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

        my $private_list_shared = $builder->build_object(
            {
                class => "Koha::Virtualshelves",
                value => { owner => $patron_1->id, public => 0 }
            }
        );

        # add share
        $builder->build_object(
            {
                class => 'Koha::Virtualshelfshares',
                value =>
                    { shelfnumber => $private_list_shared->id, invitekey => undef, borrowernumber => $patron_2->id }
            }
        );

        t::lib::Mocks::mock_preference( 'ListOwnershipUponPatronDeletion', 'transfer' );
        t::lib::Mocks::mock_preference( 'ListOwnerDesignated',             undef );

        my $public_list_to_delete = $builder->build_object(
            {
                class => "Koha::Virtualshelves",
                value => { owner => $patron_1->id, public => 1 }
            }
        );

        my $rs     = Koha::Virtualshelves->search( { shelfnumber => $public_list_to_delete->id } );
        my $result = $rs->disown_or_delete;
        is( ref($result), 'Koha::Virtualshelves', 'Return type is correct' );
        $rs->reset;

        is( $rs->count, 0, 'ListOwnerDesignated and userenv not set yield deletion' );

        t::lib::Mocks::mock_userenv( { patron => $patron_3 } );

        $rs = Koha::Virtualshelves->search(
            { shelfnumber => [ $public_list->id, $private_list->id, $private_list_shared->id ] } );

        $rs->disown_or_delete;
        $rs->reset;

        is( $rs->count, 2, 'The private/non-shared list was deleted' );
        my $first = $rs->next;
        is( $first->id,    $public_list->id );
        is( $first->owner, $patron_3->id );

        my $second = $rs->next;
        is( $second->id,    $private_list_shared->id );
        is( $second->owner, $patron_3->id );

        $schema->storage->txn_rollback;
    };

    subtest 'ListOwnershipUponPatronDeletion set to delete' => sub {

        plan tests => 2;

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

        my $private_list_shared = $builder->build_object(
            {
                class => "Koha::Virtualshelves",
                value => { owner => $patron_1->id, public => 0 }
            }
        );

        # add share
        $builder->build_object(
            {
                class => 'Koha::Virtualshelfshares',
                value =>
                    { shelfnumber => $private_list_shared->id, invitekey => undef, borrowernumber => $patron_2->id }
            }
        );

        t::lib::Mocks::mock_preference( 'ListOwnershipUponPatronDeletion', 'delete' );

        my $rs = Koha::Virtualshelves->search(
            { shelfnumber => [ $public_list->id, $private_list->id, $private_list_shared->id ] } );

        my $result = $rs->disown_or_delete;
        is( ref($result), 'Koha::Virtualshelves', 'Return type is correct' );
        $rs->reset;

        is( $rs->count, 0, 'All lists deleted' );

        $schema->storage->txn_rollback;
    };
};
