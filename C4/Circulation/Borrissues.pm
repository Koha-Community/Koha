package C4::Circulation::Borrissues;

# $Id$

#package to deal with Issues
#written 3/11/99 by chris@katipo.co.nz


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
use C4::Print;
use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&printallissues);

# FIXME - This function is only used in C4::InterfaceCDK, which looks
# obsolete. Does that mean that this module is also obsolete?
# Otherwise, this needs a POD.
sub printallissues {
  my ($env,$borrower)=@_;
  my @issues;
  my $dbh = C4::Context->dbh;
  my $sth = $dbh->prepare("select * from issues,items,biblioitems,biblio
    where borrowernumber = ?
    and (returndate is null)
    and (issues.itemnumber = items.itemnumber)
    and (items.biblioitemnumber = biblioitems.biblioitemnumber)
    and (items.biblionumber = biblio.biblionumber)
    order by date_due");
  $sth->execute($borrower->{'borrowernumber'});
  my $x;
  while (my $data = $sth->fetchrow_hashref) {
    # FIXME - This should be $issues[$x] = $data, right?
    # Or better yet, push @issues, $data.
    @issues[$x] =$data;
    $x++;
  }
  $sth->finish();
  remoteprint ($env,\@issues,$borrower);
}
