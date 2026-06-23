#!/usr/bin/perl

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

use Koha::Patrons;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'Image tests' => sub {

    plan tests => 19;

    $schema->storage->txn_begin;

    my $privileged_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $privileged_patron->borrowernumber,
                module_bit     => 4,
                code           => 'list_borrowers',
            },
        }
    );
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $privileged_patron->borrowernumber,
                module_bit     => 4,
                code           => 'edit_borrowers',
            },
        }
    );
    my $password = 'thePassword123';
    $privileged_patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid         = $privileged_patron->userid;
    my $borrowernumber = $privileged_patron->borrowernumber;

    $t->get_ok("//$userid:$password@/api/v1/patrons/$borrowernumber/default_image")
        ->status_is(403)
        ->json_is( '/error' => 'Patron images are disabled.' );

    t::lib::Mocks::mock_preference( 'patronimages', 1 );

    $t->get_ok("//$userid:$password@/api/v1/patrons/$borrowernumber/default_image")
        ->status_is(404)
        ->json_is( '/error' => 'Patron image not found.' );

    my $non_existent_patron                 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $non_existent_patron_borrower_number = $non_existent_patron->borrowernumber;
    $non_existent_patron->delete;

    $t->get_ok("//$userid:$password@/api/v1/patrons/$non_existent_patron_borrower_number/default_image")
        ->status_is(404)
        ->json_is( '/error' => 'Patron not found.' );

    my $new_image = Koha::Patron::Image->new(
        {
            borrowernumber => $privileged_patron->borrowernumber,
            mimetype       => 'image/png',
            imagefile      => 'lot of binary content',
        }
    )->store;

    $t->get_ok("//$userid:$password@/api/v1/patrons/$borrowernumber/default_image")
        ->status_is(200)
        ->content_type_is('image/png')
        ->content_is('lot of binary content');

    my $unauthorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    my $unauthorized_password = 'thePassword456';

    $unauthorized_patron->set_password( { password => $unauthorized_password, skip_validation => 1 } );
    my $unauthorized_userid = $unauthorized_patron->userid;

    $t->get_ok( "//$unauthorized_userid:$unauthorized_password@/api/v1/patrons/" . $borrowernumber . "/default_image" )
        ->status_is(403)
        ->json_is( '/error' => "Authorization failure. Missing required permission(s)." );

    $t->get_ok( "//@/api/v1/patrons/" . $borrowernumber . "/default_image" )
        ->status_is(401)
        ->json_is( '/error' => 'Authentication failure.' );
};
