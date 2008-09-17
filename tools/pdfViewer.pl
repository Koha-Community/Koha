#!/usr/bin/perl

# script to show a PDF file.
# written 07/04
# by Veleda Matias - matias_veleda@hotmail.com - Physics Library UNLP Argentina and
#    Castañeda Sebastian - seba3c@yahoo.com.ar - Physics Library UNLP Argentina and

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
use C4::Context;
use CGI;

# This script take a pdf filename as a parameter and output it to the browser.
my $cgi = new CGI;
my $filename = "barcodes.pdf";
my $tmpFileName = $cgi->param('tmpFileName');
print "Content-Disposition: attachment; filename = $filename\n\n";
print $cgi->header(-type => 'application/pdf'),
      $cgi->start_html(-title=>"Codify to PDF");
open FH, "<$tmpFileName";
while (<FH>) {
	print;
}
close FH;
print $cgi->end_html();
