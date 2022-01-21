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

    t::lib::Mocks::mock_preference('TwoFactorAuthentication', 1);

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
    $patron->secret('nv4v65dpobpxgzldojsxiii'); # this is base32 already for 'my_top_secret!'
    my $auth = Koha::Auth::TwoFactorAuth->new({ patron => $patron });
    is( $auth->secret32, $patron->secret, 'Base32 secret as expected' );
    $auth->code( $patron->secret ); # trigger conversion by passing base32 to code
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

    t::lib::Mocks::mock_preference('TwoFactorAuthentication', 1);
    my $patron = $builder->build_object({ class => 'Koha::Patrons' });
    $patron->secret('you2wont2guess2it'); # this is base32 btw
    $patron->auth_method('two-factor');
    $patron->store;

    my $auth = Koha::Auth::TwoFactorAuth->new({ patron => $patron });
    my $img_data = $auth->qr_code;
    is( substr($img_data, 0, 22), 'data:image/png;base64,', 'Checking prefix of dataurl' );
    like( substr($img_data, 22), qr/^[a-zA-Z0-9\/=+]+$/, 'Contains base64 chars' );
    is( $auth->qr_code, $img_data, 'Repeated call' );
    $auth->clear;

    # Changing the secret should generate different data, right?
    $patron->secret('no3really3not3cracked'); # base32
    $patron->store;
    $auth = Koha::Auth::TwoFactorAuth->new({ patron => $patron });
    my $img_data02 = $auth->qr_code;
    is( length($img_data02) > 22, 1, 'More characters than prefix' );
    isnt( $img_data02, $img_data, 'Another secret, another image' );

    $schema->storage->txn_rollback;
};

subtest 'send_confirm_notice' => sub {
    plan tests => 4;
    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference('TwoFactorAuthentication', 1);
    my $patron = $builder->build_object({ class => 'Koha::Patrons' });
    $patron->secret('you2wont2guess2it'); # this is base32 btw
    $patron->auth_method('two-factor');
    $patron->store;
    my $auth = Koha::Auth::TwoFactorAuth->new({ patron => $patron });

    # Trivial tests: no patron, no email
    throws_ok { $auth->send_confirm_notice; }
        'Koha::Exceptions::MissingParameter',
        'Croaked on missing patron';
    $patron->set({ email => undef, emailpro => undef, B_email => undef });
    throws_ok { $auth->send_confirm_notice({ patron => $patron }) }
        'Koha::Exceptions::Patron::MissingEmailAddress',
        'Croaked on missing email';

    $patron->email('noreply@doof.nl')->store;
    $auth->send_confirm_notice({ patron => $patron });
    is( Koha::Notice::Messages->search({ borrowernumber => $patron->id, letter_code => '2FA_REGISTER' })->count, 1, 'Found message' );
    $auth->send_confirm_notice({ patron => $patron, deregister => 1 });
    is( Koha::Notice::Messages->search({ borrowernumber => $patron->id, letter_code => '2FA_DEREGISTER' })->count, 1, 'Found message' );

    $schema->storage->txn_rollback;
    $mocked_stuffer->unmock;
};
