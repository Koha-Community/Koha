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

use Test::More tests => 1;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::ERM::Documents;
use Koha::Database;

use MIME::Base64 qw( decode_base64 );
use Koha::ERM::Licenses;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'get() tests' => sub {

    plan tests => 13;

    $schema->storage->txn_begin;

    my $document = $builder->build_object(
        {
            class => 'Koha::ERM::Documents',
            value => {
                file_content => '123',
                file_name    => 'name'
            }
        }
    );

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**28 }
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

    # This document exists, should get returned
    $t->get_ok( "//$userid:$password@/api/v1/erm/documents/"
          . $document->document_id
          . "/file/content" )->status_is(200)->json_is('123');

    # Create a document through a license, gets returned
    my $license = $builder->build_object( { class => 'Koha::ERM::Licenses' } );

    $license->documents(
        [
            {
                file_content => '321',
                file_name    => '321.jpeg'
            },
            {
                file_content => '456',
                file_name    => '456.jpeg'
            }
        ]
    );
    my @documents           = $license->documents->as_list;
    my $license_document_id = $documents[0]->document_id;

    $t->get_ok( "//$userid:$password@/api/v1/erm/documents/"
          . $license_document_id
          . "/file/content" )->status_is(200)
      ->content_is( decode_base64('321') );

    # Delete a document through a license, no longer exists
    my $deleted_document_id   = $license_document_id;
    my $remaining_document_id = $documents[1]->document_id;

    $license->documents(
        [
            {
                document_id  => $remaining_document_id,
                file_content => '456',
                file_name    => '456.jpeg'
            }
        ]
    );

    $t->get_ok( "//$userid:$password@/api/v1/erm/documents/"
          . $deleted_document_id
          . "/file/content" )->status_is(404);

    # Unauthorized access
    $t->get_ok( "//$unauth_userid:$password@/api/v1/erm/documents/"
          . $document->document_id
          . "/file/content" )->status_is(403);

    # Attempt to get non-existent document
    my $document_to_delete =
      $builder->build_object( { class => 'Koha::ERM::Documents' } );
    my $non_existent_id = $document_to_delete->id;
    $document_to_delete->delete;

    $t->get_ok(
"//$userid:$password@/api/v1/erm/documents/$non_existent_id/file/content"
    )->status_is(404)->json_is( '/error' => 'Document not found' );

    $schema->storage->txn_rollback;
};

