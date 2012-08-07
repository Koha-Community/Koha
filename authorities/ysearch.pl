#!/usr/bin/perl

# This software is placed under the gnu General Public License, v2 (http://www.gnu.org/licenses/gpl.html)

# Copyright 2011 BibLibre
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

=head1 ysearch.pl

This script allows ajax call for dynamic authorities search
(used in auth_finder.pl)

=cut

use CGI;
use Modern::Perl;
use C4::Context;
use C4::Charset;
use C4::AuthoritiesMarc;
use C4::Auth qw/check_cookie_auth/;

my $query = new CGI;

binmode STDOUT, ':encoding(UTF-8)';
print $query->header( -type => 'text/plain', -charset => 'UTF-8' );

my ( $auth_status, $sessionID ) = check_cookie_auth( $query->cookie('CGISESSID'), { } );
if ( $auth_status ne "ok" ) {
    exit 0;
}

    my $searchstr = $query->param('query');
    my $searchtype = $query->param('querytype');
    my @value;
    given ($searchtype) {
        when (/^marclist$/)      { @value = (undef, undef, $searchstr); }
        when (/^mainentry$/)     { @value = (undef, $searchstr, undef); }
        when (/^mainmainentry$/) { @value = ($searchstr, undef, undef); }
    }
    my @marclist  = ($searchtype);
    my $authtypecode = $query->param('authtypecode');
    my @and_or    = $query->param('and_or');
    my @excluding = $query->param('excluding');
    my @operator  = $query->param('operator');
    my $orderby   = $query->param('orderby');

    my $resultsperpage = 50;
    my $startfrom = 0;

    my ( $results, $total ) = SearchAuthorities( \@marclist, \@and_or, \@excluding, \@operator, \@value, $startfrom * $resultsperpage, $resultsperpage, $authtypecode, $orderby );
    foreach my $result (@$results) {
        my $value = '';
        my $authorized = $result->{'summary'}->{'authorized'};
        foreach my $heading (@$authorized) {
            $value .= $heading->{'heading'} . ' ';
        }
        # Removes new lines
        $value =~ s/<br \/>/ /g;
        $value =~ s/\n//g;
        print nsb_clean($value) . "\n";
    }
