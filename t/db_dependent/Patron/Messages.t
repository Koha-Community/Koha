#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.
#
use Modern::Perl;
use Test::More tests => 1;

use Koha::Patrons;
use Koha::Patron::Messages;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

subtest 'Delete a patron having messages' => sub {
    plan tests => 2;

    my $patron = $builder->build({ source => 'Borrower' });
    my $message = $builder->build({
        source => 'Message',
        value => {
            borrowernumber => $patron->{borrowernumber},
            message => 'This is a message.'
        }
    });

    is(Koha::Patron::Messages->find($message->{message_id})->message, 'This is a message.', 'Got the right message');

    my $patron_to_delete = Koha::Patrons->find( $patron->{borrowernumber} );
    $patron_to_delete->move_to_deleted;
    $patron_to_delete->delete;

    is(Koha::Patron::Messages->find($message->{message_id}), undef, 'Message is deleted');
};

$schema->storage->txn_rollback;