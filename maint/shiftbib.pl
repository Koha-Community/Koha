#!/usr/bin/perl

#script to do some serious catalogue maintainance
#written 22/11/00
# by chris@katipo.co.nz


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
use C4::Maintainance;

my $input = new CGI;
print $input->header;
my $type=$input->param('type');
my $bi=$input->param('bi');
my $bib=$input->param('bib');
my $type=$input->param('type');	# FIXME - Redundant
print startpage();
print startmenu('catalog');

if ($type eq 'change'){
  my $biblionumber=$input->param('biblionumber');
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select * from biblio where biblionumber=?");
  $sth->execute($biblionumber);
  my $data=$sth->fetchrow_hashref;
  print "Shifting group $bi to biblio $biblionumber<br>
  Title:$data->{'title'}<br>
  Author:$data->{'author'}<p>
  Are you sure?
  <p>
  ";
  print "<a href=/cgi-bin/koha/maint/shiftbib.pl?type=update&bi=$bi&bib=$biblionumber>Yes</a>";
} elsif ($type eq 'update'){
  shiftgroup($bib,$bi);
  print "Shifted";
} else {
  print "Shifting Group $bi from biblio $bib to <p>";
  print "<form action=/cgi-bin/koha/maint/shiftbib.pl method=post>";
  print "<input  name=bi type=hidden value=$bi>";
  print "<input type=hidden name=type value=change>";
  print "<input type=text name=biblionumber><br>";
  print "<input type=submit value=change></form>";
}
print endmenu('catalog');
print endpage();
