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
use t::lib::Mocks;

use File::Temp qw/tempfile/;
use Test::More tests => 1;
use Test::Warn;
use Test::Exception;

subtest 'Test01 -- Simple tests for Koha::Logger' => sub {
    plan tests => 10;

    my $ret;
    t::lib::Mocks::mock_config('log4perl_conf', undef);

    throws_ok { Koha::Logger->get } qr/Configuration not defined/, 'Logger did not init correctly without config';

    my $log = mytempfile();
    my $config_file = mytempfile( <<"HERE"
log4perl.logger.intranet = WARN, INTRANET
log4perl.appender.INTRANET=Log::Log4perl::Appender::File
log4perl.appender.INTRANET.filename=$log
log4perl.appender.INTRANET.mode=append
log4perl.appender.INTRANET.layout=PatternLayout
log4perl.appender.INTRANET.layout.ConversionPattern=[%d] [%p] %m %l%n
HERE
    );

    t::lib::Mocks::mock_config('log4perl_conf', $config_file);

    my $login = getlogin || getpwuid($<) || q{};

    SKIP: {
        skip "Running as root user", 1 if $login eq 'root';

        system("chmod 400 $log");
        throws_ok { Koha::Logger->get } qr/Permission denied/, 'Logger did not init correctly without permission';
        system("chmod 700 $log");
    }

    my $logger = Koha::Logger->get( { interface => 'intranet' } );
    is( exists $logger->{logger}, 1, 'Log4perl config found');
    is( $logger->warn('Message 1'), 1, '->warn returned a value' );
    warning_is { $ret = $logger->catastrophe }
               "ERROR: Unsupported method catastrophe",
               "Undefined method raises warning";
    is( $ret, undef, "'catastrophe' method undefined");

    Koha::Logger->put_mdc( 'foo', 'bar' );
    is( Koha::Logger->get_mdc( 'foo' ), 'bar', "MDC value via put_mdc is correct" );

    Koha::Logger->put_mdc( 'foo', undef );
    is( Koha::Logger->get_mdc( 'foo' ), undef, "Updated MDC value to undefined via put_mdc is correct" );

    Koha::Logger->put_mdc( 'foo', 'baz' );
    is( Koha::Logger->get_mdc( 'foo' ), 'baz', "Updated MDC value via put_mdc is correct" );

    Koha::Logger->clear_mdc();
    is( Koha::Logger->get_mdc( 'foo' ), undef, "MDC value was cleared by clear_mdc" );
};

sub mytempfile {
    my ( $fh, $fn ) = tempfile( SUFFIX => '.logger.test', UNLINK => 1 );
    print $fh $_[0]//'';
    close $fh;
    return $fn;
}

