#!/usr/bin/perl

# Copyright 2014, 2023 Koha development team
#
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
use utf8;

use Test::More tests => 5;
use Test::MockModule;
use Test::Warn;
use CGI qw(-utf8 );
use File::Temp qw(tempdir);

use t::lib::Mocks;
use t::lib::Mocks::Logger;
use t::lib::TestBuilder;

use C4::Auth_with_shibboleth qw( shib_ok login_shib_url get_login_shib checkpw_shib );
use Koha::Database;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;
my $logger = t::lib::Mocks::Logger->new();

# Mock variables
my $shibboleth;
change_config({});
my $interface = 'opac';

# Mock few preferences
t::lib::Mocks::mock_preference('OPACBaseURL', 'testopac.com' );
t::lib::Mocks::mock_preference('StaffClientBaseURL', 'teststaff.com' );
t::lib::Mocks::mock_preference( 'EmailFieldPrimary', 'OFF' );
t::lib::Mocks::mock_preference( 'EmailFieldPrecedence', 'emailpro' );

# Mock Context: config, tz and interface
my $context = Test::MockModule->new('C4::Context');
$context->mock( 'config', sub { return $shibboleth; } ); # easier than caching by Mocks::mock_config
$context->mock( 'timezone', sub { return 'local'; } );
$context->mock( 'interface', sub { return $interface; } );

# Mock Letters: GetPreparedLetter, EnqueueLetter and SendQueuedMessages
# We want to test the params
my $mocked_letters = Test::MockModule->new('C4::Letters');
$mocked_letters->mock( 'GetPreparedLetter', sub {
    warn "GetPreparedLetter called";
    return 1;
});
$mocked_letters->mock( 'EnqueueLetter', sub {
    warn "EnqueueLetter called";
    # return a 'message_id'
    return 42;
});
$mocked_letters->mock( 'SendQueuedMessages', sub {
    my $params = shift;
    warn "SendQueuedMessages called with message_id: $params->{message_id}";
    return 1;
});

# Start testing ----------------------------------------------------------------

subtest "shib_ok tests" => sub {
    plan tests => 5;
    my $result;

    # correct config, no debug
    is( shib_ok(), '1', "good config" );

    # bad config, no debug
    delete $shibboleth->{matchpoint};
    warnings_are { $result = shib_ok() }
    [ { carped => 'shibboleth matchpoint not defined' }, ],
      "undefined matchpoint = fatal config, warning given";
    is( $result, '0', "bad config" );

    change_config({ matchpoint => 'email' });
    warnings_are { $result = shib_ok() }
    [ { carped => 'shibboleth matchpoint not mapped' }, ],
      "unmapped matchpoint = fatal config, warning given";
    is( $result, '0', "bad config" );

    # add test for undefined shibboleth block
    $logger->clear;
    change_config({});
};

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

subtest "get_login_shib tests" => sub {
    plan tests => 3;

    my $login = get_login_shib();
    $logger->debug_is("koha borrower field to match: userid", "borrower match field debug info")
           ->debug_is("shibboleth attribute to match: uid",   "shib match attribute debug info")
           ->clear();
    is( $login, "test1234", "good config, attribute value returned" );
};

subtest "checkpw_shib tests" => sub {
    plan tests => 33;

    # Test borrower data
    my $test_borrowers = [
        { cardnumber => 'testcardnumber', userid => 'test1234', surname => 'renvoize', address => 'myaddress', city => 'johnston', email => undef },
        { cardnumber => 'testcardnumber1', userid => 'test12345', surname => 'clamp1', address => 'myaddress', city => 'quechee', email => 'kid@clamp.io' },
        { cardnumber => 'testcardnumber2', userid => 'test123456', surname => 'clamp2', address => 'myaddress', city => 'quechee', email => 'kid@clamp.io' },
    ];
    my $category = $builder->build_object({ class => 'Koha::Patron::Categories', value => { default_privacy => 'never' }});
    $builder->build_object({ class => 'Koha::Patrons', value => { %$_, categorycode => $category->categorycode }}) for @$test_borrowers;
    my $library = $builder->build_object({ class => 'Koha::Libraries' });

    # good user
    my $shib_login = "test1234";
    my ( $retval, $retcard, $retuserid ) = checkpw_shib($shib_login);
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
    change_config({ matchpoint => 'email', mapping => { email => { is => 'email' }} });
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

    # autocreate user (welcome)
    change_config({ autocreate => 1, welcome => 1 });
    $shib_login      = 'test4321';
    $ENV{'uid'}      = 'test4321';
    $ENV{'sn'}       = "pika";
    $ENV{'exp'}      = "2017-01-01";
    $ENV{'cat'}      = $category->categorycode;
    $ENV{'add'}      = 'Address';
    $ENV{'city'}     = 'City';
    $ENV{'emailpro'} = 'me@myemail.com';
    $ENV{branchcode} = $library->branchcode; # needed since T::D::C does no longer hides the FK constraint

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

    ok my $new_user = $schema->resultset('Borrower')
      ->search( { 'userid' => 'test4321' }, { rows => 1 } ), "new user found";
    my $rec = $new_user->next;
    is_deeply( [ map { $rec->$_ } qw/surname dateexpiry address city/ ],
        [qw/pika 2017-01-01 Address City/],
        'Found $new_user surname' );

    # sync user
    $shibboleth->{sync} = 1;
    $ENV{'city'} = 'AnotherCity';
    ( $retval, $retcard, $retuserid ) = checkpw_shib($shib_login);
    $logger->debug_is("koha borrower field to match: userid", "borrower match field debug info")
           ->debug_is("shibboleth attribute to match: uid",   "shib match attribute debug info")
           ->clear();

    ok my $sync_user = $schema->resultset('Borrower')
      ->search( { 'userid' => 'test4321' }, { rows => 1 } ), "sync user found";

    $rec = $sync_user->next;
    is_deeply( [ map { $rec->$_ } qw/surname dateexpiry address city/ ],
        [qw/pika 2017-01-01 Address AnotherCity/],
        'Found $sync_user synced city' );
    change_config({ sync => 0 });

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
    $logger->info_is("No users with userid of martin found and autocreate is disabled", "Duplicated matchpoint warned to info");
};

