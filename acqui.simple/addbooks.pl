#!/usr/bin/perl

# $Id$

#
# Modified saas@users.sf.net 12:00 01 April 2001
# The biblioitemnumber was not correctly initialised
# The max(barcode) value was broken - koha 'barcode' is a string value!
# - If left blank, barcode value now defaults to max(biblionumber)

#
# TODO
#
# Add info on biblioitems and items already entered as you enter new ones
#
# Add info on biblioitems and items already entered as you enter new ones


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
use strict;
use C4::Catalogue;
use C4::Biblio;
use C4::Output;
use C4::Circulation::Circ2;

my $input = new CGI;
my $error   = $input->param('error');
my $success = $input->param('biblioitem');

print $input->header;
print startpage();
print startmenu('acquisitions');

&searchscreen();
print endmenu('acquisitions');
print endpage();


sub searchscreen {
    print << "EOF";
<font size="6"><em>Adding new items to the Library Inventory</em></font>
<p />
EOF

    if ($error eq "notfound") {
	print << "EOF";
<font color="red" size="5">No items found</font>
<p />
EOF
    } elsif ($success eq "added") {
	print << "EOF";
<font color="red" size="5">Website Biblioitem Added</font>
<p />
EOF
    } # elsif

    print << "EOF";
<table bgcolor="#ffcc00" width="80%" cellpadding="5">
<tr valign="center">
<td><font size="5">To add a new item, scan or type the ISBN number:</font></td>
</tr>
</table>

<table>
<tr>
<form action="keywordsearch.pl">
<td>Keyword:</td>
<td><input type="text" name="keyword" /></td>
<td><input type="submit" value="Go" /></td>
</form>
</tr>
<tr>
<form action="isbnsearch.pl">
<td>ISBN:</td>
<td><input type="text" name="isbn" /></td>
<td><input type="submit" value="Go" /></td>
</form>
</tr>
</table>
<p />
<hr />
<p />
<table bgcolor="#ffcc00" width="80%" cellpadding"5">
<tr valign="center">
<td><font size="5">Tools for importing MARC records into Koha</font></td>
</tr>
</table>
<br />
<ul>
<li><a href=marcimport.pl?menu=z3950>Z39.50 Search Tool</a></li>
<li><a href=marcimport.pl?menu=uploadmarc>Upload MARC records</a></li>
</ul>
<br clear="all">
<p />
<table bgcolor="#ffcc00" width="80%" cellpadding="5">
<tr valign="center">
<td><FONT SIZE=5>Add New Website</font></td>
</tr>
</table>
<form action="websitesearch.pl" method="post">
<table>
<tr>
<td>Keyword:</td>
<td><input type="text" name="keyword" /></td>
<td><input type="submit" value="Go" /></td>
</tr>
</table>
</FORM>
<p />
<table bgcolor="#ffcc00" width="80%" cellpadding="5">
<tr valign="center">
<td><FONT SIZE=5>Help</font></td>
</tr>
</table>
<FONT SIZE=5>Koha stores data in three sections</font>
<p />
<h2>Biblio</h2>
The first section records bibliographic data such as title, author and copyright for a particular work.
<p />
<h2>Group</h2>
The second records bibliographic data for a particular publication of that work, such as ISBN number, physical description, publisher information, etc
<p />
<h2>Item</h2>
The third section holds specific item information, such as the bar code number
<p />
EOF
} # sub searchscreen
