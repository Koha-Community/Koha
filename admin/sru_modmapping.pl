#!/usr/bin/perl

# Copyright 2014 Rijksmuseum
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
use CGI;
use C4::Auth;
use C4::Output;

# Initialize CGI, template

my $input = new CGI;
my $mapstr = $input->param('mapping')//'';
my $type = $input->param('type')//'';
my ( $template, $loggedinuser, $cookie ) = get_template_and_user( {
    template_name => $type eq "authority" ? "admin/sru_modmapping_auth.tt" : "admin/sru_modmapping.tt",
    query => $input,
    type => "intranet",
    authnotrequired => 0,
});

# Main code: convert mapping string to hash structure and show template

my %map;
foreach my $singlemap ( split ',', $mapstr ) {
    my @temp = split '=', $singlemap, 2;
    $map{ $temp[0] } = $temp[1] if @temp>1;
}
$template->param( mapping => \%map );
output_html_with_http_headers $input, $cookie, $template->output;

# End of main code
