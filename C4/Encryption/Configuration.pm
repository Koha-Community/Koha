package C4::Encryption::Configuration;

# Copyright 2018 The National Library of Finland
#
# This file is part of Koha.
#

use File::Slurp;
use YAML::XS;

use C4::Context;

use Koha::Logger;
my $logger = bless({lazyLoad => {category => __PACKAGE__}}, 'Koha::Logger');

=head1 NAME

C4::Encryption::Configuration - Contains all encryption parameters

=head1 SYNOPSIS

my $ec = C4::Encryption::Configuration->new(1); # use syspref
my $ec = C4::Encryption::Configuration->new('config.txt'); # use file
my $ec = C4::Encryption::Configuration->new("passphrase\nAES-256\n"); # use text

=cut

use fields qw(passphrase cipher-algorithm);

my $syspref = 'EncryptionConfiguration';

=head2 new

Decides where to get the encryption configuration from.
See the system preference 'EncryptionConfiguration' for usage examples.

 @param {String} Source of the encryption configuration, can be one of:
                 1: Get the configuration from the syspref 'EncryptionConfiguration'
                 filePath: If this file exists, reads the contents as the configuration
                 text: If nothing else works, treats the parameter itself as the configuration
 @dies if loading the config failed

=cut

sub new {
    my ($class, $source) = @_;

    if ($source && length($source) == 1) { # This is a boolean
        $logger->info("Getting encryption configuration from the system preference '$syspref'");
        return $class->newFromSyspref();
    }
    elsif (-e $source) {
        $logger->info("Getting encryption configuration from file '$source'");
        return $class->newFromFile($source);
    }
    else {
        $logger->info("Getting encryption configuration from the commandline");
        return $class->newFromText($source);
    }
}

sub newFromSyspref {
    my ($class) = @_;
    my $text = C4::Context->preference($syspref) or die "System preference '$syspref' not defined";
    return $class->newFromText($text);
}

sub newFromText {
    my ($class, $text) = @_;
    my $config = eval { YAML::XS::Load($text) };
    die "Parsing EncryptionConfiguration YAML failed: $@" if $@;
    $config = {} unless $config;
    my $self = bless($config, $class);
    die "EncryptionConfiguration must have a passphrase!" unless ($self->{passphrase});
    $self->{'cipher-algorithm'} = 'AES-256' unless ($self->{'cipher-algorithm'});
    return $self;
}

sub newFromFile {
    my ($class, $filePath) = @_;
    my $text = File::Slurp::read_file($filePath) or die "Failed to read C4::Encryption::Configuration from file '$filePath': $!";
    return $class->newFromText($text);
}

1;