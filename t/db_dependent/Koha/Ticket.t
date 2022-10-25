#!/usr/bin/perl

# Copyright 2023 Koha Development team
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

use Test::More tests => 5;
use t::lib::TestBuilder;

use Koha::Database;

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;

subtest 'reporter() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $patron  = $builder->build_object({ class => 'Koha::Patrons' });
    my $ticket = $builder->build_object(
        {
            class => 'Koha::Tickets',
            value => {
                reporter_id => $patron->id
            }
        }
    );

    my $reporter = $ticket->reporter;
    is( ref($reporter), 'Koha::Patron', 'Koha::Ticket->reporter returns a Koha::Patron object' );
    is( $reporter->id, $patron->id, 'Koha::Ticket->reporter returns the right Koha::Patron' );

    $schema->storage->txn_rollback;
};

subtest 'resolver() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $patron  = $builder->build_object({ class => 'Koha::Patrons' });
    my $ticket = $builder->build_object(
        {
            class => 'Koha::Tickets',
            value => {
                resolver_id => $patron->id
            }
        }
    );

    my $resolver = $ticket->resolver;
    is( ref($resolver), 'Koha::Patron', 'Koha::Ticket->resolver returns a Koha::Patron object' );
    is( $resolver->id, $patron->id, 'Koha::Ticket->resolver returns the right Koha::Patron' );

    $schema->storage->txn_rollback;
};

subtest 'biblio() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $biblio  = $builder->build_object({ class => 'Koha::Biblios' });
    my $ticket = $builder->build_object(
        {
            class => 'Koha::Tickets',
            value => {
                biblio_id => $biblio->id
            }
        }
    );

    my $related_biblio = $ticket->biblio;
    is( ref($related_biblio), 'Koha::Biblio', 'Koha::Ticket->biblio returns a Koha::Biblio object' );
    is( $related_biblio->id, $biblio->id, 'Koha::Ticket->biblio returns the right Koha::Biblio' );

    $schema->storage->txn_rollback;
};

subtest 'updates() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $ticket = $builder->build_object( { class => 'Koha::Tickets' } );
    my $updates = $ticket->updates;
    is( ref($updates), 'Koha::Ticket::Updates', 'Koha::Ticket->updates should return a Koha::Ticket::Updates object' );
    is( $updates->count, 0, 'Koha::Ticket->updates should return a count of 0 when there are no related updates' );

    # Add two updates
    foreach (1..2) {
        $builder->build_object(
            {
                class => 'Koha::Ticket::Updates',
                value => { ticket_id => $ticket->id }
            }
        );
    }

    $updates = $ticket->updates;
    is( ref($updates), 'Koha::Ticket::Updates', 'Koha::Ticket->updates should return a Koha::Ticket::Updates object' );
    is( $updates->count, 2, 'Koha::Ticket->updates should return the correct number of updates' );

    $schema->storage->txn_rollback;
};

subtest 'add_update() tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    my $ticket = $builder->build_object( { class => 'Koha::Tickets' } );
    my $update = $ticket->add_update(
        { user_id => $patron->id, public => 1, message => "Some message" } );
    is( ref($update), 'Koha::Ticket::Update',
        'Koha::Ticket->add_update should return a Koha::Ticket::Update object'
    );

    my $updates = $ticket->updates;
    is( $updates->count, 1,
        'Koha::Ticket->add_update should have added 1 update linked to this ticket'
    );

    $schema->storage->txn_rollback;
};
