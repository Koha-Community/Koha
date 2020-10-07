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

use JSON qw(from_json);
use LWP::Simple qw(get);

use Koha::Plugins;
use C4::Auth;
use C4::Output;
use C4::Debug;
use C4::Context;

my $plugins_enabled = C4::Context->config("enable_plugins");

my $input  = CGI->new;
my $method = $input->param('method');
my $plugin_search = $input->param('plugin-search');

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {   template_name => ($plugins_enabled) ? "plugins/plugins-home.tt" : "plugins/plugins-disabled.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired   => { plugins => '*' },
        debug           => 1,
    }
);

if ($plugins_enabled) {

    $template->param(
        koha_version => C4::Context->preference("Version"),
        method       => $method,
    );

    my @plugins = Koha::Plugins->new()->GetPlugins(
        {
            method => $method,
            all    => 1,
            errors => 1
        }
    );

    $template->param( plugins => \@plugins, );

    $template->param( can_search => C4::Context->config('plugin_repos') ? 1 : 0 );
    my @results;
    if ($plugin_search) {
        my $repos = C4::Context->config('plugin_repos');
        foreach my $r ( @{ $repos->{repo} } ) {
            if ( $r->{service} eq 'github' ) {
                my $url = "https://api.github.com/search/repositories?q=$plugin_search+user:$r->{org_name}+in:name,description";
                my $response = from_json( get($url) );
                foreach my $result ( @{ $response->{items} } ) {
                    next unless $result->{name} =~ /^koha-plugin-/;
                    my $releases = $result->{url} . "/releases/latest";
                    my $release = from_json( get($releases) );
                    for my $asset ( @{$release->{assets}} ) {
                        if ($asset->{browser_download_url} =~ m/\.kpz$/) {
                            $result->{install_name} = $asset->{name};
                            $result->{install_url} = $asset->{browser_download_url};
                        }
                    }
                    push( @results, { repo => $r, result => $result } );
                }
            }
        }

        $template->param(
            search_results => \@results,
            search_term    => $plugin_search,
        );
    }
}

output_html_with_http_headers( $input, $cookie, $template->output );
