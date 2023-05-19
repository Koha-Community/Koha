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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

$| = 1;
use Module::Load::Conditional qw/check_install/;
use Test::More;
use Test::MockModule;
use Test::Warn;
use File::Temp qw(tempdir);

use t::lib::Mocks::Logger;

use utf8;
use CGI qw(-utf8 );
use C4::Context;

BEGIN {
    if ( check_install( module => 'Test::DBIx::Class' ) ) {
        plan tests => 18;
    }
    else {
        plan skip_all => "Need Test::DBIx::Class";
    }
}

use Test::DBIx::Class {
    schema_class => 'Koha::Schema',
    connect_info => [ 'dbi:SQLite:dbname=:memory:', '', '' ]
};

# Mock Variables
my $matchpoint = 'userid';
my $autocreate = 0;
my $welcome    = 0;
my $sync       = 0;
my %mapping    = (
    'userid'       => { 'is' => 'uid' },
    'surname'      => { 'is' => 'sn' },
    'dateexpiry'   => { 'is' => 'exp' },
    'categorycode' => { 'is' => 'cat' },
    'address'      => { 'is' => 'add' },
    'city'         => { 'is' => 'city' },
    'emailpro'     => { 'is' => 'emailpro' },
);
$ENV{'uid'}      = "test1234";
$ENV{'sn'}       = undef;
$ENV{'exp'}      = undef;
$ENV{'cat'}      = undef;
$ENV{'add'}      = undef;
$ENV{'city'}     = undef;
$ENV{'emailpro'} = undef;

# Setup Mocks
## Mock Context
my $context = Test::MockModule->new('C4::Context');

### Mock ->config
$context->mock( 'config', \&mockedConfig );

### Mock ->preference
my $OPACBaseURL = "testopac.com";
my $staffClientBaseURL = "teststaff.com";
$context->mock( 'preference', \&mockedPref );

### Mock ->tz
$context->mock( 'timezone', sub { return 'local'; } );

### Mock ->interface
my $interface = 'opac';
$context->mock( 'interface', \&mockedInterface );

## Mock Database
my $database = Test::MockModule->new('Koha::Database');

### Mock ->schema
$database->mock( 'schema', \&mockedSchema );

### Mock Letters
my $mocked_letters = Test::MockModule->new('C4::Letters');
# we want to test the params
$mocked_letters->mock( 'GetPreparedLetter', sub {
    warn "GetPreparedLetter called";
    return 1;
});
# we don't care about EnqueueLetter for now
$mocked_letters->mock( 'EnqueueLetter', sub {
    warn "EnqueueLetter called";
    # return a 'message_id'
    return 42;
});
# we don't care about EnqueueLetter for now
$mocked_letters->mock( 'SendQueuedMessages', sub {
    my $params = shift;
    warn "SendQueuedMessages called with message_id: $params->{message_id}";
    return 1;
});

# Tests
##############################################################

my $logger = t::lib::Mocks::Logger->new();

# Can module load
use C4::Auth_with_shibboleth qw( shib_ok login_shib_url get_login_shib checkpw_shib );
require_ok('C4::Auth_with_shibboleth');

# Subroutine tests
## shib_ok
subtest "shib_ok tests" => sub {
    plan tests => 5;
    my $result;

    # correct config, no debug
    is( shib_ok(), '1', "good config" );

    # bad config, no debug
    $matchpoint = undef;
    warnings_are { $result = shib_ok() }
    [ { carped => 'shibboleth matchpoint not defined' }, ],
      "undefined matchpoint = fatal config, warning given";
    is( $result, '0', "bad config" );

    $matchpoint = 'email';
    warnings_are { $result = shib_ok() }
    [ { carped => 'shibboleth matchpoint not mapped' }, ],
      "unmapped matchpoint = fatal config, warning given";
    is( $result, '0', "bad config" );

    # add test for undefined shibboleth block
    $logger->clear;
    reset_config();
};

