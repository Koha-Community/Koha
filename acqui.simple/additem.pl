#!/usr/bin/perl

use CGI;
use strict;
use C4::Acquisitions;
use C4::Output;

my $input = new CGI;
my $biblioitemnum = $input->param('biblioitemnum');
my $maxbarcode;
my $isbn;
my $count;
my @results;

if (! $biblioitemnum) {
    print $input->redirect('addbooks.pl');
} else {
    
    ($count, @results) = &getbiblioitem($biblioitemnum);
    
    if (! $count) {
	print $input->redirect('addbooks.pl');
    } else {
	$isbn       = $results[0]->{'isbn'};
	$maxbarcode = $results[0]->{'biblionumber'};
  
	print $input->header;
	print startpage();
	print startmenu('acquisitions');
    
	($count, @results) = &getitemsbybiblioitem($biblioitemnum);

	if ($count) {
	    print << "EOF";
<center>
<p>
<table border=1 bgcolor=#dddddd>
<tr>
<th colspan=4>Existing Items with ISBN $isbn</th>
</tr>
<tr>
<th>Barcode</th><th>Title</th><th>Author</th><th>Notes</th></tr>
EOF

	    for (my $i = 0; $i < $count; $i++) {
		print << "EOF";
<tr>
<td align=center>$results[$i]->{'barcode'}</td>
<td><u>$results[$i]->{'title'}</u></td>
<td>$results[$i]->{'author'}</td>
<td>$results[$i]->{'itemnotes'}</td>
</tr>
EOF
        } # for

	    print << "EOF";
</table>
</center>
EOF
	} # if

	print << "EOF";
<center>
<h2>Section Three: Specific Item Information</h2>
<form action="saveitems" method="post">
<input type="hidden" name="biblioitemnum" value="$biblioitemnum">
<table>
<tr>
<td align="right">BARCODE:</td>
<td><input name="barcode" size="10" value="$maxbarcode" /></td>
<td align="right">Home Branch:</td>
<td><select name="homebranch"><option value="STWE">Stewart Elementary<option value="MEZ">Meziadin Elementary</select></td>
</tr>
<tr>
<td align="right">Replacement Price:</td>
<td colspan="3"><input name="replacementprice" size="10"></td>
</tr>
<tr valign="top">
<td align="right">Notes:</td>
<td colspan="3"><textarea name="notes" rows="4" cols="40" wrap="physical"></textarea></td>
</tr>
</table>
<input type="submit" value="Add Item" />
</form>
</center>
EOF
    
	print endmenu();
	print endpage();
    } # if
} # if
