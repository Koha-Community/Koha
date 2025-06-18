#!/usr/bin/perl

=head1 NAME

acq_cancel_obsolete_orders.pl - Script for cancelling obsolete orders

=head1 SYNOPSIS

    # Help
    misc/maintenance/acq_cancel_obsolete_orders.pl --help

    # Count obsolete orders (with/without age)
    misc/maintenance/acq_cancel_obsolete_orders.pl
    misc/maintenance/acq_cancel_obsolete_orders.pl --age 365

    # Cancel obsolete orders (with/without age)
    misc/maintenance/acq_cancel_obsolete_orders.pl -c
    misc/maintenance/acq_cancel_obsolete_orders.pl -c --age 365

=head1 DESCRIPTION

    Obsolete order lines (in table aqorders) are defined here as:

    [1] Biblionumber is null but received < ordered and not cancelled.
    [2] Status 'cancelled' but no cancellation date.
    [3] Filled cancellation date, but status is not 'cancelled'.

    This script may count those orders or cancel them.

    Optionally, you may pass an age in DAYS to limit the
    selected set to records with an older entrydate.

=head1 OPTIONS

=over

=item B<-h|--help>

    Print a brief help message

=item B<-c|--confirm>

    Confirm to cancel obsolete orders. If you do not confirm, the script
    only counts the number of obsolete orders.

=item B<--age>

    Optional number of days. Only look at orders older than the given
    number.

=back

=cut

# Copyright 2024 Rijksmuseum
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
use Getopt::Long qw( GetOptions );
use Pod::Usage   qw( pod2usage );

use Koha::Acquisition::Orders;
use Koha::Script;

my ($params);
GetOptions(
    'confirm' => \$params->{confirm}, 'help' => \$params->{help}, 'age:i' => \$params->{age},
);
if ( $params->{help} ) {
    pod2usage( -verbose => 2 );
    exit;
}

my $rs = Koha::Acquisition::Orders->filter_by_obsolete( { age => $params->{age} } );
print sprintf( "Found %d obsolete orders\n", $rs->count );
if ( $params->{confirm} ) {
    my @results = $rs->cancel;
    print sprintf( "Cancelled %d obsolete orders\n", $results[0] );
    print sprintf( "Got %d warnings\n",              @{ $results[1] } ) if @{ $results[1] };
}
