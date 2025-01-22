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

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'import record matches tests' => sub {

    plan tests => 13;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $librarian->id,
                module_bit     => 13,                     # tools
                code           => 'manage_staged_marc',
            }
        }
    );

    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    my $match_1 = $builder->build_object(
        {
            class => 'Koha::Import::Record::Matches',
            value => {
                chosen => 0,
            }
        }
    );
    my $match_2 = $builder->build_object(
        {
            class => 'Koha::Import::Record::Matches',
            value => {
                import_record_id => $match_1->import_record_id,
                chosen           => 1,
            }
        }
    );
    my $del_match           = $builder->build_object( { class => 'Koha::Import::Record::Matches' } );
    my $del_import_batch_id = $del_match->import_record->import_batch_id;
    my $del_match_id        = $del_match->import_record_id;

    $t->put_ok( "//$unauth_userid:$password@/api/v1/import_batches/"
            . $match_1->import_record->import_batch_id
            . "/records/"
            . $match_1->import_record_id
            . "/matches/chosen" => json => { candidate_match_id => $match_1->candidate_match_id } )->status_is(403);

    # Invalid attempt to allow match on a non-existent record
    $del_match->delete();

    $t->put_ok( "//$userid:$password@/api/v1/import_batches/"
            . $del_import_batch_id
            . "/records/"
            . $del_match_id
            . "/matches/chosen" => json => { candidate_match_id => $match_1->candidate_match_id } )->status_is(404)
        ->json_is( '/error' => "Match not found" );

    # Valid, authorised update
    $t->put_ok( "//$userid:$password@/api/v1/import_batches/"
            . $match_1->import_record->import_batch_id
            . "/records/"
            . $match_1->import_record_id
            . "/matches/chosen" => json => { candidate_match_id => $match_1->candidate_match_id } )->status_is(200);

    $match_1->discard_changes;
    $match_2->discard_changes;

    ok( $match_1->chosen,  "Match 1 is correctly set to chosen" );
    ok( !$match_2->chosen, "Match 2 correctly unset when match 1 is set" );

    # Valid unsetting
    $t->delete_ok( "//$userid:$password@/api/v1/import_batches/"
            . $match_1->import_record->import_batch_id
            . "/records/"
            . $match_1->import_record_id
            . "/matches/chosen" )->status_is(204);

    $match_1->discard_changes;
    $match_2->discard_changes;
    ok( !$match_1->chosen, "Match 1 is correctly unset to chosen" );
    ok( !$match_2->chosen, "Match 2 is correctly unset to chosen" );

    $schema->storage->txn_rollback;
};
