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
use Test::More tests => 8;
use Test::Exception;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Database;
use Koha::Checkouts;
use Koha::SIP2::MessageTester;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# Builds an institution + account + patron + item that all hang together, plus
# a custom patron field and a custom item field so we can prove the templates
# are rendered into the response.
sub build_test_account {
    my ($params) = @_;

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

    # TestBuilder fills these text columns with random junk that would otherwise
    # break message building ( a bogus encoding ) or hide every field ( a random
    # allow_fields acts as an allowlist ), so set them to sane values.
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

subtest 'new() tests' => sub {
    plan tests => 2;

    throws_ok { Koha::SIP2::MessageTester->new( {} ) }
    'Koha::Exceptions::MissingParameter',
        'new() without an account throws';

    my $account = $builder->build_object( { class => 'Koha::SIP2::Accounts' } );
    isa_ok(
        Koha::SIP2::MessageTester->new( { account => $account } ),
        'Koha::SIP2::MessageTester', 'new() with an account'
    );
};

subtest 'run() patron_information tests' => sub {
    plan tests => 5;

    $schema->storage->txn_begin;

    my ( $account, $patron, $item ) = build_test_account();
    my $tester = Koha::SIP2::MessageTester->new( { account => $account } );

    my $result = $tester->run( { message => 'patron_information', patron_id => $patron->cardnumber } );

    is( substr( $result->{response}, 0, 2 ), '64', 'Got a patron information response (64)' );

    my %fields = map { $_->{field} => $_->{value} } @{ $result->{fields} };
    is( $fields{AA}, $patron->cardnumber, 'AA holds the patron identifier' );
    ok( exists $fields{AE}, 'AE personal name is present' );
    is( $fields{XY}, 'TemplateSurname', 'Custom patron field XY rendered the template' );
    like( $result->{request}, qr/^63/, 'The request is a patron information request (63)' );

    $schema->storage->txn_rollback;
};

subtest 'run() item_information tests' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my ( $account, $patron, $item ) = build_test_account();
    my $tester = Koha::SIP2::MessageTester->new( { account => $account } );

    my $result = $tester->run( { message => 'item_information', item_id => $item->barcode } );

    is( substr( $result->{response}, 0, 2 ), '18', 'Got an item information response (18)' );

    my %fields = map { $_->{field} => $_->{value} } @{ $result->{fields} };
    is( $fields{AB}, $item->barcode, 'AB holds the item identifier' );
    is( $fields{ZW}, $item->barcode, 'Custom item field ZW rendered the template' );

    $schema->storage->txn_rollback;
};

subtest 'run() patron_status tests' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    my ( $account, $patron, $item ) = build_test_account();
    my $tester = Koha::SIP2::MessageTester->new( { account => $account } );

    my $result = $tester->run( { message => 'patron_status', patron_id => $patron->cardnumber } );
    is( substr( $result->{response}, 0, 2 ), '24', 'Got a patron status response (24)' );

    $schema->storage->txn_rollback;
};

subtest 'run() rolls back changes' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my ( $account, $patron, $item ) = build_test_account();
    my $tester = Koha::SIP2::MessageTester->new( { account => $account } );

    # Check the item out so we can prove a checkin does not actually return it.
    my $checkout = Koha::Checkout->new(
        {
            borrowernumber => $patron->borrowernumber,
            itemnumber     => $item->itemnumber,
            branchcode     => $item->homebranch,
        }
    )->store;

    my $result = $tester->run( { message => 'checkin', item_id => $item->barcode } );
    is( substr( $result->{response}, 0, 2 ), '10', 'Got a checkin response (10)' );
    is(
        Koha::Checkouts->search( { itemnumber => $item->itemnumber } )->count, 1,
        'The checkout still exists, the checkin was rolled back'
    );

    $result = $tester->run( { message => 'checkout', patron_id => $patron->cardnumber, item_id => $item->barcode } );
    is( substr( $result->{response}, 0, 2 ), '12', 'Got a checkout response (12)' );

    $schema->storage->txn_rollback;
};

subtest 'run() with a raw request' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my ( $account, $patron, $item ) = build_test_account();
    my $tester = Koha::SIP2::MessageTester->new( { account => $account } );

    # Build the request through the structured path, then feed the raw string
    # straight back in and confirm we get the same kind of response.
    my $built = $tester->run( { message => 'patron_information', patron_id => $patron->cardnumber } );
    my $raw   = $tester->run( { request => $built->{request} } );

    is( substr( $raw->{response}, 0, 2 ), '64', 'Raw request produced a patron information response' );

    my %fields = map { $_->{field} => $_->{value} } @{ $raw->{fields} };
    is( $fields{XY}, 'TemplateSurname', 'Raw request rendered the custom patron field' );

    $schema->storage->txn_rollback;
};

subtest 'run() error handling' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my ( $account, $patron, $item ) = build_test_account();
    my $tester = Koha::SIP2::MessageTester->new( { account => $account } );

    throws_ok { $tester->run( {} ) }
    'Koha::Exceptions::MissingParameter',
        'run() without a message or request throws';

    throws_ok { $tester->run( { message => 'no_such_message' } ) }
    'Koha::Exceptions::BadParameter',
        'run() with an unsupported message throws';

    $schema->storage->txn_rollback;
};
