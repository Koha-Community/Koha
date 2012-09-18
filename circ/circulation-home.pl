#!/usr/bin/perl

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
# 

use strict;
#use warnings; FIXME - Bug 2505
use CGI;
use C4::Auth;
use C4::Output;
use C4::Context;
use C4::Koha;

my $query = new CGI;
my ($template, $loggedinuser, $cookie, $flags)
= get_template_and_user({template_name => "circ/circulation-home.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {circulate => "circulate_remaining_permissions"},
				});

# Checking if there is a Fast Cataloging Framework
my $fa = getframeworkinfo('FA');
$template->param( fast_cataloging => 1 ) if (defined $fa);

# Checking if the transfer page needs to be displayed
$template->param( display_transfer => 1 ) if ( ($flags->{'superlibrarian'} == 1) || (C4::Context->preference("IndependantBranches") == 0) );


output_html_with_http_headers $query, $cookie, $template->output;
