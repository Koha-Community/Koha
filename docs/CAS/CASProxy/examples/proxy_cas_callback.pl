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

# Here is an exemple of a callback page for a CAS Proxy
# This is the page the CAS server will call back with a Proxy Ticket, allowing us (the foreign application)
# to query koha webservices, being CAS authenticated 

=cut

use strict;
use warnings;
use CGI;
use Authen::CAS::Client;
use Storable qw(nstore_fd);

my $casServerUrl = 'https://localhost:8443/cas/';
my $cas = Authen::CAS::Client->new($casServerUrl);

my $cgi = new CGI;

my $proxy_service = $cgi->url;

print $cgi->header({-type  =>  'text/html'});
print $cgi->start_html("proxy cas callback");

# If we have a pgtId, it means the cas server called us back
if ($cgi->param('pgtId')) {
    warn "Got a pgtId :" . $cgi->param('pgtId');
    warn "Got a pgtIou :" . $cgi->param('pgtIou');
    my $pgtIou =  $cgi->param('pgtIou');
    my $pgtId =  $cgi->param('pgtId');

    # Now we store the pgtIou and the pgtId in the application vars (in our case a storable object in a file), 
    # so that the page requesting the webservice can retrieve the pgtId matching it's PgtIou 
    open FILE, ">", "casSession.tmp" or die "Unable to open file";
    nstore_fd({$pgtIou => $pgtId}, \*FILE);
    close FILE;

} else {
    warn "Failed to get a Proxy Ticket\n";
}

print $cgi->end_html;

