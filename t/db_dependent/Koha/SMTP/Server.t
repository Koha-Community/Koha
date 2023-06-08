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

use Test::More tests => 4;
use Test::Exception;
use Test::Warn;

use Koha::SMTP::Servers;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'transport() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $server = $builder->build_object(
        {
            class => 'Koha::SMTP::Servers',
            value => { ssl_mode => 'disabled', debug => 0 }
        }
    );

    my $transport = $server->transport;

    is( ref($transport), 'Email::Sender::Transport::SMTP::Persistent', 'Type is correct' );
    is( $transport->ssl, 0, 'SSL is not set' );

    $server->set({ ssl_mode => '1' })->store;
    $transport = $server->transport;

    is( ref($transport), 'Email::Sender::Transport::SMTP::Persistent', 'Type is correct' );
    is( $transport->ssl, '1', 'SSL is set' );
    is( $transport->debug, '0', 'Debug setting honoured (disabled)' );

    $server->set({ debug => 1 })->store;
    $transport = $server->transport;

    is( $transport->debug, '1', 'Debug setting honoured (enabled)' );

    $schema->storage->txn_rollback;
};

subtest 'is_system_default() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    Koha::SMTP::Servers->search()->delete();

    my $smtp_server = $builder->build_object(
        {
            class => 'Koha::SMTP::Servers',
            value => { is_default => 0 }
        }
    );

    ok( !$smtp_server->is_system_default, 'A generated server is not the system default' );

    my $system_default_server = Koha::SMTP::Servers->get_default;
    ok( $system_default_server->is_system_default, 'The server returned by get_default is the system default' );

    $smtp_server = $builder->build_object(
        {
            class => 'Koha::SMTP::Servers',
            value => { ssl_mode => 'disabled', debug => 0, is_default => 1 }
        }
    );
    is( Koha::SMTP::Servers->get_default->id, $smtp_server->id, "Default server correctly retrieved from database" );

    $schema->storage->txn_rollback;
};

subtest 'to_api() tests' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $smtp_server = $builder->build_object({ class => 'Koha::SMTP::Servers' });
    ok( !exists $smtp_server->to_api->{password}, 'Password is not part of the API representation' );

    $schema->storage->txn_rollback;
};

subtest 'store() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    Koha::SMTP::Servers->search->delete;

    my $server_1 = $builder->build_object(
        { class => 'Koha::SMTP::Servers', value => { is_default => 0 } } );
    my $server_2 = $builder->build_object(
        { class => 'Koha::SMTP::Servers', value => { is_default => 0 } } );
    my $server_3 = $builder->build_object(
        { class => 'Koha::SMTP::Servers', value => { is_default => 1 } } );

    my $default_servers = Koha::SMTP::Servers->search( { is_default => 1 } );

    is( $default_servers->count,    1,             'Only one default server' );
    is( $default_servers->next->id, $server_3->id, 'Server 3 is the default' );

    $server_1->set( { is_default => 1 } )->store->discard_changes;

    $default_servers = Koha::SMTP::Servers->search( { is_default => 1 } );

    is( $default_servers->count,    1,             'Only one default server' );
    is( $default_servers->next->id, $server_1->id, 'Server 1 is the default' );

    $schema->storage->txn_rollback;
};
