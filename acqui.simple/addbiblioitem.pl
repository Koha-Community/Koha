#!/usr/bin/perl

use CGI;
use strict;
use C4::Acquisitions;
use C4::Output;

my $input = new CGI;
my $biblionumber = $input->param('biblionumber');
my $title;
my $count;
my @results;

if (! $biblionumber) {
    print $input->redirect('addbooks.pl');
} else {
    
    ($count, @results) = &getbiblio($biblionumber);
    
    if (! $count) {
	print $input->redirect('addbooks.pl');
    } else {
	$title = @results[0]->{'title'};

	print $input->header;
	print startpage();
	print startmenu('acquisitions');

	print << "EOF";
<font size="6"><em>Adding New Group Information - $title</em></font>
<table bgcolor="#ffcc00" width="80%" cellpadding="5">
<tr valign="center">
<td><font size="5">Section Two: Publication information</font></td>
</tr></table> 
<p />
<form action="savebiblioitem.pl" method="post">
<input type="hidden" name="biblionumber" value="$biblionumber">
<table align="center">
<tr>
<td align="right">Publisher:</td>
<td colspan="3"><INPUT name="publishercode" size="40"></td>
</tr>
<tr>
<td align="right">Publication Year:</td>
<td><INPUT name="publicationyear" size="20"></td>
<td align="right">Place of Publication:</td>
<td><input name="place" size="20"></td>
</tr>
<tr>
<td align="right">Illustrator:</td>
<td colspan="3"><INPUT name="illus" size="40"></td>
</tr>
<tr>
<td align="right">ISBN:</td>
<td colspan="3"><input name="isbn" size="40"></td>
</tr>
<tr valign="top">
<td align="right">Additional Authors:<br><i>One Author per line</i></td>
<td colspan="3"><textarea name="additionalauthors" cols="30" rows="6"></textarea></td>
</tr>
<tr valign="top">
<td align="right">Subject Headings:<br><i>One Subject per line</i></td>
<td colspan="3"><textarea name="subjectheadings" cols="30" rows="6"></textarea></td>
</tr>
<tr>
<td align="right">Format:</td>
<td colspan="3"><select name="itemtype">
EOF

	($count, @results) = &getitemtypes;
	for (my $i = 0; $i < $count; $i++) {
	    print << "EOF";
<option value="$results[$i]->{'itemtype'}">$results[$i]->{'itemtype'} - $results[$i]->{'description'}
EOF
	} # for

	print << "EOF";
</select></td>
</tr>
<tr>
<td align="right">URL:</td>
<td colspan="3"><INPUT name="url" size="40"></td>
</tr>
<tr>
<td align="right">Dewey:</td>
<td><INPUT name="dewey" size="20"></td>
<td align="right">Dewey Subclass:</td>
<td><input name="subclass" size="20"></td>
</tr>
<tr>
<td align="right">ISSN:</td>
<td><input name="issn" size="20"></td>
<td align="right">LCCN:</td>
<td><input name="lccn" size="20"</td>
</tr>
<tr>
<td align="right">Volume:</td>
<td><input name="volume" size="20"></td>
<td align="right">Number:</td>
<td><input name="number" size="20"></td>
</tr>
<tr>
<td align="right">Volume Description:</td>
<td colspan="3"><input name="volumeddesc" size="40"></td>
</tr>
<tr>
<td align="right">Pages:</td>
<td><input name="pages" size="20"></td>
<td align="right">Size:</td>
<td><input name="size" size="20"></td>
</tr>
<tr valign="top">
<td align="right">Notes:</td>
<td colspan="3"><textarea name="notes" cols="30" rows="6"></textarea></td>
</tr>
<tr valign="top">
<td colspan="4" align="center"><input type="submit" value="Add New Item"></td>
</tr>
    
  </table></FORM>
EOF

	print endmenu();
	print endpage();
    } # else
} # else
