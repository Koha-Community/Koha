#!/usr/bin/perl 
#-----------------------------------
# Script Name: build_holds_queue.pl
# Description: builds a holds queue in the tmp_holdsqueue table
#-----------------------------------
# FIXME: add command-line options for verbosity and summary
# FIXME: expand perldoc, explain intended logic

use Modern::Perl;

use Getopt::Long qw( GetOptions );
use Pod::Usage qw( pod2usage );

use C4::Context;
use C4::HoldsQueue qw(CreateQueue);
use C4::Log qw( cronlogaction );
use Koha::Script -cron;

=head1 NAME

build_holds_queue.pl - Rebuild the holds queue

=head1 SYNOPSIS

build_holds_queue.pl [-f]

 Options:
   -h --help        Brief help message
   -m --man         Full documentation
   -f --force    Run holds queue builder even if RealTimeHoldsQueue is enabled

=head1 OPTIONS

=over 8

=item B<--help>

Print a brief help message and exits.

=item B<--man>

Prints the manual page and exits.

=item B<--force>

Allows this script to rebuild the entire holds queue even if RealTimeHoldsQueue is enabled.

=back

=head1 DESCRIPTION

This script builds or rebuilds the entire holds queue.

=cut

my $help  = 0;
my $man   = 0;
my $force = 0;

my $command_line_options = join( " ", @ARGV );

GetOptions(
    'h|help'  => \$help,
    'm|man'   => \$man,
    'f|force' => \$force,
);
pod2usage(1)                              if $help;
pod2usage( -exitval => 0, -verbose => 2 ) if $man;

my $rthq = C4::Context->preference('RealTimeHoldsQueue');

if ( $rthq && !$force ) {
    say "Real Time Holds Queue is enabled, holds queue not built.";
    say "Use --force to force building the holds queue.";
    exit(1);
}

cronlogaction( { info => $command_line_options } );

CreateQueue();

cronlogaction( { action => 'End', info => "COMPLETED" } );
