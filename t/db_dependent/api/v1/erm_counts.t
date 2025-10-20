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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 2;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::ERM::Agreements;
use Koha::ERM::Documents;
use Koha::ERM::EHoldings::Packages;
use Koha::ERM::EHoldings::Titles;
use Koha::ERM::Licenses;
use Koha::ERM::EUsage::UsageDataProviders;

use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'count() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    Koha::ERM::Agreements->search->delete;
    Koha::ERM::Documents->search->delete;
    Koha::ERM::EHoldings::Packages->search->delete;
    Koha::ERM::EHoldings::Titles->search->delete;
    Koha::ERM::Licenses->search->delete;
    Koha::ERM::EUsage::UsageDataProviders->search->delete;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**28 }
        }
    );

    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    ## Authorized user tests
    my $agreement = $builder->build_object(
        {
            class => 'Koha::ERM::Agreements',
        }
    );

    my $license = $builder->build_object(
        {
            class => 'Koha::ERM::Licenses',
        }
    );

    $t->get_ok("//$userid:$password@/api/v1/erm/counts")->status_is(200)->json_is(
        {
            counts => {
                agreements_count           => 1,
                documents_count            => 0,
                eholdings_packages_count   => 0,
                eholdings_titles_count     => 0,
                licenses_count             => 1,
                usage_data_providers_count => 0
            }
        }
    );
    $schema->storage->txn_rollback;
};
