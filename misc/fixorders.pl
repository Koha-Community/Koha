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

my $sth=$dbh->prepare("Select ordernumber,biblionumber from aqorders order by ordernumber");
$sth->execute;
my $number;
my $i=92000;
while (my $data=$sth->fetchrow_hashref){
  if ($data->{'ordernumber'} != $number){
  } else {
    my $query="update aqorders set ordernumber=$i where ordernumber=$data->{'ordernumber'} and biblionumber=$data->{'biblionumber'}";
    my $sth2=$dbh->prepare($query);
    $sth2->execute;
    $sth2->finish;
    $query="update aqorderbreakdown set ordernumber=$i where ordernumber=$data->{'ordernumber'}";
    $sth2=$dbh->prepare($query);
    $sth2->execute;
    $sth2->finish;
        $i++;
  }
  $number=$data->{'ordernumber'};
}
$sth->finish;
