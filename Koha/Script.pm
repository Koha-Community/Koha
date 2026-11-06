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

use Carp                      qw( carp );
use File::Basename            qw( fileparse );
use Fcntl                     qw( LOCK_EX LOCK_NB );
use Getopt::Long::Descriptive ();
use Koha::Script::Usage;
use Pod::Usage ();

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

    # options that must not be combined (e.g. --code and --exclude-code):
    my $opt = Koha::Script->describe_options(
        '%c %o',
        [ 'code|c:s@',         'letter code to process, repeatable' ],
        [ 'exclude-code|x:s@', 'letter code to exclude, repeatable' ],
        { exclusive => [ [qw(code exclude-code)] ] },
    );

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

The same trailing hashref may also include C<exclusive>, declaring one or
more groups of options that must not be given together, e.g. C<< [qw(code
exclude-code)] >> for a script whose C<--code> and C<--exclude-code>
options are alternatives. C<< exclusive => [ \@group1, \@group2, ... ] >>
takes a list of such groups (most scripts need only one); each group is a
list of option names I<as first declared in their spec string>, hyphens
and all (e.g. C<exclude-code>, not the accessor's C<exclude_code> --
L<Getopt::Long::Descriptive>'s introspection needs the former). If more
than one option in the same group is actually given a value, the script
dies with a clear, consistent error naming the conflicting options (as
C<--flags>) and the usage text, the same as a missing required option
would. An option is considered "given" if it was specified on the command
line I<and> resolved to a non-empty value -- a bare flag with no value
left over from L<Getopt::Long>'s optional-value (C<:s>) types (see bug
37075) does not by itself trigger the conflict. A negatable option given
as C<--no-foo> is reported as such. A group member that is not written
as an option's first-declared name (an alias, an underscore form, or an
unknown option) is a programming error: a
L<Koha::Exceptions::WrongParameter> is thrown, naming the expected name
when there is one, instead of the group being silently never enforced.

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

Scripts converted to this convention used to be parsed by plain
L<Getopt::Long>, which also accepted (and many scripts documented) a long
option with a single dash, e.g. C<-days 5>; L<Getopt::Long::Descriptive>
parses with bundling and no longer understands it, so existing command
lines such as cron jobs would stop working. To give them time to migrate,
such an argument is rewritten as the standard C<--days> and a deprecation
warning is printed to STDERR (cron mails it to the administrator). Only an
argument that is a single dash followed by at least two characters is
considered, and only if it is a declared long option name or the unique
prefix of one and is not a bundle of declared one-character flags (C<-vc>
is still C<-v -c>). A negatable option (e.g. C<send!>) is also accepted as
C<-nosend> or C<-no-send>, rewritten as C<--no-send>. The values given to options, and anything after C<-->,
are left alone. This is a compatibility shim and will be removed in a future
release; use C<--long> in new command lines and documentation.

Returns the C<$opt> object in scalar context. In list context, also
returns the C<$usage> object, useful for scripts that need to enforce
something L<Getopt::Long::Descriptive> can't express as an option (e.g. a
required positional argument) with a consistent error, via
C<< $usage->die({ pre_text => "..." }) >>.

Whatever the error (unknown option, missing required option or argument,
or a C<< $usage->die >> call by the script), the script exits with status
1, the same as C<pod2usage(1)> did.

=cut

sub describe_options {
    my ( $class, $format, @opt_specs ) = @_;

    my $meta      = ( ref $opt_specs[-1] eq 'HASH' ) ? pop(@opt_specs) : {};
    my $epilog    = $meta->{epilog};
    my $args      = $meta->{args};
    my $exclusive = $meta->{exclusive};

    my %negatable;
    if ($exclusive) {
        my $names = _option_names(@opt_specs);
        for my $group (@$exclusive) {
            for my $name (@$group) {
                next if $names->{$name} && $names->{$name} eq $name;
                Koha::Exceptions::WrongParameter->throw(
                    $names->{$name}
                    ? "The exclusive option '$name' must be written '$names->{$name}', as first declared in its spec"
                    : "The exclusive option '$name' is not a declared option"
                );
            }
        }
        %negatable = map { $_ => 1 } _negatable_option_names(@opt_specs);
    }

    # Scripts converted from plain Getopt::Long used to accept -long as well as --long
    @ARGV = _translate_legacy_options( [ @opt_specs, [ 'help|?', 'help' ], [ 'man', 'man' ] ], @ARGV );

    my ( $opt, $usage ) = eval {
        Getopt::Long::Descriptive::describe_options(
            $format,
            @opt_specs,
            [ 'help|?', 'print this usage message and exit',   { shortcircuit => 1 } ],
            [ 'man',    'print the full manual page and exit', { shortcircuit => 1 } ],
        );
    };
    unless ($opt) {

        # Unknown option, missing required option...: exit with status 1 too
        my $error = $@;
        Koha::Script::Usage::set_exit_status();
        die $error;
    }
    bless $usage, 'Koha::Script::Usage';

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

    for my $group ( @{ $exclusive || [] } ) {
        my @given = grep { _opt_is_given( $opt, $_ ) } @$group;
        if ( @given > 1 ) {
            my @flags = map {
                my $accessor = tr/-/_/r;
                $negatable{$_} && !$opt->$accessor ? "--no-$_" : "--$_"
            } @given;
            my $message =
                @flags == 2
                ? "The options $flags[0] and $flags[-1] are mutually exclusive.\nUse one or the other.\n\n"
                : "The options " . join( ', ', @flags ) . " are mutually exclusive.\nUse only one of them.\n\n";
            $usage->die( { pre_text => $message } );
        }
    }

    return wantarray ? ( $opt, $usage ) : $opt;
}

