package Koha::SharedContent;

# Copyright 2016 BibLibre Morgane Alonso
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
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
use JSON;
use HTTP::Request;
use LWP::UserAgent;

our $MANA_IP = "http://10.25.159.107:5000";

sub manaRequest {
    my $mana_request = shift;
    my $result;

    $mana_request->content_type('application/json');
    my $userAgent = LWP::UserAgent->new;
    my $response  = $userAgent->request($mana_request);

    if ( $response->code ne "204" ) {
        $result = from_json( $response->decoded_content );
    }
    $result->{code} = $response->code;

    return $result if ( $response->code =~ /^2..$/ );
}

sub manaNewUserPatchRequest {
    my $resource = shift;
    my $id       = shift;

    my $url = "$MANA_IP/$resource/$id.json/newUser";
    my $request = HTTP::Request->new( PATCH => $url );

    return manaRequest($request);
}

sub manaPostRequest {
    my $resource = shift;
    my $content  = shift;

    my $url = "$MANA_IP/$resource.json";
    my $request = HTTP::Request->new( POST => $url );

    $content->{bulk_import} = 0;
    my $json = to_json( $content, { utf8 => 1 } );
    $request->content($json);

    return manaRequest($request);
}

sub manaGetRequestWithId {
    my $resource = shift;
    my $id       = shift;

    my $url = "$MANA_IP/$resource/$id.json";
    my $request = HTTP::Request->new( GET => $url );

    return manaRequest($request);
}

sub manaGetRequest {
    my $resource   = shift;
    my $parameters = shift;

    $parameters = join '&',
      map { defined $parameters->{$_} ? $_ . "=" . $parameters->{$_} : () }
      keys %$parameters;
    my $url = "$MANA_IP/$resource.json?$parameters";
    my $request = HTTP::Request->new( GET => $url );

    return manaRequest($request);
}

1;
