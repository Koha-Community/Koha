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
use C4::Dates;
use C4::Output;
use C4::Context;
use C4::Serials;

my $query = new CGI;
my $op = $query->param('op');
my $dbh = C4::Context->dbh;
my $subscriptionid = $query->param('subscriptionid');
my $auser = $query->param('user');
my $histstartdate = format_date_in_iso($query->param('histstartdate'));
my $enddate = format_date_in_iso($query->param('enddate'));
my $recievedlist = $query->param('recievedlist');
my $missinglist = $query->param('missinglist');
my $opacnote = $query->param('opacnote');
my $librariannote = $query->param('librariannote');
my @serialids = $query->param('serialid');
my @serialseqs = $query->param('serialseq');
my @planneddates = $query->param('planneddate');
my @notes = $query->param('notes');
my @status = $query->param('status');

my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "serials/statecollection.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {serials => 1},
				debug => 1,
				});

my $HasSubscriptionExpired = HasSubscriptionExpired($subscriptionid);
my $subscription=GetSubscription($subscriptionid);
if ($op eq 'modsubscriptionhistory') {
	modsubscriptionhistory($subscriptionid,$histstartdate,$enddate,$recievedlist,$missinglist,$opacnote,$librariannote);
}
# change status except, if subscription has expired, for the "waited" issue.
if ($op eq 'serialchangestatus') {
	my $sth = $dbh->prepare("select status from serial where serialid=?");
	for (my $i=0;$i<=$#serialids;$i++) {
		$sth->execute($serialids[$i]);
		my ($oldstatus) = $sth->fetchrow;
		if ($serialids[$i]) {
			serialchangestatus($serialids[$i],$serialseqs[$i],format_date_in_iso($planneddates[$i]),$status[$i],$notes[$i]) unless ($HasSubscriptionExpired && $oldstatus == 1);
		} else {
			# add a special issue
			if ($serialseqs[$i]) {
				my $subscription=getsubscription($subscriptionid);
				newissue($serialseqs[$i],$subscriptionid,$subscription->{biblionumber},$status[$i], format_date_in_iso($planneddates[$i]));
			}
		}
	}
}
my $subs = &GetSubscription($subscriptionid);
my ($totalissues,@serialslist) = GetSerials($subscriptionid,10);

my $sth=$dbh->prepare("select * from subscriptionhistory where subscriptionid = ?");
$sth->execute($subscriptionid);
my $solhistory = $sth->fetchrow_hashref;

	$template->param(
			serialslist => \@serialslist,
			biblionumber => $subscription->{biblionumber},
			histstartdate => format_date($solhistory->{'histstartdate'}),
			enddate => format_date($solhistory->{'enddate'}),
			recievedlist => $solhistory->{'recievedlist'},
			missinglist => $solhistory->{'missinglist'},
			opacnote => $solhistory->{'opacnote'},
			librariannote => $solhistory->{'librariannote'},
			subscriptionid => $subscriptionid,
			bibliotitle => $subs->{bibliotitle},
			biblionumber => $subs->{biblionumber},
			hassubscriptionexpired =>$HasSubscriptionExpired,
		);
output_html_with_http_headers $query, $cookie, $template->output;
