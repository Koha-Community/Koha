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
use Test::More tests => 18;
use Test::Exception;
use Test::MockModule;
use Encode    qw( encode );
use Try::Tiny qw( catch try );

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::BackgroundJob;
use Koha::Caches;
use Koha::Logger;
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
    plan tests => 9;

    $schema->storage->txn_begin;

    my ( $account, $patron, $item ) = build_test_account();
    my $tester = Koha::SIP2::MessageTester->new( { account => $account } );

    throws_ok { $tester->run( {} ) }
    'Koha::Exceptions::MissingParameter',
        'run() without a message or request throws';

    throws_ok { $tester->run( { message => 'no_such_message' } ) }
    'Koha::Exceptions::BadParameter',
        'run() with an unsupported message throws';

    $account->institution->implementation('No::Such::Module')->store;
    throws_ok { $tester->run( { message => 'patron_status', patron_id => $patron->cardnumber } ) }
    'Koha::Exception', 'run() with an implementation that cannot be loaded throws';
    $account->institution->implementation('ILS')->store;

    # A value with the field delimiter would add fields to the request
    throws_ok { $tester->run( { message => 'patron_status', patron_id => '123|AB456' } ) }
    'Koha::Exceptions::BadParameter', 'A delimiter in the patron identifier is refused';
    throws_ok { $tester->run( { message => 'item_information', item_id => 'I1|AA1' } ) }
    'Koha::Exceptions::BadParameter', 'A delimiter in the item identifier is refused';
    throws_ok { $tester->run( { message => 'patron_information', patron_id => 'P1', patron_password => 'a|b' } ) }
    'Koha::Exceptions::BadParameter', 'A delimiter in the password is refused';

    my $built = $tester->_build_request(
        { account   => { institution => 'MPL' } }, 'patron_information',
        { patron_id => 'P1', patron_password => '0' }
    );
    like( $built, qr/\|AD0\|/, 'A password of 0 is kept in the request' );

    # Whatever a handler throws is a failure of the server, not of the request
    my $handler = Test::MockModule->new('C4::SIP::Sip::MsgType');
    $handler->mock( handle => sub { Koha::Exceptions::NoPermission->throw('deep in a handler') } );
    my $error;
    try { $tester->run( { message => 'patron_status', patron_id => $patron->cardnumber } ) }
    catch { $error = $_ };
    is( ref($error), 'Koha::Exception', 'An exception from a handler is not passed on as it is' );
    like( $error->error, qr/handler failed: .*deep in a handler/, 'but its message is kept' );

    $schema->storage->txn_rollback;
};

subtest 'run() access restrictions' => sub {
    plan tests => 8;

    $schema->storage->txn_begin;

    my ( $account, $patron, $item ) = build_test_account();
    my $tester = Koha::SIP2::MessageTester->new( { account => $account } );

    throws_ok { $tester->run( { request => '9300CN' . $patron->userid . '|COpassword|' } ) }
    'Koha::Exceptions::BadParameter',
        'run() refuses a raw request for a message the tester does not support';

    # A librarian without view_borrower_infos_from_any_libraries, in a library
    # with no library groups, can only see patrons from their own library.
    my $librarian = $builder->build_object(
        { class => 'Koha::Patrons', value => { branchcode => $patron->branchcode, flags => 0 } } );
    t::lib::Mocks::mock_userenv( { patron => $librarian } );

    my $other_library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $other_patron =
        $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $other_library->branchcode } } );
    my $other_item = $builder->build_sample_item( { homebranch => $other_library->branchcode } );

    my $result = $tester->run( { message => 'patron_information', patron_id => $patron->cardnumber } );
    is( substr( $result->{response}, 0, 2 ), '64', 'run() allows a patron from the librarian\'s library' );

    throws_ok { $tester->run( { message => 'patron_information', patron_id => $other_patron->cardnumber } ) }
    'Koha::Exceptions::Patron::NotFound',
        'run() refuses a patron the librarian cannot see';

    # Swap the patron in a request the librarian is allowed to run
    my $request      = $result->{request};
    my $other_number = $other_patron->cardnumber;
    $request =~ s/\|AA[^|]*\|/|AA$other_number|/;
    throws_ok { $tester->run( { request => $request } ) }
    'Koha::Exceptions::Patron::NotFound',
        'run() refuses a raw request for a patron the librarian cannot see';

    throws_ok { $tester->run( { message => 'patron_information', patron_id => 'no_such_patron' } ) }
    'Koha::Exceptions::Patron::NotFound',
        'run() refuses an unknown patron';

    t::lib::Mocks::mock_preference( 'IndependentBranches', 0 );
    $result = $tester->run( { message => 'item_information', item_id => $other_item->barcode } );
    is(
        substr( $result->{response}, 0, 2 ), '18',
        'run() allows an item from another library when IndependentBranches is disabled'
    );

    t::lib::Mocks::mock_preference( 'IndependentBranches', 1 );
    throws_ok { $tester->run( { message => 'item_information', item_id => $other_item->barcode } ) }
    'Koha::Exceptions::NoPermission',
        'run() refuses an item from another library when IndependentBranches is enabled';

    $result = $tester->run( { message => 'item_information', item_id => $item->barcode } );
    is(
        substr( $result->{response}, 0, 2 ), '18',
        'run() allows an item from the librarian\'s library when IndependentBranches is enabled'
    );

    $schema->storage->txn_rollback;
};

