#!/usr/bin/perl
#
# Copyright ByWater Solutions 2015
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

use File::Basename qw( fileparse );
use Getopt::Long   qw( GetOptions :config no_ignore_case );
use Pod::Usage     qw( pod2usage );

use Koha::Config;
use Koha::Z3950Responder;

=head1 SYNOPSIS

   z3950_responder.pl [-h|--help] [--man] [-a <pdufile>] [-v <loglevel>] [-l <logfile>] [-u <user>]
                      [-c <config>] [-t <minutes>] [-k <kilobytes>] [-d <daemon>] [-p <pidfile>]
                      [-C certfile] [-zKiDST1] [-m <time-format>] [-w <directory>] [--debug]
                      [--add-item-status=SUBFIELD] [--prefetch=NUM_RECORDS] [--config-dir=<directory>]
                      [<listener-addr>... ]

=head1 OPTIONS

See https://software.indexdata.com/yaz/doc/server.invocation.html for more information about YAZ options
not described below.

=over 8

=item B<--help>

Prints a brief usage message and exits.

=item B<--man>

Displays manual page and exits.

=item B<--debug>

Turns on debug logging to the screen and the single-process mode.

=item B<--add-item-status=SUBFIELD>

If given, adds item status information to the given subfield.

=item B<--add-status-multi-subfield>

With the above, instead of putting multiple item statuses in one subfield, adds a subfield for each
status string.

=item B<--prefetch=NUM_RECORDS>

Number of records to prefetch. Defaults to 20.

=item B<--config-dir=directory>

Directory where to find configuration files required for proper operation. Defaults to z3950 under
the Koha config directory.

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
my $prefetch   = 20;
my $config_dir = '';

my @yaz_options;

sub add_yaz_option {
    my ( $opt_name, $opt_value ) = @_;

    push @yaz_options, "-$opt_name", "$opt_value";
}

sub pass_yaz_option {
    my ($opt_name) = @_;

    push @yaz_options, "-$opt_name";
}

GetOptions(
    '-h|help'                     => \$help,
    '--man'                       => \$man,
    '--debug'                     => \$debug,
    '--add-item-status=s'         => \$add_item_status_subfield,
    '--add-status-multi-subfield' => \$add_status_multi_subfield,
    '--prefetch=i'                => \$prefetch,
    '--config-dir=s'              => \$config_dir,

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
    'z'   => \&pass_yaz_option,
    'K'   => \&pass_yaz_option,
    'i'   => \&pass_yaz_option,
    'D'   => \&pass_yaz_option,
    'S'   => \&pass_yaz_option,
    'T'   => \&pass_yaz_option,
    '1'   => \&pass_yaz_option
) || pod2usage(2);

pod2usage(1)               if $help;
pod2usage( -verbose => 2 ) if $man;

# If config_dir is not defined, default to z3950 under the Koha config directory
if ( !$config_dir ) {
    ( undef, $config_dir ) = fileparse( Koha::Config->guess_koha_conf );
    $config_dir .= 'z3950/';
} else {
    $config_dir .= '/' if ( $config_dir !~ /\/$/ );
}

# Create and start the server.

my $z = Koha::Z3950Responder->new(
    {
        add_item_status_subfield  => $add_item_status_subfield,
        add_status_multi_subfield => $add_status_multi_subfield,
        debug                     => $debug,
        num_to_prefetch           => $prefetch,
        config_dir                => $config_dir,
        yaz_options               => [ @yaz_options, @ARGV ],
    }
);

$z->start();
