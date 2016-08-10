#!/usr/bin/perl

# Copyright BibLibre 2012
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
use JSON;

use C4::Auth;
use C4::Biblio;
use C4::Items;
use C4::Koha;
use C4::Output;
use Koha::Libraries;

use Koha::AuthorisedValues;

my $cgi = new CGI;

my ( $status, $cookie, $sessionID ) = C4::Auth::check_api_auth( $cgi, { acquisition => 'order_receive' } );
unless ($status eq "ok") {
    print $cgi->header(-type => 'application/json', -status => '403 Forbidden');
    print to_json({ auth_status => $status });
    exit 0;
}

my $item = {};
my $itemnumber = $cgi->param('itemnumber');

if($itemnumber) {
    my $acq_fw = GetMarcStructure(1, 'ACQ');
    my $fw = ($acq_fw) ? 'ACQ' : '';
    $item = GetItem($itemnumber);

    if($item->{homebranch}) {
        $item->{homebranchname} = Koha::Libraries->find($item->{homebranch})->branchname;
    }

    if($item->{holdingbranch}) {
        $item->{holdingbranchname} = Koha::Libraries->find($item->{holdingbranch})->branchname;
    }

    my $av;
    $av = Koha::AuthorisedValues->search_by_koha_field({ frameworkcode => $fw, kohafield => 'items.notforloan', authorised_value => $item->{notforloan} });
    $item->{notforloan} = $av->count ? $av->next->lib : '';

    $av = Koha::AuthorisedValues->search_by_koha_field({ frameworkcode => $fw, kohafield => 'items.restricted', authorised_value => $item->{restricted} });
    $item->{restricted} = $av->count ? $av->next->lib : '';

    $av = Koha::AuthorisedValues->search_by_koha_field({ frameworkcode => $fw, kohafield => 'items.location', authorised_value => $item->{location} });
    $item->{location} = $av->count ? $av->next->lib : '';

    $av = Koha::AuthorisedValues->search_by_koha_field({ frameworkcode => $fw, kohafield => 'items.collection', authorised_value => $item->{collection} });
    $item->{collection} = $av->count ? $av->next->lib : '';

    $av = Koha::AuthorisedValues->search_by_koha_field({ frameworkcode => $fw, kohafield => 'items.materials', authorised_value => $item->{materials} });
    $item->{materials} = $av->count ? $av->next->lib : '';

    my $itemtype = getitemtypeinfo($item->{itype});
    $item->{itemtype} = $itemtype->{description};
}

my $json_text = to_json( $item, { utf8 => 1 } );

output_with_http_headers $cgi, undef, $json_text, 'json';