## logout_shib
#my $query = CGI->new();
#is(logout_shib($query),"https://".$opac."/Shibboleth.sso/Logout?return="."https://".$opac,"logout_shib");

## login_shib_url
subtest "login_shib_url tests" => sub {
    plan tests => 2;

    my $string = 'language=en-GB&param="heh❤"';
    my $query_string = Encode::encode('UTF-8', $string);
    my $query_string_uri_escaped = URI::Escape::uri_escape_utf8('?'.$string);

    local $ENV{REQUEST_METHOD} = 'GET';
    local $ENV{QUERY_STRING}   = $query_string;
    local $ENV{SCRIPT_NAME}    = '/cgi-bin/koha/opac-user.pl';
    my $query = CGI->new($query_string);
    is(
        login_shib_url($query),
        'https://testopac.com'
          . '/Shibboleth.sso/Login?target='
          . 'https://testopac.com/cgi-bin/koha/opac-user.pl'
          . $query_string_uri_escaped,
        "login shib url"
    );

    my $post_params = 'user=bob&password=wideopen';
    local $ENV{REQUEST_METHOD} = 'POST';
    local $ENV{CONTENT_LENGTH} = length($post_params);

    my $dir = tempdir( CLEANUP => 1 );
    my $infile = "$dir/in.txt";
    open my $fh_write, '>', $infile or die "Could not open '$infile' $!";
    print $fh_write $post_params;
    close $fh_write;

    open my $fh_read, '<', $infile or die "Could not open '$infile' $!";

    $query = CGI->new($fh_read);
    is(
        login_shib_url($query),
        'https://testopac.com'
          . '/Shibboleth.sso/Login?target='
          . 'https://testopac.com/cgi-bin/koha/opac-user.pl',
        "login shib url"
    );

    close $fh_read;
};

## get_login_shib
subtest "get_login_shib tests" => sub {

    plan tests => 3;

    my $login;

    $login = get_login_shib();

    $logger->debug_is("koha borrower field to match: userid", "borrower match field debug info")
           ->debug_is("shibboleth attribute to match: uid",   "shib match attribute debug info")
           ->clear();

    is( $login, "test1234", "good config, attribute value returned" );
};

