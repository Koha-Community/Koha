#!/usr/bin/perl

#
# TODO
#
# Add info on biblioitems and items already entered as you enter new ones
#

use CGI;
use strict;
use C4::Output;


my $input = new CGI;
my $error = $input->param('error');

print $input->header;
print startpage();
print startmenu('acquisitions');

print << "EOF";
<FONT SIZE=6><em>Adding a new Biblio</em></FONT><br>
  
<table bgcolor="#ffcc00" width="80%" cellpadding="5">
<tr>
<td><FONT SIZE=5>Section One: Copyright Information </font></td>
</tr>
</table>
EOF

if ($error eq "notitle") {
    print << "EOF";
<p />
<center>
<font color="#FF0000">Please Specify a Title</font>
</center>
EOF
} # if

print << "EOF";
<FORM action="savebiblio.pl" method="post">
<table align="center">
<tr>
<td>Title: *</td>
<td><INPUT name="title" size="40" /></td>
</tr>
<tr>
<td>Subtitle:</td>
<td><INPUT name="subtitle" size="40" /></td>
</tr>
<tr>
<td>Author:</td>
<td><INPUT name="author" size="40" /></td>
</tr>
    <tr valign="top">
        <td>Series Title:<br />
        <i>(if applicable)</i></td>
        <td><INPUT name="seriestitle" size="40" /></td>
    </tr>
<tr>
<td>Copyright Date:</td>
<td><INPUT name="copyrightdate" size="40" /></td>
</tr>
<tr valign="top">
<td>Abstract:</td>
<td><textarea cols="30" rows="6" name="abstract"></textarea></td>
</tr>
    <tr valign="top">
        <td>Notes:</td>
        <td><textarea cols="30" rows="6" name="notes"></textarea></td>
    </tr>
<tr valign="top">
<td colspan="2"><center><input type="submit" value="Submit"></center></td>
</tr>
</table>
</FORM>
* Required
EOF

print endmenu();
print endpage();
