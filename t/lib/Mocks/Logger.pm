package t::lib::Mocks::Logger;

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

use base 'Test::Builder::Module';
use base qw(Class::Accessor);

use Test::MockModule;
use Test::MockObject;

my $CLASS = __PACKAGE__;

=head1 NAME

t::lib::Mocks::Logger - A library to mock Koha::Logger for testing

=head1 API

=head2 Methods

=head3 new

    my $logger = t::lib::Mocks::Logger->new();

Mocks the Koha::Logger for testing purposes. The mocked subs (log levels)
return the passed string, in case we want to test the debugging string contents.

=cut

sub new {
    my ( $class, $params ) = @_;

    my $mocked_logger_class = Test::MockModule->new("Koha::Logger");
    my $mocked_logger       = Test::MockObject->new();

    $mocked_logger_class->mock(
        'get',
        sub {
            return $mocked_logger;
        }
    );

    my $self = $class->SUPER::new(
        {
            logger => $mocked_logger_class,
            debug  => [],
            error  => [],
            info   => [],
            fatal  => [],
            trace  => [],
            warn   => [],
        }
    );
    bless $self, $class;

    foreach my $level ( levels() ) {
        $mocked_logger->mock(
            $level,
            sub {
                my $message     = $_[1];
                my @caller_info = caller(2);
                push @{ $self->{$level} }, { message => $message, caller => \@caller_info };
                return $message;
            }
        );
    }

    return $self;
}

=head3 diag

    $logger->diag();

Method to output all received logs.

=cut

sub diag {
    my ($self) = @_;
    my $tb = $CLASS->builder;

    foreach my $level ( levels() ) {
        $tb->diag("$level:");
        if ( @{ $self->{$level} } ) {
            foreach my $log_entry ( @{ $self->{$level} } ) {
                my ( $package, $filename, $line ) = @{ $log_entry->{caller} };
                $tb->diag( "    \"" . $log_entry->{message} . "\" at $filename line $line" );
            }
        } else {
            $tb->diag("   (No $level messages)");
        }
    }
    return;
}

=head3 debug_is

    $logger->debug_is($expected);

Method for testing a message was written to the 'debug' log level.

=cut

sub debug_is {
    my ( $self, $expect, $name ) = @_;
    $self->generic_is( 'debug', $expect, $name );
    return $self;
}

=head3 error_is

    $logger->error_is($expected);

Method for testing a message was written to the 'error' log level.

=cut

sub error_is {
    my ( $self, $expect, $name ) = @_;
    $self->generic_is( 'error', $expect, $name );
    return $self;
}

=head3 fatal_is

    $logger->fatal_is($expected);

Method for testing a message was written to the 'fatal' log level.

=cut

sub fatal_is {
    my ( $self, $expect, $name ) = @_;
    $self->generic_is( 'fatal', $expect, $name );
    return $self;
}

=head3 info_is

    $logger->info_is($expected);

Method for testing a message was written to the 'info' log level.

=cut

sub info_is {
    my ( $self, $expect, $name ) = @_;
    $self->generic_is( 'info', $expect, $name );
    return $self;
}

=head3 trace_is

    $logger->trace_is($expected);

Method for testing a message was written to the 'trace' log level.

=cut

sub trace_is {
    my ( $self, $expect, $name ) = @_;
    $self->generic_is( 'trace', $expect, $name );
    return $self;
}

=head3 warn_is

    $logger->warn_is($expected);

Method for testing a message was written to the 'warn' log level.

=cut

sub warn_is {
    my ( $self, $expect, $name ) = @_;
    $self->generic_is( 'warn', $expect, $name );
    return $self;
}

=head3 debug_like

    $logger->debug_like($expected);

Method for testing a message matching a regex was written to the 'debug' log level.

=cut

sub debug_like {
    my ( $self, $expect, $name ) = @_;
    $self->generic_like( 'debug', $expect, $name );
    return $self;
}

=head3 error_like

    $logger->error_like($expected);

Method for testing a message matching a regex was written to the 'error' log level.

=cut

sub error_like {
    my ( $self, $expect, $name ) = @_;
    $self->generic_like( 'error', $expect, $name );
    return $self;
}

=head3 fatal_like

    $logger->fatal_like($expected);

Method for testing a message matching a regex was written to the 'fatal' log level.

=cut

sub fatal_like {
    my ( $self, $expect, $name ) = @_;
    $self->generic_like( 'fatal', $expect, $name );
    return $self;
}

=head3 info_like

    $logger->info_like($expected);

Method for testing a message matching a regex was written to the 'info' log level.

=cut

sub info_like {
    my ( $self, $expect, $name ) = @_;
    $self->generic_like( 'info', $expect, $name );
    return $self;
}

=head3 trace_like

    $logger->trace_like($expected);

Method for testing a message matching a regex was written to the 'trace' log level.

=cut

sub trace_like {
    my ( $self, $expect, $name ) = @_;
    $self->generic_like( 'trace', $expect, $name );
    return $self;
}

=head3 warn_like

    $logger->warn_like($expected);

Method for testing a message matching a regex was written to the 'warn' log level.

=cut

sub warn_like {
    my ( $self, $expect, $name ) = @_;
    $self->generic_like( 'warn', $expect, $name );
    return $self;
}

=head3 count

    is( $logger->count( [ $level ] ), 0 'No logs!' );

Method for counting the generated messages. An optional I<$level> parameter
can be passed to restrict the count to the passed level.

=cut

sub count {
    my ( $self, $level ) = @_;

    unless ($level) {
        my $sum = 0;

        map { $sum += scalar @{ $self->{$_} } } levels();

        return $sum;
    }

    return scalar @{ $self->{$level} };
}

=head3 clear

    $logger->debug_is( "Something", "Something was sent to 'debug'" )
           ->warn_like( qr/^Something$/, "Something was sent to 'warn" )
           ->clear( [ $level ] );

A method for resetting the mocked I<$logger> object buffer. Useful to avoid inter-tests
pollution.

=cut

sub clear {
    my ( $self, $level ) = @_;

    if ($level) {
        $self->{$level} = [];
    } else {
        foreach my $l ( levels() ) {
            $self->{$l} = [];
        }
    }

    return $self;
}

=head2 Internal methods

=head3 generic_is

Internal method to be used to build log level-specific exact string test methods.

=cut

sub generic_is {
    my ( $self, $level, $expect, $name ) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my $log    = shift @{ $self->{$level} };
    my $string = defined($log) ? $log->{message} : '';
    my $tb     = $CLASS->builder;
    return $tb->is_eq( $string, $expect, $name );
}

=head3 generic_like

Internal method to be used to build log level-specific regex string test methods.

=cut

sub generic_like {
    my ( $self, $level, $expect, $name ) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my $log    = shift @{ $self->{$level} };
    my $string = defined($log) ? $log->{message} : '';
    my $tb     = $CLASS->builder;
    return $tb->like( $string, $expect, $name );
}

=head3 levels

Internal method that returns a list of valid log levels.

=cut

sub levels {
    return qw(trace debug info warn error fatal);
}

1;
