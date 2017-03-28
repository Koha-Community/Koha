package C4::KohaSuomi::TestRunner;

# Copyright 2017 KohaSuomi
#
# This file is part of Koha.
#

use Modern::Perl;
use Carp;
use autodie;
$Carp::Verbose = 'true'; #die with stack trace
use English; #Use verbose alternatives for perl's strange $0 and $\ etc.
use Getopt::Long qw(:config no_ignore_case);
use Try::Tiny;
use Scalar::Util qw(blessed);

=head1 C4::KohaSuomi::TestRunner

Runs all Koha tests in petite chunks

=cut

use Koha::Exception::SystemCall;

=head2 new

Create a new test runner

=cut

sub new {
  my ($class, $verbose) = @_;
  my $self = bless({}, $class);
  $self->{verbose} = $verbose;
  return $self;
}

=head2 shell

Runs a shell command and returns the captured STDOUT

@THROWS Koha::Exception::SystemCall with params exitCode and killSignal

=cut

sub shell {
  my ($self, @cmd) = @_;
  my $rv = `@cmd`;
  my $exitCode = ${^CHILD_ERROR_NATIVE} >> 8;
  my $killSignal = ${^CHILD_ERROR_NATIVE} & 127;
  my $coreDumpTriggered = ${^CHILD_ERROR_NATIVE} & 128;
  Koha::Exception::SystemCall->throw(error => "Shell command: @cmd\n  exited with code '$exitCode'. Killed by signal '$killSignal'.".(($coreDumpTriggered) ? ' Core dumped.' : '')."\n  STDOUT: $rv\n",
                                     exitCode => $exitCode,
                                     killSignal => $killSignal,
  ) if $exitCode != 0;
  print "@cmd\n$rv\n" if $rv && $self->verbose() > 0;
  return $rv;
}


=head2 verbose

=cut

sub verbose {
  my ($self, $verbose) = @_;
  return $self->{verbose} unless $verbose;
  return $self->{verbose} = $verbose;
}

1;
