#!/usr/bin/perl

# Copyright 2017 Koha-Suomi Oy
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

use Test::More tests => 2;

use Koha::Database;

my $schema  = Koha::Database->new->schema;

subtest 'Test class imports' => sub {
    plan tests => 2;

    use_ok('Koha::Patron::MessagePreference::Transport::Type');
    use_ok('Koha::Patron::MessagePreference::Transport::Types');
};

subtest 'Test Koha::Patron::MessagePreference::Transport::Types' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $transport_type = Koha::Patron::MessagePreference::Transport::Type->new({
        message_transport_type => 'test'
    })->store;

    is($transport_type->message_transport_type, 'test',
       'Added a new message transport type.');

    $transport_type->delete;
    is(Koha::Patron::MessagePreference::Transport::Types->find('test'), undef,
       'Deleted the message transport type.');

    $schema->storage->txn_rollback;
};

1;
