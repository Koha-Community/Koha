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

# This page will display the result of the call to the koha webservice

=head1 CGI PARAMETERS

=item PGTIOU

The Proxy Granting Ticket IOU the CAS Server returned to us when we gave him the Service Ticket
This PGTIOU will allow us to retrive the matching PGTID

=cut 

use strict;
use warnings;
use CGI;
use Authen::CAS::Client;
use Storable qw(fd_retrieve);
use LWP::Simple;
use URI::Escape;

my $casServerUrl = 'https://localhost:8443/cas/';
my $cas = Authen::CAS::Client->new($casServerUrl);

# URL of the service we'd like to be proxy for (typically the Koha webservice we want to query)
my $target_service = "https://.../koha_webservice.pl";

my $cgi = new CGI;

print $cgi->header({-type  =>  'text/html'});
print $cgi->start_html("proxy cas");


if ($cgi->param('PGTIOU')) {

      # At this point, we must retrieve the PgtId by matching the PgtIou we
      # just received and the PgtIou given by the CAS Server to the callback URL
      # The callback page stored it in the application vars (in our case a storable object in a file)
      open FILE, "casSession.tmp" or die "Unable to open file";
      my $hashref = fd_retrieve(\*FILE);
      my $pgtId = %$hashref->{$cgi->param('PGTIOU')};
      close FILE;

      # Now that we have a PgtId, we can ask the cas server for a proxy ticket...
      my $rp = $cas->proxy( $pgtId, $target_service );
      if( $rp->is_success ) {
        print "Proxy Ticket issued: ", $rp->proxy_ticket, "<br />\n";

	# ...which we will provide to the target service (the koha webservice) for authentication !
	my $data = get($target_service . "?PT=" . $rp->proxy_ticket);
	
	# And finally, we can display the data gathered from the koha webservice !
	print "This is the output of the koha webservice we just queried, CAS authenticated : <br/>";
	print "<code>$data</code>";

      } else {
	print "Cannot get Proxy Ticket";
      }


}
