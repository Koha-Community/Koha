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
use LWP::Curl;
use LWP::UserAgent;
use URI::Escape;
use C4::Context;
use Encode;
use Koha::Exception::ConnectionFailed;
use Koha::Exception::SMSDeliveryFailure;

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

    #Prevent injection attack!
    $recipientNumber =~ s/'//g;
    $message =~ s/(")|(\$\()|(`)/\\"/g; #Sanitate " so it won't break the system( iconv'ed curl command )

    my $base_url = C4::Context->config('smsProviders')->{'sonera'}->{'url'};
    my $parameters = {
        'username'   => $self->{_login},
        'password'   => $self->{_password},
        'to'         => $recipientNumber,
        'message'    => Encode::encode( "utf8", $message),
    };

    if ($clientid) {
        $parameters->{'costcenter'} = $clientid;
    }

    if (C4::Context->config('smsProviders')->{'sonera'}->{'sourceName'}) {
        $parameters->{'from'} = C4::Context->config('smsProviders')->{'sonera'}->{'sourceName'};
    }

    my $lwpcurl = LWP::Curl->new();
    my $return = $lwpcurl->post($base_url, $parameters);

    if ($lwpcurl->{retcode} == 6) {
        Koha::Exception::ConnectionFailed->throw(error => "Connection failed");
    }

    my $delivery_note = $return;

    return 1 if ($return =~ m/to+/);

    # remove everything except the delivery note
    $delivery_note =~ s/^(.*)message\sfailed:\s*//g;

    # pass on the error by throwing an exception - it will be eventually caught
    # in C4::Letters::_send_message_by_sms()
    Koha::Exception::SMSDeliveryFailure->throw(error => $delivery_note);
}
1;
