#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 8;
use Test::MockModule;
use Test::NoWarnings;

# Load SIP modules (this loads Trapper and sets up the DIE handler)
use_ok('C4::SIP::Trapper');

# Verify DIE handler is installed
ok( exists $SIG{__DIE__}, "DIE signal handler is installed" );

# Mock Koha::Logger to capture both warnings and errors
my @logged_warnings;
my @logged_errors;
my $mock_logger = Test::MockModule->new('Koha::Logger');
$mock_logger->mock(
    'get',
    sub {
        my $self = bless {}, 'Koha::Logger';
        return $self;
    }
);
$mock_logger->mock(
    'warn',
    sub {
        my ( $self, $msg ) = @_;
        push @logged_warnings, $msg;
    }
);
$mock_logger->mock(
    'error',
    sub {
        my ( $self, $msg ) = @_;
        push @logged_errors, $msg;
    }
);

# Create a SIP module that will throw an error
{

    package C4::SIP::TestError;
    use Modern::Perl;

    sub cause_fatal_error {
        die "Fatal error in SIP module\n";
    }
}

# SIP errors inside eval should be logged as WARNING
# The DIE handler checks SIP namespace first, then checks if in eval and logs accordingly
@logged_warnings = ();
@logged_errors   = ();
eval { C4::SIP::TestError::cause_fatal_error(); };

like( $@, qr/Fatal error in SIP module/, "SIP error was caught by eval" );
ok(
    scalar(@logged_warnings) > 0 && $logged_warnings[0] =~ /Fatal error in SIP module/,
    "SIP error inside eval was logged as WARNING by Trapper"
);
ok(
    scalar(@logged_errors) == 0,
    "SIP error inside eval was NOT logged as error (only warning)"
);

# Verify non-SIP errors are never logged
{

    package C4::NOTSIP::TestError;
    use Modern::Perl;

    sub cause_fatal_error {
        die "Fatal error in NOTSIP module\n";
    }
}

@logged_warnings = ();
@logged_errors   = ();
eval { C4::NOTSIP::TestError::cause_fatal_error(); };

# Trapper now checks SIP namespace FIRST, then decides what to log
# Non-SIP errors return early and are never logged
ok(
    scalar(@logged_warnings) == 0 && scalar(@logged_errors) == 0,
    "Non-SIP error was NOT logged at all (Trapper filters by namespace first)"
);
like( $@, qr/Fatal error in NOTSIP module/, "Non-SIP error was still caught by eval" );

# NOTE: Errors outside eval cannot be tested in a test suite because:
# 1. Tests require eval to catch errors to prevent test termination
# 2. The DIE handler checks $^S to detect eval context
# 3. Outside eval, SIP errors would be logged as ERROR level and re-thrown
# To verify production behavior, check SIP logs for uncaught fatal errors
