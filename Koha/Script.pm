package Koha::Script;

# Copyright PTFS Europe 2019
# Copyright 2019 Koha Development Team
#
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

=head1 NAME

Koha::Script - Koha scripts base class

=head1 SYNOPSIS

    use Koha::Script
    use Koha::Script -cron;

=head1 DESCRIPTION

This class should be used in all scripts. It sets the interface and userenv appropriately.

=cut

use File::Basename            qw( fileparse );
use Fcntl                     qw( LOCK_EX LOCK_NB );
use Getopt::Long::Descriptive ();
use Pod::Usage                ();

use C4::Context;
use C4::Log qw( cronlogaction logscriptaction );
use Koha::Exceptions;
use Koha::Exception;

our $_cron = 0;

# Flag names (matched case-insensitively, substring match) whose following
# value should be redacted from logged command-line output.
my @_sensitive_patterns = qw( password passwd secret token apikey api_key credential ^p$ ^pass$ );

INIT {
    my $command_line_options = join( " ", _scrub_argv(@ARGV) );
    if ($_cron) {
        cronlogaction( { info => $command_line_options } );
    } else {
        logscriptaction( { info => $command_line_options } );
    }
}

END {
    if ($_cron) {
        cronlogaction( { action => 'End', info => "COMPLETED" } );
    } else {
        logscriptaction( { action => 'End', info => "COMPLETED" } );
    }
}

=head2 import

    use Koha::Script;
    use Koha::Script -cron;

Sets the interface and userenv appropriately based on the flags passed.

When the C<-cron> flag is used the script is automatically logged to the
CRONJOBS action log (start and end) when the C<CronjobLog> system
preference is enabled.

Without C<-cron>, the script is automatically logged to the SCRIPTS
action log when the C<ScriptLog> system preference is enabled.

In both cases, command-line arguments whose flag names contain sensitive
patterns (C<password>, C<secret>, C<token>, etc.) have their values
replaced with C<[REDACTED]> before logging.

=cut

sub import {
    my $class = shift;
    my @flags = @_;

    if ( ( $flags[0] || '' ) eq '-cron' ) {
        $_cron = 1;

        # Set userenv
        C4::Context->set_userenv(
            undef, undef, undef, 'CRON', 'CRON',
            undef, undef, undef, undef,  undef
        );

        # Set interface
        C4::Context->interface('cron');

    } else {

        # Set userenv
        C4::Context->set_userenv(
            undef, undef, undef, 'CLI', 'CLI',
            undef, undef, undef, undef, undef
        );

        # Set interface
        C4::Context->interface('commandline');
    }
}

=head2 Internal methods

=head3 _scrub_argv

    my @scrubbed = Koha::Script::_scrub_argv(@ARGV);

Returns a copy of the argument list with values redacted for any flag whose
name matches a sensitive pattern (C<password>, C<passwd>, C<secret>,
C<token>, C<apikey>, C<api_key>, C<credential>; case-insensitive substring
match). Handles both C<--flag value> and C<--flag=value> forms.

=cut

sub _scrub_argv {
    my @argv = @_;
    my $re   = join '|', @_sensitive_patterns;
    $re = qr/$re/i;

    my @out;
    my $i = 0;
    while ( $i < @argv ) {
        my $arg = $argv[$i];
        if ( $arg =~ /^(-{1,2})([\w-]+)=(.*)$/ ) {

            # --flag=value form
            my ( $dash, $name, $val ) = ( $1, $2, $3 );
            push @out, $name =~ $re ? "${dash}${name}=[REDACTED]" : $arg;
        } elsif ( $arg =~ /^(-{1,2})([\w-]+)$/ ) {

            # --flag form — peek at the next element; redact if it is a value
            # (i.e. does not itself start with a dash)
            my ( $dash, $name ) = ( $1, $2 );
            push @out, $arg;
            if ( $name =~ $re && $i + 1 < @argv && $argv[ $i + 1 ] !~ /^-/ ) {
                $i++;
                push @out, '[REDACTED]';
            }
        } else {
            push @out, $arg;
        }
        $i++;
    }
    return @out;
}

=head1 API

=head2 Class methods

=head3 new

    my $script = Koha::Script->new(
        {
            script    => $0, # mandatory
          [ lock_name => 'my_script' ]
        }
    );

Create a new Koha::Script object. The I<script> parameter is mandatory,
and will usually be passed I<$0> in the caller script. The I<lock_name>
parameter is optional, and is used to generate the lock file if passed.

=cut

sub new {
    my ( $class, $params ) = @_;
    my $script = $params->{script};

    Koha::Exceptions::MissingParameter->throw("The 'script' parameter is mandatory. You should usually pass \$0")
        unless $script;

    my $self = { script => $script };
    $self->{lock_name} = $params->{lock_name}
        if exists $params->{lock_name} and $params->{lock_name};

    bless $self, $class;
    return $self;
}

=head3 lock_exec

    # die if cannot get the lock
    try {
        $script->lock_exec;
    }
    catch {
        die "$_";
    };

    # wait for the lock to be released
    $script->lock_exec({ wait => 1 });

