use Modern::Perl '2015';
use utf8;
use English;
use Carp::Always;

use Test::Most tests => 1;
use File::Temp;

use C4::Encryption::Configuration;

subtest "Scenario: C4::Encryption::Configuration slurp configuration from various sources", sub {
    plan tests => 4;

    my $source = '1';
    C4::Context->set_preference('EncryptionConfiguration', "passphrase: 1234\ncipher-algorithm: AES-256");
    eq_or_diff(C4::Encryption::Configuration->new($source), bless({ passphrase => '1234', 'cipher-algorithm' => 'AES-256' }, 'C4::Encryption::Configuration'),
               "Slurping encryption configuration from the system preference");

    my ($fh, $fileName) = File::Temp::tempfile(UNLINK => 1);
    print $fh "passphrase: 4321\ncipher-algorithm: AES-128"; close($fh); #Flush to disk
    $source = $fileName;
    eq_or_diff(C4::Encryption::Configuration->new($source), bless({ passphrase => '4321', 'cipher-algorithm' => 'AES-128' }, 'C4::Encryption::Configuration'),
               "Slurping encryption configuration from a file");

    $source = "passphrase: 4231\ncipher-algorithm: TWOFISH";
    eq_or_diff(C4::Encryption::Configuration->new($source), bless({ passphrase => '4231', 'cipher-algorithm' => 'TWOFISH' }, 'C4::Encryption::Configuration'),
               "Slurping encryption configuration from commandline");

    throws_ok(sub { C4::Encryption::Configuration->new('') }, qr/must have a passphrase/,
               "Slurping with no passphrase dies");
};

done_testing();
