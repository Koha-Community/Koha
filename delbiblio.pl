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
use C4::Biblio;

my $input = new CGI;
#print $input->header;


my $biblio=$input->param('biblio');
# check no items attached
my $count=C4::Biblio::itemcount($biblio);


#print $count;
if ($count > 0){
  print $input->header;
  print "This biblio has $count items attached, please delete them before deleting this biblio<p>
  ";
} else {
	delbiblio($biblio);
	print $input->redirect("/cgi-bin/koha/loadmodules.pl?module=search");
}
