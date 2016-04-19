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
use Time::HiRes;

use C4::Context;
use Koha::Logger;

C4::Context->interface('intranet');

my $acceptedDelay; #This is baselined from the vanilla Log4perl subtest
my $iterations = 1000;
my $acceptedPerformanceLoss = 1.33; #33%

=head1 IN THIS FILE: Performance tests for the Koha::Logger vs the Log::Log4perl

0. Create custom logger configuration so we know where we log and can clean up afterwards.
1. First we sample performance on this platform for vanilla Log4perl and establish a performance baseline.
2. Then we sample performance on Koha::Logger, accepting a \$acceptedPerformanceLoss performance loss against the established baseline.

=cut

#Initialize the Log4perl to write to /tmp/log4perl_test.log so we can clean it later
my $conf = join("\n",<DATA>);
Log::Log4perl::init(\$conf);


subtest "Log4perl vanilla, 10000 errors", \&Log4perlVanilla;
sub Log4perlVanilla {
    my $startTime = Time::HiRes::time();
    Log::Log4perl::init_once( C4::Context->config("log4perl_conf") );
    foreach my $i (1..$iterations) {
        my $logger = Log::Log4perl->get_logger(C4::Context->interface().".vanu$i");
        _logErrors($logger);
    }
    my $testDuration = Time::HiRes::time() - $startTime;
    $acceptedDelay = $testDuration * $acceptedPerformanceLoss; #Set the performance baseline for further tests in this suite
    ok($testDuration < $acceptedDelay, "Test duration $testDuration < $acceptedDelay");
    verifyThatLogWasWritten();
}

subtest "Log4perl Koha::Logger from KOHA_CONF, 10000 errors", \&Log4perlKohaLogger;
sub Log4perlKohaLogger {
    my $startTime = Time::HiRes::time();
    foreach my $i (1..$iterations) {
        my $logger = Koha::Logger->get({category => "jarr$i"});
        _logErrors($logger);
    }
    my $testDuration = Time::HiRes::time() - $startTime;
    ok($testDuration < $acceptedDelay, "Test duration $testDuration < $acceptedDelay");
    verifyThatLogWasWritten();
}

$ENV{"LOG4PERL_CONF"} = C4::Context->config("log4perl_conf");
subtest "Log4perl Koha::Logger from ENV, 10000 errors", \&Log4perlKohaLogger2;
sub Log4perlKohaLogger2 { #Redefine the same subroutine 'Log4perlKohaLogger', otherwise perl compiler will distort the test results
    my $startTime = Time::HiRes::time();
    foreach my $i (1..$iterations) {
        my $logger = Koha::Logger->get({category => "argh$i"});
        _logErrors($logger);
    }
    my $testDuration = Time::HiRes::time() - $startTime;
    ok($testDuration < $acceptedDelay, "Test duration $testDuration < $acceptedDelay");
    verifyThatLogWasWritten();
}

done_testing();

sub _logErrors {
    my ($logger) = @_;
    $logger->error('The incredible burden of building good logging faculties');
    $logger->error('The incredible burden of building good logging faculties');
    $logger->error('The incredible burden of building good logging faculties');
    $logger->error('The incredible burden of building good logging faculties');
    $logger->error('The incredible burden of building good logging faculties');
    $logger->error('The incredible burden of building good logging faculties');
    $logger->error('The incredible burden of building good logging faculties');
    $logger->error('The incredible burden of building good logging faculties');
    $logger->error('The incredible burden of building good logging faculties');
    $logger->error('The incredible burden of building good logging faculties');
}

sub verifyThatLogWasWritten {
    #Verify that we actually wrote something and the Koha::Logger configurations work
    open(my $FH, '<', '/tmp/log4perl_test.log') or die $!;
    my $firstRow = <$FH>;
    close($FH);
    ok($firstRow =~ /The incredible burden of building good logging faculties/, "Log writing confirmed");
    #Clean up the temp log file or it will grow big quickly
    open($FH, '>', '/tmp/log4perl_test.log') or die $!;
    close($FH);
}

__DATA__
log4perl.logger.intranet = WARN, INTRANET
log4perl.appender.INTRANET=Log::Log4perl::Appender::File
log4perl.appender.INTRANET.filename=/tmp/log4perl_test.log
log4perl.appender.INTRANET.mode=append
log4perl.appender.INTRANET.layout=PatternLayout
log4perl.appender.INTRANET.layout.ConversionPattern=[%d] [%p] %m %l %n

log4perl.logger.opac = WARN, OPAC
log4perl.appender.OPAC=Log::Log4perl::Appender::File
log4perl.appender.OPAC.filename=/tmp/log4perl_test.log
log4perl.appender.OPAC.mode=append
log4perl.appender.OPAC.layout=PatternLayout
log4perl.appender.OPAC.layout.ConversionPattern=[%d] [%p] %m %l %n