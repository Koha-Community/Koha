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
use CGI  qw ( -utf8 );
use JSON qw( to_json );

use C4::Auth   qw( check_api_auth );
use C4::Biblio qw( GetMarcStructure );
use C4::Output qw( output_with_http_headers );
use Koha::Libraries;

use Koha::AuthorisedValues;
use Koha::Items;
use Koha::ItemTypes;

my $cgi = CGI->new;

my ( $status, $cookie, $sessionID ) = C4::Auth::check_api_auth( $cgi, { acquisition => 'order_receive' } );
unless ( $status eq "ok" ) {
    print $cgi->header( -type => 'application/json', -status => '403 Forbidden' );
    print to_json( { auth_status => $status } );
    exit 0;
}

my $item       = {};
my $itemnumber = $cgi->param('itemnumber');

my $item_unblessed = {};
if ($itemnumber) {
    my $acq_fw = GetMarcStructure( 1, 'ACQ' );
    my $fw     = ($acq_fw) ? 'ACQ' : '';
    $item           = Koha::Items->find($itemnumber);
    $item_unblessed = $item->unblessed; # FIXME Not needed, call home_branch and holding_branch in the templates instead

    if ( $item->homebranch ) {          # This test should not be needed, homebranch and holdingbranch are mandatory
        $item_unblessed->{homebranchname} = $item->home_branch->branchname;
    }

    if ( $item->holdingbranch ) {
        $item_unblessed->{holdingbranchname} = $item->holding_branch->branchname;
    }

    my $descriptions;
    $descriptions = Koha::AuthorisedValues->get_description_by_koha_field(
        { frameworkcode => $fw, kohafield => 'items.notforloan', authorised_value => $item->notforloan } );
    $item_unblessed->{notforloan} = $descriptions->{lib} // '';

    $descriptions = Koha::AuthorisedValues->get_description_by_koha_field(
        { frameworkcode => $fw, kohafield => 'items.restricted', authorised_value => $item->restricted } );
    $item_unblessed->{restricted} = $descriptions->{lib} // '';

    $descriptions = Koha::AuthorisedValues->get_description_by_koha_field(
        { frameworkcode => $fw, kohafield => 'items.location', authorised_value => $item->location } );
    $item_unblessed->{location} = $descriptions->{lib} // '';

    $descriptions = Koha::AuthorisedValues->get_description_by_koha_field(
        { frameworkcode => $fw, kohafield => 'items.ccode', authorised_value => $item->ccode } );
    $item_unblessed->{collection} = $descriptions->{lib} // '';

    $descriptions = Koha::AuthorisedValues->get_description_by_koha_field(
        { frameworkcode => $fw, kohafield => 'items.materials', authorised_value => $item->materials } );
    $item_unblessed->{materials} = $descriptions->{lib} // '';

    my $itemtype = Koha::ItemTypes->find( $item->effective_itemtype );

    # We should not do that here, but call ->itemtype->description when needed instea
    $item_unblessed->{itemtype} = $itemtype->description;    # FIXME Should not it be translated_description?
}

my $json_text = to_json( $item_unblessed, { utf8 => 1 } );

output_with_http_headers $cgi, undef, $json_text, 'json';
