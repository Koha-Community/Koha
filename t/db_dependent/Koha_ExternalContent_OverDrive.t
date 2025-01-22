#!/usr/bin/env perl

use Modern::Perl;

use Test::NoWarnings;
use Test::More;
use Test::MockModule;
use t::lib::Mocks;

use Module::Load::Conditional qw( can_load check_install );

BEGIN {
    if ( check_install( module => 'WebService::ILS::OverDrive::Patron' ) ) {
        plan tests => 7;
    } else {
        plan skip_all => "Need WebService::ILS::OverDrive::Patron";
    }
}

use_ok('Koha::ExternalContent::OverDrive');

t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

t::lib::Mocks::mock_preference( 'OverDriveClientKey',    'DUMMY' );
t::lib::Mocks::mock_preference( 'OverDriveClientSecret', 'DUMMY' );
t::lib::Mocks::mock_preference( 'OverDriveLibraryID',    'DUMMY' );

my $client = Koha::ExternalContent::OverDrive->new( { koha_session_id => 'DUMMY' } );

my $user_agent_string = $client->user_agent->agent();
ok( $user_agent_string =~ m/^Koha/, 'User Agent string is set' )
    or diag("User Agent string: $user_agent_string");

my $base_url = "http://mykoha.org";
ok( $client->auth_url($base_url), 'auth_url()' );
local $@;
eval { $client->auth_by_code( "blah", $base_url ) };
ok( $@, "auth_by_code() dies with bogus credentials" );
SKIP: {
    skip "No exception", 1 unless $@;
    my $error_message = $client->error_message($@);
    ok( $error_message =~ m/Authorization Failed/i, "error_message()" )
        or diag("Original:\n$@\nTurned into:\n$error_message");
}

subtest 'logger() tests' => sub {

    plan tests => 2;

    my $external_content = Koha::ExternalContent::OverDrive->new( { koha_session_id => 'DUMMY' } );
    ok( $external_content->can('logger'), 'A Koha::ExternalContent object has a logger accessor' );
    is( ref( $external_content->logger ), 'Koha::Logger', 'The accessor return the right object type' );
};
