#!/usr/bin/perl

# This file is part of Koha.
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

use Koha::SMTP::Servers;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'get_default() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $server  = Koha::SMTP::Servers->get_default;
    is( ref($server), 'Koha::SMTP::Server',
        'An object of the right type is returned' );

    ok( !$server->in_storage,
        'The default server is correctly retrieved' );

    my $unblessed_server = $server->unblessed;
    delete $unblessed_server->{id};
    is_deeply(
        $unblessed_server,
        Koha::SMTP::Servers::default_setting,
        'The default setting is returned if no user-defined default'
    );

    $schema->storage->txn_rollback;
};
