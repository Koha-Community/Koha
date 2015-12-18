package C4::SIP::Trapper;

use Modern::Perl;

use Koha::Logger;

sub TIEHANDLE {
    my $class = shift;
    bless [], $class;
}

sub PRINT {
    my $self = shift;
    $Log::Log4perl::caller_depth++;
    my $logger = Koha::Logger->get({ interface => 'sip', category => 'STDERR' });
    warn @_;
    $logger->error(@_);
    $Log::Log4perl::caller_depth--;
}

1;
