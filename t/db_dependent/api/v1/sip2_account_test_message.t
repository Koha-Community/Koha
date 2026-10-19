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
use Test::More tests => 7;
use Test::MockModule;
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
                login_id                => 'sip' . int( rand(1e9) ),
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

    # The patron the SIP account logs in as
    $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { userid => $account->login_id, branchcode => $library->branchcode },
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

# Builds a librarian at the given library with list_borrowers, plus either the
# whole sip2 module or only the given sip2 subpermission.
sub build_librarian {
    my ( $branchcode, $password, $sip2_permission ) = @_;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $branchcode, flags => $sip2_permission ? 0 : 2**31 },
        }
    );
    $builder->build(
        {
            source => 'UserPermission',
            value  => { borrowernumber => $librarian->borrowernumber, module_bit => 4, code => 'list_borrowers' },
        }
    );
    $builder->build(
        {
            source => 'UserPermission',
            value  => { borrowernumber => $librarian->borrowernumber, module_bit => 31, code => $sip2_permission },
        }
    ) if $sip2_permission;
    $librarian->set_password( { password => $password, skip_validation => 1 } );

    return $librarian;
}

subtest 'test_message() authorization tests' => sub {
    plan tests => 14;

    $schema->storage->txn_begin;

    my ( $account, $patron, $item ) = build_test_account();

    my $password = 'thePassword123';

    my $librarian = build_librarian( $patron->branchcode, $password );
    my $userid    = $librarian->userid;

    my $unauth = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );
    $unauth->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $unauth->userid;

    # sip2 alone is not enough, the endpoint also requires list_borrowers
    my $sip2_only = $builder->build_object(
        { class => 'Koha::Patrons', value => { branchcode => $patron->branchcode, flags => 2**31 } } );
    $sip2_only->set_password( { password => $password, skip_validation => 1 } );
    my $sip2_only_userid = $sip2_only->userid;

    # manage_sip2 can manage accounts but not test messages, test_sip2_messages
    # can test messages but not manage accounts
    my $manager_userid = build_librarian( $patron->branchcode, $password, 'manage_sip2' )->userid;
    my $tester_userid  = build_librarian( $patron->branchcode, $password, 'test_sip2_messages' )->userid;

    my $account_url = "/api/v1/sip2/accounts/" . $account->sip_account_id;
    my $url         = "$account_url/test_message";

    $t->post_ok(
        "//$unauth_userid:$password\@$url" => json => { message => 'patron_status', patron_id => $patron->cardnumber } )
        ->status_is(403);

    $t->post_ok( "//$sip2_only_userid:$password\@$url" => json =>
            { message => 'patron_status', patron_id => $patron->cardnumber } )->status_is(403);

    $t->post_ok(
        "//$userid:$password\@$url" => json => { message => 'patron_status', patron_id => $patron->cardnumber } )
        ->status_is(200);

    $t->post_ok(
        "//$manager_userid:$password\@$url" => json => { message => 'patron_status', patron_id => $patron->cardnumber }
    )->status_is(403);

    $t->post_ok(
        "//$tester_userid:$password\@$url" => json => { message => 'patron_status', patron_id => $patron->cardnumber } )
        ->status_is(200);

    $t->get_ok("//$manager_userid:$password\@$account_url")->status_is(200);

    $t->get_ok("//$tester_userid:$password\@$account_url")->status_is(403);

    $schema->storage->txn_rollback;
};

subtest 'test_message() tests' => sub {
    plan tests => 15;

    $schema->storage->txn_begin;

    my ( $account, $patron, $item ) = build_test_account();

    my $password  = 'thePassword123';
    my $librarian = build_librarian( $patron->branchcode, $password );
    my $userid    = $librarian->userid;

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

subtest 'test_message() library restrictions' => sub {
    plan tests => 9;

    $schema->storage->txn_begin;

    my ( $account, $patron, $item ) = build_test_account();

    my $password  = 'thePassword123';
    my $librarian = build_librarian( $patron->branchcode, $password );
    my $userid    = $librarian->userid;

    my $other_library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $other_patron =
        $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $other_library->branchcode } } );
    my $other_item = $builder->build_sample_item( { homebranch => $other_library->branchcode } );

    my $url = "/api/v1/sip2/accounts/" . $account->sip_account_id . "/test_message";

    # The librarian has no view_borrower_infos_from_any_libraries, so can only
    # see patrons from their own library
    $t->post_ok( "//$userid:$password\@$url" => json =>
            { message => 'patron_information', patron_id => $other_patron->cardnumber } )
        ->status_is(404)
        ->json_is( '/error' => 'Patron not found' );

    my $other_number = $other_patron->cardnumber;
    my $raw          = '63001' . '20260101    120000' . '          ' . "AO|AA$other_number|AC|";
    $t->post_ok( "//$userid:$password\@$url" => json => { request => $raw } )->status_is(404);

    t::lib::Mocks::mock_preference( 'IndependentBranches', 1 );

    $t->post_ok(
        "//$userid:$password\@$url" => json => { message => 'item_information', item_id => $other_item->barcode } )
        ->status_is(403);

    $t->post_ok( "//$userid:$password\@$url" => json => { message => 'item_information', item_id => $item->barcode } )
        ->status_is(200);

    $schema->storage->txn_rollback;
};

