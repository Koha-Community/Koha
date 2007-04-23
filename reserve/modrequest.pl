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
use CGI;
use C4::Output;
use C4::Reserves;

my $input = new CGI;
#print $input->header;

my @rank=$input->param('rank-request');
my @biblionumber=$input->param('biblionumber');
my @borrower=$input->param('borrowernumber');
my @branch=$input->param('pickup');
my @itemnumber=$input->param('itemnumber');
my $count=@rank;

my $CancelBiblioNumber=$input->param('CancelBiblioNumber');
my $CancelBorrowerNumber=$input->param('CancelBorrowerNumber');
my $CancelItemnumber=$input->param('CancelItemnumber');

# 2 possibilitys : cancel an item reservation, or modify or cancel the queded list

# 1) cancel an item reservation by fonction GlobalCancel (in reserves.pm)
if ($CancelBorrowerNumber) {
	GlobalCancel($CancelItemnumber, $CancelBorrowerNumber);
	$biblionumber[0] = $CancelBiblioNumber,
}

# 2) Cancel or modify the queue list of reserves (without item linked)
else {
	for (my $i=0;$i<$count;$i++){
		UpdateReserve($rank[$i],$biblionumber[$i],$borrower[$i],$branch[$i],$itemnumber[$i]); #from C4::Reserves
	}
}
my $from=$input->param('from');
if ($from eq 'borrower'){
  print $input->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=$borrower[0]");
 } else {
   print $input->redirect("/cgi-bin/koha/reserve/request.pl?biblionumber=$biblionumber[0]");
}
