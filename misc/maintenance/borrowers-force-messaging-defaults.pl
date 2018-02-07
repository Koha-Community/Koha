#!/usr/bin/perl
#
# Copyright (C) 2011 Tamil s.a.r.l.
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

use strict;
use warnings;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

use C4::Context;
use C4::Members::Messaging;
use Getopt::Long;
use Pod::Usage;


sub usage {
    pod2usage( -verbose => 2 );
    exit;
}


sub force_borrower_messaging_defaults {
    my ($doit, $truncate, $since, $not_expired, $no_overwrite) = @_;

    $since = '0000-00-00' if (!$since);
    print "Since: $since\n";

    my $dbh = C4::Context->dbh;
    $dbh->{AutoCommit} = 0;

    if ( $doit && $truncate ) {
        $dbh->do(q|SET FOREIGN_KEY_CHECKS = 0|);
        $dbh->do(q|TRUNCATE borrower_message_transport_preferences|);
        $dbh->do(q|TRUNCATE borrower_message_preferences|);
        $dbh->do(q|SET FOREIGN_KEY_CHECKS = 1|);
    }

    my $sql = "SELECT borrowernumber, categorycode FROM borrowers bo WHERE dateenrolled >= ?";
    if ($not_expired) {
        $sql .= " AND dateexpiry >= NOW()"
    }
    if( $no_overwrite ) {
        $sql .= " AND (SELECT COUNT(*) FROM borrower_message_preferences mp WHERE mp.borrowernumber=bo.borrowernumber) = 0"
    }
    my $sth = $dbh->prepare($sql);
    $sth->execute($since);
    while ( my ($borrowernumber, $categorycode) = $sth->fetchrow ) {
        print "$borrowernumber: $categorycode\n";
        next unless $doit;
        C4::Members::Messaging::SetMessagingPreferencesFromDefaults( {
            borrowernumber => $borrowernumber,
            categorycode   => $categorycode,
        } );
    }
    $dbh->commit();
}


my ( $doit, $truncate, $since, $help, $not_expired, $no_overwrite );
my $result = GetOptions(
    'doit'        => \$doit,
    'truncate'    => \$truncate,
    'since:s'     => \$since,
    'not-expired' => \$not_expired,
    'no-overwrite'  => \$no_overwrite,
    'help|h'      => \$help,
);

usage() if $help;

force_borrower_messaging_defaults( $doit, $truncate, $since, $not_expired, $no_overwrite );

=head1 NAME

borrowers-force-messaging-defaults.pl

=head1 SYNOPSIS

  borrowers-force-messaging-defaults.pl
  borrowers-force-messaging-defaults.pl --help
  borrowers-force-messaging-defaults.pl --doit
  borrowers-force-messaging-defaults.pl --doit --truncate
  borrowers-force-messaging-defaults.pl --doit --not-expired

=head1 DESCRIPTION

If the EnhancedMessagingPreferences syspref is enabled after borrowers have
been created in the DB, those borrowers won't have messaging transport
preferences default values as defined for their borrower category. So you would
have to modify each borrower one by one if you would like to send them 'Hold
Filled' notice for example.

This script creates/overwrites messaging preferences for all borrowers and sets
them to default values defined for the category they belong to (unless you
use the options -not-expired or -no-overwrite to update a subset).

=over 8

=item B<--help>

Prints this help

=item B<--doit>

Actually update the borrowers.

=item B<--truncate>

Truncate all borrowers transport preferences before (re-)creating them. It
affects borrower_message_preferences table.

=item B<--not-expired>

Will only update active borrowers (borrowers who didn't pass their expiration date).

=item B<--no-overwrite>

Will only update patrons without messaging preferences and skip patrons that
already set their preferences.

=back

=cut
