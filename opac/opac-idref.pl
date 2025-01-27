#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2014 BibLibre
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
use LWP::UserAgent;
use JSON qw( from_json );
use Encode;

use C4::Auth qw( get_template_and_user );
use C4::Context;
use C4::Search;
use C4::Output qw( output_html_with_http_headers );

my $cgi = CGI->new;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-idref.tt",
        query           => $cgi,
        type            => "opac",
        authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
    }
);

my $ua = LWP::UserAgent->new;

# See http://documentation.abes.fr/aideidrefdeveloppeur/index.html#MicroWebBiblio
my $base     = 'http://www.idref.fr/services/biblio/';
my $unimarc3 = $cgi->param('unimarc3');

my $request = HTTP::Request->new(
    'GET',
    $base . $unimarc3 . ".json",
);
$request->protocol('HTTP/1.1');
my $response = $ua->request($request);
if ( not $response->is_success ) {
    $template->param( error => $base . $unimarc3 . '.json' );
    output_html_with_http_headers $cgi, $cookie, $template->output;
    exit;
}

my $content = Encode::decode( "utf8", $response->content );
my $json    = from_json($content);
my $r;
my @results =
    ref $json->{sudoc}{result} eq "ARRAY"
    ? @{ $json->{sudoc}{result} }
    : ( $json->{sudoc}{result} );

for my $result (@results) {
    my $role_node = $result->{'role'};
    my @roles =
        ref $role_node eq "ARRAY"
        ? @$role_node
        : ($role_node);
    for my $role (@roles) {
        my @docs =
            ref $role->{doc} eq "ARRAY"
            ? @{ $role->{doc} }
            : $role->{doc};
        push @$r,
            {
            role_name => $role->{roleName},
            count     => $role->{count},
            docs      => \@docs,
            };
    }
}

$template->param(
    content  => $r,
    unimarc3 => $unimarc3,
);

output_html_with_http_headers $cgi, $cookie, $template->output;
