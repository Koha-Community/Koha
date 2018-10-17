#!/usr/bin/env perl

use Modern::Perl;

use t::lib::Mocks;
use Test::More;
use Test::MockModule;

use Module::Load::Conditional qw( can_load check_install );

BEGIN {
    if ( check_install( module => 'Test::DBIx::Class' ) ) {
        plan tests => 5;
    } else {
        plan skip_all => "Need Test::DBIx::Class"
    }
}

use Test::DBIx::Class;

my $db = Test::MockModule->new('Koha::Database');
$db->mock( _new_schema => sub { return Schema(); } );

SKIP: {
    skip "cannot find WebService::ILS::OverDrive::Patron", 5
      unless can_load( modules => { 'WebService::ILS::OverDrive::Patron' => undef } );

    use_ok('Koha::ExternalContent::OverDrive');

    t::lib::Mocks::mock_preference('SessionStorage','tmp');

    t::lib::Mocks::mock_preference('OverDriveClientKey', 'DUMMY');
    t::lib::Mocks::mock_preference('OverDriveClientSecret', 'DUMMY');
    t::lib::Mocks::mock_preference('OverDriveLibraryID', 'DUMMY');

    my $client = Koha::ExternalContent::OverDrive->new({koha_session_id => 'DUMMY'});

    my $user_agent_string = $client->user_agent->agent();
    ok ($user_agent_string =~ m/^Koha/, 'User Agent string is set')
      or diag("User Agent string: $user_agent_string");

    my $base_url = "http://mykoha.org";
    ok ($client->auth_url($base_url), 'auth_url()');
    local $@;
    eval { $client->auth_by_code("blah", $base_url) };
    ok($@, "auth_by_code() dies with bogus credentials");
    SKIP: {
        skip "No exception", 1 unless $@;
        my $error_message = $client->error_message($@);
        ok($error_message =~ m/Authorization Failed/i, "error_message()")
          or diag("Original:\n$@\nTurned into:\n$error_message");
    }
}
