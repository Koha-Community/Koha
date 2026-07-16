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

use Test::More tests => 9;
use Test::Exception;
use Test::NoWarnings;
use Test::Warn;
use Test::MockModule;

use Koha::File::Transports;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'scalar context in authentication tests' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    # Test 1: Transport with no password - plain_text_password should return undef in scalar context
    my $transport_no_pass = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'ftp', password => undef }
        }
    );

    # Mock Net::FTP to verify parameters passed to login()
    my $login_called = 0;
    my @login_params;
    my $mock_ftp = Test::MockModule->new('Net::FTP');
    $mock_ftp->mock(
        'new',
        sub {
            my $class = shift;
            return bless {}, $class;
        }
    );
    $mock_ftp->mock(
        'login',
        sub {
            $login_called = 1;
            @login_params = @_;
            return 1;
        }
    );
    $mock_ftp->mock( 'quit',    sub { return 1; } );
    $mock_ftp->mock( 'abort',   sub { return 1; } );
    $mock_ftp->mock( 'status',  sub { return 0; } );
    $mock_ftp->mock( 'message', sub { return ''; } );

    # Test that plain_text_password returns undef when no password set
    is(
        scalar $transport_no_pass->plain_text_password, undef,
        'plain_text_password returns undef in scalar context when no password'
    );

    # Test 2: Attempt connection with no password - should pass undef not empty list
    $transport_no_pass->connect;
    is( $login_called,        1,     'login was called' );
    is( scalar @login_params, 3,     'login called with correct number of parameters (self, user, password)' );
    is( $login_params[2],     undef, 'password parameter is undef, not empty list' );

    # Clean up connection to avoid warnings in DESTROY
    $transport_no_pass->{connection} = undef;

    $schema->storage->txn_rollback;
};

subtest 'connect() tests' => sub {
    plan tests => 1;

    my $transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'ftp', password => 'testpass' }
        }
    );

    can_ok( $transport, 'connect' );
};

subtest 'upload_file() tests' => sub {
    plan tests => 1;
    my $transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'ftp', password => 'testpass' }
        }
    );

    can_ok( $transport, 'upload_file' );
};

subtest 'download_file() tests' => sub {
    plan tests => 1;
    my $transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'ftp', password => 'testpass' }
        }
    );

    can_ok( $transport, 'download_file' );
};

subtest 'change_directory() tests' => sub {
    plan tests => 1;
    my $transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'ftp', password => 'testpass' }
        }
    );

    can_ok( $transport, 'change_directory' );
};

subtest 'current_directory() tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'ftp', password => 'testpass' }
        }
    );

    can_ok( $transport, 'current_directory' );

    # Net::FTP's own cwd() is a mutator (no-arg means "change to /" and
    # returns a boolean) - current_directory() must read pwd(), the real
    # read-only accessor, never cwd().
    my $mock_ftp = Test::MockModule->new('Net::FTP');
    $mock_ftp->mock( 'pwd', sub { return '/incoming/'; } );
    $mock_ftp->mock( 'cwd', sub { die 'cwd() must not be called by current_directory()'; } );

    $transport->{connection}          = bless {}, 'Net::FTP';
    $transport->{_user_set_directory} = 1;

    is( $transport->current_directory, '/incoming/', 'current_directory() reads pwd(), not cwd()' );

    $transport->{connection} = undef;

    $schema->storage->txn_rollback;
};

