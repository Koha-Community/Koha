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
use C4::Context;
C4::Context->interface('commandline'); #Set the context already prior to loading Koha::Logger (this actually doesn't fix the logger interface definition issue. Just doing it like this to show this doesn't work)
is(C4::Context->interface(), 'commandline', "Current Koha interface is 'commandline'"); #Show in test output what we are expecting to make test plan more understandable

#Initialize the Log4perl to write to /tmp/log4perl_test.log so we can clean it later
Log::Log4perl::init( t::Koha::Logger::getLog4perlConfig() );

use Koha::Logger;
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


done_testing();