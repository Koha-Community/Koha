use Modern::Perl;
use Test::More tests => 1;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::Database;
use Koha::Auth::TwoFactorAuth;

our $schema = Koha::Database->new->schema;
our $builder = t::lib::TestBuilder->new;

subtest 'qr_code' => sub {
    plan tests => 9;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference('TwoFactorAuthentication', 1);
    my $patron = $builder->build_object({ class => 'Koha::Patrons' });

    # Testing without secret (might change later on)
    is( $patron->secret, undef, 'Secret still undefined' );
    my $auth = Koha::Auth::TwoFactorAuth->new({ patron => $patron });
    is( $auth->secret, undef, 'Still no secret yet as expected' );
    # Auth::GoogleAuth will generate a secret when calling qr_code
    my $img_data = $auth->qr_code;
    is( length($auth->secret32), 16, 'Secret of 16 base32 chars expected' );
    is( length($img_data) > 22, 1, 'Dataurl not empty too' ); # prefix is 22
    $auth->clear;

    # Update patron data
    $patron->secret('you2wont2guess2it'); # this is base32 btw
    $patron->auth_method('two-factor');
    $patron->store;

    $auth = Koha::Auth::TwoFactorAuth->new({ patron => $patron });
    $img_data = $auth->qr_code;
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