subtest 'get_uri' => sub {
    plan tests => 13;
    # Tests for OPAC
    t::lib::Mocks::mock_preference('OPACBaseURL', 'testopac.com' );
    is( C4::Auth_with_shibboleth::_get_uri(),
        "https://testopac.com", "https opac uri returned" );

    $logger->clear;

    t::lib::Mocks::mock_preference('OPACBaseURL', 'http://testopac.com' );
    my $result = C4::Auth_with_shibboleth::_get_uri();
    is( $result, "https://testopac.com", "https opac uri returned" );
    $logger->warn_is("Shibboleth requires OPACBaseURL/staffClientBaseURL to use the https protocol!", "Improper protocol logged to warn")
           ->clear();

    t::lib::Mocks::mock_preference('OPACBaseURL', 'https://testopac.com' );
    is( C4::Auth_with_shibboleth::_get_uri(),
        "https://testopac.com", "https opac uri returned" );

    $logger->clear();

    t::lib::Mocks::mock_preference('OPACBaseURL', undef );
    $result = C4::Auth_with_shibboleth::_get_uri();
    is( $result, "https://", "https $interface uri returned" );

    $logger->warn_is("Syspref staffClientBaseURL or OPACBaseURL not set!", "undefined OPACBaseURL - received expected warning")
           ->clear();

    # Tests for staff client
    $interface = 'intranet';
    t::lib::Mocks::mock_preference('StaffClientBaseURL', 'teststaff.com' );
    is( C4::Auth_with_shibboleth::_get_uri(),
        "https://teststaff.com", "https $interface uri returned" );

    $logger->clear;

    t::lib::Mocks::mock_preference('StaffClientBaseURL', 'http://teststaff.com' );
    $result = C4::Auth_with_shibboleth::_get_uri();
    is( $result, "https://teststaff.com", "https $interface uri returned" );
    $logger->warn_is("Shibboleth requires OPACBaseURL/staffClientBaseURL to use the https protocol!", 'check protocol warn')
           ->clear;

    t::lib::Mocks::mock_preference('StaffClientBaseURL', 'https://teststaff.com' );
    is( C4::Auth_with_shibboleth::_get_uri(),
        "https://teststaff.com", "https $interface uri returned" );
    is( $logger->count(), 0, 'No logging' );

    t::lib::Mocks::mock_preference('StaffClientBaseURL', undef );
    $result = C4::Auth_with_shibboleth::_get_uri();
    is( $result, "https://", "https $interface uri returned" );
    $logger->warn_is("Syspref staffClientBaseURL or OPACBaseURL not set!", "undefined staffClientBaseURL - received expected warning")
           ->clear;
};
$schema->storage->txn_rollback;

# Internal helper function

sub change_config {
    my $params = shift;

    my %mapping = (
        'userid'       => { 'is' => 'uid' },
        'surname'      => { 'is' => 'sn' },
        'dateexpiry'   => { 'is' => 'exp' },
        'categorycode' => { 'is' => 'cat' },
        'address'      => { 'is' => 'add' },
        'city'         => { 'is' => 'city' },
        'emailpro'     => { 'is' => 'emailpro' },
        'branchcode'   => { 'is' => 'branchcode' },
    );
    if( exists $params->{mapping} ) {
        $mapping{$_} = $params->{mapping}->{$_} for keys %{$params->{mapping}};
    }
    $shibboleth = {
        autocreate => $params->{autocreate} // 0,
        welcome    => $params->{welcome} // 0,
        sync       => $params->{sync} // 0,
        matchpoint => $params->{matchpoint} // 'userid',
        mapping    => \%mapping,
    };

    # Change environment too
    $ENV{'uid'}      = "test1234";
    $ENV{'sn'}       = undef;
    $ENV{'exp'}      = undef;
    $ENV{'cat'}      = undef;
    $ENV{'add'}      = undef;
    $ENV{'city'}     = undef;
    $ENV{'emailpro'} = undef;
}