This method sets an execution lock to prevent concurrent execution of the caller
script. If passed the I<wait> parameter with a true value, it will make the caller
wait until it can be granted the lock (flock's LOCK_NB behaviour). It will
otherwise throw an exception immediately.

=cut

sub lock_exec {
    my ( $self, $params ) = @_;

    $self->_initialize_locking
        unless $self->{lock_file};

    my $lock_params = ( $params->{wait} ) ? LOCK_EX : LOCK_EX | LOCK_NB;

    open my $lock_handle, '>', $self->{lock_file}
        or Koha::Exception->throw( "Unable to open the lock file " . $self->{lock_file} . ": $!" );
    $self->{lock_handle} = $lock_handle;
    flock( $lock_handle, $lock_params )
        or Koha::Exception->throw( "Unable to acquire the lock " . $self->{lock_file} . ": $!" );
}

=head3 describe_options

    my $opt = Koha::Script->describe_options(
        'Move cart items back to their original shelving location.

%c %o',
        [ 'hours|h=i', 'hours since item was placed on the cart', { required => 1 } ],
        { epilog => "Examples:\n  %c --hours 24\n" },
    );

    # a required positional argument (e.g. one or more report IDs):
    my $opt = Koha::Script->describe_options(
        '%c %o reportID [ reportID ... ]',
        [ 'verbose|v', 'verbose output' ],
        { args => { min => 1, name => 'reportID', variadic => 1 } },
    );

    # or, when a post-parse check describe_options can't express needs $usage too:
    my ( $opt, $usage ) = Koha::Script->describe_options( ... );

Thin wrapper around L<Getopt::Long::Descriptive>'s C<describe_options>, and
the recommended way for scripts to declare and parse their command-line
options. Options can be declared C<required>, which is enforced before
control returns to the caller: a missing required option makes the script
die with a clear, consistent error and the generated usage text, before any
script logic runs.

The C<$format> string is passed straight through to
L<Getopt::Long::Descriptive>. C<%c> expands to the program name and C<%o> to
a short flags summary; anything else in C<$format> is free-form and always
rendered I<before> the per-option description list, so it is the place for a
short description of what the script does, not for examples (see below).

An optional trailing hashref may include an C<epilog>, which is printed
I<after> the per-option description list -- the natural place for
"Examples:" text, since C<$format> is always rendered first regardless of
where C<%o> appears within it. Unlike C<$format>, C<epilog> is not passed
to Getopt::Long::Descriptive itself, but C<%c> and C<%%> are still expanded
in it for consistency, so example invocations can use the program name.

The same trailing hashref may also include C<args>, declaring a minimum
number of positional (non-option) arguments -- something
L<Getopt::Long::Descriptive> has no way to express as an option, but which
scripts commonly require (e.g. one or more record IDs on the command
line). C<< args => { min => 1, name => 'reportID' } >> makes this exactly as
declarative and enforced-for-you as C<< { required => 1 } >> is for a named
option: if C<@ARGV> has fewer than C<min> elements after parsing, the
script dies with a clear, consistent error and the usage text, the same as
a missing required option would. C<name> is used in that error message.
C<variadic> is accepted as documentation only (whether more than C<min>
arguments are meaningful); it is not itself enforced. Note that
C<$format> is not updated automatically to mention the positional
argument(s) -- describe them there yourself, as in the SYNOPSIS above.

Two options are added automatically to every script using this convention:

=over

=item C<--help>

Prints the usage text (and epilog, if any) and exits cleanly (status 0).

=item C<--man>

Prints the calling script's own POD as a full manual page (via
L<Pod::Usage>'s C<< -verbose => 2 >>) and exits cleanly (status 0). This is
for scripts whose POD is thorough enough to be worth showing in full;
C<$format>/C<epilog> above remain the place for a short overview.

=back

Neither returns control to the caller; some options being declared
C<required> does not stop C<--help> or C<--man> from working, as both
shortcircuit that check.

Returns the C<$opt> object in scalar context. In list context, also
returns the C<$usage> object, useful for scripts that need to enforce
something L<Getopt::Long::Descriptive> can't express as an option (e.g. a
required positional argument) with a consistent error, via
C<< $usage->die({ pre_text => "..." }) >>.

=cut

sub describe_options {
    my ( $class, $format, @opt_specs ) = @_;

    my $meta   = ( ref $opt_specs[-1] eq 'HASH' ) ? pop(@opt_specs) : {};
    my $epilog = $meta->{epilog};
    my $args   = $meta->{args};

    my ( $opt, $usage ) = Getopt::Long::Descriptive::describe_options(
        $format,
        @opt_specs,
        [ 'help|?', 'print this usage message and exit',   { shortcircuit => 1 } ],
        [ 'man',    'print the full manual page and exit', { shortcircuit => 1 } ],
    );

    if ( $opt->man ) {
        Pod::Usage::pod2usage( { -verbose => 2, -exitval => 0 } );
    }

    if ( $opt->help ) {
        print $usage->text;
        if ( defined $epilog ) {
            my $prog_name = Getopt::Long::Descriptive::prog_name();
            ( my $text = $epilog ) =~ s/%c/$prog_name/g;
            $text =~ s/%%/%/g;
            print "\n$text";
        }
        exit 0;
    }

    if ($args) {
        my $min   = $args->{min} // 0;
        my $count = scalar @ARGV;
        if ( $count < $min ) {
            my $name = $args->{name} // 'argument';
            my $noun = $min == 1 ? 'argument' : 'arguments';
            $usage->die( { pre_text => "ERROR: At least $min $name $noun required (got $count)\n\n" } );
        }
    }

    return wantarray ? ( $opt, $usage ) : $opt;
}

=head2 Internal methods

=head3 _initialize_locking

    $self->_initialize_locking

This method initializes the locking configuration.

=cut

sub _initialize_locking {
    my ($self) = @_;

    my $lock_dir = C4::Context->config('lockdir') // C4::Context->temporary_directory();

    my $lock_name = $self->{lock_name} // fileparse( $self->{script} );
    $self->{lock_file} = "$lock_dir/$lock_name";

    return $self;
}

=head1 AUTHOR

Martin Renvoize <martin.renvoize@ptfs-europe.com>

=cut

1;
