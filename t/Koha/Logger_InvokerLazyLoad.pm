package t::Koha::Logger_InvokerLazyLoad;

use Modern::Perl;

use Koha::Logger;

my $logger = Koha::Logger->new({category => __PACKAGE__});

sub arbitrarySubroutineWritingToLog {
    $logger->error('A run-of-a-mill -error');
}