package C4::Stats;

# $Id$

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
require Exporter;
use DBI;
use C4::Context;
use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = $VERSION = do { my @v = '$Revision$' =~ /\d+/g;
    shift(@v) . "." . join( "_", map { sprintf "%03d", $_ } @v );
};

=head1 NAME

C4::Stats - Update Koha statistics (log)

=head1 SYNOPSIS

  use C4::Stats;

=head1 DESCRIPTION

The C<&UpdateStats> function adds an entry to the statistics table in
the Koha database, which acts as an activity log.

=head1 FUNCTIONS

=over 2

=cut

@ISA    = qw(Exporter);
@EXPORT = qw(&UpdateStats);

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
        $itemtype, $borrowernumber
      )
      = @_;
    my $dbh = C4::Context->dbh;
    # FIXME - Use $dbh->do() instead
    my $sth = $dbh->prepare(
        "Insert into statistics (datetime,branch,type,value,
                                        other,itemnumber,itemtype,borrowernumber) values (now(),?,?,?,?,?,?,?)"
    );
    $sth->execute(
        $branch,    $type,    $amount,
        $other,     $itemnum, $itemtype, $borrowernumber,
    );
    $sth->finish;
}

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut

