package t::lib::Mocks;

use Modern::Perl;
use C4::Context;

use Koha::Schema;
use Test::MockModule;

use Koha::Exceptions;
use Koha::Exceptions::File;

my %configs;
sub mock_config {
    my $context = new Test::MockModule('C4::Context');
    my ( $conf, $value ) = @_;
    $configs{$conf} = $value;
    $context->mock('config', sub {
        my ( $self, $conf ) = @_;
        if ( exists $configs{$conf} ) {
            return $configs{$conf}
        } else {
            my $method = $context->original('config');
            return $method->($self, $conf);
        }
    });
}

my %preferences;
sub mock_preference {
    my ( $pref, $value ) = @_;

    $preferences{lc($pref)} = $value;

    my $context = new Test::MockModule('C4::Context');
    $context->mock('preference', sub {
        my ( $self, $pref ) = @_;
        $pref = lc($pref);
        if ( exists $preferences{$pref} ) {
            return $preferences{$pref}
        } else {
            my $method = $context->original('preference');
            return $method->($self, $pref);
        }
    });
}

=head2 mock_session

    t::lib::Mocks::mock_session({
        borrower => { #One can give a borrower-hash or a Koha::Borrower-object to mint the session.
            borrowernumber => 0420,
            userid => 'OG Kush',
        },
        params => { #Extra parameters given directly to the CGI::Session as param(), overwrites previous defaults, such as the values inferred from borrower
            number   => $borrowernumber,
            id       => $userid,
            ip       => '127.0.0.1',
            lasttime => time(),
            ...
        },
    });

Mocks a CGI::Session used by C4::Auth.
Sets reasonable defaults for most values.

@PARAM1 Hashref of parameters to be given to CGI::Session
@RETURNS CGI::Session, a new session object serialized to the backing store, ready to be authenticated with
@THROWS Koha::Exception::File, if flushing the session to a file failed

=cut

sub mock_session {
    my ($args) = @_;
    my $params = $args->{params};

    my $session = C4::Auth::get_session('');
    if (my $borrower = $args->{borrower}) {
        $borrower = Koha::Patrons->cast($borrower);
        $session->param( 'number', $borrower->borrowernumber);
        $session->param( 'id',     $borrower->userid);
    }
    foreach my $k (keys %$params) {
        $session->param( $k, $params->{$k});
    }
    $session->param('ip', '127.0.0.1')  unless $session->param('ip');
    $session->param('lasttime', time()) unless $session->param('lasttime');
    Koha::Exceptions::BadParameter->throw(error => "Mandatory CGI::Session parameter 'number' is not defined!") unless $session->param('number');
    $session->flush;

    if ($session->errstr()) {
        if($session->errstr() =~ /couldn't open '(.+)'/) {
            Koha::Exceptions::File->throw(error => "While trying to mock a CGI::Session, got the following CGI::Session error string '".$session->errstr()."'", path => $1);
        }
        else {
            Koha::Exceptions::Exception->throw(error => "Getting a CGI::Session failed with an unexpected error    '$session->errstr()'    ");
        }
    }

    return $session;
}

1;
