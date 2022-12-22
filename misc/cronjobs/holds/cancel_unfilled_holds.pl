#!/usr/bin/perl

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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Getopt::Long qw( GetOptions );
use Pod::Usage qw( pod2usage );

use Koha::Script -cron;
use C4::Reserves;
use C4::Log qw( cronlogaction );
use Koha::Holds;
use Koha::Calendar;
use Koha::Libraries;

cronlogaction();

=head1 NAME

cancel_unfilled_holds.pl - script to delete unfilled holds after a given
number of days.

=head1 SYNOPSIS

 cancel_unfilled_holds.pl [--days][--library][--holidays][--confirm][--verbose][--reason]

=head1 OPTIONS

=over 8

=item B<--help | -h>

Print brief help and exit.

=item B<--days>

Specify the number of days waiting since a hold that remains unfilled was placed.
E.g. a value of 730 would cancel holds placed 2 years ago or more that have never been filled

=item B<--library>

Repeatable option to specify which branchcode(s) to cancel holds for.

=item B<--holidays>

This switch specifies whether to count holidays as days waiting. Default is no.

=item B<--confirm>

Without this option, the script will run in test mode, and only report what it
would have done if it were not running in test mode.

=item B<--verbose | -v>

More verbose output.

=item B<--reason>

Optionally adds a reason for cancellation (which will trigger a notice to be sent to the patron)

=back

=cut

my $help = 0;
my $days;
my @branchcodes;
my $use_calendar = 0;
my $verbose      = 0;
my $confirm      = 0;
my $reason;

my $command_line_options = join(" ",@ARGV);

GetOptions(
    'h|help|?'   => \$help,
    'days=s'     => \$days,
    'library=s'  => \@branchcodes,
    'holidays'   => \$use_calendar,
    'v|verbose'  => \$verbose,
    'confirm'    => \$confirm,
    'reason=s' => \$reason
) or pod2usage(1);
pod2usage(1) if $help;

unless ( defined $days ) {
    pod2usage(
        {
            -exitval => 1,
            -msg =>
qq{\nError: You must specify a value for days waiting to cancel holds.\n},
        }
    );
}

cronlogaction({ info => $command_line_options });

warn "Running in test mode, no actions will be taken" unless ($confirm);

$verbose and warn "Looking for unfilled holds placed $days or more days ago\n";

@branchcodes = Koha::Libraries->search->get_column('branchcode') if !@branchcodes;
$verbose and warn "Running for branch(es): " . join( "|", @branchcodes ) . "\n";

my $cancellation_params = {};
$cancellation_params->{cancellation_reason} = $reason if $reason;

foreach my $branch (@branchcodes) {

    my $holds =
      Koha::Holds->search( { branchcode => $branch } )->unfilled();

    while ( my $hold = $holds->next ) {

        my $age = $hold->age( $use_calendar );

        $verbose
          and warn "Hold #"
          . $hold->reserve_id
          . " has been unfilled for $age day(s)\n";

        if ( $age >= $days ) {
            my $action = $confirm ? "Cancelling " : "Would have cancelled ";
            $verbose
              and warn $action
              . "reserve_id: "
              . $hold->reserve_id
              . " for borrower: "
              . $hold->borrowernumber
              . " on biblio: "
              . $hold->biblionumber . "\n";
            $hold->cancel( $cancellation_params ) if $confirm;
        }

    }

}

cronlogaction({ action => 'End', info => "COMPLETED" });
