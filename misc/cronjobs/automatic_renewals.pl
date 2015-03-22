#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2014 Hochschule für Gesundheit (hsg), Germany
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

=head1 NAME

automatic_renewals.pl - cron script to renew loans

=head1 SYNOPSIS

./automatic_renewals.pl

or, in crontab:
0 3 * * * automatic_renewals.pl

=head1 DESCRIPTION

This script searches for issues scheduled for automatic renewal
(issues.auto_renew). If there are still renews left (Renewals allowed)
and the renewal isn't premature (No Renewal before) the issue is renewed.

=head1 OPTIONS

No options.

=cut

use Modern::Perl;

use C4::Circulation;
use C4::Context;
use C4::Log;

cronlogaction();

my $dbh = C4::Context->dbh;
my ( $borrowernumber, $itemnumber, $branch, $ok, $error );

my $query =
"SELECT borrowernumber, itemnumber, branchcode FROM issues WHERE auto_renew = 1";
my $sth = $dbh->prepare($query);
$sth->execute();

while ( ( $borrowernumber, $itemnumber, $branch ) = $sth->fetchrow_array ) {

# CanBookBeRenewed returns 'auto_renew' when the renewal should be done by this script
    ( $ok, $error ) = CanBookBeRenewed( $borrowernumber, $itemnumber );
    AddRenewal( $borrowernumber, $itemnumber, $branch )
      if ( $error eq "auto_renew" );
}
