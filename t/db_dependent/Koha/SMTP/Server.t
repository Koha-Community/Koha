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

use Test::More tests => 2;
use Test::Exception;
use Test::Warn;

use Koha::SMTP::Servers;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'transport() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $server = $builder->build_object(
        {
            class => 'Koha::SMTP::Servers',
            value => { ssl_mode => 'disabled' }
        }
    );

    my $transport = $server->transport;

    is( ref($transport), 'Email::Sender::Transport::SMTP', 'Type is correct' );
    is( $transport->ssl, 0, 'SSL is not set' );

    $server->set({ ssl_mode => '1' })->store;
    $transport = $server->transport;

    is( ref($transport), 'Email::Sender::Transport::SMTP', 'Type is correct' );
    is( $transport->ssl, '1', 'SSL is set' );

    $schema->storage->txn_rollback;
};

subtest 'is_system_default() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $smtp_server = $builder->build_object({ class => 'Koha::SMTP::Servers' });
    ok( !$smtp_server->is_system_default, 'A generated server is not the system default' );

    my $system_default_server = Koha::SMTP::Servers->get_default;
    ok( $system_default_server->is_system_default, 'The server returned by get_default is the system default' );

    $schema->storage->txn_rollback;
};
