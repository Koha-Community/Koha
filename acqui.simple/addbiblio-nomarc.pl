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

# $Log$
# Revision 1.2  2003/05/09 23:47:22  rangi
# This script is now templated
# 3 more to go i think
#

use CGI;
use strict;
use C4::Output;
use HTML::Template;
use C4::Auth;
use C4::Interface::CGI::Output;

my $input = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "acqui.simple/addbiblio-nomarc.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

my $error = $input->param('error');

$template->param(
    ERROR => $error,
);

output_html_with_http_headers $input, $cookie, $template->output;
