#!/usr/bin/perl

# 2009 BibLibre <jeanandre.santoni@biblibre.com>

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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA
#

use CGI;
use C4::Auth;
use C4::Circulation;

my $cgi = CGI->new;

# get the status of the user, this will check his credentials and rights
my ($status, $cookie, $sessionId) = C4::Auth::check_api_auth($cgi, undef);

my $result;

if ($status eq 'ok') { # if authentication is ok
	if ( $cgi->param('pending') eq 'true' ) { # if the 'pending' flag is true, we store the operation in the db instead of directly processing them
		$result = AddOfflineOperation(
	        $cgi->param('userid')     || '',
            $cgi->param('branchcode') || '',
            $cgi->param('timestamp')  || '',
            $cgi->param('action')     || '',
            $cgi->param('barcode')    || '',
            $cgi->param('cardnumber') || '',
		);
	} else {
		$result = ProcessOfflineOperation(
            {
                'userid'      => $cgi->param('userid'),
                'branchcode'  => $cgi->param('branchcode'),
                'timestamp'   => $cgi->param('timestamp'),
                'action'      => $cgi->param('action'),
                'barcode'     => $cgi->param('barcode'),
                'cardnumber'  => $cgi->param('cardnumber'),
            }
		);
	}
} else {
    $result = "Authentication failed."
}

print CGI::header('-type'=>'text/plain', '-charset'=>'utf-8');
print $result;
