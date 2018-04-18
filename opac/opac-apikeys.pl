#!/usr/bin/env perl

# This file is part of Koha.
#
# Copyright 2015 BibLibre
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

use Koha::ApiKeys;
use Koha::Patrons;
use Koha::Token;

my $cgi = new CGI;

my ($template, $loggedinuser, $cookie) = get_template_and_user({
    template_name   => 'opac-apikeys.tt',
    query           => $cgi,
    type            => 'opac',
    authnotrequired => 0
});

my $patron_id = $loggedinuser;
my $patron = Koha::Patrons->find( $patron_id );

if ( not defined $patron
    or !C4::Context->preference('AllowPatronsManageAPIKeysInOPAC') )
{
    # patron_id invalid -> exit
    print $cgi->redirect("/cgi-bin/koha/errors/404.pl");    # escape early
    exit;
}

my $op = $cgi->param('op') // '';

if ( $op eq 'generate' or
     $op eq 'delete' or
     $op eq 'revoke' or
     $op eq 'activate' ) {

    die "Wrong CSRF token"
    unless Koha::Token->new->check_csrf({
        session_id => scalar $cgi->cookie('CGISESSID'),
        token      => scalar $cgi->param('csrf_token'),
    });
}

if ($op) {
    if ($op eq 'generate') {
        my $description = $cgi->param('description') // '';
        my $apikey = Koha::ApiKey->new({
            patron_id   => $patron_id,
            description => $description
        });
        $apikey->store;
        print $cgi->redirect('/cgi-bin/koha/opac-apikeys.pl');
        exit;
    }

    if ($op eq 'delete') {
        my $key_id  = $cgi->param('key');
        my $api_key = Koha::ApiKeys->find({ patron_id => $patron_id, client_id => $key_id });
        if ($api_key) {
            $api_key->delete;
        }
        print $cgi->redirect('/cgi-bin/koha/opac-apikeys.pl');
        exit;
    }

    if ($op eq 'revoke') {
        my $key_id  = $cgi->param('key');
        my $api_key = Koha::ApiKeys->find({ patron_id => $patron_id, client_id => $key_id });
        if ($api_key) {
            $api_key->active(0);
            $api_key->store;
        }
        print $cgi->redirect('/cgi-bin/koha/opac-apikeys.pl');
        exit;
    }

    if ($op eq 'activate') {
        my $key_id  = $cgi->param('key');
        my $api_key = Koha::ApiKeys->find({ patron_id => $patron_id, client_id => $key_id });
        if ($api_key) {
            $api_key->active(1);
            $api_key->store;
        }
        print $cgi->redirect('/cgi-bin/koha/opac-apikeys.pl');
        exit;
    }
}

my @api_keys = Koha::ApiKeys->search({ patron_id => $patron_id });

$template->param(
    api_keys    => \@api_keys,
    apikeysview => 1,
    csrf_token  => Koha::Token->new->generate_csrf({ session_id => scalar $cgi->cookie('CGISESSID') }),
    patron      => $patron
);

output_html_with_http_headers $cgi, $cookie, $template->output;
