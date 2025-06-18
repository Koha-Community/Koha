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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use strict;
use warnings;

use Koha::Script;
use C4::Context;
use C4::Members::Messaging;
use Getopt::Long qw( GetOptions );
use Pod::Usage   qw( pod2usage );

sub usage {
    pod2usage( -verbose => 2 );
    exit;
}

sub force_borrower_messaging_defaults {
    my ( $doit, $since, $not_expired, $no_overwrite, $category, $branchcode, $message_name ) = @_;

    print "Since: $since\n" if $since;

    my $dbh = C4::Context->dbh;
    $dbh->{AutoCommit} = 0;

    my $sql = q|SELECT DISTINCT bo.borrowernumber, bo.categorycode FROM borrowers bo
LEFT JOIN borrower_message_preferences mp USING (borrowernumber)
WHERE 1|;

    if ($since) {
        $sql .= " AND bo.dateenrolled >= ?";
    }
    if ($not_expired) {
        $sql .= " AND bo.dateexpiry >= NOW()";
    }
    if ($no_overwrite) {
        $sql .= " AND mp.borrowernumber IS NULL";
    }
    $sql .= " AND bo.categorycode = ?" if $category;
    $sql .= " AND bo.branchcode = ?"   if $branchcode;
    my $sth = $dbh->prepare($sql);
    $sth->execute( $since || (), $category || (), $branchcode || () );
    my $cnt = 0;
    while ( my ( $borrowernumber, $categorycode ) = $sth->fetchrow ) {
        print "$borrowernumber: $categorycode\n";
        next unless $doit;
        my $options = {
            borrowernumber => $borrowernumber,
            categorycode   => $categorycode,
        };
        $options->{message_name} = $message_name if defined $message_name;
        C4::Members::Messaging::SetMessagingPreferencesFromDefaults($options);
        $cnt++;
    }
    $dbh->commit();
    print "Total borrowers updated: $cnt\n" if $doit;
}

my ( $doit, $since, $help, $not_expired, $no_overwrite, $category, $branchcode, $message_name );
my $result = GetOptions(
    'doit'           => \$doit,
    'since:s'        => \$since,
    'not-expired'    => \$not_expired,
    'no-overwrite'   => \$no_overwrite,
    'category:s'     => \$category,
    'library:s'      => \$branchcode,
    'message-name:s' => \$message_name,
    'help|h'         => \$help,
);

usage() if $help;

force_borrower_messaging_defaults( $doit, $since, $not_expired, $no_overwrite, $category, $branchcode, $message_name );

=head1 NAME

borrowers-force-messaging-defaults.pl

=head1 SYNOPSIS

  borrowers-force-messaging-defaults.pl
  borrowers-force-messaging-defaults.pl --help
  borrowers-force-messaging-defaults.pl --doit
  borrowers-force-messaging-defaults.pl --doit --not-expired
  borrowers-force-messaging-defaults.pl --doit --category PT
  borrowers-force-messaging-defaults.pl --doit --library CPL
  borrowers-force-messaging-defaults.pl --doit --message-name 'Item_Due'

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

=item B<--not-expired>

Will only update active borrowers (borrowers who didn't pass their expiration date).

=item B<--no-overwrite>

Will only update patrons without messaging preferences and skip patrons that
already set their preferences.

=item B<--category>

Will only update patrons in the category specified.

=item B<--library>

Will only update patrons whose home library matches the given library id.

=item B<--message-name>

Will only update the specified message name.
List of values can be found in installer/data/mysql/mandatory/sample_notices_message_attributes.sql
or in message_attributes.message_name in the database.

=item B<--since>

Will only update borrowers enrolled since the specified date.

Examples:

--since "2022-07-13"

--since `date -d "1 day ago" '+%Y-%m-%d'

=back

=cut
