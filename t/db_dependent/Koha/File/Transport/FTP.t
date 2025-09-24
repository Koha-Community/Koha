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

use Test::More tests => 6;
use Test::Exception;
use Test::NoWarnings;
use Test::Warn;

use Koha::File::Transports;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

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

subtest 'list_files() tests' => sub {
    plan tests => 1;
    my $transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'ftp', password => 'testpass' }
        }
    );

    can_ok( $transport, 'list_files' );
};

1;
