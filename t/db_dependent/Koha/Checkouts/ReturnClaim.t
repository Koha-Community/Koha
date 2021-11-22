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

use Test::More tests => 2;
use Test::Exception;

use Koha::Database;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Checkouts::ReturnClaims;

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest "store() tests" => sub {

    plan tests => 13;

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

    {   # hide useless warnings
        local *STDERR;
        open STDERR, '>', '/dev/null';
        throws_ok {
            Koha::Checkouts::ReturnClaim->new(
                {
                    issue_id       => $checkout->id,
                    itemnumber     => $checkout->itemnumber,
                    borrowernumber => $checkout->borrowernumber,
                    notes          => 'Some notes',
                    created_by     => $librarian->borrowernumber
                }
            )->store;
        }
        'Koha::Exceptions::Object::DuplicateID',
            'An exception is thrown on duplicate issue_id';
        close STDERR;

        like(
            $@->duplicate_id,
            qr/(return_claims\.)?issue_id/,
            'Exception field is correct'
        );
    }

    {    # hide useless warnings
        local *STDERR;
        open STDERR, '>', '/dev/null';

        my $another_checkout = $builder->build_object({ class => 'Koha::Checkouts' });
        my $checkout_id = $another_checkout->id;
        $another_checkout->delete;

        my $THE_claim;

        throws_ok {
            $THE_claim = Koha::Checkouts::ReturnClaim->new(
                {
                    issue_id       => $checkout_id,
                    itemnumber     => $checkout->itemnumber,
                    borrowernumber => $checkout->borrowernumber,
                    notes          => 'Some notes',
                    created_by     => $librarian->borrowernumber
                }
            )->store;
        }
        'Koha::Exceptions::Object::FKConstraint',
          'An exception is thrown on invalid issue_id';
        close STDERR;

        is( $@->broken_fk, 'issue_id', 'Exception field is correct' );
    }

    $schema->storage->txn_rollback;
};

subtest "resolve() tests" => sub {

    plan tests => 9;

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

    $schema->storage->txn_rollback;
};
