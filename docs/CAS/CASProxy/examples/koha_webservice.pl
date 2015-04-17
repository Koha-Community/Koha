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

# Here is an exemple of a simple phony webservice, returning "Hello World" if the user is authenticated
# The purpose is to show how CAS Proxy can work with koha
# In this configuration, this page acts as a CAS Client, instead of the user's browser.
# This page is meant to be called from a foreign application

=head1 CGI PARAMETERS

=item PT
The Proxy Ticket, needed for check_api_auth, that will try to make the CAS Server validate it.

=cut 

use utf8;
use strict;
use warnings;
binmode(STDOUT, ":utf8");

use C4::Auth qw(check_api_auth);
use C4::Output;
use C4::Context;
use CGI;

my $cgi = new CGI;

print CGI::header('-type'=>'text/plain', '-charset'=>'utf-8');

# The authentication : if $cgi contains a PT parameter, and CAS is enabled (casAuthentication syspref),
# a CAS Proxy authentication will take place
my ( $status, $cookie_, $sessionID ) = check_api_auth( $cgi, {circulate => 'override_renewals'});

if ($status ne 'ok') {
    print "Authentication failed : $status";
} else {
    print "Hello World!";
}
exit 0;

