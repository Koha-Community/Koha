#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 3;
use Test::MockModule;
use Test::NoWarnings;

use_ok('C4::SIP::Trapper');

subtest 'PRINT() tests' => sub {
    plan tests => 3;

    my @logged_warnings;
    my $mock_logger = Test::MockModule->new('Koha::Logger');
    $mock_logger->mock(
        'get',
        sub {
            return bless {}, 'Koha::Logger';
        }
    );
    $mock_logger->mock(
        'warn',
        sub {
            my ( $self, $msg ) = @_;
            push @logged_warnings, $msg;
        }
    );

    my @stderr_output;
    local $SIG{__WARN__} = sub { push @stderr_output, @_ };

    my $trapper = C4::SIP::Trapper->TIEHANDLE;
    $trapper->PRINT("Warning from the SIP server");

    is( scalar @logged_warnings, 1, "Message was passed to Koha::Logger once" );
    is(
        $logged_warnings[0], "Warning from the SIP server",
        "Koha::Logger received the message as a warning"
    );
    like(
        $stderr_output[0], qr/^Warning from the SIP server/,
        "Message was also written to STDERR"
    );
};
