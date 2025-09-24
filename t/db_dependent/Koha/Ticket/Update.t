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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 5;
use t::lib::TestBuilder;

use Koha::Database;

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;

subtest 'ticket() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $ticket = $builder->build_object( { class => 'Koha::Tickets' } );
    my $update = $builder->build_object(
        {
            class => 'Koha::Ticket::Updates',
            value => { ticket_id => $ticket->id }
        }
    );

    my $linked_ticket = $update->ticket;
    is( ref($linked_ticket), 'Koha::Ticket', 'Koha::Ticket::Update->ticket returns a Koha::Ticket object' );
    is( $linked_ticket->id,  $ticket->id,    'Koha::Ticket::Update->ticket returns the right Koha::Ticket' );

    $schema->storage->txn_rollback;
};

subtest 'user() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $user   = $builder->build_object( { class => 'Koha::Patrons' } );
    my $update = $builder->build_object(
        {
            class => 'Koha::Ticket::Updates',
            value => { user_id => $user->id }
        }
    );

    my $linked_user = $update->user;
    is( ref($linked_user), 'Koha::Patron', 'Koha::Ticket::Update->user returns a Koha::Patron object' );
    is( $linked_user->id,  $user->id,      'Koha::Ticket::Update->user returns the right Koha::Patron' );

    $schema->storage->txn_rollback;
};

subtest 'assignee() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $assignee = $builder->build_object( { class => 'Koha::Patrons' } );
    my $update   = $builder->build_object(
        {
            class => 'Koha::Ticket::Updates',
            value => { assignee_id => $assignee->id }
        }
    );

    my $linked_assignee = $update->assignee;
    is( ref($linked_assignee), 'Koha::Patron', 'Koha::Ticket::Update->assignee returns a Koha::Patron object' );
    is( $linked_assignee->id,  $assignee->id,  'Koha::Ticket::Update->assignee returns the right Koha::Patron' );

    $schema->storage->txn_rollback;
};

subtest 'strings_map() tests' => sub {
    plan tests => 16;

    $schema->storage->txn_begin;

    my $status_av = $builder->build_object(
        {
            class => 'Koha::AuthorisedValues',
            value => {
                authorised_value => 'TEST',
                category         => 'TICKET_STATUS',
                lib              => 'internal description',
                lib_opac         => 'public description',
            }
        }
    );

    my $ticket_update = $builder->build_object(
        {
            class => 'Koha::Ticket::Updates',
            value => { status => 'TEST' }
        }
    );

    my $strings = $ticket_update->strings_map();
    ok( exists $strings->{status}, "'status' entry exists" );
    is( $strings->{status}->{str},      $status_av->lib, "'str' set to av->lib" );
    is( $strings->{status}->{type},     'av',            "'type' is 'av'" );
    is( $strings->{status}->{category}, 'TICKET_STATUS', "'category' exists and set to 'TICKET_STATUS'" );

    $strings = $ticket_update->strings_map( { public => 1 } );
    ok( exists $strings->{status}, "'status' entry exists when called in public" );
    is( $strings->{status}->{str},      $status_av->lib_opac, "'str' set to av->lib_opac when called in public" );
    is( $strings->{status}->{type},     'av',                 "'type' is 'av'" );
    is( $strings->{status}->{category}, 'TICKET_STATUS',      "'category' exists and set to 'TICKET_STATUS'" );

    my $resolution_av = $builder->build_object(
        {
            class => 'Koha::AuthorisedValues',
            value => {
                authorised_value => 'RES_TEST',
                category         => 'TICKET_RESOLUTION',
                lib              => 'internal resolution description',
                lib_opac         => 'public resolution description',
            }
        }
    );

    $ticket_update = $builder->build_object(
        {
            class => 'Koha::Ticket::Updates',
            value => { status => 'RES_TEST' }
        }
    );

    $strings = $ticket_update->strings_map();
    ok( exists $strings->{status}, "'status' entry exists for resolution fallthrough" );
    is( $strings->{status}->{str},      $resolution_av->lib, "'str' set to av->lib" );
    is( $strings->{status}->{type},     'av',                "'type' is 'av'" );
    is( $strings->{status}->{category}, 'TICKET_STATUS',     "'category' exists and set to 'TICKET_STATUS'" );

    $strings = $ticket_update->strings_map( { public => 1 } );
    ok( exists $strings->{status}, "'status' entry exists for resolution fallthrough when called in public" );
    is( $strings->{status}->{str},      $resolution_av->lib_opac, "'str' set to av->lib_opac when called in public" );
    is( $strings->{status}->{type},     'av',                     "'type' is 'av'" );
    is( $strings->{status}->{category}, 'TICKET_STATUS',          "'category' exists and set to 'TICKET_STATUS'" );

    $schema->storage->txn_rollback;
};
