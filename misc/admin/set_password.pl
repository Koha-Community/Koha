#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2019 Koha Development Team
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

use Bytes::Random::Secure;
use Getopt::Long;
use Pod::Usage;
use String::Random;

use Koha::Patrons;

my ( $help, $password, $cardnumber, $patron_id, $userid );
GetOptions(
    'help|?'         => \$help,
    'userid=s'       => \$userid,
    'password=s'     => \$password,
    'patron_id=s'    => \$patron_id,
    'cardnumber=s'   => \$cardnumber,
);

pod2usage(1) if $help;

unless ( $userid or $patron_id or $cardnumber ) {
    pod2usage("userid is mandatory")       unless $userid;
    pod2usage("patron_id is mandatory")    unless $patron_id;
    pod2usage("cardnumber is mandatory")   unless $cardnumber;
}

unless ($password) {
    my $generator  = String::Random->new( rand_gen => \&alt_rand );
    $password      = $generator->randregex('[A-Za-z][A-Za-z0-9_]{6}.[A-Za-z][A-Za-z0-9_]{6}\d');
}

my $filter;

if ( $userid ) {
    $filter->{userid} = $userid;
}

if ( $cardnumber ) {
    $filter->{cardnumber} = $cardnumber;
}

if ( $patron_id ) {
    $filter->{borrowernumber} = $patron_id;
}

my $patrons = Koha::Patrons->search( $filter );

unless ( $patrons->count > 0 ) {
    pod2usage( "No patron found matching the specified criteria" );
}

my $patron = $patrons->next;
$patron->set_password({ password => $password, skip_validation => 1 });

print $patron->userid . " " . $password . "\n";

sub alt_rand { # Alternative randomizer
    my ($max) = @_;
    my $random = Bytes::Random::Secure->new( NonBlocking => 1 );
    my $r = $random->irand / 2**32;
    return int( $r * $max );
}

=head1 NAME

set_password.pl - Set the specified password for the user in Koha

=head1 SYNOPSIS

set_password.pl
  --userid <userid> --password <password> --patron_id <patron_id> --cardnumber <cardnumber>

 Options:
   -?|--help        brief help message
   --password       the password to be set (optional)
   --userid         the userid to be used to find the patron
   --patron_id      the borrowernumber for the patron
   --cardnumber     the cardnumber for the patron

=head1 OPTIONS

=over 8

=item B<--help|-?>

Print a brief help message and exits

=item B<--userid>

The patron's userid (for finding the patron)

=item B<--password>

The password to be set in the database. If no password is passed, a random one is generated.

=item B<--patron_id>

The patron's internal id (for finding the patron)

=item B<--cardnumber>

Patron's cardnumber (for finding the patron)

=back

=head1 DESCRIPTION

A simple script to change an existing's user password in the Koha database

=cut
