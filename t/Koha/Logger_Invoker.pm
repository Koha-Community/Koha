package t::Koha::Logger_Invoker;

use Modern::Perl;

use Koha::Logger;

my $logger = Koha::Logger->get({category => __PACKAGE__});

sub arbitrarySubroutineWritingToLog {
    $logger->error('A run-of-a-mill -error');
}