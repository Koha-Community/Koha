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
use Mojo::Base -strict;
use Mojolicious::Lite;
use Log::Log4perl;

use Test::Mojo;
use Test::More tests => 4;
use t::lib::Mocks;

use C4::Context;

BEGIN {
    $ENV{MOJO_MODE}    = 'development';
    $ENV{MOJO_NO_IPV6} = 1;
    $ENV{MOJO_REACTOR} = 'Mojo::Reactor::Poll';
    $ENV{'LOG4PERL_CONF'} = undef;
}

use_ok('Koha::Logger::Mojo');

# Create test context
my $config = {
    'log4perl.logger.rest' => 'ERROR, TEST',
    'log4perl.appender.TEST' => 'Log::Log4perl::Appender::TestBuffer',
    'log4perl.appender.TEST.layout' => 'SimpleLayout',
};
C4::Context->interface('rest');
t::lib::Mocks::mock_config('log4perl_conf', $config);

subtest 'check inteface' => sub {
    plan tests => 1;

    is(C4::Context->interface, 'rest', 'Using appropriate interface.');
};

subtest 'get() tests' => sub {
    plan tests => 1;

    app->log(Koha::Logger::Mojo->get);
    my $log = app->log;
    isa_ok($log, 'Koha::Logger::Mojo');
};

subtest 'Test configuration effectiveness' => sub {
    plan tests => 6;

    get '/test' => sub {
        package Koha::REST::V1::Test; # otherwise category would be rest.main
        $_[0]->app->log->error('Very problem');
        $_[0]->app->log->warn('Such issue');
        $_[0]->render(text => 'Hello World');
    };

    app->log(Koha::Logger::Mojo->get);

    my $appender = Log::Log4perl->appenders->{TEST};
    ok($appender, 'Got TEST appender');

    my $t = Test::Mojo->new;
    $t->app->log(Koha::Logger::Mojo->get);
    $t->get_ok('/test')
      ->status_is(200)
      ->content_is('Hello World');
    like($appender->buffer, qr/ERROR - Very problem/, 'found wanted message');
    unlike($appender->buffer, qr/WARN - Such issue/, 'did not find unwanted message');
};

1;
