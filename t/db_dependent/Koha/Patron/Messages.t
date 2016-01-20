#!/usr/bin/perl

# Copyright 2015 Koha Development team
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

use Test::More tests => 4;

use Koha::Patron::Message;
use Koha::Patron::Messages;
use Koha::Database;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder        = t::lib::TestBuilder->new;
my $library        = $builder->build( { source => 'Branch' } );
my $patron         = $builder->build( { source => 'Borrower', values => { branchcode => $library->{branchcode} } } );
my $nb_of_messages = Koha::Patron::Messages->search->count;
my $new_message_1  = Koha::Patron::Message->new(
    {   borrowernumber => $patron->{borrowernumber},
        branchcode     => $library->{branchcode},
        message_type   => 'L',
        message        => 'my message 1',
    }
)->store;
my $new_message_2  = Koha::Patron::Message->new(
    {   borrowernumber => $patron->{borrowernumber},
        branchcode     => $library->{branchcode},
        message_type   => 'B',
        message        => 'my message 2',
    }
)->store;

like( $new_message_1->message_id, qr|^\d+$|, 'Adding a new message should have set the message_id');
is( Koha::Patron::Messages->search->count, $nb_of_messages + 2, 'The 2 messages should have been added' );

my $retrieved_message_1 = Koha::Patron::Messages->find( $new_message_1->message_id );
is( $retrieved_message_1->message, $new_message_1->message, 'Find a message by id should return the correct message' );

$retrieved_message_1->delete;
is( Koha::Patron::Messages->search->count, $nb_of_messages + 1, 'Delete should have deleted the message' );

$schema->storage->txn_rollback;

1;
