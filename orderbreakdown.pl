#!/usr/bin/perl

#script to display info about acquisitions
#written by chris@katipo.co.nz 31/01/2000


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

use C4::Acquisitions;
use C4::Biblio;
use C4::Output;
use CGI;
my $input=new CGI;
print $input->header();
my $id=$input->param('id');
my ($count,$order)=breakdown($id);
print startpage;
print mktablehdr;
#print $id;
for (my$i=0;$i<$count;$i++){
print mktablerow(5,'white',"<b>Ordernumber:</b>$order->[$i]->{'ordernumber'}",
"<b>Line umber</b>:$order->[$i]->{'linenumber'}","<b>Branch Code:</b>$order->[$i]->{'branchcode'}",
"<b>Bookfundid</b>:$order->[$i]->{'bookfundid'}","<b>Allocation:</b>$order->[$i]->{'allocation'}");
}
print mktableft;
print endpage;
