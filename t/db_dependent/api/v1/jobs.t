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

use Test::More tests => 31;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::BackgroundJobs;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
#use t::lib::Mojo;
#my $t = t::lib::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

$schema->storage->txn_begin;

Koha::BackgroundJobs->delete;
my $superlibrarian = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => { flags => 1 },
    }
);
my $password = 'thePassword123';
$superlibrarian->set_password( { password => $password, skip_validation => 1 } );
my $superlibrarian_userid = $superlibrarian->userid;

my $librarian = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => { flags => 2 ** 2 }, # catalogue flag = 2
    }
);
$librarian->set_password( { password => $password, skip_validation => 1 } );
my $librarian_userid = $librarian->userid;

my $patron = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => { flags => 0 },
    }
);
$patron->set_password( { password => $password, skip_validation => 1 } );
my $patron_userid = $patron->userid;

$t->get_ok("//$librarian_userid:$password@/api/v1/jobs")
  ->status_is(200)
  ->json_is( [] );

my $job = $builder->build_object(
    {
        class => 'Koha::BackgroundJobs',
        value => {
            status         => 'finished',
            progress       => 100,
            size           => 100,
            borrowernumber => $patron->borrowernumber,
            type           => 'batch_item_record_modification',
            queue => 'default',
            #data => '{"record_ids":["1"],"regex_mod":null,"exclude_from_local_holds_priority":null,"new_values":{"itemnotes":"xxx"}}' ,
            data => '{"regex_mod":null,"report":{"total_records":1,"modified_fields":1,"modified_itemnumbers":[1]},"new_values":{"itemnotes":"xxx"},"record_ids":["1"],"exclude_from_local_holds_priority":null}',
        }
    }
);

my $job_current = $builder->build_object(
    {
        class => 'Koha::BackgroundJobs',
        value => {
            status         => 'new',
            progress       => 100,
            size           => 100,
            borrowernumber => $patron->borrowernumber,
            type           => 'batch_item_record_modification',
            queue => 'default',
            #data => '{"record_ids":["1"],"regex_mod":null,"exclude_from_local_holds_priority":null,"new_values":{"itemnotes":"xxx"}}' ,
            data => '{"regex_mod":null,"report":{"total_records":1,"modified_fields":1,"modified_itemnumbers":[1]},"new_values":{"itemnotes":"xxx"},"record_ids":["1"],"exclude_from_local_holds_priority":null}',
        }
    }
);

{
    $t->get_ok("//$superlibrarian_userid:$password@/api/v1/jobs")
      ->status_is(200)->json_is( [ $job->to_api, $job_current->to_api ] );

    $t->get_ok("//$superlibrarian_userid:$password@/api/v1/jobs?only_current=1")
      ->status_is(200)->json_is( [ $job_current->to_api ] );

    $t->get_ok("//$librarian_userid:$password@/api/v1/jobs")
      ->status_is(200)->json_is( [] );

    $t->get_ok("//$patron_userid:$password@/api/v1/jobs")
      ->status_is(403);

    $job->borrowernumber( $librarian->borrowernumber )->store;

    $t->get_ok("//$librarian_userid:$password@/api/v1/jobs")
      ->status_is(200)->json_is( [ $job->to_api ] );

    $t->get_ok("//$librarian_userid:$password@/api/v1/jobs?only_current=1")
      ->status_is(200)->json_is( [] );
}

{
    $t->get_ok( "//$superlibrarian_userid:$password@/api/v1/jobs/"
          . $job->id )->status_is(200)
      ->json_is( $job->to_api );

    $t->get_ok( "//$librarian_userid:$password@/api/v1/jobs/"
          . $job->id )->status_is(200)
      ->json_is( $job->to_api );

    $job->borrowernumber( $superlibrarian->borrowernumber )->store;
    $t->get_ok( "//$librarian_userid:$password@/api/v1/jobs/"
          . $job->id )->status_is(403);
}

{
    $job->delete;
    $t->get_ok( "//$superlibrarian_userid:$password@/api/v1/jobs/"
          . $job->id )->status_is(404)
      ->json_is( '/error' => 'Object not found' );
}

$schema->storage->txn_rollback;
