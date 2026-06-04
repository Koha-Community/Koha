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
use Test::More tests => 3;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::SIP2::Accounts;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

# Builds an institution + account + patron + item that all hang together, plus
# a custom patron field and a custom item field so we can prove the templates
# are rendered into the response.
sub build_test_account {
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode, flags => 1 } );

    my $institution = $builder->build_object(
        {
            class => 'Koha::SIP2::Institutions',
            value => {
                name           => $library->branchcode,
                implementation => 'ILS',
                checkin        => 1,
                checkout       => 1,
                renewal        => 1,
            },
        }
    );

    my $account = $builder->build_object(
        {
            class => 'Koha::SIP2::Accounts',
            value => {
                sip_institution_id      => $institution->sip_institution_id,
                encoding                => 'utf8',
                allow_fields            => '',
                hide_fields             => '',
                ae_field_template       => '',
                av_field_template       => '',
                da_field_template       => '',
                show_checkin_message    => 0,
                show_outstanding_amount => 0,
            },
        }
    );

    $account->custom_patron_fields( [ { field => 'XY', template => '[% patron.surname %]' } ] );
    $account->custom_item_fields( [ { field => 'ZW', template => '[% item.barcode %]' } ] );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->branchcode, surname => 'TemplateSurname' },
        }
    );

    my $item = $builder->build_sample_item( { homebranch => $library->branchcode } );

    return ( $account, $patron, $item );
}

subtest 'test_message() authorization tests' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    my ( $account, $patron, $item ) = build_test_account();

    my $password = 'thePassword123';

    my $librarian = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 2**31 } } );
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $unauth = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );
    $unauth->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $unauth->userid;

    my $url = "/api/v1/sip2/accounts/" . $account->sip_account_id . "/test_message";

    $t->post_ok(
        "//$unauth_userid:$password\@$url" => json => { message => 'patron_status', patron_id => $patron->cardnumber } )
        ->status_is(403);

    $t->post_ok(
        "//$userid:$password\@$url" => json => { message => 'patron_status', patron_id => $patron->cardnumber } )
        ->status_is(200);

    $schema->storage->txn_rollback;
};

subtest 'test_message() tests' => sub {
    plan tests => 15;

    $schema->storage->txn_begin;

    my ( $account, $patron, $item ) = build_test_account();

    my $password  = 'thePassword123';
    my $librarian = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 2**31 } } );
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $url = "/api/v1/sip2/accounts/" . $account->sip_account_id . "/test_message";

    # Patron information
    $t->post_ok(
        "//$userid:$password\@$url" => json => { message => 'patron_information', patron_id => $patron->cardnumber } )
        ->status_is(200)
        ->json_like( '/response', qr/^64/ );

    my $response = $t->tx->res->json;
    my %fields   = map { $_->{field} => $_->{value} } @{ $response->{fields} };
    is( $fields{AA}, $patron->cardnumber, 'AA holds the patron identifier' );
    is( $fields{XY}, 'TemplateSurname',   'Custom patron field XY rendered the template' );

    # Item information
    $t->post_ok( "//$userid:$password\@$url" => json => { message => 'item_information', item_id => $item->barcode } )
        ->status_is(200)
        ->json_like( '/response', qr/^18/ );

    # Raw request
    my $raw = $response->{request};
    $t->post_ok( "//$userid:$password\@$url" => json => { request => $raw } )
        ->status_is(200)
        ->json_like( '/response', qr/^64/ );

    # Unsupported message
    $t->post_ok( "//$userid:$password\@$url" => json => { message => 'no_such_message' } )->status_is(400);

    # Unknown account
    $t->post_ok( "//$userid:$password\@/api/v1/sip2/accounts/0/test_message" => json =>
            { message => 'patron_status', patron_id => $patron->cardnumber } )->status_is(404);

    $schema->storage->txn_rollback;
};
