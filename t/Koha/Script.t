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
use Test::More tests => 10;
use Test::Exception;
use Test::Warn;

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

subtest 'describe_options() exclusive tests' => sub {

    plan tests => 7;

    my $describe = sub {
        local @ARGV = @_;
        return Koha::Script->describe_options(
            '%c %o',
            [ 'code|c:s@',         'letter code, repeatable' ],
            [ 'exclude-code|x:s@', 'exclude letter code, repeatable' ],
            [ 'active',            'active' ],
            [ 'inactive',          'inactive' ],
            {
                exclusive => [
                    [qw(code exclude-code)],
                    [qw(active inactive)],
                ]
            },
        );
    };

    my $opt = $describe->();
    ok( $opt, 'No options given: does not die' );

    $opt = $describe->( '--code', 'FOO' );
    is_deeply( $opt->code, ['FOO'], 'One side of a group given on its own: does not die' );

    throws_ok { $describe->( '--code', 'FOO', '--exclude-code', 'BAR' ) }
    qr/The options --code and --exclude-code are mutually exclusive/,
        'Both sides of a group given: dies with a clear message';

    throws_ok { $describe->( '--active', '--inactive' ) }
    qr/The options --active and --inactive are mutually exclusive/,
        'Both sides of a different group given: dies with a clear message';

    lives_ok { $describe->( '-c', '--exclude-code', 'BAR' ) }
    'A bare optional-value flag with no value (bug 37075) is not mistaken for a real value';

    throws_ok { $describe->( '--code', 'FOO', '--active', '--inactive' ) }
    qr/The options --active and --inactive are mutually exclusive/,
        'Only the violated group is reported when multiple groups are declared';

    $opt = $describe->( '--exclude-code', 'BAR' );
    is_deeply( $opt->exclude_code, ['BAR'], 'The other side of a group given on its own: does not die' );
};

subtest 'describe_options() exclusive group names tests' => sub {

    plan tests => 6;

    my $describe = sub {
        my ( $exclusive, @argv ) = @_;
        local @ARGV = @argv;
        return Koha::Script->describe_options(
            '%c %o',
            [ 'code|c:s@',         'letter code, repeatable' ],
            [ 'exclude-code|x:s@', 'exclude letter code, repeatable' ],
            [ 'active!',           'active' ],
            [ 'inactive',          'inactive' ],
            { exclusive => $exclusive },
        );
    };

    throws_ok { $describe->( [ [qw(code exclude_code)] ] ) }
    qr/The exclusive option 'exclude_code' must be written 'exclude-code'/,
        'An underscore form is rejected, naming the expected name';

    throws_ok { $describe->( [ [qw(c exclude-code)] ] ) }
    qr/The exclusive option 'c' must be written 'code'/,
        'An alias is rejected, naming the expected name';

    throws_ok { $describe->( [ [qw(code nosuch)] ] ) }
    'Koha::Exceptions::WrongParameter',
        'An unknown option is rejected';
    like( $@->message, qr/The exclusive option 'nosuch' is not a declared option/, 'with a clear message' );

    throws_ok { $describe->( [ [qw(active inactive)] ], '--no-active', '--inactive' ) }
    qr/The options --no-active and --inactive are mutually exclusive/,
        'A negated option is reported as --no-foo';

    throws_ok { $describe->( [ [qw(active inactive)] ], '--active', '--inactive' ) }
    qr/The options --active and --inactive are mutually exclusive/,
        'A negatable option given as is is reported as --foo';
};

1;