subtest 'run() isolation and clean up' => sub {
    plan tests => 19;

    $schema->storage->txn_begin;

    my ( $account, $patron, $item ) = build_test_account();
    my $tester = Koha::SIP2::MessageTester->new( { account => $account } );

    my $login_patron  = Koha::Patrons->find( { userid => $account->login_id } );
    my $institution   = $account->institution->name;
    my $original_conn = \&Koha::BackgroundJob::connect;

    # What the handler sees while it runs
    my %seen;
    my $handler = Test::MockModule->new('C4::SIP::Sip::MsgType');
    $handler->mock(
        handle => sub {
            my $userenv = C4::Context->userenv;
            %seen = (
                number           => $userenv->{number},
                branch           => $userenv->{branch},
                connection       => scalar Koha::BackgroundJob->connect,
                protocol_version => $C4::SIP::Sip::protocol_version,
            );
            $C4::SIP::Sip::last_response = '24' . ( ' ' x 35 );
            return;
        }
    );

    # The state we expect to get back untouched, the staff member running the test
    my $staff = $builder->build_object(
        { class => 'Koha::Patrons', value => { branchcode => $patron->branchcode, flags => 0 } } );
    t::lib::Mocks::mock_userenv( { patron => $staff } );
    $C4::SIP::Sip::protocol_version = 'sentinel_protocol';
    $C4::SIP::Sip::error_detection  = 'sentinel_error_detection';
    $C4::SIP::Sip::last_response    = 'sentinel_last_response';
    local $ENV{MESSAGE_TESTER_SENTINEL} = 'untouched';
    my %env_before = %ENV;
    my $depth      = $schema->storage->transaction_depth;

    my $check_state_restored = sub {
        my ($label) = @_;
        is( $C4::SIP::Sip::protocol_version, 'sentinel_protocol',        "$label: protocol version restored" );
        is( $C4::SIP::Sip::error_detection,  'sentinel_error_detection', "$label: error detection restored" );
        is( $C4::SIP::Sip::last_response,    'sentinel_last_response',   "$label: last response restored" );
        is( C4::Context->userenv->{number},  $staff->borrowernumber,     "$label: userenv restored" );
        is_deeply( \%ENV, \%env_before, "$label: environment restored" );
        is( $schema->storage->transaction_depth, $depth, "$label: transaction closed" );
    };

    $tester->run( { message => 'patron_status', patron_id => $patron->cardnumber } );

    is( $seen{number},           $login_patron->borrowernumber, 'The handler ran as the SIP account patron' );
    is( $seen{branch},           $institution,                  'The handler ran at the institution library' );
    is( $seen{protocol_version}, 2,                             'The handler ran with protocol version 2' );
    ok( !$seen{connection}, 'No message broker connection while the handler ran' );
    $check_state_restored->('after success');

    ok( \&Koha::BackgroundJob::connect == $original_conn, 'The broker connection method is back' );

    # A handler that dies
    $handler->mock( handle => sub { die "handler blew up\n" } );
    throws_ok { $tester->run( { message => 'patron_status', patron_id => $patron->cardnumber } ) }
    'Koha::Exception', 'A handler error is thrown as a Koha::Exception';
    like( $@->error, qr/handler failed: handler blew up/, 'The handler error is kept in the message' );
    $check_state_restored->('after handler error');

    $schema->storage->txn_rollback;
};

