#!/usr/bin/perl

# $Id$

#
# TODO
#
# Add info on biblioitems and items already entered as you enter new ones
#

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

if ( $error eq "notitle" ) {
    print << "EOF";
    <p />
      <center>
      <font color="#FF0000">Please Specify a Title</font>
      </center>
EOF
}    # if

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
