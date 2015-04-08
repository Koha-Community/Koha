#!/usr/bin/perl

# Copyright 2010 Koha Development team
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
use C4::Templates;
use C4::Output;
# use C4::Auth;
use C4::Context;
use CGI;

sub _help_template_file_of_url {
    my $url = shift;
    my $file;
    if ($url =~ /koha\/(.*)\.pl/) {
        $file = $1;
    } else {
        $file = 'mainpage';
    }
    $file =~ s/[^a-zA-Z0-9_\-\/]*//g;
    return "help/$file.tt";
}

my $query = new CGI;

# find the script that called the online help using the CGI referer()
our $refer = $query->param('url');
$refer = $query->referer()  if !$refer || $refer eq 'undefined';
my $from = _help_template_file_of_url($refer);
my $htdocs = C4::Context->config('intrahtdocs');

#
# checking that the help file exist, otherwise, display nohelp.tt page
#
my ( $theme, $lang ) = C4::Templates::themelanguage( $htdocs, $from, "intranet", $query );
unless ( -e "$htdocs/$theme/$lang/modules/$from" ) {
    $from = "help/nohelp.tt";
    ( $theme, $lang ) = C4::Templates::themelanguage( $htdocs, $from, "intranet", $query );
}

my $template = C4::Templates::gettemplate($from, 'intranet', $query);
$template->param(
    referer => $refer,
    intranetstylesheet => C4::Context->preference("intranetstylesheet"),
    intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
);

my $help_version = C4::Context->preference("Version");
if ( $help_version =~ m|^(\d+)\.(\d{2}).*$| ) {
    my $version = $1;
    my $major = $2;
    if ( $major % 2 ) { $major-- };
    $help_version = "$version.$major";
}
$template->param( helpVersion => $help_version );

output_html_with_http_headers $query, "", $template->output;
