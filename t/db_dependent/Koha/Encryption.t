use Modern::Perl;

use Test::More tests => 2;
use Test::Exception;
use t::lib::Mocks;
use Koha::Encryption;

t::lib::Mocks::mock_config( 'encryption_key', 'my secret passphrase' );

my $string = 'a string to encrypt';

my $crypt            = Koha::Encryption->new;
my $encrypted_string = $crypt->encrypt_hex($string);
is( $crypt->decrypt_hex($encrypted_string), $string, 'Decrypted to original text' );

# Check if exception raised when key is empty or missing
t::lib::Mocks::mock_config( 'encryption_key', '' );
throws_ok { $crypt = Koha::Encryption->new } 'Koha::Exceptions::MissingParameter', 'Exception raised';