subtest 'list_files() MLSD tests' => sub {
    plan tests => 16;

    $schema->storage->txn_begin;

    my $transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'ftp', password => 'testpass' }
        }
    );

    can_ok( $transport, 'list_files' );

    # MLSD output: "facts filename" per RFC 3659. Facts are locale-independent,
    # the filename is everything after the facts and a single space (so spaces
    # in filenames are handled), and cdir/pdir entries must be skipped while
    # real subdirectories (type=dir) are now included.
    my @mlsd_output = (
        'type=file;size=1234;modify=20250101120000;perm=adfr; QUOTES_413514.CEQ',
        'type=file;size=4096;modify=20250214093000;UNIX.mode=0644; INVOICE_99.CEI',
        'type=dir;modify=20250303080000;perm=cpmel; subdir',
        'type=cdir;modify=20250303080000; .',
        'type=pdir;modify=20250303080000; ..',
        'type=file;size=55;modify=20250405091000; name with spaces.CEA',
    );

    my $mock_ftp = Test::MockModule->new('Net::FTP');
    $mock_ftp->mock( '_list_cmd', sub { my ( $s, $cmd ) = @_; return $cmd eq 'MLSD' ? [@mlsd_output] : undef; } );
    $mock_ftp->mock( 'ls',        sub { die 'MLSD succeeded, fallback ls() must not be called'; } );
    $mock_ftp->mock( 'pwd',       sub { return '/incoming/'; } );

    # Pretend we are already connected so list_files() skips (re)connection
    $transport->{connection}          = bless {}, 'Net::FTP';
    $transport->{_user_set_directory} = 1;

    my $files = $transport->list_files();

    is( ref($files), 'ARRAY', 'list_files() returns an arrayref' );

    my @names = sort map { $_->{filename} } @{$files};
    is( scalar @names, 4, 'cdir and pdir entries are skipped, dir entries are now included' );

    is_deeply(
        \@names,
        [ 'INVOICE_99.CEI', 'QUOTES_413514.CEQ', 'name with spaces.CEA', 'subdir' ],
        'filenames parsed from MLSD, spaces preserved'
    );

    my ($quote)   = grep { $_->{filename} eq 'QUOTES_413514.CEQ' } @{$files};
    my ($invoice) = grep { $_->{filename} eq 'INVOICE_99.CEI' } @{$files};
    my ($subdir)  = grep { $_->{filename} eq 'subdir' } @{$files};
    my ($spaced)  = grep { $_->{filename} eq 'name with spaces.CEA' } @{$files};

    is( $quote->{size},  1234,       'size fact parsed correctly' );
    is( $quote->{type},  'file',     'type=file fact maps to "file"' );
    is( $quote->{perms}, '0666',     'perm-only fact (adfr: read+write) approximated to octal' );
    is( $quote->{mtime}, 1735732800, 'modify fact (2025-01-01 12:00:00 UTC) parsed into mtime' );

    is( $invoice->{perms}, '0644',     'UNIX.mode fact used verbatim when present' );
    is( $invoice->{type},  'file',     'type=file fact maps to "file"' );
    is( $invoice->{mtime}, 1739525400, 'modify fact (2025-02-14 09:30:00 UTC) parsed into mtime' );

    is( $subdir->{type},  'directory', 'type=dir fact maps to "directory"' );
    is( $subdir->{perms}, '0111',      'perm-only fact (cpmel: execute via e) approximated to octal' );
    is( $subdir->{mtime}, 1740988800,  'modify fact is parsed into mtime for directories too' );

    is( $spaced->{perms}, undef,      'entries with neither perm nor UNIX.mode fact get undef perms' );
    is( $spaced->{mtime}, 1743844200, 'modify fact still parsed into mtime when perms is undef' );

    $transport->{connection} = undef;

    $schema->storage->txn_rollback;
};

subtest 'list_files() NLST fallback tests' => sub {
    plan tests => 11;

    $schema->storage->txn_begin;

    my $transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'ftp', password => 'testpass' }
        }
    );

    # Server without MLSD support: _list_cmd('MLSD') returns nothing, so
    # list_files() must fall back to NLST (ls) and probe each entry with
    # SIZE/MDTM (plain Net::FTP methods) for size/mtime/type.
    my $ls_called = 0;
    my $mock_ftp  = Test::MockModule->new('Net::FTP');
    $mock_ftp->mock( '_list_cmd', sub { return; } );
    $mock_ftp->mock(
        'ls',
        sub { $ls_called = 1; return [ 'QUOTES_1.CEQ', '.', '..', 'INVOICE_2.CEI', 'subdir' ]; }
    );
    $mock_ftp->mock( 'pwd', sub { return '/incoming/'; } );
    $mock_ftp->mock(
        'size',
        sub {
            my ( $s, $name ) = @_;
            return { 'QUOTES_1.CEQ' => 100, 'INVOICE_2.CEI' => 200 }->{$name};
        }
    );
    $mock_ftp->mock(
        'mdtm',
        sub {
            my ( $s, $name ) = @_;
            return { 'QUOTES_1.CEQ' => 1700000000, 'INVOICE_2.CEI' => 1700000100 }->{$name};
        }
    );

    $transport->{connection}          = bless {}, 'Net::FTP';
    $transport->{_user_set_directory} = 1;

    my $files = $transport->list_files();

    is( $ls_called, 1, 'falls back to ls() when MLSD is unsupported' );

    my @names = sort map { $_->{filename} } @{$files};
    is( scalar @names, 3, 'current/parent dir entries filtered from NLST output' );
    is_deeply(
        \@names,
        [ 'INVOICE_2.CEI', 'QUOTES_1.CEQ', 'subdir' ],
        'bare filenames returned from NLST fallback, including the directory'
    );

    my ($quote)   = grep { $_->{filename} eq 'QUOTES_1.CEQ' } @{$files};
    my ($invoice) = grep { $_->{filename} eq 'INVOICE_2.CEI' } @{$files};
    my ($subdir)  = grep { $_->{filename} eq 'subdir' } @{$files};

    is( $quote->{type},  'file',     'SIZE succeeding means type "file"' );
    is( $quote->{size},  100,        'size populated via SIZE probe' );
    is( $quote->{mtime}, 1700000000, 'mtime populated via MDTM probe' );

    is( $invoice->{type}, 'file', 'SIZE succeeding means type "file"' );
    is( $invoice->{size}, 200,    'size populated via SIZE probe' );

    is( $subdir->{type},  'directory', 'SIZE failing is treated as a directory' );
    is( $subdir->{perms}, undef,       'perms stay undef on the NLST fallback path' );

    ok(
        exists( $quote->{longname} ) && exists( $quote->{perms} ),
        'longname and perms keys are present (as undef) on the NLST fallback path, matching the MLSD/SFTP/Local shape'
    );

    $transport->{connection} = undef;

    $schema->storage->txn_rollback;
};

1;
