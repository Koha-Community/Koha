#!/usr/bin/perl


#written by chris@katipo.co.nz
#9/10/2000
#script to display and update currency rates


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

use CGI;
use C4::Acquisition;
use C4::Biblio;
use C4::Bookfund;

my $input=new CGI;

my @params=$input->param;
foreach my $param (@params){
	if ($param ne 'type' && $param !~ /submit/){
		my $data=$input->param($param);
		ModCurrencies($param,$data);
}
}
print $input->redirect('/cgi-bin/koha/acqui/acqui-home.pl');
