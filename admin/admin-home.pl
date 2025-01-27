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

use CGI        qw ( -utf8 );
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use Koha::Plugins;

my $query = CGI->new;

my $mana_url = C4::Context->config('mana_config');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "admin/admin-home.tt",
        query         => $query,
        type          => "intranet",
        flagsrequired => { parameters => '*' },
    }
);

if ( C4::Context->config('enable_plugins') ) {
    my @admin_plugins = Koha::Plugins->new()->GetPlugins(
        {
            method => 'admin',
        }
    );
    $template->param( admin_plugins => \@admin_plugins );
}

$template->param( mana_url => $mana_url, );

output_html_with_http_headers $query, $cookie, $template->output;
