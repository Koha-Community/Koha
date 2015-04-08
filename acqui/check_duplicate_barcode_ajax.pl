#!/usr/bin/perl

# Frédérick Capovilla, 2011 - Libéo
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

use strict;
#use warnings; FIXME - Bug 2505
use CGI;
use CGI::Cookie;
use JSON;
use C4::Auth;
use C4::Items;
use C4::Context;

my $input        = new CGI;
print $input->header('application/json');

# Check the user's permissions
my %cookies = fetch CGI::Cookie;
my $sessid = $cookies{'CGISESSID'}->value || $input->param('CGISESSID');
my ($auth_status, $auth_sessid) = C4::Auth::check_cookie_auth($sessid, {acquisition => 'order_manage'});
if ($auth_status ne "ok") {
    print to_json({status => 'UNAUTHORIZED'});
    exit 0;
}

my $json;

#Check if the barcodes already exist.
my @barcodes = $input->param('barcodes');
foreach my $barcode (@barcodes) {
    my $existing_itemnumber = GetItemnumberFromBarcode($barcode);
    if ($existing_itemnumber) {
        $json->{status} = "DUPLICATES";
        push @{$json->{barcodes}}, $barcode;
    }
}

$json->{status} = 'OK' unless defined $json->{status};
print to_json($json);

