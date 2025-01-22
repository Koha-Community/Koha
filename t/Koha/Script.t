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

use Test::NoWarnings;
use Test::More tests => 5;
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
    },
    "Context userenv set correctly with no flags"
);

my $interface = C4::Context->interface;
is( $interface, 'commandline', "Context interface set correctly with no flags" );

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

1;
