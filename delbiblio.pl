#!/usr/bin/perl

#script to delete biblios
#written 2/5/00
#by chris@katipo.co.nz


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

use C4::Search;
use CGI;
use C4::Output;
use C4::Acquisitions;
use C4::Biblio;
use C4::Auth;

my $input = new CGI;
#print $input->header;
my $flagsrequired;
$flagsrequired->{editcatalogue}=1;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0, $flagsrequired);


my $biblio=$input->param('biblio');
#print $input->header;
#check no items attached
my $count=C4::Acquisitions::itemcount($biblio);
#check no biblioitems attached
my $biblioitemcount=C4::Acquisitions::biblioitemcount($biblio);


#print $count;
if ($count > 0){
  print $input->header(-cookie => $cookie);
  print "This biblio has $count items attached, please delete them before deleting this biblio<p>
  ";
} else {
    if ($biblioitemcount && !($input->param('confirmed'))) {
      print $input->header(-cookie => $cookie);
      print << "EOF";
      <table border=1 cellpadding=10 width=40%>
      <tr><td>
This biblio has $biblioitemcount group(s) attached to it but no actual items.
Would you like to delete the biblio and all of its subgroups?
<p>
<center>
<table border=0 cellpadding=10>
<tr><td>
<form method=get>
<input type=hidden name=biblio value=$biblio>
<input type=hidden name=confirmed value=1>
<input type=submit value="Yes">
</form>
</td><td>
<form action=detail.pl>
<input type=hidden name=bib value=$biblio>
<input type=submit value="No">
</form>
</td></tr>
</table>
</td></tr>
EOF
    } else {
	delbiblio($biblio);
	print $input->redirect("/cgi-bin/koha/catalogue-home.pl");
    }
}
