#!/usr/bin/perl

# written 10/5/2002 by Paul

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
use C4::Context;
use HTML::Template;
use C4::Search;
use C4::Output;

# get all the data ....
my %env;

my $input = new CGI;
my $index= $input->param('index');
my $result= $input->param('result');


my $dbh = C4::Context->dbh;

my $template = gettemplate("value_builder/unimarc_field_100.tmpl",0);
my $f1 = substr($result,0,8);
my $f2 = substr($result,8,1);
my $f3 = substr($result,9,4);
my $f4 = substr($result,13,4);
warn "f2 : $f2";
$template->param(index => $index,
						f1 => $f1,
						f3 => $f3,
						"f2$f2" => $f2,
						f4 => $f4);
print "Content-Type: text/html\n\n", $template->output;


