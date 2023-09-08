#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 3;
use Test::Exception;
use Test::MockModule;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::Database;
use Koha::Auth::TwoFactorAuth;
use Koha::Exceptions;
use Koha::Exceptions::Patron;
use Koha::Notice::Messages;

our $schema = Koha::Database->new->schema;
our $builder = t::lib::TestBuilder->new;
our $mocked_stuffer =  Test::MockModule->new('Email::Stuffer');
$mocked_stuffer->mock( 'send_or_die', sub { warn 'I do not send mails now'; } );

subtest 'new' => sub {
    plan tests => 10;
    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference('TwoFactorAuthentication', 'enabled');
    t::lib::Mocks::mock_config('encryption_key', 'bad_example');

    # Trivial test: no patron, no object
    throws_ok { Koha::Auth::TwoFactorAuth->new; }
        'Koha::Exceptions::MissingParameter',
        'Croaked on missing patron';
    throws_ok { Koha::Auth::TwoFactorAuth->new({ patron => 'Henk', secret => q<> }) }
        'Koha::Exceptions::MissingParameter',
        'Croaked on missing patron object';

    # Testing without secret
    my $patron = $builder->build_object({ class => 'Koha::Patrons' });
    is( $patron->secret, undef, 'Secret still undefined' );
    throws_ok { Koha::Auth::TwoFactorAuth->new({ patron => $patron }) }
        'Koha::Exceptions::MissingParameter', 'Croaks on missing secret';
    # Pass a wrong encoded secret
    throws_ok { Koha::Auth::TwoFactorAuth->new({ patron => $patron, secret32 => '@' }) }
        'Koha::Exceptions::BadParameter',
        'Croaked on wrong encoding';

    # Test passing secret or secret32 (converted to base32)
    $patron->encode_secret('nv4v65dpobpxgzldojsxiii'); # this is base32 already for 'my_top_secret!'
    my $auth = Koha::Auth::TwoFactorAuth->new({ patron => $patron });
    is( $auth->secret32, $patron->decoded_secret, 'Base32 secret as expected' );
    $auth->code( $patron->decoded_secret ); # trigger conversion by passing base32 to code
    is( $auth->secret, 'my_top_secret!', 'Decoded secret fine too' );
    # The other way around
    $auth = Koha::Auth::TwoFactorAuth->new({ patron => $patron, secret => 'my_top_secret!' });
    is( $auth->secret32, undef, 'GoogleAuth did not yet encode' );
    $auth->code; # this will trigger base32 encoding now
    is( $auth->secret, 'my_top_secret!', 'Check secret' );
    is( $auth->secret32, 'nv4v65dpobpxgzldojsxiii', 'Check secret32' );

    $schema->storage->txn_rollback;
};

subtest 'qr_code' => sub {
    plan tests => 5;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference('TwoFactorAuthentication', 'enabled');
    t::lib::Mocks::mock_config('encryption_key', 'bad_example');
    my $patron = $builder->build_object({ class => 'Koha::Patrons' });
    $patron->encode_secret('you2wont2guess2it'); # this is base32 btw
    $patron->auth_method('two-factor');
    $patron->store;

    my $auth = Koha::Auth::TwoFactorAuth->new({ patron => $patron });
    my $img_data = $auth->qr_code;
    is( substr($img_data, 0, 22), 'data:image/png;base64,', 'Checking prefix of dataurl' );
    like( substr($img_data, 22), qr/^[a-zA-Z0-9\/=+]+$/, 'Contains base64 chars' );
    is( $auth->qr_code, $img_data, 'Repeated call' );
    $auth->clear;

    # Changing the secret should generate different data, right?
    $patron->encode_secret('no3really3not3cracked'); # base32
    $patron->store;
    $auth = Koha::Auth::TwoFactorAuth->new({ patron => $patron });
    my $img_data02 = $auth->qr_code;
    is( length($img_data02) > 22, 1, 'More characters than prefix' );
    isnt( $img_data02, $img_data, 'Another secret, another image' );

    $schema->storage->txn_rollback;
};

subtest 'verify' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'TwoFactorAuthentication', 'enabled' );
    t::lib::Mocks::mock_config( 'encryption_key', 'bad_example' );
    t::lib::Mocks::mock_config( 'mfa_range',      undef );
    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    $patron->encode_secret('6557s35ui2gyhkmuuvei6rpk44');    # this is base32 btw
    $patron->auth_method('two-factor');
    $patron->store;

    my $auth      = Koha::Auth::TwoFactorAuth->new( { patron => $patron } );
    my $code      = 394342;
    my $timestamp = 1694137671;
    my $verified;
    $verified = $auth->verify( $code, undef, undef, $timestamp, undef );
    is( $verified, 1, "code valid within 1 minute" );

    $verified = $auth->verify( $code, undef, undef, ( $timestamp + 60 ), undef );
    is( $verified, 0, "code invalid within 2 minutes" );

    t::lib::Mocks::mock_config( 'mfa_range', 10 );
    $verified = $auth->verify( $code, undef, undef, ( $timestamp + 300 ), undef );
    is( $verified, 1, "code valid within 5 minutes" );

    $verified = $auth->verify( $code, undef, undef, ( $timestamp + 330 ), undef );
    is( $verified, 0, "code valid within 5.5 minutes" );

    $schema->storage->txn_rollback;
};
