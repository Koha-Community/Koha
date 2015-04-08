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
use CGI;
use JSON;

use C4::Biblio;
use C4::Branch;
use C4::Items;
use C4::Koha;
use C4::Output;

my $cgi = new CGI;
my $item = {};
my $itemnumber = $cgi->param('itemnumber');

if($itemnumber) {
    my $acq_fw = GetMarcStructure(1, 'ACQ');
    my $fw = ($acq_fw) ? 'ACQ' : '';
    $item = GetItem($itemnumber);

    if($item->{homebranch}) {
        $item->{homebranchname} = GetBranchName($item->{homebranch});
    }

    if($item->{holdingbranch}) {
        $item->{holdingbranchname} = GetBranchName($item->{holdingbranch});
    }

    if(my $code = GetAuthValCode("items.notforloan", $fw)) {
        $item->{notforloan} = GetKohaAuthorisedValueLib($code, $item->{notforloan});
    }

    if(my $code = GetAuthValCode("items.restricted", $fw)) {
        $item->{restricted} = GetKohaAuthorisedValueLib($code, $item->{restricted});
    }

    if(my $code = GetAuthValCode("items.location", $fw)) {
        $item->{location} = GetKohaAuthorisedValueLib($code, $item->{location});
    }

    if(my $code = GetAuthValCode("items.ccode", $fw)) {
        $item->{collection} = GetKohaAuthorisedValueLib($code, $item->{ccode});
    }

    if(my $code = GetAuthValCode("items.materials", $fw)) {
        $item->{materials} = GetKohaAuthorisedValueLib($code, $item->{materials});
    }

    my $itemtype = getitemtypeinfo($item->{itype});
    $item->{itemtype} = $itemtype->{description};
}

my $json_text = to_json( $item, { utf8 => 1 } );

output_with_http_headers $cgi, undef, $json_text, 'json';
