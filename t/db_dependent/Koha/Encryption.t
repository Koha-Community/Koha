use Modern::Perl;

use Test::More tests => 1;
use Koha::Encryption;
use t::lib::Mocks;

t::lib::Mocks::mock_config('encryption_key', 'my secret passphrase');

my $string = 'a string to encrypt';

my $crypt = Koha::Encryption->new;
my $encrypted_string = $crypt->encrypt_hex($string);
is( $crypt->decrypt_hex($encrypted_string), $string, 'Decrypted to original text' );
