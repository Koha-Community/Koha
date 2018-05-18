=head IN THIS FILE

This module extends the SMS::Send::Driver interface
to implement a driver compatible with the Sonera SMS Gateway HTTP interface.

Module parameters are sanitated against injection attacks.

    success

{
"accepted" : [ {
"to" : "46701234567",
"id" : "354284289"
} ],
"rejected" : [ "4681234567" ]
}


=cut

package SMS::Send::Sonera::Driver;
#use Modern::Perl; #Can't use this since SMS::Send uses hash keys starting with _
use utf8;
use SMS::Send::Driver ();
use LWP::Simple;
use LWP::UserAgent;
use C4::Context;
use Encode;
use Koha::Exception::ConnectionFailed;
use Koha::Exception::SMSDeliveryFailure;
use URI::Escape;

use vars qw{$VERSION @ISA};
BEGIN {
    $VERSION = '0.06';
    @ISA     = 'SMS::Send::Driver';
}


#####################################################################
# Constructor

sub new {
    my $class = shift;
    my $params = {@_};

    my $username = $params->{_login} ? $params->{_login} : C4::Context->config('smsProviders')->{'sonera'}->{'user'};
    my $password = $params->{_password} ? $params->{_password} : C4::Context->config('smsProviders')->{'sonera'}->{'passwd'};

    my $from = $params->{_from};
    
    if (! defined $username ) {
        warn "->send_sms(_login) must be defined!";
        return;
    }
    if (! defined $password ) {
        warn "->send_sms(_password) must be defined!";
        return;
    }

    if (! defined $from ) {
        warn "->send_sms(_from) must be defined!";
        return;
    }

    #Prevent injection attack
    $self->{_login} =~ s/'//g;
    $self->{_password} =~ s/'//g;
    $self->{_from} =~ s/'//g;

    # Create the object
    my $self = bless {}, $class;

    $self->{UserAgent} = LWP::UserAgent->new(timeout => 5);
    $self->{_login} = $username;
    $self->{_password} = $password;
    $self->{_from} = $from;

    return $self;
}

sub send_sms {
    my $self    = shift;
    my $params = {@_};
    my $message = $params->{text};
    my $recipientNumber = $params->{to};

    my $dbh=C4::Context->dbh;
    my $branches=$dbh->prepare("SELECT branchcode FROM branches WHERE branchemail = ?;");
    $branches->execute($self->{_from});
    my $branch = $branches->fetchrow;
    my $branchcode = substr($branch, 0, 3);

    my $clientid = C4::Context->config('smsProviders')->{'sonera'}->{$branchcode}->{'clientid'};

    if (! defined $message ) {
        warn "->send_sms(text) must be defined!";
        return;
    }
    if (! defined $recipientNumber ) {
        warn "->send_sms(to) must be defined!";
        return;
    }

    #Clean recipientnumber
    $recipientNumber =~ s/^\+//;
    $recipientNumber =~ s/^0/358/;
    $recipientNumber =~ s/\-//;
    $recipientNumber =~ s/ //;
    #Prevent injection attack!
    $recipientNumber =~ s/'//g;
    $message =~ s/(")|(\$\()|(`)/\\"/g; #Sanitate " so it won't break the system( iconv'ed curl command )

    my $base_url = C4::Context->config('smsProviders')->{'sonera'}->{'url'};
    my $parameters = {
        'U'   => $self->{_login},
        'P'   => $self->{_password},
        'T'         => $recipientNumber,
        'M'    =>  Encode::encode( "iso-8859-1", $message)
    };

    if ($clientid) {
        $parameters->{'C'} = $clientid;
    }

    if (C4::Context->config('smsProviders')->{'sonera'}->{'sourceName'}) {
        $parameters->{'F'} = C4::Context->config('smsProviders')->{'sonera'}->{'sourceName'};
    }

    $parameters->{'M'} = uri_escape($parameters->{'M'});
    $parameters->{'P'} = uri_escape($parameters->{'P'});

    my $get_request = '?U='.$parameters->{'U'}.'&P='.$parameters->{'P'}.'&F='.$parameters->{'F'}.'&T='.$parameters->{'T'}.'&M='.$parameters->{'M'};

    my $return = get($base_url.$get_request);

    my $delivery_note = $return;

    return 1 if ($return =~ m/to+/);

    # remove everything except the delivery note
    $delivery_note =~ s/^(.*)message\sfailed:\s*//g;

    # pass on the error by throwing an exception - it will be eventually caught
    # in C4::Letters::_send_message_by_sms()
    Koha::Exception::SMSDeliveryFailure->throw(error => $delivery_note);
}
1;

