#!/usr/bin/env perl

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

use Test::NoWarnings;
use Test::More tests => 2;
use Test::Mojo;
use t::lib::TestBuilder;
use t::lib::Mocks;

use JSON qw(encode_json);

use C4::Budgets;

use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new();

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'list() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $superlibrarian =
        $builder->build_object( { class => 'Koha::Patrons', value => { flags => 1 } } );
    my $password = 'thePassword123';
    $superlibrarian->set_password( { password => $password, skip_validation => 1 } );
    $superlibrarian->discard_changes;

    my $userid = $superlibrarian->userid;

    $t->get_ok("//$userid:$password@/api/v1/auth/identity_providers")->status_is(200);

    my $provider = $builder->build_object( { class => 'Koha::Auth::Identity::Providers' } );

    $provider->set(
        {
            config  => '{"some":"value","and":"élève"}',
            mapping => '{"some":"value","and":"tréma"}'
        }
    )->store;

    $t->get_ok("//$userid:$password@/api/v1/auth/identity_providers")->status_is(200);

    $schema->storage->txn_rollback;
};
