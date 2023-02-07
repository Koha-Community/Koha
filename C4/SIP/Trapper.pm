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
    $Log::Log4perl::caller_depth++;
    my $logger =
      Koha::Logger->get( { interface => 'sip', category => 'STDERR' } );
    warn @_;
    $logger->warn(@_);
    $Log::Log4perl::caller_depth--;
}

=head2 BINMODE

    Suppress errors from Log::Log4perl::Appender::Screen

=cut

sub BINMODE {
    my ( $self, $mode ) = @_;
    binmode( STDOUT, $mode );
};

1;
