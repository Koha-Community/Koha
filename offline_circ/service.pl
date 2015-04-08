#!/usr/bin/perl

# 2009 BibLibre <jeanandre.santoni@biblibre.com>

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
#

use strict;
use warnings;

use CGI;
use C4::Auth;
use C4::Circulation;

my $cgi = CGI->new;

# get the status of the user, this will check his credentials and rights
my ($status, $cookie, $sessionId) = C4::Auth::check_api_auth($cgi, undef);
($status, $sessionId) = C4::Auth::check_cookie_auth($cgi, undef) if ($status ne 'ok');

my $result;

if ($status eq 'ok') { # if authentication is ok

    my $userid     = $cgi->param('userid')     || '';
    my $branchcode = $cgi->param('branchcode') || '';
    my $timestamp  = $cgi->param('timestamp')  || '';
    my $action     = $cgi->param('action')     || '';
    my $barcode    = $cgi->param('barcode')    || '';
    my $amount     = $cgi->param('amount')     || 0;
    $barcode    =~ s/^\s+//;
    $barcode    =~ s/\s+$//;
    my $cardnumber = $cgi->param('cardnumber') || '';
    $cardnumber =~ s/^\s+//;
    $cardnumber =~ s/\s+$//;

    if ( $cgi->param('pending') eq 'true' ) { # if the 'pending' flag is true, we store the operation in the db instead of directly processing them
        $result = AddOfflineOperation(
            $userid,
            $branchcode,
            $timestamp,
            $action,
            $barcode,
            $cardnumber,
            $amount
        );
    } else {
        $result = ProcessOfflineOperation(
            {
                'userid'      => $userid,
                'branchcode'  => $branchcode,
                'timestamp'   => $timestamp,
                'action'      => $action,
                'barcode'     => $barcode,
                'cardnumber'  => $cardnumber,
                'amount'      => $amount
            }
        );
    }
} else {
    $result = "Authentication failed."
}

print CGI::header('-type'=>'text/plain', '-charset'=>'utf-8');
print $result;
