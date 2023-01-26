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

use CGI qw ( -utf8 );
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::Tags qw( get_count_by_tag_status );
use Koha::Reviews;

my $query = CGI->new;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "tools/tools-home.tt",
        query           => $query,
        type            => "intranet",
        flagsrequired   => [ tools => '*', clubs => '*' ],
    }
);

my $pendingcomments = Koha::Reviews->search_limited({ approved => 0 })->count;
my $pendingtags = get_count_by_tag_status(0);

$template->param(
    pendingcomments => $pendingcomments,
    pendingtags     => $pendingtags
);

if ( C4::Context->config('enable_plugins') ) {
    my @tool_plugins = Koha::Plugins->new()->GetPlugins({
        method => 'tool',
    });
    $template->param( tool_plugins => \@tool_plugins );
}

output_html_with_http_headers $query, $cookie, $template->output;
