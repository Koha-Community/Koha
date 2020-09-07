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

use Test::More tests => 1;
use Test::Exception;

use Koha::Database;
use Koha::Checkouts::ReturnClaims;

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest "store() tests" => sub {

    plan tests => 8;

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
        'Exception thrown correctly';

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
