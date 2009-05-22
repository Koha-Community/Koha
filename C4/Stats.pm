package C4::Stats;


# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
#use warnings; # FIXME
require Exporter;
use C4::Context;
use C4::Debug;
use vars qw($VERSION @ISA @EXPORT);

our $debug;

BEGIN {
	# set the version for version checking
	$VERSION = 3.01;
	@ISA    = qw(Exporter);
	@EXPORT = qw(
		&UpdateStats
		&TotalPaid
	);
}


=head1 NAME

C4::Stats - Update Koha statistics (log)

=head1 SYNOPSIS

  use C4::Stats;

=head1 DESCRIPTION

The C<&UpdateStats> function adds an entry to the statistics table in
the Koha database, which acts as an activity log.

=head1 FUNCTIONS

=over 2

=item UpdateStats

  &UpdateStats($branch, $type, $value, $other, $itemnumber,
               $itemtype, $borrowernumber);

Adds a line to the statistics table of the Koha database. In effect,
it logs an event.

C<$branch>, C<$type>, C<$value>, C<$other>, C<$itemnumber>,
C<$itemtype>, and C<$borrowernumber> correspond to the fields of the
statistics table in the Koha database.

=cut

#'
sub UpdateStats {

    #module to insert stats data into stats table
    my (
        $branch,         $type,
        $amount,   $other,          $itemnum,
        $itemtype, $borrowernumber, $accountno
      )
      = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(
        "INSERT INTO statistics
        (datetime, branch, type, value,
         other, itemnumber, itemtype, borrowernumber, proccode)
         VALUES (now(),?,?,?,?,?,?,?,?)"
    );
    $sth->execute(
        $branch,    $type,    $amount,
        $other,     $itemnum, $itemtype, $borrowernumber,
		$accountno
    );
}

# Otherwise, it'd need a POD.
sub TotalPaid {
    my ( $time, $time2, $spreadsheet ) = @_;
    $time2 = $time unless $time2;
    my $dbh   = C4::Context->dbh;
    my $query = "SELECT * FROM statistics 
  LEFT JOIN borrowers ON statistics.borrowernumber= borrowers.borrowernumber
  WHERE (statistics.type='payment' OR statistics.type='writeoff') ";
    if ( $time eq 'today' ) {
        $query .= " AND datetime = now()";
    } else {
        $query .= " AND datetime > '$time'";    # FIXME: use placeholders
    }
    if ( $time2 ne '' ) {
        $query .= " AND datetime < '$time2'";   # FIXME: use placeholders
    }
    if ($spreadsheet) {
        $query .= " ORDER BY branch, type";
    }
    $debug and warn "TotalPaid query: $query";
    my $sth = $dbh->prepare($query);
    $sth->execute();
    return @{$sth->fetchall_arrayref({})};
}

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut

