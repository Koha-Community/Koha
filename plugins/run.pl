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

use Modern::Perl;

use CGI qw ( -utf8 );

use Koha::Plugins::Handler;
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::Context;

my $plugins_enabled = C4::Context->config("enable_plugins");

my $cgi = CGI->new;

my $class  = $cgi->param('class');
my $method = $cgi->param('method');

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "plugins/plugins-disabled.tt",
        query         => $cgi,
        type          => "intranet",
        flagsrequired => { plugins => $method },
    }
);

if ($plugins_enabled) {
    my $plugin = Koha::Plugins::Handler->run( { class => $class, method => $method, cgi => $cgi } );
} else {
    output_html_with_http_headers( $cgi, $cookie, $template->output );
}
