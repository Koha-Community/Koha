#!/usr/bin/perl

# Copyright 2009-2010 Kyle Hall
# Copyright 2020 PTFS Europe
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

=head1 NAME

cancel_expired_holds.pl - cron script to cancel holds as they expire

=head1 SYNOPSIS

  ./cancel_expired_holds.pl
  ./cancel_expired_holds.pl --reason="EXPIRED"

or, in crontab:

  0 1 * * * cancel_expired_holds.pl
  0 1 * * * cancel_expired_holds.pl --reason="EXPIRED"

=head1 DESCRIPTION

This script calls C4::Reserves::CancelExpiredReserves which will find and cancel all expired reserves in the system.

=cut

use Modern::Perl;
use Getopt::Long qw( GetOptions );
use Pod::Usage   qw( pod2usage );

use Koha::Script -cron;
use C4::Reserves;
use C4::Log qw( cronlogaction );

=head1 OPTIONS

=over 8

=item B<--help>

Print a brief help message and exits.

=item B<--reason>

Optionally adds a reason for cancellation (which will trigger a notice to be sent to the patron)

=back

=cut

my $help = 0;
my $reason;

my $command_line_options = join( " ", @ARGV );
cronlogaction( { info => $command_line_options } );

GetOptions(
    'help|?'   => \$help,
    'reason=s' => \$reason
) or pod2usage(1);
pod2usage(1) if $help;

C4::Reserves::CancelExpiredReserves($reason);

cronlogaction( { action => 'End', info => "COMPLETED" } );
