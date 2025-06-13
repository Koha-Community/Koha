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
    my $msg    = shift;
    my $logger = Koha::Logger->get( { interface => 'sip', category => 'STDERR' } );
    $logger->error($msg) if $logger;
    die $msg;
};

1;
