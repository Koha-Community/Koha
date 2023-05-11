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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 6;
use Test::Exception;

use Koha::Database;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Checkouts::ReturnClaims;

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest "store() tests" => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object({ class => 'Koha::Patrons' });
    my $patron    = $builder->build_object({ class => 'Koha::Patrons' });
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

    throws_ok
        { Koha::Checkouts::ReturnClaim->new(
            {
                issue_id       => $checkout->id,
                itemnumber     => $checkout->itemnumber,
                borrowernumber => $checkout->borrowernumber,
                notes          => 'Some notes'
            }
          )->store }
        'Koha::Exceptions::Checkouts::ReturnClaims::NoCreatedBy',
        'Exception thrown if no created_by passed on creation';

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

    my $nullable_created_by = Koha::Checkouts::ReturnClaim->new(
        {
            issue_id       => $old_checkout->id,
            itemnumber     => $old_checkout->itemnumber,
            borrowernumber => $old_checkout->borrowernumber,
            notes          => 'Some notes',
            created_by     => $librarian->borrowernumber
        }
    )->store;
    is( $nullable_created_by->created_by, $librarian->borrowernumber, 'Claim created with created_by set' );
    ok( $nullable_created_by->in_storage, 'In storage' );

    $nullable_created_by->created_by(undef)->store();
    is( $nullable_created_by->created_by, undef, 'Deletion was deleted' );
    ok( $nullable_created_by->in_storage, 'In storage' );
    is(
        ref($nullable_created_by->notes('Some other note')->store),
        'Koha::Checkouts::ReturnClaim',
        'Subsequent store succeeds after created_by has been unset'
    );

    is( Koha::Checkouts::ReturnClaims->search({ issue_id => $checkout->id })->count, 0, 'No claims stored' );

    my $claim = Koha::Checkouts::ReturnClaim->new(
        {
            issue_id       => $checkout->id,
            itemnumber     => $checkout->itemnumber,
            borrowernumber => $checkout->borrowernumber,
            notes          => 'Some notes',
            created_by     => $librarian->borrowernumber
        }
    )->store;

    is( ref($claim), 'Koha::Checkouts::ReturnClaim', 'Object type is correct' );
    is( Koha::Checkouts::ReturnClaims->search( { issue_id => $checkout->id } )->count, 1, 'Claim stored on the DB');

    $schema->storage->txn_rollback;
};

