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
use File::Slurp;
use Test::MockModule;
use Test::More tests => 1;
use Test::Warn;

subtest 'Test01 -- Simple tests for Koha::Logger' => sub {
    plan tests => 6;
    test01();
};

sub test01 {

    my ($ret, $logger);
    my $mContext = new Test::MockModule('C4::Context');

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
    $logger = Koha::Logger->get({ interface => 'intranet' });

    is( ref($logger), 'Koha::Logger', 'Log4perl config found');
    is( $logger->warn('Message 2'), 1, 'Message 2 returned a value' );
    $ret = File::Slurp::read_file($log);
    like($ret, qr/Message 2/, 'Got a correct log entry');

    warning_is { $ret = $logger->catastrophe }
               "ERROR: Unsupported method Koha::Logger::catastrophe, params ''",
               "Undefined method raises warning";
    is( $ret, undef, "'catastrophe' method undefined");

    BAIL_OUT('Running test as root') if (getpwuid $>) eq 'root';
    eval {
        system("chmod 400 $log");
        kill 'HUP', $$; #HUP myself to reload log4perl config
        $logger->warn('Message 3');
        ok(0, 'Should have crashed because of missing write permission');
    };
    if ($@) {
        like($@, qr/Can't open $log \(Permission denied\)/, 'Crashed due to missing write permission');
    }
}

sub mytempfile {
    my ( $fh, $fn ) = tempfile( SUFFIX => '.logger.test', UNLINK => 1 );
    print $fh $_[0]//'';
    close $fh;
    return $fn;
}

