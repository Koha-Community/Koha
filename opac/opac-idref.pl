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
use HTTP::Request::Common;
use JSON;
use Encode;

use C4::Auth;
use C4::Context;
use C4::Search;
use C4::Output;

my $cgi = new CGI;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-idref.tt",
        query           => $cgi,
        type            => "opac",
        authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
    }
);

my $ua = LWP::UserAgent->new;

my $base = 'http://www.idref.fr/services/biblio/';
my $unimarc3 = $cgi->param('unimarc3');

my $request = HTTP::Request->new(
    'GET',
    $base . $unimarc3 . ".json",
);
$request->protocol('HTTP/1.1');
my $response = $ua->request($request);
if ( not $response->is_success) {
    $template->param(error => $base.$unimarc3.'.json');
    output_html_with_http_headers $cgi, $cookie, $template->output;
    exit;
}

my $content = Encode::decode("utf8", $response->content);
my $json = from_json( $content );
my $r;
my $role_name;
my @unimarc3;
my @results = ref $json->{sudoc}{result} eq "ARRAY"
            ? @{ $json->{sudoc}{result} }
            : ($json->{sudoc}{result});

for my $role_node ( @results ) {
    while ( my ( $k, $v ) = each %$role_node ) {
        next unless $k eq "role";
        my $role_name;
        my $count = 0;
        my $role_data = {};
        my @nodes = ref $v eq "ARRAY"
                    ? @$v
                    : ($v);
        for my $node ( @nodes ) {
            while ( ( $k, $v ) = each %$node ) {
                if ( $k eq 'roleName' ) {
                    $role_name = $v;
                    $role_data->{role_name} = $role_name;
                }
                elsif ( $k eq 'count' ) {
                    $role_data->{count} = $v;
                }
                elsif ( $k eq 'doc' ) {
                    push @{ $role_data->{docs} }, $v;
                }
            }
        }
        push @$r, $role_data;
    }
}

$template->param(
    content => $r,
    unimarc3 => $unimarc3,
);

output_html_with_http_headers $cgi, $cookie, $template->output;
