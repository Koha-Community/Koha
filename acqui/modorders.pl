#!/usr/bin/perl

#script to add an order into the system
#written 29/2/00 by chris@katipo.co.nz


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
use C4::Catalogue;
use C4::Biblio;

my $input = new CGI;
my $basketno=$input->param('basketno');
my $count=$input->param('number');
for (my $i=0;$i<$count;$i++){
	my  $bibnum=$input->param("bibnum$i");
	my $ordnum=$input->param("ordnum$i");
	my $quantity=$input->param("quantity$i");
	if ($quantity == 0){
		delorder($bibnum,$ordnum);
	}
}
print $input->redirect("basket.pl?basket=$basketno");
