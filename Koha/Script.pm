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

use File::Basename qw( fileparse );
use Fcntl          qw( LOCK_EX LOCK_NB );

use C4::Context;
use C4::Log qw( cronlogaction logscriptaction );
use Koha::Exceptions;
use Koha::Exception;

our $_cron = 0;

# Flag names (matched case-insensitively, substring match) whose following
# value should be redacted from logged command-line output.
my @_sensitive_patterns = qw( password passwd secret token apikey api_key credential );

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