## checkpw_shib
subtest "checkpw_shib tests" => sub {

    plan tests => 34;

    my $shib_login;
    my ( $retval, $retcard, $retuserid );

    # Setup Mock Database Data
    fixtures_ok [
        'Borrower' => [
            [qw/cardnumber userid surname address city email/],
            [qw/testcardnumber test1234 renvoize myaddress johnston  /],
            [qw/testcardnumber1 test12345 clamp1 myaddress quechee kid@clamp.io/],
            [qw/testcardnumber2 test123456 clamp2 myaddress quechee kid@clamp.io/],
        ],
        'Category' => [ [qw/categorycode default_privacy/], [qw/S never/], ]
      ],
      'Installed some custom fixtures via the Populate fixture class';

    # good user
    $shib_login = "test1234";
    ( $retval, $retcard, $retuserid ) = checkpw_shib($shib_login);

    is( $logger->count(), 2,          "Two debugging entries");
    is( $retval,    "1",              "user authenticated" );
    is( $retcard,   "testcardnumber", "expected cardnumber returned" );
    is( $retuserid, "test1234",       "expected userid returned" );
    $logger->debug_is("koha borrower field to match: userid", "borrower match field debug info")
           ->debug_is("shibboleth attribute to match: uid",   "shib match attribute debug info")
           ->clear();

    # bad user
    $shib_login = 'martin';
    ( $retval, $retcard, $retuserid ) = checkpw_shib($shib_login);
    is( $retval, "0", "user not authenticated" );
    $logger->debug_is("koha borrower field to match: userid", "borrower match field debug info")
           ->debug_is("shibboleth attribute to match: uid",   "shib match attribute debug info")
           ->clear();

    # duplicated matchpoint
    $matchpoint = 'email';
    $mapping{'email'} = { is => 'email' };
    $shib_login = 'kid@clamp.io';
    ( $retval, $retcard, $retuserid ) = checkpw_shib($shib_login);
    is( $retval, "0", "user not authenticated if duplicated matchpoint" );
    $logger->debug_is("koha borrower field to match: email",  "borrower match field debug info")
           ->debug_is("shibboleth attribute to match: email", "shib match attribute debug info")
           ->clear();

    ( $retval, $retcard, $retuserid ) = checkpw_shib($shib_login);
    $logger->debug_is("koha borrower field to match: email",  "borrower match field debug info")
           ->debug_is("shibboleth attribute to match: email", "shib match attribute debug info")
           ->warn_is('There are several users with email of kid@clamp.io, matchpoints must be unique', "duplicated matchpoint warned with debug")
           ->clear();

    reset_config();

    # autocreate user (welcome)
    $autocreate      = 1;
    $welcome         = 1;
    $shib_login      = 'test4321';
    $ENV{'uid'}      = 'test4321';
    $ENV{'sn'}       = "pika";
    $ENV{'exp'}      = "2017";
    $ENV{'cat'}      = "S";
    $ENV{'add'}      = 'Address';
    $ENV{'city'}     = 'City';
    $ENV{'emailpro'} = 'me@myemail.com';

    warnings_are {
        ( $retval, $retcard, $retuserid ) = checkpw_shib($shib_login);
    }
    [
        'GetPreparedLetter called',
        'EnqueueLetter called',
        'SendQueuedMessages called with message_id: 42'
    ],
      "WELCOME notice Prepared, Enqueued and Send";
    is( $retval,    "1",        "user authenticated" );
    is( $retuserid, "test4321", "expected userid returned" );
    $logger->debug_is("koha borrower field to match: userid", "borrower match field debug info")
           ->debug_is("shibboleth attribute to match: uid",   "shib match attribute debug info")
           ->clear();

    ok my $new_user = ResultSet('Borrower')
      ->search( { 'userid' => 'test4321' }, { rows => 1 } ), "new user found";
    is_fields [qw/surname dateexpiry address city/], $new_user->next,
      [qw/pika 2017 Address City/],
      'Found $new_users surname';
    $autocreate = 0;
    $welcome    = 0;

    # sync user
    $sync = 1;
    $ENV{'city'} = 'AnotherCity';
    ( $retval, $retcard, $retuserid ) = checkpw_shib($shib_login);
    $logger->debug_is("koha borrower field to match: userid", "borrower match field debug info")
           ->debug_is("shibboleth attribute to match: uid",   "shib match attribute debug info")
           ->clear();

    ok my $sync_user = ResultSet('Borrower')
      ->search( { 'userid' => 'test4321' }, { rows => 1 } ), "sync user found";

    is_fields [qw/surname dateexpiry address city/], $sync_user->next,
      [qw/pika 2017 Address AnotherCity/],
      'Found $sync_user synced city';
    $sync = 0;

    # good user
    $shib_login = "test1234";
    ( $retval, $retcard, $retuserid ) = checkpw_shib($shib_login);
    is( $retval,    "1",              "user authenticated" );
    is( $retcard,   "testcardnumber", "expected cardnumber returned" );
    is( $retuserid, "test1234",       "expected userid returned" );
    $logger->debug_is("koha borrower field to match: userid", "borrower match field debug info")
           ->debug_is("shibboleth attribute to match: uid",   "shib match attribute debug info")
           ->clear();

    # bad user
    $shib_login = "martin";
    ( $retval, $retcard, $retuserid ) = checkpw_shib($shib_login);
    is( $retval, "0", "user not authenticated" );
    $logger->info_is("There are several users with userid of martin, matchpoints must be unique", "Duplicated matchpoint warned to info");
};

