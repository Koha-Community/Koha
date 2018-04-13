=head IN THIS FILE

This module extends the SMS::Send::Driver interface
to implement a driver compatible with the Labyrintti SMS Gateway HTTP interface.

Module parameters are sanitated against injection attacks.

Labyrintti responds:

    success

phone-number OK message-count description
+358401234567 OK 1 message accepted for sending

    failure

phone-number ERROR error-code message-count description
e.g: 12345 ERROR 2 1 message failed: Too short phone number

=cut

package SMS::Send::Labyrintti::Driver;
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
use Koha::Hdiacritic;
use Koha::Notice::Messages;

use Try::Tiny;

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
    my $from = $params->{_from};
    my $dbh=C4::Context->dbh;
    my $branches=$dbh->prepare("SELECT branchcode FROM branches WHERE branchemail = ?;");
    $branches->execute($from);
    my $branch = $branches->fetchrow;
    my $prefix = substr($branch, 0, 3);
    my $group_branch = C4::Context->config('smsProviders')->{'labyrintti'}->{$prefix}->{'user'};
    my $single_branch = C4::Context->config('smsProviders')->{'labyrintti'}->{$branch}->{'user'};

    my $username;
    my $password;

    if($single_branch) {
        $username = $params->{_login} ? $params->{_login} : C4::Context->config('smsProviders')->{'labyrintti'}->{$branch}->{'user'};
        $password = $params->{_password} ? $params->{_password} : C4::Context->config('smsProviders')->{'labyrintti'}->{$branch}->{'passwd'};
    }elsif($group_branch) {
        $username = $params->{_login} ? $params->{_login} : C4::Context->config('smsProviders')->{'labyrintti'}->{$prefix}->{'user'};
        $password = $params->{_password} ? $params->{_password} : C4::Context->config('smsProviders')->{'labyrintti'}->{$prefix}->{'passwd'};
    }else{
        $username = $params->{_login} ? $params->{_login} : C4::Context->config('smsProviders')->{'labyrintti'}->{'user'};
        $password = $params->{_password} ? $params->{_password} : C4::Context->config('smsProviders')->{'labyrintti'}->{'passwd'};
    }


    if (! defined $username ) {
        warn "->send_sms(_login) must be defined!";
        return;
    }
    if (! defined $password ) {
        warn "->send_sms(_password) must be defined!";
        return;
    }

    #Prevent injection attack
    $self->{_login} =~ s/'//g;
    $self->{_password} =~ s/'//g;

    # Create the object
    my $self = bless {}, $class;

    $self->{UserAgent} = LWP::UserAgent->new(timeout => 5);
    $self->{_login} = $username;
    $self->{_password} = $password;

    return $self;
}

sub send_sms {
    my $self    = shift;
    my $params = {@_};
    my $message = $params->{text};
    my $recipientNumber = $params->{to};

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

    my $base_url = "https://gw.labyrintti.com:28443/sendsms";
    my $parameters = {
        'user'      => $self->{_login},
        'password'  => $self->{_password},
        'dests'     => $recipientNumber,
    };

    # check if we need to use unicode
    #  -> if unicode => yes, maxlength for 1 sms = 70 chars
    #  -> else maxlenght = 160 chars (140 bytes, GSM 03.38)
    my $gsm0388 = decode("gsm0338",encode("gsm0338", $message));

    # Set the encoding for dealing with Labyrintti server, this is separate from the actual message encoding
    my $requestEncoding='UTF-8';
    if (C4::Context->config('smsProviders')->{'labyrintti'}->{'requestEncoding'}) {
        $requestEncoding = C4::Context->config('smsProviders')->{'labyrintti'}->{'requestEncoding'};
    }

    if ($message ne $gsm0388 and C4::Context->config('smsProviders')->{'labyrintti'}->{'Unicode'} eq "yes"){
        $parameters->{'unicode'} = 'yes';
        $parameters->{'text'} = encode($requestEncoding, $message);
        my $notice = Koha::Notice::Messages->find($params->{_message_id});
        $notice->set({ metadata   => 'UTF-16' })->store if defined $notice;
    } else {
        $parameters->{'text'} = encode($requestEncoding, hdiacritic($message));
        $parameters->{'unicode'} = 'no';
    }

    if (C4::Context->config('smsProviders')->{'labyrintti'}->{'sourceName'}) {
        $parameters->{'source-name'} = C4::Context->config('smsProviders')->{'labyrintti'}->{'sourceName'};
    }

    my $report_url = C4::Context->config('smsProviders')->{'labyrintti'}->{'reportUrl'};
    if ($report_url) {
        my $msg_id = $params->{_message_id};
        $report_url =~ s/\{message_id\}|\{messagenumber\}/$msg_id/g;
        $parameters->{'report'} = $report_url;
    }

    my $lwpcurl = LWP::Curl->new();
    my $return;
    try {
        $return = $lwpcurl->post($base_url, $parameters);
    } catch {
        if ($_ =~ /Couldn't resolve host name \(6\)/) {
            Koha::Exception::ConnectionFailed->throw(error => "Connection failed");
        }
        die $_;
    };

    if ($lwpcurl->{retcode} == 6) {
        Koha::Exception::ConnectionFailed->throw(error => "Connection failed");
    }

    my $delivery_note = $return;

    return 1 if ($return =~ m/OK [1-9](\d*)?/);

    # remove everything except the delivery note
    $delivery_note =~ s/^(.*)message\sfailed:\s*//g;

    # pass on the error by throwing an exception - it will be eventually caught
    # in C4::Letters::_send_message_by_sms()
    Koha::Exception::SMSDeliveryFailure->throw(error => $delivery_note);
}

1;