subtest 'test_message() error handling tests' => sub {
    plan tests => 10;

    $schema->storage->txn_begin;

    my ( $account, $patron, $item ) = build_test_account();

    my $password  = 'thePassword123';
    my $librarian = build_librarian( $patron->branchcode, $password );
    my $userid    = $librarian->userid;

    my $url = "/api/v1/sip2/accounts/" . $account->sip_account_id . "/test_message";

    $t->post_ok( "//$userid:$password\@$url" => json => {} )->status_is(400);

    # What a handler throws is a failure of the server, it must not be reported
    # as a refusal or as a missing patron
    my $handler = Test::MockModule->new('C4::SIP::Sip::MsgType');
    $handler->mock( handle => sub { Koha::Exceptions::NoPermission->throw('deep in a handler') } );
    $t->post_ok(
        "//$userid:$password\@$url" => json => { message => 'patron_status', patron_id => $patron->cardnumber } )
        ->status_is(500)
        ->json_is( '/error_code' => 'internal_server_error' );

    $handler->mock( handle => sub { die "something went wrong\n" } );
    $t->post_ok(
        "//$userid:$password\@$url" => json => { message => 'patron_status', patron_id => $patron->cardnumber } )
        ->status_is(500);
    $handler->unmock_all;

    # An account that has no patron to log in as is a missing object
    Koha::Patrons->find( { userid => $account->login_id } )->delete;
    $t->post_ok(
        "//$userid:$password\@$url" => json => { message => 'patron_status', patron_id => $patron->cardnumber } )
        ->status_is(404)
        ->json_like( '/error' => qr/No patron with the userid/ );

    $schema->storage->txn_rollback;
};

subtest 'test_message() patron password tests' => sub {
    plan tests => 12;

    $schema->storage->txn_begin;

    my ( $account, $patron, $item ) = build_test_account();

    my $password = 'thePassword123';
    $patron->set_password( { password => 'real_secret', skip_validation => 1 } );
    my $librarian = build_librarian( $patron->branchcode, $password );
    my $userid    = $librarian->userid;

    my $url = "/api/v1/sip2/accounts/" . $account->sip_account_id . "/test_message";

    my $fields = sub {
        return { map { $_->{field} => $_->{value} } @{ $t->tx->res->json->{fields} } };
    };

    $t->post_ok( "//$userid:$password\@$url" => json =>
            { message => 'patron_information', patron_id => $patron->cardnumber, patron_password => 'GOOD' } )
        ->status_is(200);
    is( $fields->()->{CQ}, 'Y', 'GOOD is reported as a valid password' );

    $t->post_ok( "//$userid:$password\@$url" => json =>
            { message => 'patron_information', patron_id => $patron->cardnumber, patron_password => 'BAD' } )
        ->status_is(200);
    is( $fields->()->{CQ}, 'N', 'BAD is reported as a password that is not valid' );

    # The real password is not accepted, it is not even a value the API takes
    $t->post_ok( "//$userid:$password\@$url" => json =>
            { message => 'patron_information', patron_id => $patron->cardnumber, patron_password => 'real_secret' } )
        ->status_is(400);

    # ...and typing it into a raw request does not get it past the tester either
    $t->post_ok(
        "//$userid:$password\@$url" => json => { message => 'patron_information', patron_id => $patron->cardnumber } );
    ( my $raw = $t->tx->res->json->{request} ) =~ s/(\|AC\|)/$1ADreal_secret|/;
    $t->post_ok( "//$userid:$password\@$url" => json => { request => $raw } )
        ->status_is(400)
        ->json_like( '/error' => qr/GOOD or BAD/ );

    $schema->storage->txn_rollback;
};

subtest 'test_message() patron information detail tests' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    my ( $account, $patron, $item ) = build_test_account();
    $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value => {
                borrowernumber    => $patron->borrowernumber,
                amount            => 2.5,
                amountoutstanding => 2.5,
                debit_type_code   => 'OVERDUE',
                credit_type_code  => undef,
                description       => 'Photocopies',
                status            => undef,
            },
        }
    );

    my $password  = 'thePassword123';
    my $librarian = build_librarian( $patron->branchcode, $password );
    my $userid    = $librarian->userid;

    my $url = "/api/v1/sip2/accounts/" . $account->sip_account_id . "/test_message";

    $t->post_ok( "//$userid:$password\@$url" => json =>
            { message => 'patron_information', patron_id => $patron->cardnumber, summary => 'fine_items' } )
        ->status_is(200);
    my @fines = grep { $_->{field} eq 'AV' } @{ $t->tx->res->json->{fields} };
    is( scalar @fines, 1, 'The fines are in the response' );
    like( $fines[0]->{value}, qr/Photocopies/, 'and are the fines of the patron' );

    $t->post_ok( "//$userid:$password\@$url" => json =>
            { message => 'patron_information', patron_id => $patron->cardnumber, summary => 'bogus' } )->status_is(400);

    $schema->storage->txn_rollback;
};
