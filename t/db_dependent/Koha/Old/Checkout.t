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
use Test::More tests => 3;
use Test::Exception;

use Koha::Database;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'anonymize() tests' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    is( $patron->old_checkouts->count, 0, 'Patron has no old checkouts' );

    my $checkout_1 = $builder->build_object(
        {
            class => 'Koha::Old::Checkouts',
            value => { borrowernumber => $patron->id }
        }
    );
    my $checkout_2 = $builder->build_object(
        {
            class => 'Koha::Old::Checkouts',
            value => { borrowernumber => $patron->id }
        }
    );
    my $renewal_1 = $builder->build_object(
        {
            class => 'Koha::Checkouts::Renewals',
            value => {
                checkout_id => undef,
                interface   => 'opac',
                renewer_id  => $patron->id
            }
        }
    );
    $renewal_1->checkout_id( $checkout_2->id )->store();
    my $renewal_2 = $builder->build_object(
        {
            class => 'Koha::Checkouts::Renewals',
            value => {
                checkout_id => undef,
                interface   => 'intranet'
            }
        }
    );
    $renewal_2->checkout_id( $checkout_2->id )->store();

    is( $patron->old_checkouts->count, 2, 'Patron has 2 completed checkouts' );

    t::lib::Mocks::mock_preference( 'AnonymousPatron', undef );

    throws_ok { $checkout_1->anonymize; }
    'Koha::Exceptions::SysPref::NotSet',
        'Exception thrown because AnonymousPatron not set';

    is( $@->syspref,                   'AnonymousPatron', 'syspref parameter is correctly passed' );
    is( $patron->old_checkouts->count, 2,                 'No changes, patron has 2 linked completed checkouts' );

    is(
        $checkout_2->borrowernumber, $patron->id,
        'Checkout to anonymize still linked to patron'
    );
    is( $checkout_2->renewals->count, 2, 'Checkout 2 has 2 renewals' );

    my $anonymous_patron = $builder->build_object( { class => 'Koha::Patrons' } );
    t::lib::Mocks::mock_preference( 'AnonymousPatron', $anonymous_patron->id );

    # anonymize second checkout
    $checkout_2->anonymize;
    $checkout_2->discard_changes;
    is(
        $checkout_2->borrowernumber, $anonymous_patron->id,
        'Anonymized checkout linked to anonymouspatron'
    );
    is(
        $checkout_2->renewals->search( { renewer_id => $anonymous_patron->id } )->count,
        1,
        'OPAC renewal was anonymized'
    );

    $schema->storage->txn_rollback;
};

subtest 'deleteitem() tests' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    my $checkout_3 = $builder->build_object(
        {
            class => 'Koha::Old::Checkouts',
            value => { borrowernumber => $patron->id }
        }
    );

    # delete first checkout
    my $item_to_del = $checkout_3->item;
    $item_to_del->delete;
    $checkout_3->discard_changes();
    is( $checkout_3->item, undef, "Item is deleted" );

    $schema->storage->txn_rollback;
};