subtest 'run() forgets the last seen activity it caused' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my ( $account, $patron, $item ) = build_test_account();
    my $tester = Koha::SIP2::MessageTester->new( { account => $account } );

    t::lib::Mocks::mock_preference( 'TrackLastPatronActivityTriggers', 'connection' );

    my $cache = Koha::Caches->get_instance;
    my $key   = 'track_activity_' . $patron->borrowernumber;
    $cache->clear_from_cache($key);

    $tester->run( { message => 'patron_status', patron_id => $patron->cardnumber } );
    ok( !$cache->get_from_cache($key), 'No activity cache entry was left after the test' );

    # A real connection afterwards must still be recorded
    $patron->discard_changes;
    $patron->update_lastseen('connection');
    ok( $cache->get_from_cache($key), 'A real activity is still tracked afterwards' );
    $cache->clear_from_cache($key);

    $schema->storage->txn_rollback;
};

subtest 'run() needs the patron the account logs in as' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    my ( $account, $patron, $item ) = build_test_account();
    Koha::Patrons->find( { userid => $account->login_id } )->delete;

    throws_ok {
        Koha::SIP2::MessageTester->new( { account => $account } )
            ->run( { message => 'patron_status', patron_id => $patron->cardnumber } )
    }
    'Koha::Exceptions::ObjectNotFound', 'run() throws when the account has no login patron';

    $schema->storage->txn_rollback;
};

subtest 'run() reports a rollback that failed' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my ( $account, $patron, $item ) = build_test_account();
    my $tester = Koha::SIP2::MessageTester->new( { account => $account } );

    my $depth = $schema->storage->transaction_depth;
    my $error;
    {
        no warnings 'redefine';

        # Only the tester's own rollback fails, others ( the template
        # processing rolls back too ) carry on as usual
        my $real_rollback = \&DBIx::Class::Schema::txn_rollback;
        local *DBIx::Class::Schema::txn_rollback = sub {
            die "rollback exploded\n" if caller eq 'Koha::SIP2::MessageTester';
            goto &$real_rollback;
        };
        try { $tester->run( { message => 'patron_status', patron_id => $patron->cardnumber } ) }
        catch { $error = $_ };
    }

    isa_ok( $error, 'Koha::Exception', 'A failed rollback is thrown' );
    like( $error->error, qr/Could not roll back the test transaction: rollback exploded/, 'The cause is reported' );

    # Undo what the failed rollback left open ( the tester's and our own )
    $schema->storage->txn_rollback while $schema->storage->transaction_depth >= $depth;
    is( $schema->storage->transaction_depth, $depth - 1, 'Test transaction cleaned up' );
};

