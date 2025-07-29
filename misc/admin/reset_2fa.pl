#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2025 Koha Development Team
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
use Pod::Usage   qw( pod2usage );

use Koha::Patrons;
use Koha::Script;

my ( $help, $cardnumber, $patron_id, $userid );
GetOptions(
    'help|?'       => \$help,
    'userid=s'     => \$userid,
    'patron_id=s'  => \$patron_id,
    'cardnumber=s' => \$cardnumber,
);

pod2usage(1) if $help;

# Validate that exactly one parameter is provided (mutually exclusive)
my $param_count = grep { defined } ( $userid, $patron_id, $cardnumber );

if ( $param_count == 0 ) {
    pod2usage("Error: One of --userid, --patron_id, or --cardnumber is required");
} elsif ( $param_count > 1 ) {
    pod2usage("Error: Only one of --userid, --patron_id, or --cardnumber can be specified");
}

# Build search filter based on the provided parameter
my $filter = {};
my $search_type;

if ($userid) {
    $filter->{userid} = $userid;
    $search_type = "userid '$userid'";
} elsif ($cardnumber) {
    $filter->{cardnumber} = $cardnumber;
    $search_type = "cardnumber '$cardnumber'";
} elsif ($patron_id) {
    $filter->{borrowernumber} = $patron_id;
    $search_type = "patron_id '$patron_id'";
}

# Find the patron
my $patrons = Koha::Patrons->search($filter);

unless ( $patrons->count > 0 ) {
    say "Error: No patron found with $search_type";
    exit 1;
}

my $patron = $patrons->next;

# Check if patron actually has 2FA enabled
unless ( $patron->has_2fa_enabled ) {
    say "Patron "
        . $patron->cardnumber . " ("
        . $patron->firstname . " "
        . $patron->surname
        . ") does not have 2FA enabled.";
    exit 0;
}

# Display patron information and current status
say "Resetting 2FA for patron:";
say "  Card number: " . $patron->cardnumber;
say "  Name: " . $patron->firstname . " " . $patron->surname;
say "  Current auth method: " . ( $patron->auth_method || 'password' );

# Reset 2FA settings using the new method
eval { $patron->reset_2fa; };

if ($@) {
    say "Error: Failed to reset 2FA settings: $@";
    exit 1;
}

say "Success: 2FA has been reset for patron " . $patron->cardnumber;

=head1 NAME

reset_2fa.pl - Reset the 2FA setting for the Koha user

=head1 SYNOPSIS

reset_2fa.pl --userid <userid>
reset_2fa.pl --patron_id <patron_id>
reset_2fa.pl --cardnumber <cardnumber>

 Options:
   -?|--help        brief help message
   --userid         the userid to be used to find the patron
   --patron_id      the borrowernumber for the patron
   --cardnumber     the cardnumber for the patron

 Note: Only one of --userid, --patron_id, or --cardnumber should be specified.

=head1 OPTIONS

=over 8

=item B<--help|-?>

Print a brief help message and exits

=item B<--userid>

The patron's userid (for finding the patron). Mutually exclusive with other options.

=item B<--patron_id>

The patron's internal id (borrowernumber) for finding the patron. Mutually exclusive with other options.

=item B<--cardnumber>

Patron's cardnumber (for finding the patron). Mutually exclusive with other options.

=back

=head1 DESCRIPTION

A simple script to reset an existing user's 2FA authentication settings.

This script will:
- Find the patron using the specified identifier
- Check if the patron has 2FA enabled
- Reset the patron's 2FA setting

The script requires exactly one of the patron identification parameters and will
exit with an error if none or multiple parameters are provided.

=cut
