#!/usr/bin/perl

# $Id$

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

my $input = new CGI;
my $biblionumber = $input->param('biblionumber');
my $error        = $input->param('error');
my $maxbarcode;
my $isbn;
my $bibliocount;
my @biblios;
my $biblioitemcount;
my @biblioitems;
my $branchcount;
my @branches;
my %branchnames;
my $itemcount;
my @items;
my $itemtypecount;
my @itemtypes;
my %itemtypedescriptions;

if (! $biblionumber) {
    print $input->redirect('addbooks.pl');
} else {

    ($bibliocount, @biblios)  = &getbiblio($biblionumber);

    if (! $bibliocount) {
	print $input->redirect('addbooks.pl');
    } else {

	($biblioitemcount, @biblioitems) = &getbiblioitembybiblionumber($biblionumber);
        ($branchcount, @branches)        = &branches;
	($itemtypecount, @itemtypes)     = &getitemtypes;

	for (my $i = 0; $i < $itemtypecount; $i++) {
	    $itemtypedescriptions{$itemtypes[$i]->{'itemtype'}} = $itemtypes[$i]->{'description'};
	} # for

	for (my $i = 0; $i < $branchcount; $i++) {
	    $branchnames{$branches[$i]->{'branchcode'}} = $branches[$i]->{'branchname'};
	} # for

	print $input->header;
	print startpage();
	print startmenu('acquisitions');

	print << "EOF";
<font size="6"><em>$biblios[0]->{'title'}</em></font>
<p>
EOF

	if ($error eq "nobarcode") {
	    print << "EOF";
<font size="5" color="red">You must give the item a barcode</font>
<p>
EOF
	} elsif ($error eq "nobiblioitem") {
	    print << "EOF";
<font size="5" color="red">You must create a new group for your item to be added to</font>
<p>
EOF
	} elsif ($error eq "barcodeinuse") {
	    print << "EOF";
<font size="5" color="red">Sorry, that barcode is already in use</font>
<p>
EOF
	} # elsif
	print << "EOF";
<table align="left" cellpadding="5" cellspacing="0" border="1" width="220">
<tr valign="top" bgcolor="#CCCC99">
<td background="/images/background-mem.gif"><b>BIBLIO RECORD $biblionumber</b></td>
</tr>
<tr valign="top">
<td><b>Author:</b> $biblios[0]->{'author'}<br>
<b>Copyright:</b> $biblios[0]->{'copyrightdate'}<br>
<b>Series Title:</b> $biblios[0]->{'seriestitle'}<br>
<b>Notes:</b> $biblios[0]->{'notes'}</td>
</tr>
EOF

	for (my $i = 0; $i < $biblioitemcount; $i++) {
	    if ($biblioitems[$i]->{'itemtype'} eq "WEB") {

		print << "EOF";
<tr valign="top" bgcolor="#CCCC99">
<td background="/images/background-mem.gif"><b>$biblioitems[$i]->{'biblioitemnumber'} GROUP - $itemtypedescriptions{$biblioitems[$i]->{'itemtype'}}</b></td>
</tr>
<tr valign="top">
<td><b>URL:</b> $biblioitems[$i]->{'url'}<br>
<b>Date:</b> $biblioitems[$i]->{'publicationyear'}<br>
<b>Notes:</b> $biblioitems[$i]->{'notes'}</td>
</tr>
EOF

	    } else {
		$biblioitems[$i]->{'dewey'} =~ /(\d*\.\d\d)/;
		$biblioitems[$i]->{'dewey'} = $1;

		print << "EOF";
<tr valign="top" bgcolor="#CCCC99">
<td background="/images/background-mem.gif"><b>$biblioitems[$i]->{'biblioitemnumber'} GROUP - $itemtypedescriptions{$biblioitems[$i]->{'itemtype'}}</b></td>
</tr>
<tr valign="top">
<td><b>ISBN:</b> $biblioitems[$i]->{'isbn'}<br>
<b>Dewey:</b> $biblioitems[$i]->{'dewey'}<br>
<b>Publisher:</b> $biblioitems[$i]->{'publishercode'}<br>
<b>Place:</b> $biblioitems[$i]->{'place'}<br>
<b>Date:</b> $biblioitems[$i]->{'publicationyear'}</td>
</tr>
EOF

		($itemcount, @items) = &getitemsbybiblioitem($biblioitems[$i]->{'biblioitemnumber'});

		for (my $j = 0; $j < $itemcount; $j++) {
		    print << "EOF";
<tr valign="top" bgcolor="#FFFFCC">
<td><b>Item:</b> $items[$j]->{'barcode'}<br>
<b>Home Branch:</b> $branchnames{$items[$j]->{'homebranch'}}<br>
<b>Notes:</b> $items[$j]->{'itemnotes'}</td>
</tr>
EOF
		} # for
	    } # else
	} # for

	print << "EOF";
</table>
<img src="/images/holder.gif" width="16" height="650" align="left">

<center>

<form action="saveitem.pl" method="post">
<input type="hidden" name="biblionumber" value="$biblionumber">
<table border="1" cellspacing="0" cellpadding="5">
<tr valign="top" bgcolor="#CCCC99">
<td background="/images/background-mem.gif" colspan="2"><b>ADD NEW ITEM:</b><br>
<small><i>For a website add the group only</i></small></td>
</tr>
<tr valign="top">
<td>Item Barcode:</td>
<td><input type="text" name="barcode" size="40"></td>
</tr>
<tr valign="top">
<td>Branch:</td>
<td><select name="homebranch">
EOF

	for (my $i = 0; $i < $branchcount; $i++) {
	    print << "EOF";
<option value="$branches[$i]->{'branchcode'}">$branches[$i]->{'branchname'}</option>
EOF
	} # for

	print << "EOF";
</select></td>
</tr>
<tr valign="top">
<td>Replacement Price:</td>
<td><input type="text" name="replacementprice" size="40"></td>
</tr>
<tr valign="top">
<td>Notes:</td>
<td><textarea name="itemnotes" cols="30" rows="6"></textarea></td>
</tr>
<tr valign="top" bgcolor="#CCCC99">
<td colspan="2" background="/images/background-mem.gif"><b>Add to existing group:</b></td>
</tr>
<tr valign="top">
<td>Group:</td>
<td><select name="biblioitemnumber">
EOF

	for (my $i = 0; $i < $biblioitemcount; $i++) {
	    if ($biblioitems[$i]->{'itemtype'} ne "WEB") {
		print << "EOF";
<option value="$biblioitems[$i]->{'biblioitemnumber'}">$itemtypedescriptions{$biblioitems[$i]->{'itemtype'}}</option>
EOF
	    } # if
	} # for

	print << "EOF";
</select></td>
</tr>
<tr valign="top">
<td colspan="2" align="center"><input type="submit" name="existinggroup" value="Add New Item to Existing Group"></td>
</tr>
<tr valign="top" bgcolor="#CCCC99">
<td colspan="2" background="/images/background-mem.gif"><b>OR Add to a new Group:</b></td>
</tr>
<tr valign="top">
<td>Format:</td>
<td><select name="itemtype">
EOF

	for (my $i = 0; $i < $itemtypecount; $i++) {
	    print << "EOF";
<option value="$itemtypes[$i]->{'itemtype'}">$itemtypes[$i]->{'description'}</option>
EOF
	} # for

	print << "EOF";
</select></td>
</tr>
<tr valign="top">
<td>ISBN:</td>
<td><input name="isbn" size="40"></td>
</tr>
<tr valign="top">
<td>Publisher:</td>
<td><input name="publishercode" size="40"></td>
</tr>
<tr valign="top">
<td>Publication Year:</td>
<td><input name="publicationyear" size="40"></td>
</tr>
<tr valign="top">
<td>Place of Publication:</td>
<td><input name="place" size="40"></td>
</tr>
<tr valign="top">
<td>Illustrator:</td>
<td><INPUT name="illus" size="40"></td>
</tr>
<tr valign="top">
<td>Additional Authors:<br><i>One Author per line</i></td>
<td><textarea name="additionalauthors" cols="30" rows="6"></textarea></td>
</tr>
<tr valign="top">
<td>Subject Headings:<br><i>One Subject per line</i></td>
<td><textarea name="subjectheadings" cols="30" rows="6"></textarea></td>
</tr>
<tr valign="top">
<td>Website URL:</td>
<td><INPUT name="url" size="40"></td>
</tr>
<tr valign="top">
<td>Dewey:</td>
<td><INPUT name="dewey" size="40"></td>
</tr>
<tr valign="top">
<td>Dewey Subclass:</td>
<td><input name="subclass" size="40"></td>
</tr>
<tr valign="top">
<td>ISSN:</td>
<td><input name="issn" size="40"></td>
</tr>
<tr valign="top">
<td>LCCN:</td>
<td><input name="lccn" size="40"</td>
</tr>
<tr valign="top">
<td>Volume:</td>
<td><input name="volume" size="40"></td>
</tr>
<tr valign="top">
<td>Number:</td>
<td><input name="number" size="40"></td>
</tr>
<tr valign="top">
<td>Volume Description:</td>
<td><input name="volumeddesc" size="40"></td>
</tr>
<tr valign="top">
<td>Pages:</td>
<td><input name="pages" size="40"></td>
</tr>
<tr valign="top">
<td>Size:</td>
<td><input name="size" size="40"></td>
</tr>
<tr valign="top">
<td>Notes:</td>
<td><textarea name="notes" cols="30" rows="6"></textarea></td>
</tr>
<tr valign="top">
<td colspan="2" align="center"><input type="submit" name="newgroup" value="Add New Item to New Group"></td>
</tr>
</table>

</form>
</center>
EOF

	print endmenu('acquisitions');
	print endpage();
    } # if
} # if
