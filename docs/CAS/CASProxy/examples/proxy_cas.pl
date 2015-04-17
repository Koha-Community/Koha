#!/usr/bin/perl

# Copyright 2009 SARL BibLibre
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

=head1 DESCRIPTION

# Here is an exemple of a CAS Proxy
# The proxy is a foreign application that will authenticate the user against CAS
# Once authenticated as a proxy, the foreign application will be able to call some
# Koha webservices, proving authentication only by giving a proxy ticket

# Note: please keep in mind that all url's must be https and their certificates must be trusted

=cut

use strict;
use warnings;
use CGI;
use Authen::CAS::Client;

# URL Of the CAS Server
my $casServerUrl = 'https://localhost:8443/cas/';
my $cas = Authen::CAS::Client->new($casServerUrl);
my $cgi = new CGI;

# URL of the service we're requesting a Service Ticket for (typically this very same page)
my $proxy_service = $cgi->url;


# Callback URL (this is an URL the CAS Server will query, providing the Proxy Ticket we'll need 
# to query the koha webservice). It can be this page or another. In this example, another page will be 
# called back
my $pgtUrl = "https://.../proxy_cas_callback.pl";

print $cgi->header({-type  =>  'text/html'});
print $cgi->start_html("proxy cas");

# If we already have a service ticket
if ($cgi->param('ticket')) {

    print "Got a ticket :" . $cgi->param('ticket') . "<br>\n";
  
    # We validate it against the CAS Server, providing the callback URL
    my $r = $cas->service_validate( $proxy_service, $cgi->param('ticket'), pgtUrl => $pgtUrl);

    # If it is sucessful, we are authenticated
    if( $r->is_success() ) {
	print "User authenticated as: ", $r->user(), "<br>\n";
    } else {
	print "User authentication failed<br />\n";
    }

    # If we have a PGTIou ticket, the proxy validation was sucessful 
    if (defined $r->iou) {
      print "Proxy granting ticket IOU: ", $r->iou, "<br />\n";
      my $pgtIou = $r->iou;

      print '<a href="proxy_cas_data.pl?PGTIOU=', $r->iou, '">Next</a>';

      
     	    
    } else {
      print "Service validation for proxying failed\n";
   }

# If we don't have a Service Ticket, we ask for one (ie : the user will be redirected to the CAS Server for authentication)
} else {

    my $url = $cas->login_url($proxy_service);
    print "<a href=\"$url\">Please log in</a>";
}

print $cgi->end_html;



