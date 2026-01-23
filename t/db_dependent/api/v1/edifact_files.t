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

use JSON qw(encode_json);

use Koha::Edifact::Files;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {

    plan tests => 20;

    $schema->storage->txn_begin;

    Koha::Edifact::Files->search->delete;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**11 }    #acquisition
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

    ## Authorized user tests
    # No acquisitions\/edifiles, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/acquisitions/edifiles")->status_is(200)->json_is( [] );

    my $file = $builder->build_object(
        { class => 'Koha::Edifact::Files', value => { message_type => 'ORDER', deleted => 0 } } );

    my $deleted_file = $builder->build_object(
        { class => 'Koha::Edifact::Files', value => { message_type => 'ORDER', deleted => 1 } } );

    # One file undeleted, should get returned
    $t->get_ok("//$userid:$password@/api/v1/acquisitions/edifiles")->status_is(200)->json_is( [ $file->to_api ] );

    my $another_file_ORDER =
        $builder->build_object(
        { class => 'Koha::Edifact::Files', value => { message_type => 'ORDER', deleted => 0 } } );
    my $another_file_QUOTE =
        $builder->build_object(
        { class => 'Koha::Edifact::Files', value => { message_type => 'QUOTE', deleted => 0 } } );

    # Two files created, they should both be returned
    $t->get_ok("//$userid:$password@/api/v1/acquisitions/edifiles")->status_is(200)->json_is(
        [
            $file->to_api,
            $another_file_ORDER->to_api,
            $another_file_QUOTE->to_api
        ]
    );

    # Filtering works, two files sharing type
    my $api_filter = encode_json( { 'me.type' => ['ORDER'] } );
    $t->get_ok("//$userid:$password@/api/v1/acquisitions/edifiles?q=$api_filter")->status_is(200)->json_is(
        [
            $file->to_api,
            $another_file_ORDER->to_api
        ]
    );

    $api_filter = encode_json( { 'me.filename' => $file->filename } );
    $t->get_ok("//$userid:$password@/api/v1/acquisitions/edifiles?q=$api_filter")
        ->status_is(200)
        ->json_is( [ $file->to_api ] );

    # Warn on unsupported query parameter
    $api_filter = encode_json( { 'me.file_blah' => 'blah' } );
    $t->get_ok("//$userid:$password@/api/v1/acquisitions/edifiles?file_blah=blah")
        ->status_is(400)
        ->json_is( [ { path => '/query/file_blah', message => 'Malformed query string' } ] );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/acquisitions/edifiles")->status_is(403);

    $schema->storage->txn_rollback;
};
