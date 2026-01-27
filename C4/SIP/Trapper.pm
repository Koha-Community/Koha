package C4::SIP::Trapper;

use Modern::Perl;

use Koha::Logger;

=head1 NAME

C4::SIP::Trapper - Module for capturing warnings for the SIP logger

=head2 TIEHANDLE

    Ties the given class to this module.

=cut

sub TIEHANDLE {
    my $class = shift;
    bless [], $class;
}

=head2 PRINT

    Captures warnings and directs them to Koha::Logger as well as STDERR

=cut

sub PRINT {
    my $self = shift;
    $Log::Log4perl::caller_depth += 3;
    my $logger = Koha::Logger->get( { interface => 'sip', category => 'STDERR' } );
    warn @_;
    $logger->warn(@_);
    $Log::Log4perl::caller_depth -= 3;
}

=head2 OPEN

    We need OPEN in case Net::Server tries to redirect STDERR. This will
    be tried when param log_file or setsid is passed.

=cut

sub OPEN {
    return 1;
}

=head2 BINMODE

    Suppress errors from Log::Log4perl::Appender::Screen

=cut

sub BINMODE {
    my ( $self, $mode ) = @_;
    binmode( STDOUT, $mode );
}

=head2 DIE signal handler

    A global die handler to capture fatal errors and ensures they are logged.
    When DIE is emitted, the message will be logged using Koha::Logger if available,
    and also printed to stderr

=cut

$SIG{__DIE__} = sub {
    my $msg = shift;

    # Check if we are inside an eval
    my $logger_method = 'error';
    $logger_method = 'warn' if defined $^S && $^S != 0;

    # Check if error originated from SIP code
    my $is_sip_error = 0;
    my $i            = 0;    # Start from 0 to check the current caller
    while ( my @caller = caller( $i++ ) ) {
        if ( $caller[0] =~ /^C4::SIP::/ || $caller[1] =~ /\/C4\/SIP\// ) {
            $is_sip_error = 1;
            last;
        }
        last if $i > 10;     # Don't check too deep
    }

    # Only log if it's from SIP code
    return unless $is_sip_error;
    my $logger = Koha::Logger->get( { interface => 'sip', category => 'STDERR' } );
    $logger->$logger_method($msg) if $logger;
    die $msg;
};

1;
