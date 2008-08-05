#!/usr/bin/perl

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

use strict;
use CGI;
use C4::Auth;
use C4::Koha;
use C4::Dates qw/format_date/;
use C4::Serials;
use C4::Output;
use C4::Context;
use Date::Calc qw/Today Day_of_Year Week_of_Year Add_Delta_Days/;
#use Date::Manip;

my $query = new CGI;
my $op = $query->param('op');
my $dbh = C4::Context->dbh;
my $sth;
# my $id;
my ($template, $loggedinuser, $cookie, $hemisphere);
my $subscriptionid = $query->param('subscriptionid');
my $subs = &GetSubscription($subscriptionid);

$subs->{enddate} = GetExpirationDate($subscriptionid);

if ($op eq 'del') {
	if ($subs->{'cannotedit'}){
		warn "Attempt to delete subscription $subscriptionid by ".C4::Context->userenv->{'id'}." not allowed";
		print $query->redirect("/cgi-bin/koha/serials/subscription-detail.pl?subscriptionid=$subscriptionid");
	}  
	&DelSubscription($subscriptionid);
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=serials-home.pl\"></html>";
	exit;
}
my ($routing, @routinglist) = getroutinglist($subscriptionid);
my ($totalissues,@serialslist) = GetSerials($subscriptionid);
$totalissues-- if $totalissues; # the -1 is to have 0 if this is a new subscription (only 1 issue)
# the subscription must be deletable if there is NO issues for a reason or another (should not happend, but...)

($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "serials/subscription-detail.tmpl",
                query => $query,
                type => "intranet",
                authnotrequired => 0,
                flagsrequired => {serials => 1},
                debug => 1,
                });

my ($user, $sessionID, $flags);
($user, $cookie, $sessionID, $flags)
    = checkauth($query, 0, {catalogue => 1}, "intranet");

# COMMENT hdl : IMHO, we should think about passing more and more data hash to template->param rather than duplicating code a new coding Guideline ?

$subs->{startdate}      = format_date($subs->{startdate});
$subs->{firstacquidate} = format_date($subs->{firstacquidate});
$subs->{histstartdate}  = format_date($subs->{histstartdate});
$subs->{enddate}        = format_date($subs->{enddate});
$subs->{histenddate}    = format_date($subs->{histenddate});
$subs->{abouttoexpire}  = abouttoexpire($subs->{subscriptionid});
# Done in Serials.pm
# $subs->{'donotedit'}=(C4::Context->preference('IndependantBranches') && 
#         C4::Context->userenv && 
#         C4::Context->userenv->{flags} !=1  && 
#         C4::Context->userenv->{branch} && $subs->{branchcode} &&
#         (C4::Context->userenv->{branch} ne $subs->{branchcode}));

$template->param($subs);

$template->param(
	subscriptionid => $subscriptionid,
    routing => $routing,
    serialslist => \@serialslist,
    totalissues => $totalissues,
    hemisphere => $hemisphere,
    cannotedit =>(C4::Context->preference('IndependantBranches') && 
                C4::Context->userenv && 
                C4::Context->userenv->{flags} !=1  && 
                C4::Context->userenv->{branch} && $subs->{branchcode} &&
                (C4::Context->userenv->{branch} ne $subs->{branchcode})),
    "periodicity".($subs->{periodicity}?$subs->{periodicity}:'0') => 1,
    "arrival".$subs->{dow} => 1,
    "numberpattern".$subs->{numberpattern} => 1,
    intranetstylesheet => C4::Context->preference("intranetstylesheet"),
    intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"), 
    irregular_issues => scalar(split(/,/,$subs->{irregularity})),
    );

output_html_with_http_headers $query, $cookie, $template->output;
