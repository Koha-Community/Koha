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
    my ($doit, $since, $not_expired) = @_;

    $since = '0000-00-00' if (!$since);
    print "Since: $since\n";

    my $dbh = C4::Context->dbh;
    $dbh->{AutoCommit} = 0;

    my $sql = "SELECT borrowernumber, categorycode FROM borrowers WHERE dateenrolled >= ?";
    if ($not_expired) {
        $sql .= " AND dateexpiry >= NOW()"
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


my ($doit, $since, $help, $not_expired);
my $result = GetOptions(
    'doit'        => \$doit,
    'since:s'     => \$since,
    'not-expired' => \$not_expired,
    'help|h'      => \$help,
);

usage() if $help;

force_borrower_messaging_defaults( $doit, $since, $not_expired );

=head1 NAME

borrowers-force-messaging-defaults.pl

=head1 SYNOPSIS

  borrowers-force-messaging-defaults.pl
  borrowers-force-messaging-defaults.pl --help
  borrowers-force-messaging-defaults.pl --doit
  borrowers-force-messaging-defaults.pl --doit --not-expired

=head1 DESCRIPTION

If the EnhancedMessagingPreferences syspref is enabled after borrowers have
been created in the DB, those borrowers won't have messaging transport
preferences default values as defined for their borrower category. So you would
have to modify each borrower one by one if you would like to send them 'Hold
Filled' notice for example.

This script create transport preferences for all existing borrowers and set
them to default values defined for the category they belong to.

=over 8

=item B<--help>

Prints this help

=item B<--doit>

Actually update the borrowers.

=item B<--not-expired>

Will only update active borrowers (borrowers who didn't pass their expiration date).

=back

=cut
