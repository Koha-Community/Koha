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

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 3;

use t::lib::Mocks;
use t::lib::TestBuilder;

BEGIN {
    use_ok('Koha::Template::Plugin::Branches');
}

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'all' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $plugin = Koha::Template::Plugin::Branches->new();
    subtest 'when given no parameters' => sub {
        plan tests => 1;
        my $libraries     = $plugin->all();
        my $library_count = Koha::Libraries->search()->count();

        is( scalar @$libraries, $library_count, 'We get all the branches' );
    };

    subtest 'when given parameter "ip_limit"' => sub {
        plan tests => 4;
        t::lib::Mocks::mock_preference( 'StaffLoginRestrictLibraryByIP', '' );
        $ENV{REMOTE_ADDR} = '127.0.0.1';
        my $library   = $builder->build_object( { class => 'Koha::Libraries', value => { branchip => '127.0.0.2' } } );
        my $libraries = $plugin->all( { ip_limit => 1 } );
        my $library_count = Koha::Libraries->search()->count();

        is(
            scalar @$libraries, $library_count,
            'We get all the libraries when ip_limit passed but StaffLoginRestrictLibraryIP not enabled'
        );

        t::lib::Mocks::mock_preference( 'StaffLoginRestrictLibraryByIP', '1' );
        $library_count = Koha::Libraries->search( { branchip => [ undef, '127.0.0.1' ] } )->count();
        $libraries     = $plugin->all( { ip_limit => 1 } );
        is(
            scalar @$libraries, $library_count,
            'We remove non-matching libraries when ip_limit passed and StaffLoginRestrictLibraryIP enabled'
        );

        $ENV{REMOTE_ADDR} = '127.0.0.2';
        $libraries        = $plugin->all( { ip_limit => 1 } );
        $library_count    = Koha::Libraries->search( { branchip => [ undef, '127.0.0.2' ] } )->count();
        is(
            scalar @$libraries, $library_count,
            'We get all the expected libraries when ip_limit passed and StaffLoginRestrictLibraryIP and IP matches'
        );

        $library->branchip("127.0.*.*");
        $library_count = Koha::Libraries->search( { branchip => [ undef, '127.0.0.2', '127.0.*.*' ] } )->count();
        is(
            scalar @$libraries, $library_count,
            'We get all the expected libraries when ip_limit passed and StaffLoginRestrictLibraryIP and IP matches patternwise'
        );
    };

    $schema->storage->txn_rollback;
};
