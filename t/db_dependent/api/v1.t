#!/usr/bin/env perl

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

use Test::More tests => 2;
use Test::Mojo;
use Test::Warn;

use t::lib::Mocks;
use Koha::Exceptions;

use Log::Log4perl;
use Mojolicious::Lite;
use Try::Tiny;

my $config = {
    'log4perl.logger.rest.Koha.REST.V1' => 'TRACE, TEST',
    'log4perl.appender.TEST' => 'Log::Log4perl::Appender::TestBuffer',
    'log4perl.appender.TEST.layout' => 'SimpleLayout',
};
t::lib::Mocks::mock_config('log4perl_conf', $config);

my $remote_address = '127.0.0.1';
my $t              = Test::Mojo->new('Koha::REST::V1');
my $tx;

subtest 'default_exception_handling() tests' => sub {
    plan tests => 5;

    add_default_exception_routes($t);

    my $appender = Log::Log4perl->appenders->{TEST};

    subtest 'Mojo::Exception' => sub {
        plan tests => 4;

        $t->get_ok('/default_exception_handling/mojo')
          ->status_is(500)
          ->json_is('/error' => 'Something went wrong, check the logs.');

        like($appender->buffer, qr/ERROR - test mojo exception/,
             'Found test mojo exception in log');
        $appender->{appender}->{buffer} = undef;
    };

    subtest 'die() outside try { } catch { };' => sub {
        plan tests => 4;

        $t->get_ok('/default_exception_handling/dieoutsidetrycatch')
          ->status_is(500)
          ->json_is('/error' => 'Something went wrong, check the logs.');
        like($appender->buffer, qr/ERROR - die outside try-catch/,
             'Found die outside try-catch in log');
        $appender->{appender}->{buffer} = undef;
    };

    subtest 'DBIx::Class::Exception' => sub {
        plan tests => 4;

        $t->get_ok('/default_exception_handling/dbix')
          ->status_is(500)
          ->json_is('/error' => 'Something went wrong, check the logs.');
        like($appender->buffer, qr/ERROR - DBIx::Class::Exception => .* test dbix exception/,
             'Found test dbix exception in log');
        $appender->{appender}->{buffer} = undef;
    };

    subtest 'Koha::Exceptions::Exception' => sub {
        plan tests => 4;

        $t->get_ok('/default_exception_handling/koha')
          ->status_is(500)
          ->json_is('/error' => 'Something went wrong, check the logs.');
        like($appender->buffer, qr/ERROR - Koha::Exceptions::Exception => test koha exception/,
             'Found test koha exception in log');
        $appender->{appender}->{buffer} = undef;
    };

    subtest 'Unknown exception' => sub {
        plan tests => 4;

        $t->get_ok('/default_exception_handling/unknown')
          ->status_is(500)
          ->json_is('/error' => 'Something went wrong, check the logs.');
        like($appender->buffer, qr/ERROR - Unknown::Exception::OhNo => \{"what":"test unknown exception"\}/,
             'Found test unknown exception in log');
        $appender->{appender}->{buffer} = undef;
    };
};

subtest 'log_request() and log_response() tests' => sub {
    plan tests => 12;

    $t->app->routes->get('/response/log/json' => sub {
        $_[0]->render( status => 200, json => { wow => "it worked" } )
    });
    $t->app->routes->post('/response/log/other' => sub {
        $_[0]->render( status => 200, data => '<b>ERROR!</b>' )
    });
    $t->app->routes->put('/response/log/500' => sub {
        die;
    });

    my $appender = Log::Log4perl->appenders->{TEST};

    $t->get_ok('/response/log/json')
      ->status_is(200)
      ->json_is('/wow' => 'it worked');
    is($appender->buffer,
       "TRACE - Request JSON body null\nTRACE - Request params {}\n".
       "TRACE - Rendering response {\"json\":{\"wow\":\"it worked\"},\"status\":200}\n",
       'Found request and response content'
    );
    $appender->{appender}->{buffer} = undef;

    $t->post_ok('/response/log/other' => form => { param1 => "value" })
      ->status_is(200)
      ->content_is('<b>ERROR!</b>');
    is($appender->buffer,
       "TRACE - Request JSON body null\nTRACE - Request params {\"param1\":\"value\"}\n".
       "TRACE - Rendering response {\"data\":\"<b>ERROR!<\\/b>\",\"status\":200}\n",
       'Found request and response content'
    );
    $appender->{appender}->{buffer} = undef;

    $t->put_ok('/response/log/500' => json => { param2 => "value" })
      ->status_is(500)
      ->json_is('/error' => 'Something went wrong, check the logs.');
    like($appender->buffer,
qr{TRACE - Request JSON body \{"param2":"value"\}\nTRACE - Request params \{\}
ERROR - Died at .* line \d+\.\n
TRACE - Rendering response \{"json":\{"error":"Something went wrong, check the logs\."\},"status":500\}
}msi,
       'Found request and response content'
    );
    $appender->{appender}->{buffer} = undef;

};

sub add_default_exception_routes {
    my ($t) = @_;

    # Mojo::Exception
    $t->app->routes->get('/default_exception_handling/mojo' => sub {
        try {
            die "test mojo exception";
        } catch {
            Koha::Exceptions::rethrow_exception($_);
        };
    });

    # die outside try-catch
    $t->app->routes->get('/default_exception_handling/dieoutsidetrycatch' => sub {
        die "die outside try-catch";
    });

    # DBIx::Class::Exception
    $t->app->routes->get('/default_exception_handling/dbix' => sub {
        package Koha::REST::V1::Test;
        try {
            DBIx::Class::Exception->throw('test dbix exception');
        } catch {
            Koha::Exceptions::rethrow_exception($_);
        };
    });

    # Koha::Exceptions::Exception
    $t->app->routes->get('/default_exception_handling/koha' => sub {
        try {
            Koha::Exceptions::Exception->throw('test koha exception');
        } catch {
            Koha::Exceptions::rethrow_exception($_);
        };
    });

    # Unknown exception
    $t->app->routes->get('/default_exception_handling/unknown' => sub {
        try {
            my $exception = { what => 'test unknown exception'};
            bless $exception, 'Unknown::Exception::OhNo';
            die $exception;
        } catch {
            Koha::Exceptions::rethrow_exception($_);
        };
    });
}

1;
