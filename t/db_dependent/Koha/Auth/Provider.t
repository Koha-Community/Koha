#!/usr/bin/perl

# Copyright 2022 Theke Solutions
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

use Koha::Auth::Providers;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'domains() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $provider = $builder->build_object({ class => 'Koha::Auth::Providers' });
    my $domains  = $provider->domains;

    is( ref($domains), 'Koha::Auth::Provider::Domains', 'Type is correct' );
    is( $domains->count, 0, 'No domains defined' );

    $builder->build_object({ class => 'Koha::Auth::Provider::Domains', value => { auth_provider_id => $provider->id } });
    $builder->build_object({ class => 'Koha::Auth::Provider::Domains', value => { auth_provider_id => $provider->id } });

    is( $provider->domains->count, 2, 'The provider has 2 domains defined' );

    $schema->storage->txn_rollback;
};
