#!/usr/bin/perl

# Bouzid Fergani, 2020   - inLibro
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
use CGI;
use JSON;
use C4::Auth qw(check_cookie_auth);
use C4::Biblio;
use C4::Context;

my $input = CGI->new;
print $input->header('application/json');

# Check the user's permissions
my ( $auth_status, $auth_sessid ) =
  C4::Auth::check_cookie_auth( $input->cookie('CGISESSID'), { editauthorities => 1, editcatalogue => 1 } );
if ( $auth_status ne "ok" ) {
    print to_json( { status => 'UNAUTHORIZED' } );
    exit 0;
}

# Link the biblio headings to authorities and return a json containing the status of all the links.
# Example : {"status":"OK","links":[{"authid":"123","status":"LINK_CHANGED","tag":"650"}]}
#
# tag = the tag number of the field
# authid = the value of the $9 subfield for this tag
# status = The status of the link (LOCAL_FOUND, NONE_FOUND, MULTIPLE_MATCH, UNCHANGED, CREATED)

my $json;

my $record = TransformHtmlToMarc($input,1);

my ( $headings_changed, $results ) = BiblioAutoLink (
    $record,
    $input->param('frameworkcode'),
    1
);

$json->{status} = 'OK';
$json->{links} = $results->{details} || '';

print to_json($json);
