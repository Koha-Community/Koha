#!/usr/bin/perl
# Copyright 2015 Vaara-kirjastot
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
use CGI qw ( -utf8 );
use Try::Tiny;
use Scalar::Util qw(blessed);
use JSON::XS;

use C4::Context;
use C4::Output;
use C4::Auth qw(check_cookie_auth);
use C4::Items;

use Koha::FloatingMatrix;

my $input = new CGI;

#my ( $auth_status, $sessionID ) =
#  check_cookie_auth( $input->cookie('CGISESSID'),
#    { circulate => 'circulate_remaining_permissions' } );
my ( $auth_status, $sessionID ) =
  check_cookie_auth( $input->cookie('CGISESSID'),
                    {
                        parameters => 1,
                    } );


binmode STDOUT, ":encoding(UTF-8)";

my $fm = Koha::FloatingMatrix->new();

my $data = $input->Vars();
if ($data) {
    try {
        ##If we are getting a DELETE-request, we DELETE (CGI doesn't know what DELETE is :(((
        if ($data->{delete}) {
            $fm->deleteBranchRule($data->{fromBranch}, $data->{toBranch});
            $fm->store();
        }
        elsif ($data->{test}) {
            my $item = C4::Items::GetItem(undef, $data->{barcode});
            if ($data->{barcode} && $item) {
                $data->{testResult} = $fm->checkFloating($item, $data->{fromBranch}, $data->{toBranch});
            }
            else {
                Koha::Exception::BadParameter->throw(error => "No Item found using barcode '".$data->{barcode}."'");
            }
        }
        ##If we are getting a POST-request, we UPSERT
        else {
            $fm->upsertBranchRule($data);
            $fm->store();
        }
    } catch {
        if (blessed $_ && $_->isa('Koha::Exception::BadParameter')) {
            respondBadParameterException($_);
        }
        else {
            die $_;
        }
    };

    print $input->header( -type => 'text/json',
                          -charset => 'UTF-8',
                          -status => "200 OK");
    print JSON::XS->new->utf8->convert_blessed->encode($data);
}
else {
    print $input->header( -type => 'text/plain',
                          -charset => 'UTF-8',
                          -status => "405 Method Not Allowed");
}

sub respondBadParameterException {
    my ($e) = @_;
    print $input->header( -type => 'text/json',
                          -charset => 'UTF-8',
                          -status => "400 Bad Request");
    print JSON::XS->new->utf8->encode({error => $e->as_string()});
    exit 1;
}