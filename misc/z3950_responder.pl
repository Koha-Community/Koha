#!/usr/bin/perl
#
# Copyright ByWater Solutions 2015
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Carp;
use Getopt::Long;
use Pod::Usage;

use C4::Context;
use Koha::Z3950Responder;

=head1 SYNOPSIS

   z3950_responder.pl [-h|--help] [--man] [-a <pdufile>] [-v <loglevel>] [-l <logfile>] [-u <user>]
                      [-c <config>] [-t <minutes>] [-k <kilobytes>] [-d <daemon>] [-p <pidfile>]
                      [-C certfile] [-zKiDST1] [-m <time-format>] [-w <directory>] [--debug]
                      [--add-item-status=SUBFIELD] [--prefetch=NUM_RECORDS]
                      [<listener-addr>... ]

=head1 OPTIONS

=over 8

=item B<--help>

Prints a brief usage message and exits.

=item B<--man>

Displays manual page and exits.

=item B<--debug>

Turns on debug logging to the screen, and turns on single-process mode.

=item B<--add-item-status=SUBFIELD>

If given, adds item status information to the given subfield.

=item B<--add-status-multi-subfield>

With the above, instead of putting multiple item statuses in one subfield, adds a subfield for each
status string.

=item B<--prefetch=NUM_RECORDS>

Number of records to prefetch from Zebra. Defaults to 20.

=back

=head1 CONFIGURATION

The item status strings added by B<--add-item-status> can be configured with the B<Z3950_STATUS>
authorized value, using the following keys:

=over 4

=item AVAILABLE

=item CHECKED_OUT

=item LOST

=item NOT_FOR_LOAN

=item DAMAGED

=item WITHDRAWN

=item IN_TRANSIT

=item ON_HOLD

=back

=cut

my $add_item_status_subfield;
my $add_status_multi_subfield;
my $debug = 0;
my $help;
my $man;
my $prefetch = 20;
my @yaz_options;

sub add_yaz_option {
    my ( $opt_name, $opt_value ) = @_;

    push @yaz_options, "-$opt_name", "$opt_value";
}

GetOptions(
    '-h|help' => \$help,
    '--man' => \$man,
    '--debug' => \$debug,
    '--add-item-status=s' => \$add_item_status_subfield,
    '--add-status-multi-subfield' => \$add_status_multi_subfield,
    '--prefetch=i' => \$prefetch,
    # Pass through YAZ options.
    'a=s' => \&add_yaz_option,
    'v=s' => \&add_yaz_option,
    'l=s' => \&add_yaz_option,
    'u=s' => \&add_yaz_option,
    'c=s' => \&add_yaz_option,
    't=s' => \&add_yaz_option,
    'k=s' => \&add_yaz_option,
    'd=s' => \&add_yaz_option,
    'p=s' => \&add_yaz_option,
    'C=s' => \&add_yaz_option,
    'm=s' => \&add_yaz_option,
    'w=s' => \&add_yaz_option,
    'z' => \&add_yaz_option,
    'K' => \&add_yaz_option,
    'i' => \&add_yaz_option,
    'D' => \&add_yaz_option,
    'S' => \&add_yaz_option,
    'T' => \&add_yaz_option,
    '1' => \&add_yaz_option
) || pod2usage(2);

pod2usage(1) if $help;
pod2usage( -verbose => 2 ) if $man;

# Create and start the server.

die "This tool only works with Zebra" if C4::Context->preference('SearchEngine') ne 'Zebra';

my $z = Koha::Z3950Responder->new( {
    add_item_status_subfield => $add_item_status_subfield,
    add_status_multi_subfield => $add_status_multi_subfield,
    debug => $debug,
    num_to_prefetch => $prefetch,
    yaz_options => [ @yaz_options, @ARGV ],
} );

$z->start();
