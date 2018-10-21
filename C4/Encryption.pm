package C4::Encryption;

# Copyright 2018 The National Library of Finland
#
# This file is part of Koha.
#

use Modern::Perl '2015';

use Try::Tiny;
use Scalar::Util qw(blessed);

use IPC::Cmd;
use IPC::Run;

use C4::Encryption::Configuration;

use Koha::Logger;
my $logger = bless({lazyLoad => {category => __PACKAGE__}}, 'Koha::Logger');

=head2 encrypt

Encrypt a file

 @param {String} File path to encrypt
 @param {String} Encryption configuration source, see C4::Encryption::Configuration->new()
 @returns {String} File path to the encrypted file
 @dies if encryption failed

=cut

sub encrypt {
    my ($sourceFilePath, $encryptionConfigSource) = @_;
    $logger->info("Encrypting file '$sourceFilePath'");

    my $config = C4::Encryption::Configuration->new($encryptionConfigSource);

    my $gpgCmd = IPC::Cmd::can_run('gpg');
    die "'gpg' is not installed on your system?" unless $gpgCmd;

    my $verbosity = $logger->is_debug() ? '-vv' :
                    $logger->is_info()  ? '-v' :
                                          '';

    my $cmd = [$gpgCmd, '--batch', '--passphrase-fd', '0', '--cipher-algo', $config->{'cipher-algorithm'}, '--symmetric', $sourceFilePath];
    splice(@$cmd, 1, 0, $verbosity) if $verbosity; #Inject verbosity.

    $logger->info("Encrypting with '@$cmd'");
    my ($in, $out, $err, $exitCode) = ($config->{passphrase}, '', '', undef); # Define input and output pipes
    eval {
        my $program = IPC::Run::harness($cmd, \$in, \$out, \$err); # Start the program and take a reference to the running instance
        IPC::Run::pump($program); # Keep pumping the program until it has consumed all the data going in
        IPC::Run::finish($program);
        $exitCode = IPC::Run::result($program);
    };

    $logger->logdie("Encrypting with '@$cmd' failed with exit code '".($exitCode || 'undef')."'\nSTDOUT: $out\nSTDERR: $err\nDIE: $@") if ($exitCode || $@);
    $logger->debug($out.' '.$err);

    die "Encryption seems to have succeeded, but the encrypted file '$sourceFilePath.gpg' seems to be missing?" unless (-e "$sourceFilePath.gpg");

    return "$sourceFilePath.gpg";
}

1;
