#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use C4::Context;
use Koha::Logger;

use File::Temp qw/tempfile/;
use Test::MockModule;
use Test::More tests => 1;
use Test::Warn;

subtest 'Test01 -- Simple tests for Koha::Logger' => sub {
    plan tests => 8;
    test01();
};

sub test01 {

    my $ret;
    my $mContext = new Test::MockModule('C4::Context');
    $mContext->mock( 'config', sub { return; } );

    my $logger= Koha::Logger->get;
    is( exists $logger->{logger}, '', 'No log4perl config');
    my $d= $logger->debug('Message 1');
    is( $d, undef, 'No return value for debug call');

    my $log = mytempfile();
    my $conf = mytempfile( <<"HERE"
log4perl.logger.intranet = WARN, INTRANET
log4perl.appender.INTRANET=Log::Log4perl::Appender::File
log4perl.appender.INTRANET.filename=$log
log4perl.appender.INTRANET.mode=append
log4perl.appender.INTRANET.layout=PatternLayout
log4perl.appender.INTRANET.layout.ConversionPattern=[%d] [%p] %m %l %n
HERE
    );
    $mContext->mock( 'config', sub { return $conf; } );
    $logger= Koha::Logger->get({ interface => 'intranet' });
    is( exists $logger->{logger}, 1, 'Log4perl config found');
    is( $logger->warn('Message 2'), 1, 'Message 2 returned a value' );
    warning_is { $ret = $logger->catastrophe }
               "ERROR: Unsupported method catastrophe",
               "Undefined method raises warning";
    is( $ret, undef, "'catastrophe' method undefined");
    system("chmod 400 $log");
    warnings_are { $ret = $logger->warn('Message 3') }
                 [ "Log file not writable for log4perl",
                   "warn: Message 3" ],
                 "Warnings raised if log file is not writeable";
    is( $ret, undef, 'Message 3 returned undef' );
}

sub mytempfile {
    my ( $fh, $fn ) = tempfile( SUFFIX => '.logger.test', UNLINK => 1 );
    print $fh $_[0]//'';
    close $fh;
    return $fn;
}

1;
