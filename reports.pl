#!/usr/bin/perl

# $Id$

#script to display reports
#written 8/11/99


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
use C4::Stats;
use C4::Stock;

my $input = new CGI;
print $input->header;
my $type=$input->param('type');
print startpage();
print startmenu('issue');
my @data;
if ($type eq 'search'){
 @data=statsreport('search','something');
}
if ($type eq 'issue'){
 @data=statsreport('issue','today');
}
if ($type eq 'stock'){
 @data=stockreport();
}

print mkheadr(1,"$type reports");
print @data;

print endmenu('issue');
print endpage();