## _get_uri - opac
$OPACBaseURL = "testopac.com";
is( C4::Auth_with_shibboleth::_get_uri(),
    "https://testopac.com", "https opac uri returned" );

$logger->clear;

$OPACBaseURL = "http://testopac.com";
my $result = C4::Auth_with_shibboleth::_get_uri();
is( $result, "https://testopac.com", "https opac uri returned" );
$logger->warn_is("Shibboleth requires OPACBaseURL/staffClientBaseURL to use the https protocol!", "Improper protocol logged to warn")
       ->clear();

$OPACBaseURL = "https://testopac.com";
is( C4::Auth_with_shibboleth::_get_uri(),
    "https://testopac.com", "https opac uri returned" );

$logger->clear();

$OPACBaseURL = undef;
$result = C4::Auth_with_shibboleth::_get_uri();
is( $result, "https://", "https $interface uri returned" );

$logger->warn_is("Syspref staffClientBaseURL or OPACBaseURL not set!", "undefined OPACBaseURL - received expected warning")
       ->clear();

## _get_uri - intranet
$interface = 'intranet';
$staffClientBaseURL = "teststaff.com";
is( C4::Auth_with_shibboleth::_get_uri(),
    "https://teststaff.com", "https $interface uri returned" );


$logger->clear;

$staffClientBaseURL = "http://teststaff.com";
$result = C4::Auth_with_shibboleth::_get_uri();
is( $result, "https://teststaff.com", "https $interface uri returned" );
$logger->warn_is("Shibboleth requires OPACBaseURL/staffClientBaseURL to use the https protocol!")
       ->clear;

$staffClientBaseURL = "https://teststaff.com";
is( C4::Auth_with_shibboleth::_get_uri(),
    "https://teststaff.com", "https $interface uri returned" );
is( $logger->count(), 0, 'No logging' );

$staffClientBaseURL = undef;
$result = C4::Auth_with_shibboleth::_get_uri();
is( $result, "https://", "https $interface uri returned" );
$logger->warn_is("Syspref staffClientBaseURL or OPACBaseURL not set!", "undefined staffClientBaseURL - received expected warning")
       ->clear;

## _get_shib_config
# Internal helper function, covered in tests above

sub mockedConfig {
    my $param = shift;

    my %shibboleth = (
        'autocreate' => $autocreate,
        'welcome'    => $welcome,
        'sync'       => $sync,
        'matchpoint' => $matchpoint,
        'mapping'    => \%mapping
    );

    return \%shibboleth;
}

sub mockedPref {
    my $param = $_[1];
    my $return;

    if ( $param eq 'OPACBaseURL' ) {
        $return = $OPACBaseURL;
    }

    if ( $param eq 'staffClientBaseURL' ) {
        $return = $staffClientBaseURL;
    }

    if ( $param eq 'AutoEmailPrimaryAddress' ) {
        $return = 'OFF';
    }

    if ( $param eq 'EmailFieldPrecedence' ) {
        $return = 'emailpro';
    }

    return $return;
}

sub mockedInterface {
    return $interface;
}

sub mockedSchema {
    return Schema();
}

## Convenience method to reset config
sub reset_config {
    $matchpoint = 'userid';
    $autocreate = 0;
    $welcome = 0;
    $sync = 0;
    %mapping = (
        'userid'       => { 'is' => 'uid' },
        'surname'      => { 'is' => 'sn' },
        'dateexpiry'   => { 'is' => 'exp' },
        'categorycode' => { 'is' => 'cat' },
        'address'      => { 'is' => 'add' },
        'city'         => { 'is' => 'city' },
        'emailpro'     => { 'is' => 'emailpro' },
    );
    $ENV{'uid'}      = "test1234";
    $ENV{'sn'}       = undef;
    $ENV{'exp'}      = undef;
    $ENV{'cat'}      = undef;
    $ENV{'add'}      = undef;
    $ENV{'city'}     = undef;
    $ENV{'emailpro'} = undef;

    return 1;
}

