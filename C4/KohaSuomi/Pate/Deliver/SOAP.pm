#!/usr/bin/perl
use warnings;
use strict;
use utf8;

use LWP::UserAgent;
use HTTP::Request::Common qw(POST);
use POSIX qw(mkfifo);
use Data::Dumper;

sub callSOAPSigner {
    my %hash=@_;

    # Get trustfile and keyfile from config
    my $trustfile=C4::Context->config('ksmessaging')->{'suomifi'}->{'branches'}->{"$hash{'branchconfig'}"}->{'wsapi'}{'sign'}->{'trust'};
    my $keyfile=C4::Context->config('ksmessaging')->{'suomifi'}->{'branches'}->{"$hash{'branchconfig'}"}->{'wsapi'}->{'sign'}->{'key'};

    my $nullstderr = '';
       $nullstderr = "2> /dev/null" unless $ENV{'DEBUG'};

    # We need JRE for signing, so check that we have that installed first
    die "No Java installed. Please run 'apt-get install default-jre' as root." unless system ( "java -version $nullstderr" ) == 0 ;
    print "Java check passed\n" if $ENV{'DEBUG'};

    # Start the signer in the background
    print "Starting signer\n" if $ENV{'DEBUG'};
    system ( "java -cp Deliver/Signer/signsoap.jar signsoap.soap_main $keyfile $trustfile $nullstderr &" );

    # Make pipes
    print "Creating FIFO pipes\n" if $ENV{'DEBUG'};
    mkfifo ( '/tmp/unsigned-pipe', 0700 );
    mkfifo ( '/tmp/signed-pipe', 0700 );

    # Put the unsigned SOAP message in named pipe for signer
    print "Opening unsiged-pipe for writing\n" if $ENV{'DEBUG'};
    open ( UNSIGNED, '>:encoding(UTF-8)', '/tmp/unsigned-pipe' ) or die "Can't open FIFO for signing.";
    print "Writing to FIFO\n" if $ENV{'DEBUG'};
    print UNSIGNED $hash{'message'};
    close UNSIGNED;

    # Get signed message
    print "Opening FIFO pipe for reading\n" if $ENV{'DEBUG'};
    open ( SIGNED, '<:encoding(UTF-8)', '/tmp/signed-pipe' ) or die "Can't read signed message from FIFO.";
    print "Reading from signed-pipe\n" if $ENV{'DEBUG'};
    my $signedmessage;
    $signedmessage.=$_ foreach ( <SIGNED> );
    close SIGNED;
    print "Read, unlinking FIFO pipes\n" if $ENV{'DEBUG'};
    unlink ( '/tmp/unsigned-pipe', '/tmp/signed-pipe' ); # Do we want this?

    return $signedmessage;
}

sub POSTSOAP {
    my $xml=shift;

    return 0; # Do nothing yet. FIXME!

    my $useragent=LWP::UserAgent->new;
       $useragent->ssl_opts(verify_hostname=>0, SSL_verify_mode=> 0x00);

    my $request=POST('https://www.suomi.fi/asiointitili/Viranomaispalvelut/LahetaViesti', [$xml]);
    my $response=$useragent->request($request);

    if ($response == 400) {
        print STDERR 'Invalid request format.\n';
        return 0;
    }
    elsif ($response == 403) {
        print STDERR 'Authority identifier doesn\'t match authentication.\n';
        return 0;
    }
    elsif ($response == 404) {
        print STDERR 'Service id doesn\'t match authority identifier.\n';
        return 0;
    }
    elsif ($response == 405) {
        print STDERR 'Operation not permitted.\n';
        return 0;
    }
    elsif ($response == 406) {
        print STDERR 'Signature doesn\'t match service id\'s signature.\n';
        return 0;
    }
    elsif ($response == 453) {
        print STDERR 'Service not responding.\n';
        return 0;
    }
    elsif ($response == 461) {
        print STDERR 'Account not available.\n';
        return 0;
    }
    elsif ($response == 525) {
        print STDERR 'Errors in data.\n';
        return 0;
    }
    elsif ($response == 550) {
        print STDERR 'Undefined error.\n';
        return 0;
    }
    else {
        print STDERR 'Unknown response (' . $response . ').\n';
        return 0;
    }

    return 1;
}

1;
