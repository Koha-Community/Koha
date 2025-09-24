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
use Test::More tests => 5;
use Test::Exception;

use Koha::Database;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Checkouts::Renewal;
use Koha::Checkouts::Renewals;

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest "store() tests" => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron    = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item      = $builder->build_sample_item;

    my $checkout = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => {
                borrowernumber => $patron->borrowernumber,
                itemnumber     => $item->itemnumber,
                branchcode     => $patron->branchcode
            }
        }
    );

    my $old_checkout = $builder->build_object(
        {
            class => 'Koha::Old::Checkouts',
            value => {
                borrowernumber => $patron->borrowernumber,
                itemnumber     => $item->itemnumber,
                branchcode     => $patron->branchcode
            }
        }
    );

    throws_ok {
        Koha::Checkouts::Renewal->new( { interface => 'intranet' } )->store()
    }
    'Koha::Exceptions::Object::FKConstraint',
        'Exception thrown if no checkout_id is passed on creation';

    my $renewal = Koha::Checkouts::Renewal->new(
        {
            checkout_id => $checkout->id,
            renewer_id  => $librarian->borrowernumber,
            interface   => 'intranet'
        }
    )->store;

    is( ref($renewal), 'Koha::Checkouts::Renewal', 'Object type is correct' );
    is(
        Koha::Checkouts::Renewals->search( { checkout_id => $checkout->id } )->count,
        1,
        'Renewal stored on the DB'
    );

    my $another_checkout = $builder->build_object( { class => 'Koha::Checkouts' } );
    my $checkout_id      = $another_checkout->id;
    $another_checkout->delete;

    throws_ok {
        Koha::Checkouts::Renewal->new(
            {
                checkout_id => $checkout_id,
                interface   => 'intranet'
            }
        )->store;
    }
    'Koha::Exceptions::Object::FKConstraint',
        'An exception is thrown on invalid checkout_id';

    is( $@->broken_fk, 'checkout_id', 'Exception field is correct' );

    $schema->storage->txn_rollback;
};

subtest 'renewer() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron    = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item      = $builder->build_sample_item;
    my $checkout  = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => {
                borrowernumber => $patron->borrowernumber,
                itemnumber     => $item->itemnumber,
                branchcode     => $patron->branchcode
            }
        }
    );

    my $renewal = Koha::Checkouts::Renewal->new(
        {
            checkout_id => $checkout->id,
            renewer_id  => $librarian->id,
            interface   => 'intranet'
        }
    )->store;

    my $renewal_renewer_patron = $renewal->renewer;
    is(
        ref($renewal_renewer_patron),
        'Koha::Patron',
        'Koha::Checkouts::Renewal->renewer should return a Koha::Patron'
    );
    is(
        $renewal->renewer_id, $renewal_renewer_patron->borrowernumber,
        'Koha::Checkouts::Renewal->renewer should return the correct borrower'
    );

    my $checkout_id = $checkout->id;
    $librarian->delete;
    my $renewals = Koha::Checkouts::Renewals->search( { checkout_id => $checkout_id } );
    is(
        $renewals->count, 1,
        'Koha::Checkouts::Renewal is not deleted on librarian deletion'
    );

    $schema->storage->txn_rollback;
};

subtest 'checkout() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron    = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item      = $builder->build_sample_item;
    my $checkout  = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => {
                borrowernumber => $patron->borrowernumber,
                itemnumber     => $item->itemnumber,
                branchcode     => $patron->branchcode
            }
        }
    );

    my $renewal = Koha::Checkouts::Renewal->new(
        {
            checkout_id => $checkout->id,
            renewer_id  => $librarian->id,
            interface   => 'intranet'
        }
    )->store;

    my $renewal_checkout = $renewal->checkout;
    is(
        ref($renewal_checkout), 'Koha::Checkout',
        'Koha::Checkouts::Renewal->checkout should return a Koha::Checkout'
    );
    is(
        $renewal->checkout_id, $renewal_checkout->id,
        'Koha::Checkouts::Renewal->checkout should return the correct checkout'
    );

    my $issue_id = $checkout->issue_id;
    $checkout->delete;

    my $renewals = Koha::Checkouts::Renewals->search( { checkout_id => $issue_id } );
    is(
        $renewals->count, 1,
        'Koha::Checkouts::Renewal remains on checkout deletion'
    );

    $renewal->discard_changes;
    is(
        $renewal->checkout, undef,
        'Koha::Checkouts::Renewal->checkout should return undef if checkout has been deleted'
    );

    $schema->storage->txn_rollback;
};

subtest 'old_checkout() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $librarian    = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron       = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item         = $builder->build_sample_item;
    my $old_checkout = $builder->build_object(
        {
            class => 'Koha::Old::Checkouts',
            value => {
                borrowernumber => $patron->borrowernumber,
                itemnumber     => $item->itemnumber,
                branchcode     => $patron->branchcode
            }
        }
    );

    my $renewal = Koha::Checkouts::Renewal->new(
        {
            checkout_id => $old_checkout->id,
            renewer_id  => $librarian->id,
            interface   => 'intranet'
        }
    )->store;

    my $renewal_old_checkout = $renewal->old_checkout;
    is(
        ref($renewal_old_checkout), 'Koha::Old::Checkout',
        'Koha::Checkouts::Renewal->old_checkout should return a Koha::Old::Checkout'
    );
    is(
        $renewal->checkout_id, $renewal_old_checkout->id,
        'Koha::Checkouts::Renewal->old_checkout should return the correct old checkout'
    );

    my $issue_id = $old_checkout->issue_id;
    $old_checkout->delete;

    my $renewals = Koha::Checkouts::Renewals->search( { checkout_id => $issue_id } );
    is(
        $renewals->count, 1,
        'Koha::Checkouts::Renewal remains on old_checkout deletion'
    );

    # FIXME: Should we actually set null on OldCheckout deletion?

    $renewal->discard_changes;
    is(
        $renewal->old_checkout, undef,
        'Koha::Checkouts::Renewal->old_checkout should return undef if old_checkout has been deleted'
    );

    $schema->storage->txn_rollback;
};
