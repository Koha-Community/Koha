#!/usr/bin/perl

#simple script to provide basic redirection
#used by members section

# Allows a single script to handle the addition of either an adult
# or a corporate member


# Copyright 2000-2003 Katipo Communications
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

my $input=new CGI;

my $choice=$input->param('chooseform');

if ($choice eq 'adult'){
  print $input->redirect("/cgi-bin/koha/memberentry.pl?type=Add");
}

if ($choice eq 'organisation'){
  print $input->redirect("/cgi-bin/koha/imemberentry.pl?type=Add");
}

print <<EOF;
Content-Type: text/plain

Internal error: Invalid chooseform parameter "$choice"
EOF
