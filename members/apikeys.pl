#!/usr/bin/env perl

# Copyright 2015 BibLibre
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use CGI;
use String::Random;

use C4::Auth;
use C4::Members;
use C4::Output;
use Koha::ApiKeys;
use Koha::ApiKey;

my $cgi = new CGI;

my ($template, $loggedinuser, $cookie) = get_template_and_user({
    template_name => 'members/apikeys.tt',
    query => $cgi,
    type => 'intranet',
    authnotrequired => 0,
    flagsrequired => {borrowers => 1},
});

my $borrowernumber = $cgi->param('borrowernumber');
my $borrower = C4::Members::GetMember(borrowernumber => $borrowernumber);
my $op = $cgi->param('op');

if ($op) {
    if ($op eq 'generate') {
        my $apikey = new Koha::ApiKey;
        $apikey->borrowernumber($borrowernumber);
        $apikey->api_key(String::Random->new->randregex('[a-zA-Z0-9]{32}'));
        $apikey->store;
        print $cgi->redirect('/cgi-bin/koha/members/apikeys.pl?borrowernumber=' . $borrowernumber);
        exit;
    }

    if ($op eq 'delete') {
        my $key = $cgi->param('key');
        my $api_key = Koha::ApiKeys->find({borrowernumber => $borrowernumber, api_key => $key});
        if ($api_key) {
            $api_key->delete;
        }
        print $cgi->redirect('/cgi-bin/koha/members/apikeys.pl?borrowernumber=' . $borrowernumber);
        exit;
    }

    if ($op eq 'revoke') {
        my $key = $cgi->param('key');
        my $api_key = Koha::ApiKeys->find({borrowernumber => $borrowernumber, api_key => $key});
        if ($api_key) {
            $api_key->active(0);
            $api_key->store;
        }
        print $cgi->redirect('/cgi-bin/koha/members/apikeys.pl?borrowernumber=' . $borrowernumber);
        exit;
    }

    if ($op eq 'activate') {
        my $key = $cgi->param('key');
        my $api_key = Koha::ApiKeys->find({borrowernumber => $borrowernumber, api_key => $key});
        if ($api_key) {
            $api_key->active(1);
            $api_key->store;
        }
        print $cgi->redirect('/cgi-bin/koha/members/apikeys.pl?borrowernumber=' . $borrowernumber);
        exit;
    }
}

my @api_keys = Koha::ApiKeys->search({borrowernumber => $borrowernumber});

$template->param(
    api_keys => \@api_keys,
    borrower => $borrower,
    borrowernumber => $borrowernumber,
);

output_html_with_http_headers $cgi, $cookie, $template->output;
