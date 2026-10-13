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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 7;
use Test::Exception;

BEGIN { use_ok('Koha::Script') }

use File::Basename;

use C4::Context;

my $userenv = C4::Context->userenv;
is_deeply(
    $userenv,
    {
        'surname'       => 'CLI',
        'id'            => undef,
        'flags'         => undef,
        'cardnumber'    => undef,
        'firstname'     => 'CLI',
        'branchname'    => undef,
        'emailaddress'  => undef,
        'number'        => undef,
        'shibboleth'    => undef,
        'branch'        => undef,
        'desk_id'       => undef,
        'desk_name'     => undef,
        'register_id'   => undef,
        'register_name' => undef,
        'session_id'    => undef,
    },
    "Context userenv set correctly with no flags"
);

my $interface = C4::Context->interface;
is( $interface, 'commandline', "Context interface set correctly with no flags" );

ok( !$Koha::Script::_cron, '_cron flag is false when Koha::Script is loaded without -cron' );

subtest 'lock_exec() tests' => sub {

    plan tests => 3;

    # Launch the sleep script
    my $pid = fork();
    if ( $pid == 0 ) {
        system( dirname(__FILE__) . '/sleep.pl 2>&1' );
        exit;
    }

    sleep 1;    # Make sure we start after the fork
    my $command = dirname(__FILE__) . '/sleep.pl';
    my $result  = `$command 2>&1`;

    like( $result, qr{Unable to acquire the lock.*}, 'Exception found' );

    $pid = fork();
    if ( $pid == 0 ) {
        system( dirname(__FILE__) . '/sleep.pl 2>&1' );
        exit;
    }

    sleep 1;    # Make sure we start after the fork
    $command = dirname(__FILE__) . '/wait.pl';
    $result  = `$command 2>&1`;

    is( $result, 'YAY!', 'wait.pl successfully waits for the lock' );

    throws_ok { Koha::Script->new( { lock_name => 'blah' } ); }
    'Koha::Exceptions::MissingParameter',
        'Not passing the "script" parameter makes it raise an exception';
};

subtest 'describe_options() exit status tests' => sub {

    plan tests => 3;

    my $inc = join ' ', map { "-I$_" } grep { !ref } @INC;
    my $run = sub {
        my ($code) = @_;
        `$^X $inc -e '$code' 2>&1`;
        return $? >> 8;
    };
    my $describe = q{use Koha::Script; open my $fh, "<", "/nonexistent"; }
        . q{my ( $opt, $usage ) = Koha::Script->describe_options( "%c %o", [ "foo=s", "foo", { required => 1 } ] );};

    is( $run->("\@ARGV = qw(--bogus); $describe"), 1, 'An unknown option exits with status 1' );
    is( $run->("$describe"),                       1, 'A missing required option exits with status 1' );
    is(
        $run->("\@ARGV = qw(--foo bar); $describe \$usage->die( { pre_text => qq{Wrong\\n} } );"), 1,
        '$usage->die exits with status 1'
    );
};

1;
