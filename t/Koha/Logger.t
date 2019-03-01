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
use Test::Most tests => 5;

#Initialize the Log4perl to write to /tmp/log4perl_test.log so we can clean it later
BEGIN {
    $ENV{KOHA_INTERFACE} = 'commandline';
    require t::Koha::Logger;
    $ENV{LOG4PERL_CONF} = t::Koha::Logger::getLog4perlConfig();
}

use Scalar::Util qw(blessed);
use Try::Tiny;

use C4::Context;
use Koha::Logger;


use t::Koha::Logger::Invoker;
use t::Koha::Logger::Submodule::Subvoker;

my $prevLogger;

subtest "Basic logging", \&commandline_logging;
sub commandline_logging {
    plan tests => 4;
    is(C4::Context->interface(), 'commandline', "Current Koha interface is 'commandline'"); #Show in test output what we are expecting to make test plan more understandable

    t::Koha::Logger::Submodule::Subvoker::loggingSubroutine();

    my $log = t::Koha::Logger::slurpLog('wantArray');
    like($log->[0], qr/\[commandline\./, "Log entry has 'commandline'-interface");
    like($log->[0], qr/\Qsubvoker says no\E/, 'Log entry is sane');
    ok($prevLogger = $t::Koha::Logger::Invoker::logger, 'Got hold of the package-level logger so it can be later re-interfaced');
}
t::Koha::Logger::clearLog();

subtest "Interface changes, and Loggers are reoriented", \&interface_changes;
sub interface_changes {
    plan tests => 4;
    is(C4::Context->interface('opac'), 'opac', "Given a new interface 'opac'");

    t::Koha::Logger::Invoker::arbitrarySubroutineWritingToLog();

    my $log = t::Koha::Logger::slurpLog('wantArray');
    like($log->[0], qr/\[opac\./, "Log entry has 'opac'-interface");
    like($log->[0], qr/\QA run-of-a-mill -error\E/, 'Log entry is sane');
    isnt($prevLogger, $t::Koha::Logger::Invoker::logger, 'Package-logger has been re-interfaced to use the log4perl-config from the new Koha interface');
}
t::Koha::Logger::clearLog();


subtest "Koha::Logger->setVerbosity() - Overload Logger levels", \&overloadLoggerLevels;
sub overloadLoggerLevels {
    plan tests => 7;
    my ($logger, $log);

    subtest "Increment global log verbosity by 1 from the initial level.", sub {
        plan tests => 7;

        ok(Koha::Logger->setVerbosity(1),
            "When the global log verbosity levels are incremented by one.");

        ok(t::Koha::Logger::Submodule::Subvoker::blarbAllLevels(), #Make sure the nested loggers don't get adjusted multiple times. First change inherited from the parent logger and then doubly from themselves.
            "And a message is blarbed on all the log levels.");

        $log = t::Koha::Logger::slurpLog('wantArray');
        is(scalar(@$log), 4,
            "Then 4 log entries are generated");

        like($log->[0],     qr/info/,  'And info ok');
        like($log->[1],     qr/warn/,  'And warn ok');
        like($log->[2],     qr/error/, 'And error ok');
        like($log->[3],     qr/fatal/, 'And fatal ok');
        t::Koha::Logger::clearLog();
    };

    subtest "Decrement global log verbosity by 1 from the initial level.", sub {
        plan tests => 5;

        ok(Koha::Logger->setVerbosity(-1),
            "When the global log verbosity levels are decremented by one.");

        ok(t::Koha::Logger::Invoker::blarbAllLevels(),
            "And a message is blarbed on all the log levels.");

        $log = t::Koha::Logger::slurpLog('wantArray');
        is(scalar(@$log), 2,
            "Then 2 log entries are generated");

        like($log->[0],     qr/error/, 'And error ok');
        like($log->[1],     qr/fatal/, 'And fatal ok');
        t::Koha::Logger::clearLog();
    };

    subtest "Increment global log verbosity by 3 from the initial level.", sub {
        plan tests => 9;

        ok(Koha::Logger->setVerbosity(3),
            "When the global log verbosity levels are incremented by three.");

        ok(t::Koha::Logger::Submodule::Subvoker::blarbAllLevels(),
            "And a message is blarbed on all the log levels.");

        $log = t::Koha::Logger::slurpLog('wantArray');
        is(scalar(@$log), 6,
            "Then 6 log entries are generated");

        like($log->[0],     qr/trace/, 'And trace ok');
        like($log->[1],     qr/debug/, 'And debug ok');
        like($log->[2],     qr/info/,  'And info ok');
        like($log->[3],     qr/warn/,  'And warn ok');
        like($log->[4],     qr/error/, 'And error ok');
        like($log->[5],     qr/fatal/, 'And fatal ok');
        t::Koha::Logger::clearLog();
    };

    subtest "Set global log verbosity to OFF.", sub {
        plan tests => 3;

        ok(Koha::Logger->setVerbosity('OFF'),
            "When the global log verbosity level is set to OFF.");

        ok(t::Koha::Logger::Invoker::blarbAllLevels(),
            "And a message is blarbed on all the log levels.");

        $log = t::Koha::Logger::slurpLog('wantArray');
        is(scalar(@$log), 0,
            "Then no log entries are generated");

        t::Koha::Logger::clearLog();
    };

    subtest "Set global log verbosity to ERROR.", sub {
        plan tests => 5;

        ok(Koha::Logger->setVerbosity('ERROR'),
            "When the global log verbosity level is set to ERROR.");

        ok(t::Koha::Logger::Submodule::Subvoker::blarbAllLevels(),
            "And a message is blarbed on all the log levels.");

        $log = t::Koha::Logger::slurpLog('wantArray');
        is(scalar(@$log), 2,
            "Then 2 log entries are generated");

        like($log->[0],     qr/error/, 'And error ok');
        like($log->[1],     qr/fatal/, 'And fatal ok');
        t::Koha::Logger::clearLog();
    };

    subtest "Setting the global log verbosity to a bad level causes an exception.", sub {
        plan tests => 1;

        throws_ok(sub { Koha::Logger->setVerbosity('FUTUL') }, qr/FUTUL/,
            "When the global log verbosity level is set to FUTUL. An exception is thrown");

        t::Koha::Logger::clearLog();
    };

    subtest "Re-interfacing loggers pick log level overloads", sub {
        plan tests => 7;

        my $prevLogger = $t::Koha::Logger::Invoker::logger;

        is(C4::Context->interface('intranet'), 'intranet',
            "Given a new interface 'intranet'");

        ok(Koha::Logger->getVerbosity('ERROR'),
            "When the global log verbosity level is at ERROR.");

        ok(t::Koha::Logger::Invoker::blarbAllLevels(),
            "And a message is blarbed on all the log levels.");

        $log = t::Koha::Logger::slurpLog('wantArray');
        is(scalar(@$log), 2,
            "Then 2 log entries are generated");

        like($log->[0],     qr/error/, 'And error ok');
        like($log->[1],     qr/fatal/, 'And fatal ok');

        isnt($prevLogger, $t::Koha::Logger::Invoker::logger, 'Package-logger has been re-interfaced to use the log4perl-config from the new Koha interface');

        t::Koha::Logger::clearLog();
    };
}


subtest "Return value passthrough", \&returnValuePassthrough;
sub returnValuePassthrough {
    plan tests => 4;
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


subtest "Koha::Logger->sql()", \&sqlsql;
sub sqlsql {
    plan tests => 3;
    my $logger = Koha::Logger->get({category => "sqlsql-1"});
    my $retval = Koha::Logger->sql($logger, 'fatal', 'SELECT * FROM a WHERE b=? AND c=? OR d=?', [1,2,3]) if $logger->is_fatal();
    my $log = t::Koha::Logger::slurpLog('wantArray');
    is(scalar(@$log), 1, "One entry written");
    is($retval, 1, "Koha::Logger->sql() returns 'true' per Log4perl best practices");
    ok($log->[0] =~ /SELECT \* FROM a WHERE b=\? AND c=\? OR d=\? -- 1 2 3/);
    t::Koha::Logger::clearLog();
}


t::Koha::Logger::clearLog();
done_testing();