#!/usr/bin/perl

#written 18/1/2000 by chris@katipo.co.nz
# adapted for use in the hlt opac by finlay@katipo.co.nz 29/11/2002
# script to renew items from the web
# Parts Copyright 2010 Catalyst IT

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


use strict;
use warnings;

use CGI;
use C4::Circulation;
use C4::Auth;

my $query = new CGI;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
	{
		  template_name   => "opac-user.tmpl",
		  query           => $query,
		  type            => "opac",
		  authnotrequired => 0,
		  flagsrequired   => { borrow => 1 },
		  debug           => 1,
	}
); 
my @items          = $query->param('item');
$borrowernumber = $query->param('borrowernumber') || $query->param('bornum');
my $opacrenew = C4::Context->preference("OpacRenewalAllowed");

my $errorstring='';
for my $itemnumber ( @items ) {
    my ($status,$error) = CanBookBeRenewed( $borrowernumber, $itemnumber );
    if ( $status == 1 && $opacrenew == 1 ) {
        AddRenewal( $borrowernumber, $itemnumber );
    }
    else {
	$errorstring .= $error ."|";
    }
}

print $query->redirect("/cgi-bin/koha/opac-user.pl?renew_error=$errorstring");

