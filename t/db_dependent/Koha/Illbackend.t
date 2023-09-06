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

    # Mock ILLBackend (as object)
    my $backend = Test::MockObject->new;
    $backend->set_isa('Koha::Illbackends::Mock');
    $backend->set_always( 'name', 'Mock' );

    $backend->mock(
        'status_graph',
        sub {
            return {
                READY => {
                    prev_actions   => [ 'NEW', 'REQREV', 'QUEUED', 'CANCREQ' ],
                    id             => 'READY',
                    name           => 'Ready',
                    ui_method_name => 'Make request ready',
                    method         => 'confirm',
                    next_actions   => [ 'REQREV', 'COMP', 'CHK' ],
                    ui_method_icon => 'fa-check',
                }
            };
        },
    );

    # Mock Koha::Illrequest::load_backend (to load Mocked Backend)
    my $illreqmodule = Test::MockModule->new('Koha::Illrequest');
    $illreqmodule->mock(
        'load_backend',
        sub { my $self = shift; $self->{_my_backend} = $backend; return $self }
    );

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

    my $backend_req_status = $builder->build_object(
        {
            class => 'Koha::Illrequests',
            value => {
                status       => 'READY',
                status_alias => undef,
                biblio_id    => undef,
                backend      => 'Mock'
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
                backend      => 'Mock'
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
                backend      => 'Mock'
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
                backend      => 'Mock'
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
                backend      => 'Mock'
            }
        }
    );

    my $backend_module = Koha::Illbackend->new;

    my $existing_statuses = $backend_module->existing_statuses('Mock');

    is( @{$existing_statuses}, 4, "Return 4 unique existing statuses" );

    # FIXME: Add tests to check content and order of return
    my $expected_statuses = [
        { code => 'CHK',   str => 'Checked out' },
        { code => 'READY', str => 'Ready' },
        { code => 'REQ',   str => 'Requested' },
        { code => 'BOB',   str => 'Bob is the best status' }
    ];

    is_deeply( $existing_statuses, $expected_statuses, 'Deep match on return' );

    $schema->storage->txn_rollback;
};
