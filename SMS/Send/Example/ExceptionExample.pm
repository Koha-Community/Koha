package SMS::Send::Example::ExceptionExample;

=pod

=head1 NAME

SMS::Send::Example::ExceptionExample

=head1 SYNOPSIS

  use Try::Tiny;
  use Scalar::Util qw( blessed );

  # Create a testing sender
  my $send = SMS::Send->new( 'Example::ExceptionExample' );

  # Send a message
  try {
    $send->send_sms(
      text => 'Hi there',
      to   => '+61 (4) 1234 5678',
   );
  } catch {
    if (blessed($_) && $_->can('rethrow')){
        # handle exception
    } else {
        die $_;
    }
  }

=head1 DESCRIPTION

    This SMS::Send module provides an example for how
    to throw Koha::Exceptions in case of an error.

    Exceptions will be caught outside this module by
    try-catch block.

=cut

use strict;
use SMS::Send::Driver ();
use Koha::Exception::ConnectionFailed;

use vars qw{$VERSION @ISA};
BEGIN {
        $VERSION = '0.06';
        @ISA     = 'SMS::Send::Driver';
}





#####################################################################
# Constructor

sub new {
        my $class = shift;

        my $self = bless {}, $class;

        $self->{_login} = "ned";
        $self->{_password} = "flanders";

        return $self;
}

sub send_sms {
    # ...
    # ... our imaginary cURL implementation of sending sms messages to gateway
    #  $curl = sendMessageWithcURL("http://url.com/send", {
    #                           destination => $params->{to},
    #                           text        => $params->{text}
    #                          });
    # my $errorCode = $curl->{'retcode'};
    # Using cURL, our request produced error code 6, CURLE_COULDNT_RESOLVE_HOST
    my $errorCode = 6;

    if ($errorCode == 6) {
        Koha::Exception::ConnectionFailed->throw(error => "Connection failed");
    }

    return 1;
}

1;