=head3 _opt_is_given

    my $bool = Koha::Script::_opt_is_given( $opt, 'exclude-code' );

Returns true if the option first declared as C<$name> (hyphens and all --
see C<exclusive> in L</describe_options>) was both specified on the
command line and resolved to a non-empty value: a scalar option with a
defined, non-empty-string value, or an array option with at least one
non-empty element. A bare optional-value (C<:s>) flag left over as an
empty string (bug 37075) is not mistaken for a real conflicting value.

=cut

sub _opt_is_given {
    my ( $opt, $name ) = @_;

    return 0 unless $opt->_specified($name);

    my $accessor = $name =~ tr/-/_/r;
    my $value    = $opt->$accessor;
    return
          ref $value eq 'ARRAY'
        ? ( grep { defined($_) && $_ ne q{} } @$value )
            ? 1
            : 0
        : ( defined($value) && $value ne q{} ) ? 1
        :                                        0;
}

=head3 _option_names

    my $names = Koha::Script::_option_names(@opt_specs);

Returns a hashref mapping every name an option can be referred to by (its
first-declared name, its aliases, and their underscore forms) to its
first-declared name, the one C<exclusive> groups must use.

=cut

sub _option_names {
    my (@opt_specs) = @_;

    my %names;
    for my $spec (@opt_specs) {
        next unless ref $spec eq 'ARRAY' && @$spec > 1 && defined $spec->[0];
        my ($all) = $spec->[0] =~ /^([\w|?-]+)/;
        next unless defined $all;
        my ( $first, @aliases ) = split /\|/, $all;
        for my $alias ( $first, @aliases ) {
            $names{$alias} //= $first;
            $names{ $alias =~ tr/-/_/r } //= $first;
        }
    }
    return \%names;
}

=head3 _negatable_option_names

    my @names = Koha::Script::_negatable_option_names(@opt_specs);

Returns the first-declared names of the negatable (C<!>) options, so a
conflict on C<--no-foo> is reported as such.

=cut

sub _negatable_option_names {
    my (@opt_specs) = @_;

    return map { $_->[0] =~ /^([\w?-]+)[\w|?-]*!/ ? $1 : () }
        grep { ref $_ eq 'ARRAY' && @$_ > 1 && defined $_->[0] } @opt_specs;
}

=head3 _translate_legacy_options

    my @argv = _translate_legacy_options( \@opt_specs, @ARGV );

Rewrites legacy single-dash long options (C<-days 5>, C<-days=5>) as the
standard C<--days>, warning that the old form is deprecated. See
L</describe_options> for the rules.

=cut

sub _translate_legacy_options {
    my ( $opt_specs, @argv ) = @_;

    # name => 0 (flag), 1 (mandatory value) or 2 (optional value)
    my ( %takes_value, %is_short, @long_names );

    # Every accepted spelling of a long option => the standard --long form to rewrite it as.
    # A negatable option (e.g. 'send!') is also accepted as -nosend and -no-send, rewritten
    # as --no-send, as plain Getopt::Long did.
    my %standard;
    for my $spec (@$opt_specs) {
        next unless ref $spec eq 'ARRAY' && defined $spec->[0];
        my ( $names, $type ) = $spec->[0] =~ /^([\w|?-]+)([=:].*)?/ or next;
        my $negatable = $spec->[0]                 =~ /^[\w|?-]+!$/;
        my $arity     = !defined $type ? 0 : $type =~ /^=/ ? 1 : 2;
        for my $name ( split /\|/, $names ) {
            $takes_value{$name} = $arity;
            if ( length $name == 1 ) { $is_short{$name} = 1 }
            else {
                push @long_names, $name;
                $standard{$name} = $name;
                if ($negatable) {
                    $standard{"no$name"}     = "no-$name";
                    $standard{"no-$name"}    = "no-$name";
                    $takes_value{"no-$name"} = 0;
                }
            }
        }
    }

    # A declared long option name or the negated form of a negatable one, or the unique
    # prefix of a declared long option name, resolved to the standard long form
    my $resolve = sub {
        my ($name) = @_;
        return $standard{$name} if exists $standard{$name};
        my @matches = grep { index( $_, $name ) == 0 } @long_names;
        return @matches == 1 ? $matches[0] : undef;
    };

    my ( @out, $value_follows );
    while (@argv) {
        my $arg = shift @argv;

        if ($value_follows) {    # the value of the previous option, never an option
            push @out, $arg;
            $value_follows = 0;
        } elsif ( $arg eq '--' ) {
            push @out, $arg, @argv;
            last;
        } elsif ( $arg =~ /^--([\w?-]+)(=.*)?$/s ) {
            my ( $name, $value ) = ( $1, $2 );
            my $known = $resolve->($name);
            $value_follows = 1 if defined $known && $takes_value{$known} == 1 && !defined $value;
            push @out, $arg;
        } elsif ( $arg =~ /^-([A-Za-z][\w-]+)(=.*)?$/s ) {    # a dash and at least two characters
            my ( $word, $value ) = ( $1, $2 );
            my $is_bundle = !grep { !$is_short{$_} } split //, $word;
            my $name      = $is_bundle ? undef : $resolve->($word);
            if ( defined $name ) {
                carp "WARNING: -$word is deprecated, use --$name instead "
                    . "(single-dash long options will stop working in a future release)";
                push @out, "--$name" . ( $value // '' );
                $value_follows = 1 if $takes_value{$name} == 1 && !defined $value;
            } else {
                push @out, $arg;
                $value_follows = 1 if $is_bundle && $takes_value{ substr $word, -1 } == 1;
            }
        } else {
            $value_follows = 1 if $arg =~ /^-([A-Za-z?])$/ && ( $takes_value{$1} // 0 ) == 1;
            push @out, $arg;
        }
    }

    return @out;
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