subtest 'run() logs each test where the web server keeps it' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my ( $account, $patron, $item ) = build_test_account();
    my $tester = Koha::SIP2::MessageTester->new( { account => $account } );

    # Under Plack Koha::Logger prefixes the category with plack-, and plack-api
    # only logs from WARN, so the line is lost unless the prefix is turned off
    my $context = Test::MockModule->new('C4::Context');
    $context->mock( psgi_env => sub { return 1 } );

    my $real_get = Koha::Logger->can('get');
    my @loggers;
    my $logger = Test::MockModule->new('Koha::Logger');
    $logger->mock( get => sub { my $l = $real_get->(@_); push @loggers, $l; return $l } );

    $tester->run( { message => 'patron_status', patron_id => $patron->cardnumber } );

    my @tester_loggers = grep { ( $_->{cat} // q{} ) =~ /sip2\.message_tester/ } @loggers;
    is( scalar @tester_loggers,    1,                         'The test is logged once' );
    is( $tester_loggers[0]->{cat}, 'api.sip2.message_tester', 'under the api category, not plack-api' );

    $schema->storage->txn_rollback;
};

subtest 'run() returns the response as characters, not as the account encoding' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    my ( $account, $patron, $item ) = build_test_account();
    $account->encoding('utf8')->store;
    my $tester = Koha::SIP2::MessageTester->new( { account => $account } );

    # The handler writes the response in the encoding of the account
    my $surname = "M\x{fc}ller \x{263a}";
    my $handler = Test::MockModule->new('C4::SIP::Sip::MsgType');
    $handler->mock(
        handle => sub {
            $C4::SIP::Sip::last_response = encode( 'UTF-8', '24' . ( ' ' x 35 ) . "AE$surname|" );
            return;
        }
    );

    my $result = $tester->run( { message => 'patron_status', patron_id => $patron->cardnumber } );
    is( $result->{fields}->[0]->{value}, $surname, 'The value is the characters the terminal reads' );
    ok( utf8::is_utf8( $result->{fields}->[0]->{value} ), 'and a character string' );
    is(
        length( $result->{response} ), 37 + length("AE$surname|"),
        'The response has one character for each character'
    );

    $account->encoding(undef)->store;
    $result = Koha::SIP2::MessageTester->new( { account => $account } )
        ->run( { message => 'patron_status', patron_id => $patron->cardnumber } );
    is(
        $result->{fields}->[0]->{value}, encode( 'UTF-8', $surname ),
        'Without an encoding the response is left alone'
    );

    $schema->storage->txn_rollback;
};

subtest '_parse_response() tests' => sub {
    plan tests => 4;

    my $tester = Koha::SIP2::MessageTester->new( { account => 'not used here' } );

    is_deeply( [ $tester->_parse_response(q{}) ], [ q{}, [] ], 'An empty response has nothing in it' );

    my $fixed = '24' . ( ' ' x 35 );    # patron status response, 37 characters
    my ( $got_fixed, $fields ) = $tester->_parse_response( $fixed . 'AEA Patron||AAP1|' );
    is( $got_fixed, $fixed, 'The fixed portion is split off' );
    is_deeply(
        $fields,
        [ { field => 'AE', value => 'A Patron' }, { field => 'AA', value => 'P1' } ],
        'Fields are split and empty chunks skipped'
    );

    # A trailing chunk shorter than a field identifier and value must not warn
    is_deeply(
        [ $tester->_parse_response( $fixed . 'X' ) ],
        [ $fixed, [ { field => 'X', value => q{} } ] ],
        'A chunk of one character is a field without a value'
    );
};

