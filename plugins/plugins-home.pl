#!/usr/bin/perl

# Copyright 2010 Kyle M Hall <kyle.m.hall@gmail.com>
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

use CGI;

use Koha::Plugins;
use C4::Auth;
use C4::Output;
use C4::Dates;
use C4::Debug;
use C4::Context;

my $plugins_enabled = C4::Context->preference('UseKohaPlugins') && C4::Context->config("enable_plugins");

my $input  = new CGI;
my $method = $input->param('method');

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {   template_name => ($plugins_enabled) ? "plugins/plugins-home.tt" : "plugins/plugins-disabled.tt",
        query         => $input,
        type          => "intranet",
        authnotrequired => 0,
        flagsrequired   => { plugins => '*' },
        debug           => 1,
    }
);

if ($plugins_enabled) {

    $template->param(
        koha_version => C4::Context->preference("Version"),
        method       => $method,
    );

    my @plugins = Koha::Plugins->new()->GetPlugins($method);

    $template->param( plugins => \@plugins, );

}

output_html_with_http_headers( $input, $cookie, $template->output );
