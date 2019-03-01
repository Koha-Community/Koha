package t::Koha::Logger::Invoker;

use Modern::Perl;

use Koha::Logger;

our $logger = Koha::Logger->get(); #This must be our so it can be reoriented to another interface on demand

sub arbitrarySubroutineWritingToLog {
    $logger->error('A run-of-a-mill -error');
}

sub blarbAllLevels {
    $logger->trace('trace');
    $logger->debug('debug');
    $logger->info('info');
    $logger->warn('warn');
    $logger->error('error');
    $logger->fatal('fatal');
    return 1;
}

1;
