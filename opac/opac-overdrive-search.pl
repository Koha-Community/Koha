#!/usr/bin/perl

# Copyright 2013 ByWater
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use strict;
use warnings;

use CGI qw ( -utf8 );

use C4::Auth qw(:DEFAULT get_session);
use C4::Output;

my $cgi = new CGI;

# Getting the template and auth
my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "opac-overdrive-search.tt",
                                query => $cgi,
                                type => "opac",
                                authnotrequired => 1,
                                flagsrequired => {borrowers => 'edit_borrowers'},
                                debug => 1,
                                });

$template->{'VARS'}->{'q'} = $cgi->param('q');
$template->{'VARS'}->{'limit'} = C4::Context->preference('OPACnumSearchResults') || 20;
$template->{'VARS'}->{'OPACnumSearchResults'} = C4::Context->preference('OPACnumSearchResults') || 20;
$template->{'VARS'}->{'OverDriveLibraryID'} = C4::Context->preference('OverDriveLibraryID');
$template->param(overdrive_error => scalar $cgi->param('overdrive_error'));

output_html_with_http_headers $cgi, $cookie, $template->output;
