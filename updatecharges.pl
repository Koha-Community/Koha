#!/usr/bin/perl

# $Id$

#script to update charges for overdue in database
#updates categoryitem
# is called by charges.pl
# written 1/1/2000 by chris@katipo.co.nz


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
use CGI;
use C4::Context;
use C4::Output;

my $input = new CGI;
#print $input->header;
#print startpage();
#print startmenu('issue');


my $dbh = C4::Context->dbh;
#print $input->dump;
my @names=$input->param();

foreach my $key (@names){

  my $bor=substr($key,0,1);
  my $cat=$key;
  $cat =~ s/[A-Z]//i;
  my $data=$input->param($key);
  my @dat=split(',',$data);
#  print "$bor $cat $dat[0] $dat[1] $dat[2] <br> ";
  my $sth=$dbh->prepare("Update categoryitem set fine=?,firstremind=?,chargeperiod=? where
  categorycode=? and itemtype=?");
  $sth->execute($dat[0],$dat[1],$dat[2],$bor,$cat);
  $sth->finish;
}
print $input->redirect("/cgi-bin/koha/charges.pl");
#print endmenu('issue');
#print endpage();
