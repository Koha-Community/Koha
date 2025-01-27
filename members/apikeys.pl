#!/usr/bin/perl

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

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_and_exit output_html_with_http_headers );

use Koha::ApiKeys;
use Koha::Patrons;

my $cgi = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => 'members/apikeys.tt',
        query         => $cgi,
        type          => 'intranet',
        flagsrequired => { borrowers => 'edit_borrowers' },
    }
);

my $patron;
my $patron_id = $cgi->param('patron_id') // '';
my $api_key   = $cgi->param('key')       // '';

$patron = Koha::Patrons->find($patron_id) if $patron_id;

if (   not defined $patron
    or not C4::Context->preference('RESTOAuth2ClientCredentials') )
{

    # patron_id invalid -> exit
    print $cgi->redirect("/cgi-bin/koha/errors/404.pl");    # escape early
    exit;
}

if ( $patron_id != $loggedinuser && !C4::Context->IsSuperLibrarian() ) {

    # not the owner of the account viewing/editing own API keys, nor superlibrarian -> exit
    print $cgi->redirect("/cgi-bin/koha/errors/403.pl");    # escape early
    exit;
}

my $op = $cgi->param('op') // '';

if ($op) {
    if ( $op eq 'cud-generate' ) {
        my $description = $cgi->param('description') // '';
        my $api_key     = Koha::ApiKey->new(
            {
                patron_id   => $patron_id,
                description => $description
            }
        );
        $api_key->store;

        $template->param(
            fresh_api_key => $api_key,
            api_keys      => Koha::ApiKeys->search( { patron_id => $patron_id } ),
        );
    }

    if ( $op eq 'cud-delete' ) {
        my $api_key_id = $cgi->param('key');
        my $key        = Koha::ApiKeys->find( { patron_id => $patron_id, client_id => $api_key_id } );
        if ($key) {
            $key->delete;
        }
        print $cgi->redirect( '/cgi-bin/koha/members/apikeys.pl?patron_id=' . $patron_id );
        exit;
    }

    if ( $op eq 'cud-revoke' ) {
        my $api_key_id = $cgi->param('key');
        my $key        = Koha::ApiKeys->find( { patron_id => $patron_id, client_id => $api_key_id } );
        if ($key) {
            $key->active(0);
            $key->store;
        }
        print $cgi->redirect( '/cgi-bin/koha/members/apikeys.pl?patron_id=' . $patron_id );
        exit;
    }

    if ( $op eq 'cud-activate' ) {
        my $api_key_id = $cgi->param('key');
        my $key        = Koha::ApiKeys->find( { patron_id => $patron_id, client_id => $api_key_id } );
        if ($key) {
            $key->active(1);
            $key->store;
        }
        print $cgi->redirect( '/cgi-bin/koha/members/apikeys.pl?patron_id=' . $patron_id );
        exit;
    }
}

$template->param(
    api_keys => Koha::ApiKeys->search( { patron_id => $patron_id } ),
    patron   => $patron
);

output_html_with_http_headers $cgi, $cookie, $template->output;
