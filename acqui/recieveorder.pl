#!/usr/bin/perl

# $Id$

#script to show display basket of orders
#written by chris@katipo.co.nz 24/2/2000


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
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Database;
use HTML::Template;
use C4::Catalogue;

my $input=new CGI;
my $id=$input->param('id');
my ($count,@booksellers)=bookseller($id);

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "acqui/recieveorder.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {acquisition => 1},
			     debug => 1,
			     });

$template->param(
		name => $booksellers[0]->{'name'},
		id => $id,
		);

output_html_with_http_headers $input, $cookie, $template->output;
