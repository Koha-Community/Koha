#!/usr/bin/perl

# Copyright 2023 Koha Development team
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

use Test::More tests => 1;

use Koha::Illbackend;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;

subtest 'existing_statuses() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;
    Koha::Illrequests->search->delete;

    my $alias = $builder->build_object(
        {
            class => 'Koha::AuthorisedValues',
            value => {
                category         => 'ILL_STATUS_ALIAS',
                authorised_value => 'BOB',
                lib              => "Bob is the best status"
            }
        }
    );

    my $req = $builder->build_object(
        {
            class => 'Koha::Illrequests',
            value => {
                status       => 'REQ',
                status_alias => undef,
                biblio_id    => undef,
                backend      => 'FreeForm'
            }
        }
    );
    my $chk = $builder->build_object(
        {
            class => 'Koha::Illrequests',
            value => {
                status       => 'CHK',
                status_alias => undef,
                biblio_id    => undef,
                backend      => 'FreeForm'
            }
        }
    );
    my $bob = $builder->build_object(
        {
            class => 'Koha::Illrequests',
            value => {
                status       => 'REQ',
                status_alias => 'BOB',
                biblio_id    => undef,
                backend      => 'FreeForm'
            }
        }
    );
    my $req2 = $builder->build_object(
        {
            class => 'Koha::Illrequests',
            value => {
                status       => 'REQ',
                status_alias => undef,
                biblio_id    => undef,
                backend      => 'FreeForm'
            }
        }
    );

    my $backend_module = Koha::Illbackend->new;

    my $existing_statuses = $backend_module->existing_statuses('FreeForm');

    is( @{$existing_statuses}, 3, "Return 3 unique existing statuses" );

    # FIXME: Add tests to check content and order of return
    my $expected_statuses = [
        { code => 'CHK', str => 'Checked out' },
        { code => 'REQ', str => 'Requested' },
        { code => 'BOB', str => 'Bob is the best status' }
    ];

    is_deeply( $existing_statuses, $expected_statuses, 'Deep match on return' );

    $schema->storage->txn_rollback;
};