subtest 'describe_options() legacy single-dash long options tests' => sub {

    plan tests => 35;

    my $describe = sub {
        local @ARGV = @_;
        my $opt = Koha::Script->describe_options(
            '%c %o',
            [ 'days=i',       'days' ],
            [ 'lettercode=s', 'letter code' ],
            [ 'limit|l=s',    'limit' ],
            [ 'verbose|v',    'verbose' ],
            [ 'confirm|c',    'confirm' ],
            [ 'name:s',       'optional value' ],
            [ 'send!',        'negatable flag' ],
        );
        return ( $opt, [@ARGV] );
    };

    my ( $opt, $rest );

    warning_like { ( $opt, $rest ) = $describe->( '-days', '5' ) }
    qr/^WARNING: -days is deprecated, use --days instead/,
        '-days is accepted with a deprecation warning';
    is( $opt->days, 5, '-days 5 sets the option' );

    warnings_like { ( $opt, $rest ) = $describe->( '-days=5', '-lettercode', 'X' ) }
    [ qr/-days is deprecated, use --days/, qr/-lettercode is deprecated, use --lettercode/ ],
        'Each legacy option warns, with the =value form too';
    is_deeply( [ $opt->days, $opt->lettercode ], [ 5, 'X' ], '-days=5 -lettercode X set both options' );

    warnings_are { ( $opt, $rest ) = $describe->( '--days', '5' ) } [], 'The standard --days does not warn';
    is( $opt->days, 5, '--days 5 sets the option' );

    warnings_like { ( $opt, $rest ) = $describe->( '-letter', 'X' ) }
    [qr/-letter is deprecated, use --lettercode/],
        'A unique prefix of a long option is accepted, warning with the full name';
    is( $opt->lettercode, 'X', 'The prefix set the option' );

    warnings_like { ( $opt, $rest ) = $describe->( '-name', 'foo' ) }
    [qr/-name is deprecated, use --name/], 'An optional-value option is translated';
    is( $opt->name, 'foo', 'The optional value was kept' );

    warnings_are { ( $opt, $rest ) = $describe->('-vc') } [], 'A bundle of declared flags does not warn';
    ok( $opt->verbose && $opt->confirm, '-vc is still -v -c' );

    warnings_are { ( $opt, $rest ) = $describe->( '--lettercode', '-days' ) } [],
        'The value of an option is not rewritten';
    is_deeply( [ $opt->lettercode, $opt->days ], [ '-days', undef ], '--lettercode -days keeps -days as the value' );

    warnings_are { ( $opt, $rest ) = $describe->( '-l', '-days', '--days', '3' ) } [],
        'The value of a short option is not rewritten either';
    is_deeply( [ $opt->limit, $opt->days ], [ '-days', 3 ], '-l -days keeps -days as the value' );

    warnings_are { ( $opt, $rest ) = $describe->( '--days', '1', '--', '-days' ) } [], 'Nothing is rewritten after --';
    is_deeply( $rest, ['-days'], '-days after -- is left as a positional argument' );

    # Negatable options: -nosend and -no-send were accepted by plain Getopt::Long
    warnings_like { ( $opt, $rest ) = $describe->('-nosend') }
    [qr/-nosend is deprecated, use --no-send instead/], '-nosend is accepted with a deprecation warning';
    is( $opt->send, 0, '-nosend turns the negatable option off' );

    warnings_like { ( $opt, $rest ) = $describe->('-no-send') }
    [qr/-no-send is deprecated, use --no-send instead/], '-no-send is accepted with a deprecation warning';
    is( $opt->send, 0, '-no-send turns the negatable option off' );

    warnings_like { ( $opt, $rest ) = $describe->('-send') }
    [qr/-send is deprecated, use --send instead/], 'The positive form of a negatable option is translated too';
    is( $opt->send, 1, '-send turns the negatable option on' );

    warnings_are { ( $opt, $rest ) = $describe->('--nosend') } [], 'The standard --nosend does not warn';
    is( $opt->send, 0, '--nosend turns the negatable option off' );

    warnings_are { ( $opt, $rest ) = $describe->( '--lettercode', '-nosend' ) } [],
        'The value of an option is not rewritten, whether it looks like a negated option';
    is_deeply(
        [ $opt->lettercode, $opt->send ], [ '-nosend', undef ],
        '--lettercode -nosend keeps -nosend as the value'
    );

    my @warnings;
    my $died;
    {
        local $SIG{__WARN__} = sub { push @warnings, @_ };
        $died = !eval { $describe->('-nodays'); 1 };
    }
    ok( $died, 'A negated form of an option that is not negatable is still an error' );

    @warnings = ();
    {
        local $SIG{__WARN__} = sub { push @warnings, @_ };
        $died = !eval { $describe->('-bogus'); 1 };
    }
    ok( $died, 'An unknown single-dash option is still an error' );
    like( $warnings[0], qr/Unknown option/, '... with the usual Getopt::Long message, and no deprecation warning' );
    unlike( join( '', @warnings ), qr/deprecated/, 'An unknown option is not reported as deprecated' );

    my $inc = join ' ', map { "-I$_" } grep { !ref } @INC;
    my $out =
        `$^X $inc -e 'use Koha::Script; \@ARGV = qw(-help); Koha::Script->describe_options( "%c %o", [ "days=i", "days" ] );' 2>&1`;
    is( $? >> 8, 0, '-help exits with status 0' );
    like( $out, qr/-help is deprecated, use --help instead/, '-help warns that it is deprecated' );
    like( $out, qr/--days/,                                  '-help prints the usage text' );
};
