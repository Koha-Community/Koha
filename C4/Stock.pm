package C4::Stock;


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

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use C4::Context;

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&stockreport);

# FIXME - This function is only used in reports.pl, which in turn is
# never used. This function (and therefore this module) is probably
# obsolete.
sub stockreport {
  my $dbh = C4::Context->dbh;
  my @results;
  my $query="Select count(*) from items where homebranch='C'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $count=$sth->fetchrow_hashref;
  $results[0]->{'value'}="$count->{'count'}\t Levin";
  $sth->finish;
  $query="Select count(*) from items where homebranch='F'";
  $sth=$dbh->prepare($query);
  $sth->execute;
  $count=$sth->fetchrow_hashref;
  $results[1]->{'value'}="$count->{'count'}\t Foxton";
  $sth->finish;
  return(@results);
}
