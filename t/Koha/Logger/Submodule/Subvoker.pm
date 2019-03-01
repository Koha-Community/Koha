package t::Koha::Logger::Submodule::Subvoker;

use Modern::Perl;

use Koha::Logger;

our $logger = Koha::Logger->get(); #This must be our so it can be reoriented to another interface on demand

sub loggingSubroutine {
    $logger->error('subvoker says no');
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
