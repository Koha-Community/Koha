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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 4;
use Test::NoWarnings;

use Koha::Database;
use Koha::File::Transports;

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'Polymorphic object creation' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    # Test SFTP transport polymorphism
    my $sftp_transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => {
                transport => 'sftp',
                name      => 'Test SFTP',
                host      => 'test.example.com',
            }
        }
    );

    is(
        ref($sftp_transport), 'Koha::File::Transport::SFTP',
        'SFTP transport should be polymorphic Koha::File::Transport::SFTP object'
    );

    can_ok( $sftp_transport, '_write_key_file' );

    # Test FTP transport polymorphism
    my $ftp_transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => {
                transport => 'ftp',
                name      => 'Test FTP',
                host      => 'ftp.example.com',
            }
        }
    );

    is(
        ref($ftp_transport), 'Koha::File::Transport::FTP',
        'FTP transport should be polymorphic Koha::File::Transport::FTP object'
    );

    can_ok( $ftp_transport, 'connect' );

    # Test Local transport polymorphism
    my $local_transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => {
                transport => 'local',
                name      => 'Test Local',
                host      => 'localhost',
            }
        }
    );

    is(
        ref($local_transport), 'Koha::File::Transport::Local',
        'Local transport should be polymorphic Koha::File::Transport::Local object'
    );

    can_ok( $local_transport, 'rename_file' );

    $schema->storage->txn_rollback;
};

subtest 'search() tests' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    # Create test transports
    my $sftp_transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'sftp', name => 'Test SFTP' }
        }
    );
    my $ftp_transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'ftp', name => 'Test FTP' }
        }
    );

    # Search for both transports
    my $transports = Koha::File::Transports->search(
        { file_transport_id => { -in => [ $sftp_transport->id, $ftp_transport->id ] } } );

    is(
        ref($transports), 'Koha::File::Transports',
        'search() should return Koha::File::Transports object'
    );

    # Check each object type from resultset
    my @objects = $transports->as_list;
    my %refs    = map { $_->transport => ref($_) } @objects;

    is(
        $refs{sftp}, 'Koha::File::Transport::SFTP',
        'SFTP object from search should be polymorphic'
    );
    is(
        $refs{ftp}, 'Koha::File::Transport::FTP',
        'FTP object from search should be polymorphic'
    );

    $schema->storage->txn_rollback;
};

subtest 'find() tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    # Create test transports
    my $sftp_transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'sftp', name => 'Test SFTP' }
        }
    );
    my $ftp_transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'ftp', name => 'Test FTP' }
        }
    );

    # Test find() returns correct polymorphic types
    my $found_sftp = Koha::File::Transports->find( $sftp_transport->id );
    my $found_ftp  = Koha::File::Transports->find( $ftp_transport->id );

    is(
        ref($found_sftp), 'Koha::File::Transport::SFTP',
        'find() should return polymorphic SFTP object'
    );
    is(
        ref($found_ftp), 'Koha::File::Transport::FTP',
        'find() should return polymorphic FTP object'
    );

    $schema->storage->txn_rollback;
};
