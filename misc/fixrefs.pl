#!/usr/bin/perl


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
use C4::Context;

my $dbh = C4::Context->dbh;
my $count=0;
my $query="Select * from biblioitems where itemtype='REF' or itemtype='TREF'";
my $sth=$dbh->prepare($query);
$sth->execute;

while (my $data=$sth->fetchrow_hashref){
  $query="update items set notforloan=1 where biblioitemnumber='$data->{'biblioitemnumber'}'";
  my $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;
}
$sth->finish;
