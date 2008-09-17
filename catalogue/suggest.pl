#!/usr/bin/perl
# WARNING: 4-character tab stops here

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

use C4::Context;
use C4::Auth;
use C4::Output;
use C4::Biblio;
use C4::Acquisition;
use C4::Koha; # XXX subfield_is_koha_internal_p

# Creates the list of active tags using the active MARC configuration
my $query=new CGI;
my $Q=$query->param('Q');
my @words = split / /,$Q;
my $dbh = C4::Context->dbh;

my $suggestions = findsuggestion($dbh,\@words);
my @loop_suggests;
foreach my $line (@$suggestions) {
    my ($word,$suggestion,$count) = split /\|/,$line;
    push @loop_suggests, { word => $word, suggestion =>$suggestion, count => $count };
}

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "catalogue/suggest.tmpl",
                 query => $query,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {editcatalogue => 1},
                 debug => 1,
                 });
$template->param("loop" => \@loop_suggests,
        );

output_html_with_http_headers $query, $cookie, $template->output;

