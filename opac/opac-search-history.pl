#!/usr/bin/perl

# Copyright 2009 BibLibre SARL
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

use strict;
use warnings;

use C4::Auth qw(:DEFAULT get_session ParseSearchHistoryCookie);
use CGI;
use JSON qw/decode_json encode_json/;
use C4::Context;
use C4::Output;
use C4::Log;
use C4::Items;
use C4::Debug;
use C4::Dates;
use URI::Escape;
use POSIX qw(strftime);


my $cgi = new CGI;

# Getting the template and auth
my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "opac-search-history.tmpl",
                                query => $cgi,
                                type => "opac",
                                authnotrequired => 1,
                                flagsrequired => {borrowers => 1},
                                debug => 1,
                                });

# If the user is not logged in, we deal with the cookie
if (!$loggedinuser) {

    # Deleting search history
    if ($cgi->param('action') && $cgi->param('action') eq 'delete') {
	# Deleting cookie's content 
	my $recentSearchesCookie = $cgi->cookie(
	    -name => 'KohaOpacRecentSearches',
	    -value => encode_json([]),
	    -expires => ''
	    );

	# Redirecting to this same url with the cookie in the headers so it's deleted immediately
	my $uri = $cgi->url();
	print $cgi->redirect(-uri => $uri,
			     -cookie => $recentSearchesCookie);

    # Showing search history
    } else {

        my @recentSearches = ParseSearchHistoryCookie($cgi);
	    if (@recentSearches) {

		# As the dates are stored as unix timestamps, let's do some formatting
		foreach my $asearch (@recentSearches) {

		    # We create an iso date from the unix timestamp
		    my $isodate = strftime "%Y-%m-%d", localtime($asearch->{'time'});

		    # So we can create a C4::Dates object, to get the date formatted according to the dateformat syspref
		    my $date = C4::Dates->new($isodate, "iso");
		    my $sysprefdate = $date->output("syspref");
		    
		    # We also get the time of the day from the unix timestamp
		    my $time = strftime " %H:%M:%S", localtime($asearch->{'time'});

		    # And we got our human-readable date : 
		    $asearch->{'time'} = $sysprefdate . $time;
		}

		$template->param(recentSearches => \@recentSearches);
	    }
    }
} else {
# And if the user is logged in, we deal with the database
   
    my $dbh = C4::Context->dbh;

    # Deleting search history
    if ($cgi->param('action') && $cgi->param('action') eq 'delete') {
	my $query = "DELETE FROM search_history WHERE userid = ?";
	my $sth   = $dbh->prepare($query);
	$sth->execute($loggedinuser);

	# Redirecting to this same url so the user won't see the search history link in the header
	my $uri = $cgi->url();
	print $cgi->redirect($uri);


    # Showing search history
    } else {

	my $date = C4::Dates->new();
	my $dateformat = $date->DHTMLcalendar() . " %H:%i:%S"; # Current syspref date format + standard time format

	# Getting the data with date format work done by mysql
    my $query = "SELECT userid, sessionid, query_desc, query_cgi, total, time FROM search_history WHERE userid = ? AND sessionid = ?";
	my $sth   = $dbh->prepare($query);
	$sth->execute($loggedinuser, $cgi->cookie("CGISESSID"));
	my $searches = $sth->fetchall_arrayref({});
	$template->param(recentSearches => $searches);
	
	# Getting searches from previous sessions
	$query = "SELECT COUNT(*) FROM search_history WHERE userid = ? AND sessionid != ?";
	$sth   = $dbh->prepare($query);
	$sth->execute($loggedinuser, $cgi->cookie("CGISESSID"));

	# If at least one search from previous sessions has been performed
        if ($sth->fetchrow_array > 0) {
        $query = "SELECT userid, sessionid, query_desc, query_cgi, total, time FROM search_history WHERE userid = ? AND sessionid != ?";
	    $sth   = $dbh->prepare($query);
	    $sth->execute($loggedinuser, $cgi->cookie("CGISESSID"));
    	    my $previoussearches = $sth->fetchall_arrayref({});
    	    $template->param(previousSearches => $previoussearches);
	
	}

	$sth->finish;


    }

}

$template->param(searchhistoryview => 1);

output_html_with_http_headers $cgi, $cookie, $template->output;


