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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use CGI             qw ( -utf8 );
use C4::Auth        qw( get_template_and_user );
use C4::Output      qw( output_html_with_http_headers );
use Koha::DateUtils qw( output_pref );
use Koha::Libraries;

my $query = CGI->new;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "admin/usage_statistics.tt",
        query         => $query,
        type          => "intranet",
        flagsrequired => { parameters => 'manage_usage_stats' },
    }
);

my $op = $query->param('op') || q||;

if ( $op eq 'cud-update' ) {
    my $UsageStats              = $query->param('UsageStats');
    my $UsageStatsCountry       = $query->param('UsageStatsCountry');
    my $UsageStatsLibraryName   = $query->param('UsageStatsLibraryName');
    my $UsageStatsLibraryType   = $query->param('UsageStatsLibraryType');
    my $UsageStatsLibraryUrl    = $query->param('UsageStatsLibraryUrl');
    my $UsageStatsLibrariesInfo = $query->param('UsageStatsLibrariesInfo');
    my $UsageStatsGeolocation   = $query->param('UsageStatsGeolocation');
    C4::Context->set_preference( 'UsageStats',              $UsageStats );
    C4::Context->set_preference( 'UsageStatsCountry',       $UsageStatsCountry );
    C4::Context->set_preference( 'UsageStatsLibraryName',   $UsageStatsLibraryName );
    C4::Context->set_preference( 'UsageStatsLibraryType',   $UsageStatsLibraryType );
    C4::Context->set_preference( 'UsageStatsLibraryUrl',    $UsageStatsLibraryUrl );
    C4::Context->set_preference( 'UsageStatsLibrariesInfo', $UsageStatsLibrariesInfo );
    C4::Context->set_preference( 'UsageStatsGeolocation',   $UsageStatsGeolocation );
    my $libraries = Koha::Libraries->search;

    while ( my $library = $libraries->next ) {
        if ( my $latlng = $query->param( 'geolocation_' . $library->branchcode ) ) {
            $library->geolocation($latlng)->store;
        }
    }
}

if ( C4::Context->preference('UsageStatsLastUpdateTime') ) {
    my $dt = DateTime->from_epoch( epoch => C4::Context->preference('UsageStatsLastUpdateTime') );
    $template->param( UsageStatsLastUpdateTime => output_pref($dt) );
}

my $libraries = Koha::Libraries->search;
$template->param(
    libraries => $libraries,
);

output_html_with_http_headers $query, $cookie, $template->output;