subtest "resolve() tests" => sub {

    plan tests => 10;

    $schema->storage->txn_begin;

    my $itemlost  = 1;
    my $librarian = $builder->build_object({ class => 'Koha::Patrons' });
    my $patron    = $builder->build_object({ class => 'Koha::Patrons' });
    my $item      = $builder->build_sample_item({ itemlost => $itemlost });

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

    my $claim = Koha::Checkouts::ReturnClaim->new(
        {
            issue_id       => $checkout->id,
            itemnumber     => $checkout->itemnumber,
            borrowernumber => $checkout->borrowernumber,
            notes          => 'Some notes',
            created_by     => $librarian->borrowernumber
        }
    )->store;

    throws_ok
        { $claim->resolve({ resolution => 1 }); }
        'Koha::Exceptions::MissingParameter',
        "Not passing 'resolved_by' makes it throw an exception";

    throws_ok
        { $claim->resolve({ resolved_by => 1 }); }
        'Koha::Exceptions::MissingParameter',
        "Not passing 'resolution' makes it throw an exception";

    my $deleted_patron = $builder->build_object({ class => 'Koha::Patrons' });
    my $deleted_patron_id = $deleted_patron->id;
    $deleted_patron->delete;

    {   # hide useless warnings
        local *STDERR;
        open STDERR, '>', '/dev/null';

        throws_ok
            { $claim->resolve({ resolution => "X", resolved_by => $deleted_patron_id }) }
            'Koha::Exceptions::Object::FKConstraint',
            "Exception thrown on invalid resolver";

        close STDERR;
    }

    my $today    = dt_from_string;
    my $tomorrow = dt_from_string->add( days => 1 );

    $claim->resolve(
        {
            resolution  => "X",
            resolved_by => $librarian->id,
            resolved_on => $tomorrow,
        }
    )->discard_changes;

    is( output_pref( { str => $claim->resolved_on } ), output_pref( { dt => $tomorrow } ), 'resolved_on set to the passed param' );
    is( $claim->updated_by, $librarian->id, 'updated_by set to the passed resolved_by' );

    # Make sure $item is refreshed
    $item->discard_changes;
    is( $item->itemlost, $itemlost, 'Item lost status remains unchanged' );

    # New checkout and claim
    $checkout->delete;
    $checkout = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => {
                borrowernumber => $patron->borrowernumber,
                itemnumber     => $item->itemnumber,
                branchcode     => $patron->branchcode
            }
        }
    );

    $claim = Koha::Checkouts::ReturnClaim->new(
        {
            issue_id       => $checkout->id,
            itemnumber     => $checkout->itemnumber,
            borrowernumber => $checkout->borrowernumber,
            notes          => 'Some notes',
            created_by     => $librarian->borrowernumber
        }
    )->store;

    my $new_lost_status = 2;

    $claim->resolve(
        {
            resolution      => "X",
            resolved_by     => $librarian->id,
            resolved_on     => $tomorrow,
            new_lost_status => $new_lost_status,
        }
    )->discard_changes;

    is( output_pref( { str => $claim->resolved_on } ), output_pref( { dt => $tomorrow } ), 'resolved_on set to the passed param' );
    is( $claim->updated_by, $librarian->id, 'updated_by set to the passed resolved_by' );

    # Make sure $item is refreshed
    $item->discard_changes;
    is( $item->itemlost, $new_lost_status, 'Item lost status is updated' );

    # Resolve claim for checkout that has been cleaned from the database
    $checkout->delete;
    $checkout = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => {
                borrowernumber => $patron->borrowernumber,
                itemnumber     => $item->itemnumber,
                branchcode     => $patron->branchcode
            }
        }
    );

    $claim = Koha::Checkouts::ReturnClaim->new(
        {
            issue_id       => $checkout->id,
            itemnumber     => $checkout->itemnumber,
            borrowernumber => $checkout->borrowernumber,
            notes          => 'Some notes',
            created_by     => $librarian->borrowernumber
        }
    )->store;

    $checkout->delete;

    $claim->resolve(
        {
            resolution      => "X",
            resolved_by     => $librarian->id,
            resolved_on     => $tomorrow,
            new_lost_status => $new_lost_status,
        }
    )->discard_changes;

    is( $claim->issue_id, undef, "Resolved claim cleaned checkout is updated correctly" );

    $schema->storage->txn_rollback;
};

subtest 'item() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object({ class => 'Koha::Patrons' });
    my $patron    = $builder->build_object({ class => 'Koha::Patrons' });
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

    my $claim = Koha::Checkouts::ReturnClaim->new(
        {
            issue_id       => $checkout->id,
            itemnumber     => $checkout->itemnumber,
            borrowernumber => $checkout->borrowernumber,
            notes          => 'Some notes',
            created_by     => $librarian->borrowernumber
        }
    )->store;

    my $return_claim_item = $claim->item;
    is( ref( $return_claim_item ), 'Koha::Item', 'Koha::Checkouts::ReturnClaim->item should return a Koha::Item' );
    is( $claim->itemnumber, $return_claim_item->itemnumber, 'Koha::Checkouts::ReturnClaim->item should return the correct item' );

    my $itemnumber = $item->itemnumber;
    $checkout->delete; # Required to allow deletion of item
    $item->delete;

    my $claims = Koha::Checkouts::ReturnClaims->search({ itemnumber => $itemnumber });
    is( $claims->count, 0, 'Koha::Checkouts::ReturnClaim is deleted on item deletion' );

    $schema->storage->txn_rollback;
};