subtest 'run() never checks a real patron password' => sub {
    plan tests => 10;

    $schema->storage->txn_begin;

    my ( $account, $patron, $item ) = build_test_account();
    $patron->set_password( { password => 'real_secret', skip_validation => 1 } );
    my $tester = Koha::SIP2::MessageTester->new( { account => $account } );

    # The real check is what would make this a way to guess passwords
    my $checks = 0;
    my $ils    = Test::MockModule->new('C4::SIP::ILS::Patron');
    $ils->mock( checkpw => sub { $checks++; die "a real password was checked\n" } );

    my $fields_of = sub {
        return { map { $_->{field} => $_->{value} } @{ shift->{fields} } };
    };

    my $result = $tester->run(
        { message => 'patron_information', patron_id => $patron->cardnumber, patron_password => 'GOOD' } );
    is( substr( $result->{response}, 0, 2 ), '64', 'GOOD: got a patron information response' );
    is( $fields_of->($result)->{CQ},         'Y',  'GOOD: the password is reported as valid' );

    $result =
        $tester->run( { message => 'patron_information', patron_id => $patron->cardnumber, patron_password => 'BAD' } );
    is( $fields_of->($result)->{CQ}, 'N', 'BAD: the password is reported as not valid' );

    # The real password is the one that must not be sent
    throws_ok {
        $tester->run(
            { message => 'patron_information', patron_id => $patron->cardnumber, patron_password => 'real_secret' } )
    }
    'Koha::Exceptions::BadParameter', 'A real password is refused';
    like( $@->error // "$@", qr/GOOD or BAD/, 'and the message says what to use instead' );

    # ...also when it is typed into the raw request
    my $built = $tester->run(
        { message => 'patron_information', patron_id => $patron->cardnumber, patron_password => 'GOOD' } );
    ( my $raw = $built->{request} ) =~ s/\|ADGOOD\|/|ADreal_secret|/;
    isnt( $raw, $built->{request}, 'The raw request was changed to carry the real password' );
    throws_ok { $tester->run( { request => $raw } ) }
    'Koha::Exceptions::BadParameter', 'A real password in a raw request is refused';

    # No password, and an empty one, are fine and answer as not valid
    lives_ok {
        $tester->run( { message => 'patron_information', patron_id => $patron->cardnumber } )
    }
    'A request without a password is run';
    lives_ok {
        $tester->run( { message => 'patron_information', patron_id => $patron->cardnumber, patron_password => q{} } )
    }
    'A request with an empty password is run';

    is( $checks, 0, 'No real password was ever checked' );

    $schema->storage->txn_rollback;
};

subtest 'run() patron information detail' => sub {
    plan tests => 14;

    $schema->storage->txn_begin;

    my ( $account, $patron, $item ) = build_test_account();
    $account->av_field_template('[% accountline.description %] owes [% accountline.amountoutstanding %]')->store;
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
    my $tester = Koha::SIP2::MessageTester->new( { account => $account } );

    my $fine_items = sub {
        return [ grep { $_->{field} eq 'AV' } @{ shift->{fields} } ];
    };

    # Without a detail the lists of items, and the templates that format them, are left out
    my $result = $tester->run( { message => 'patron_information', patron_id => $patron->cardnumber } );
    is( scalar @{ $fine_items->($result) }, 0, 'No detail: no fine items in the response' );
    like( $result->{request}, qr/^63001.{18} {10}AO/, 'No detail: the summary field of the request is all spaces' );

    $result =
        $tester->run( { message => 'patron_information', patron_id => $patron->cardnumber, summary => 'fine_items' } );
    like( $result->{request}, qr/^63001.{18} {3}Y {6}AO/, 'Fine items: the request has a Y in the fourth place' );
    is( scalar @{ $fine_items->($result) }, 1, 'Fine items: the fine is in the response' );
    like(
        $fine_items->($result)->[0]->{value}, qr/^Photocopies owes 2\.5/,
        'and is formatted by the template of the account'
    );

    # Another detail brings another list, not the fines
    $result = $tester->run(
        { message => 'patron_information', patron_id => $patron->cardnumber, summary => 'charged_items' } );
    is( scalar @{ $fine_items->($result) }, 0, 'Charged items: the fines are not in the response' );

    # Where the Y goes for each of the details
    my @details = qw( hold_items overdue_items charged_items fine_items recall_items unavailable_holds );
    foreach my $i ( 0 .. $#details ) {
        is(
            Koha::SIP2::MessageTester::_summary( $details[$i] ),
            ( q{ } x $i ) . 'Y' . ( q{ } x ( 9 - $i ) ),
            "$details[$i]: the Y is in place " . ( $i + 1 )
        );
    }
    is( Koha::SIP2::MessageTester::_summary(), q{ } x 10, 'No detail is ten spaces' );

    throws_ok {
        $tester->run( { message => 'patron_information', patron_id => $patron->cardnumber, summary => 'bogus' } )
    }
    'Koha::Exceptions::BadParameter', 'A detail that does not exist is refused';

    $schema->storage->txn_rollback;
};
