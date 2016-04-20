# Copyright 2016 KohaSuomi
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use Test::More;

use Log::Log4perl;
use Scalar::Util qw(blessed);
use Try::Tiny;

use C4::Context;
C4::Context->setCommandlineEnvironment(); #Set the context already prior to loading Koha::Logger (this actually doesn't fix the logger interface definition issue. Just doing it like this to show this doesn't work)
is(C4::Context->interface(), 'commandline', "Current Koha interface is 'commandline'"); #Show in test output what we are expecting to make test plan more understandable

#Initialize the Log4perl to write to /tmp/log4perl_test.log so we can clean it later
Log::Log4perl::init( t::Koha::Logger::getLog4perlConfig() );

require Koha::Logger;
use t::Koha::Logger;


##################################################################################################
#### Test for Bug 16304 - Koha::Logger, lazy load loggers so environment has time to get set  ####
use t::Koha::Logger_Invoker; #Inside the invoker we already get the Koha's interface from C4::Context->interface. Unfortunately use-definitions are resolved before other code is executed, so the context is not yet properly set.
use t::Koha::Logger_InvokerLazyLoad; #We set the reference to the Koha::Logger as package-level, but dont load the Log::Log4perl-object yet with uninitialized environment

subtest "Logger_Invoker package-level logger has a bad interface", \&Logger_Invoker_badInterface;
sub Logger_Invoker_badInterface {
    t::Koha::Logger_Invoker::arbitrarySubroutineWritingToLog();

    my $log = t::Koha::Logger::slurpLog('wantArray');
    ok($log->[0] =~ /\[opac\./, "Log entry doesn't have 'commandline'-interface, but the default 'opac' instead");
}
t::Koha::Logger::clearLog();

subtest "Logger_InvokerLazyLoad package-level logger has the correct interface", \&Logger_InvokerLazyLoad_correctInterface;
sub Logger_InvokerLazyLoad_correctInterface {
    t::Koha::Logger_InvokerLazyLoad::arbitrarySubroutineWritingToLog();

    my $log = t::Koha::Logger::slurpLog('wantArray');
    ok($log->[0] =~ /\[commandline\./, "Log entry has 'commandline'-interface");
}
t::Koha::Logger::clearLog();

#### END OF Test for Bug 16304 - Koha::Logger, lazy load loggers so environment has time to get set  ####
#########################################################################################################

###############################################################################################
#### KD976 - Koha::Logger overload configuration for command line scripts verbosity levels ####
subtest "Overload Logger configurations", \&overloadLoggerConfigurations;
sub overloadLoggerConfigurations {
    my ($logger, $log, $LOGFILEOUT, $stdoutLogHandle, $stdoutLogPtr, @stdoutLog);
    $stdoutLogPtr = \$stdoutLogHandle;

    #Test increasing log verbosity
    ($LOGFILEOUT, $stdoutLogPtr) = _reopenStdoutScalarHandle($LOGFILEOUT, $stdoutLogPtr);
    Koha::Logger->setConsoleVerbosity(1);
    $logger = Koha::Logger->get({category => "test-is-fun-1"});
    _loggerBlarbAllLevels($logger);
    $log = t::Koha::Logger::slurpLog('wantArray');
    @stdoutLog = split("\n", $stdoutLogHandle);
    ok($log->[0]     =~ /info/,  'Increment by 1. file   - info ok');
    ok($stdoutLog[0] =~ /info/,  'Increment by 1. stdout - info ok');
    ok($log->[1]     =~ /warn/,  'Increment by 1. file   - warn ok');
    ok($stdoutLog[1] =~ /warn/,  'Increment by 1. stdout - warn ok');
    ok($log->[2]     =~ /error/, 'Increment by 1. file   - error ok');
    ok($stdoutLog[2] =~ /error/, 'Increment by 1. stdout - error ok');
    ok($log->[3]     =~ /fatal/, 'Increment by 1. file   - fatal ok');
    ok($stdoutLog[3] =~ /fatal/, 'Increment by 1. stdout - fatal ok');
    t::Koha::Logger::clearLog();

    #Test decreasing log verbosity
    ($LOGFILEOUT, $stdoutLogPtr) = _reopenStdoutScalarHandle($LOGFILEOUT, $stdoutLogPtr);
    Koha::Logger->setConsoleVerbosity(-1);
    $logger = Koha::Logger->get({category => "test-is-fun-2"});
    _loggerBlarbAllLevels($logger);
    $log = t::Koha::Logger::slurpLog('wantArray');
    @stdoutLog = split("\n", $stdoutLogHandle);
    ok($log->[0]     =~ /error/, 'Decrement by 1. file   - error ok');
    ok($stdoutLog[0] =~ /error/, 'Decrement by 1. stdout - error ok');
    ok($log->[1]     =~ /fatal/, 'Decrement by 1. file   - fatal ok');
    ok($stdoutLog[1] =~ /fatal/, 'Decrement by 1. stdout - fatal ok');
    t::Koha::Logger::clearLog();

    #Test increasing log verbosity multiple levels
    ($LOGFILEOUT, $stdoutLogPtr) = _reopenStdoutScalarHandle($LOGFILEOUT, $stdoutLogPtr);
    Koha::Logger->setConsoleVerbosity(2);
    $logger = Koha::Logger->get({category => "test-is-fun-3"});
    _loggerBlarbAllLevels($logger);
    $log = t::Koha::Logger::slurpLog('wantArray');
    @stdoutLog = split("\n", $stdoutLogHandle);
    ok($log->[0]     =~ /debug/, 'Increment by 1. file   - debug ok');
    ok($stdoutLog[0] =~ /debug/, 'Increment by 1. stdout - debug ok');
    ok($log->[1]     =~ /info/,  'Increment by 1. file   - info ok');
    ok($stdoutLog[1] =~ /info/,  'Increment by 1. stdout - info ok');
    ok($log->[2]     =~ /warn/,  'Increment by 1. file   - warn ok');
    ok($stdoutLog[2] =~ /warn/,  'Increment by 1. stdout - warn ok');
    ok($log->[3]     =~ /error/, 'Increment by 1. file   - error ok');
    ok($stdoutLog[3] =~ /error/, 'Increment by 1. stdout - error ok');
    ok($log->[4]     =~ /fatal/, 'Increment by 1. file   - fatal ok');
    ok($stdoutLog[4] =~ /fatal/, 'Increment by 1. stdout - fatal ok');
    t::Koha::Logger::clearLog();

    #Test decreasing log verbosity beyond FATAL, this results to no output
    ($LOGFILEOUT, $stdoutLogPtr) = _reopenStdoutScalarHandle($LOGFILEOUT, $stdoutLogPtr);
    Koha::Logger->setConsoleVerbosity(-3);
    $logger = Koha::Logger->get({category => "test-is-fun-4"});
    _loggerBlarbAllLevels($logger);
    $log = t::Koha::Logger::slurpLog('wantArray');
    @stdoutLog = split("\n", $stdoutLogHandle);
    is(scalar(@$log), 0,         'Decrement overboard. no logging');
    t::Koha::Logger::clearLog();

    #Test static log level
    ($LOGFILEOUT, $stdoutLogPtr) = _reopenStdoutScalarHandle($LOGFILEOUT, $stdoutLogPtr);
    Koha::Logger->setConsoleVerbosity('FATAL');
    $logger = Koha::Logger->get({category => "test-is-fun-5"});
    _loggerBlarbAllLevels($logger);
    $log = t::Koha::Logger::slurpLog('wantArray');
    @stdoutLog = split("\n", $stdoutLogHandle);
    ok($log->[0]     =~ /fatal/, 'Static log level. file   - fatal ok');
    ok($stdoutLog[0] =~ /fatal/, 'Static log level. stdout - fatal ok');
    t::Koha::Logger::clearLog();

    #Test bad log level, then continue using the default config unhindered
    Koha::Logger->setConsoleVerbosity(); #Clear overrides with empty params
    ($LOGFILEOUT, $stdoutLogPtr) = _reopenStdoutScalarHandle($LOGFILEOUT, $stdoutLogPtr);
    try {
        Koha::Logger->setConsoleVerbosity('WARNNNG');
        die "We should have died";
    } catch {
        ok($_ =~ /verbosity must be a positive or negative digit/, "Bad \$verbosiness, but got instructions on how to properly give \$verbosiness");
    };
    $logger = Koha::Logger->get({category => "test-is-fun-6"});
    _loggerBlarbAllLevels($logger);
    $log = t::Koha::Logger::slurpLog('wantArray');
    @stdoutLog = split("\n", $stdoutLogHandle);
    is(scalar(@stdoutLog), 0,    'Bad config, defaulting. Stdout not printed to in default mode.');
    ok($log->[0]     =~ /warn/,  'Bad config, defaulting. file   - warn ok');
    ok($log->[1]     =~ /error/, 'Bad config, defaulting. file   - error ok');
    ok($log->[2]     =~ /fatal/, 'Bad config, defaulting. file   - fatal ok');
    t::Koha::Logger::clearLog();

    close($LOGFILEOUT);
}

#### END OF Test for KD976 - Koha::Logger overload configuration for command line scripts verbosity levels ####
###############################################################################################################

subtest "Return value passthrough", \&returnValuePassthrough;
sub returnValuePassthrough {
    my ($logger, $log, $retval);

    $logger = Koha::Logger->get({category => "retval-madness-1"});
    $retval = $logger->trace('This is not printed');
    $log = t::Koha::Logger::slurpLog('wantArray');
    is(scalar(@$log), 0, "No trace written");
    is($retval, undef, "Koha::Logger returns undef per Log4perl best practices");
    t::Koha::Logger::clearLog();

    $retval = $logger->error('This is printed');
    $log = t::Koha::Logger::slurpLog('wantArray');
    is(scalar(@$log), 1, "Error written");
    is($retval, 1, "Koha::Logger returns 1 per Log4perl best practices");
    t::Koha::Logger::clearLog();
}
t::Koha::Logger::clearLog();

sub _loggerBlarbAllLevels {
    my ($logger) = @_;
    $logger->trace('trace');
    $logger->debug('debug');
    $logger->info('info');
    $logger->warn('warn');
    $logger->error('error');
    $logger->fatal('fatal');
}
sub _reopenStdoutScalarHandle {
    my ($LOGFILEOUT, $pointerToScalar) = @_;
    $$pointerToScalar = '';
    close($LOGFILEOUT) if $LOGFILEOUT;
    open($LOGFILEOUT, '>', $pointerToScalar) or die $!;
    $LOGFILEOUT->autoflush ( 1 );
    select $LOGFILEOUT; #Use this as the default print target, so Console appender is redirected to this logfile
    return ($LOGFILEOUT, $pointerToScalar);
}

done_testing();