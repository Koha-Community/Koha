#!/usr/bin/perl

#script to modify reserves/requests
#written 2/1/00 by chris@katipo.oc.nz
#last update 27/1/2000 by chris@katipo.co.nz


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
#use DBI;
use C4::Search;
use CGI;
use C4::Output;
use C4::Reserves2;

my $input = new CGI;
#print $input->header;

#print $input->Dump;

my @rank=$input->param('rank-request');
my @biblio=$input->param('biblio');
my @borrower=$input->param('borrowernumber');
my @branch=$input->param('pickup');
my $count=@rank;

# goes through and manually changes the reserves record....
# no attempt is made to check consistency.
for (my $i=0;$i<$count;$i++){
    UpdateReserve($rank[$i],$biblio[$i],$borrower[$i],$branch[$i]); #from C4::Reserves2
}

my $from=$input->param('from');
if ($from eq 'borrower'){
  print $input->redirect("/cgi-bin/koha/members/moremember.pl?bornum=$borrower[0]");
 } else {
   print $input->redirect("/cgi-bin/koha/request.pl?bib=$biblio[0]");
}
