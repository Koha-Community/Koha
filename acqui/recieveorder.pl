#!/usr/bin/perl

#script to show display basket of orders
#written by chris@katipo.co.nz 24/2/2000


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

use C4::Catalogue;
use C4::Biblio;
use C4::Output;
use CGI;
use strict;

my $input=new CGI;
print $input->header();
my $id=$input->param('id');
my ($count,@booksellers)=bookseller($id); 
print startpage;

print startmenu('acquisitions');

print <<EOP

<FONT SIZE=6><em>Receive Orders From Supplier <a href=whitcoulls.html>$booksellers[0]->{'name'}</a></em></FONT>
<p>
<CENTER>
<form method=post action="receive.pl">
<input type=hidden name=id value=$id>
<p>
<table border=1 cellspacing=0 cellpadding=5>
<tr valign=top bgcolor=#99cc33><td background="/images/background-mem.gif" colspan=2><B>SUPPLIER INVOICE INFORMATION</B></td></tr>
<TR VALIGN=TOP >
<TD>Supplier Invoice Number</td>
<td><input type=text size=20 name=invoice>        
</td>
</tr>
<TR VALIGN=TOP>
<TD>GST</td>
<td><input type=text size=20 name=gst>
</td>
</tr>
<TR VALIGN=TOP>
<TD>Freight</td>
<td><input type=text size=20 name=freight>
</td>
</tr>
<TR VALIGN=TOP>
<TD></td>
<td><input type=image  name=submit src=/images/continue.gif border=0 width=120 height=42>
</td>
</tr>
</table>
</CENTER>

EOP
;


print endmenu('acquisitions');

print endpage;
