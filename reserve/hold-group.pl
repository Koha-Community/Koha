#!/usr/bin/perl

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
use CGI qw( -utf8 );

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use Koha::HoldGroups;

my $cgi = CGI->new;
my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {
        template_name => "reserve/hold-group.tt",
        query         => $cgi,
        type          => "intranet",
        flagsrequired => { circulate => 'circulate_remaining_permissions' },
    }
);

my $reserve_group_id = $cgi->param('hold_group_id');
my $hold_group       = Koha::HoldGroups->find($reserve_group_id);

$template->param(
    hold_group => $hold_group,
);

output_html_with_http_headers $cgi, $cookie, $template->output;
