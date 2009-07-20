#!/usr/bin/perl
#
# Copyright 2006 Katipo Communications.
# Parts Copyright 2009 Foundations Bible College.
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
use warnings;
use Sys::Syslog qw(syslog);
use CGI;
use HTML::Template::Pro;
use Data::Dumper;

use C4::Auth;
use C4::Output;
use C4::Context;
use C4::Debug;
use C4::Labels::Lib 1.000000 qw(get_all_templates get_all_layouts get_barcode_types get_label_types);
use C4::Labels::Layout 1.000000;

my $cgi = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "labels/label-layout.tmpl",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

my $error = 0;

my $op = $cgi->param('op') || $ARGV[0];
my $layout_id = $cgi->param('layout_id') || $ARGV[1];

if ($op eq 'delete') {
	$error = C4::Labels::Layout::delete(layout_id => $layout_id);
}

my $layouts = get_all_layouts();

$template->param(
                error           => $error,
                layout_id       => $layout_id,
                ) if ($error ne 0);

$template->param(
                op              => $op,
                barcode_types   => get_barcode_types(),
                printingtypes   => get_label_types(),
                layout_loop     => $layouts,
                );

output_html_with_http_headers $cgi, $cookie, $template->output;