subtest 'patron() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object({ class => 'Koha::Patrons' });
    my $patron    = $builder->build_object({ class => 'Koha::Patrons' });
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

    my $claim = Koha::Checkouts::ReturnClaim->new(
        {
            issue_id       => $checkout->id,
            itemnumber     => $checkout->itemnumber,
            borrowernumber => $checkout->borrowernumber,
            notes          => 'Some notes',
            created_by     => $librarian->borrowernumber
        }
    )->store;

    my $return_claim_patron = $claim->patron;
    is( ref( $return_claim_patron ), 'Koha::Patron', 'Koha::Checkouts::ReturnClaim->patron should return a Koha::Patron' );
    is( $claim->borrowernumber, $return_claim_patron->borrowernumber, 'Koha::Checkouts::ReturnClaim->patron should return the correct borrower' );

    my $borrowernumber = $patron->borrowernumber;
    $checkout->delete; # Required to allow deletion of patron
    $patron->delete;

    my $claims = Koha::Checkouts::ReturnClaims->search({ borrowernumber => $borrowernumber });
    is( $claims->count, 0, 'Koha::Checkouts::ReturnClaim is deleted on borrower deletion' );

    $schema->storage->txn_rollback;
};

subtest 'old_checkout() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object({ class => 'Koha::Patrons' });
    my $patron    = $builder->build_object({ class => 'Koha::Patrons' });
    my $item      = $builder->build_sample_item;
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

    my $claim = Koha::Checkouts::ReturnClaim->new(
        {
            issue_id       => $old_checkout->id,
            itemnumber     => $old_checkout->itemnumber,
            borrowernumber => $old_checkout->borrowernumber,
            notes          => 'Some notes',
            created_by     => $librarian->borrowernumber
        }
    )->store;

    my $return_claim_old_checkout = $claim->old_checkout;
    is( ref( $return_claim_old_checkout ), 'Koha::Old::Checkout', 'Koha::Checkouts::ReturnClaim->old_checkout should return a Koha::Old::Checkout' );
    is( $claim->issue_id, $return_claim_old_checkout->issue_id, 'Koha::Checkouts::ReturnClaim->old_checkout should return the correct borrower' );

    my $issue_id = $old_checkout->issue_id;
    $old_checkout->delete;

    my $claims = Koha::Checkouts::ReturnClaims->search({ issue_id => $issue_id });
    is( $claims->count, 1, 'Koha::Checkouts::ReturnClaim remains on old_checkout deletion' );
    # FIXME: Should we actually set null on OldCheckout deletion?

    $claim->issue_id(undef)->store;
    is( $claim->old_checkout, undef, 'Koha::Checkouts::ReturnClaim->old_checkout should return undef if no old_checkout linked' );

    $schema->storage->txn_rollback;
};

subtest 'checkout() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object({ class => 'Koha::Patrons' });
    my $patron    = $builder->build_object({ class => 'Koha::Patrons' });
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

    my $claim = Koha::Checkouts::ReturnClaim->new(
        {
            issue_id       => $checkout->id,
            itemnumber     => $checkout->itemnumber,
            borrowernumber => $checkout->borrowernumber,
            notes          => 'Some notes',
            created_by     => $librarian->borrowernumber
        }
    )->store;

    my $return_claim_checkout = $claim->checkout;
    is( ref( $return_claim_checkout ), 'Koha::Checkout', 'Koha::Checkouts::ReturnClaim->checkout should return a Koha::Checkout' );
    is( $claim->issue_id, $return_claim_checkout->issue_id, 'Koha::Checkouts::ReturnClaim->checkout should return the correct borrower' );

    my $issue_id = $checkout->issue_id;
    $checkout->delete;

    my $claims = Koha::Checkouts::ReturnClaims->search({ issue_id => $issue_id });
    is( $claims->count, 1, 'Koha::Checkouts::ReturnClaim remains on checkout deletion' );

    $claim->issue_id(undef)->store;
    is( $claim->checkout, undef, 'Koha::Checkouts::ReturnClaim->checkout should return undef if no checkout linked' );

    $schema->storage->txn_rollback;
};
