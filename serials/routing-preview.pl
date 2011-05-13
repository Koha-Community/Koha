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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

# Routing Preview.pl script used to view a routing list after creation
# lets one print out routing slip and create (in this instance) the heirarchy
# of reserves for the serial
use strict;
use warnings;
use CGI;
use C4::Koha;
use C4::Auth;
use C4::Dates;
use C4::Output;
use C4::Acquisition;
use C4::Reserves;
use C4::Circulation;
use C4::Context;
use C4::Members;
use C4::Biblio;
use C4::Items;
use C4::Serials;
use URI::Escape;
use C4::Branch;

my $query = new CGI;
my $subscriptionid = $query->param('subscriptionid');
my $issue = $query->param('issue');
my $routingid;
my $ok = $query->param('ok');
my $edit = $query->param('edit');
my $delete = $query->param('delete');
my $dbh = C4::Context->dbh;

if($delete){
    delroutingmember($routingid,$subscriptionid);
    my $sth = $dbh->prepare("UPDATE serial SET routingnotes = NULL WHERE subscriptionid = ?");
    $sth->execute($subscriptionid);
    print $query->redirect("routing.pl?subscriptionid=$subscriptionid&op=new");
}

if($edit){
    print $query->redirect("routing.pl?subscriptionid=$subscriptionid");
}

my ($routing, @routinglist) = getroutinglist($subscriptionid);
my $subs = GetSubscription($subscriptionid);
my ($tmp ,@serials) = GetSerials($subscriptionid);
my ($template, $loggedinuser, $cookie);

if($ok){
    # get biblio information....
    my $biblio = $subs->{'biblionumber'};
	my ($count2,@bibitems) = GetBiblioItemByBiblioNumber($biblio);
	my @itemresults = GetItemsInfo( $subs->{biblionumber} );
	my $branch = $itemresults[0]->{'holdingbranch'};
	my $branchname = GetBranchName($branch);

	if (C4::Context->preference('RoutingListAddReserves')){
		# get existing reserves .....
		my ($count,$reserves) = GetReservesFromBiblionumber($biblio);
		my $totalcount = $count;
		foreach my $res (@$reserves) {
			if ($res->{'found'} eq 'W') {
				$count--;
			}
		}
		my $const = 'o';
		my $notes;
		my $title = $subs->{'bibliotitle'};
		for(my $i=0;$i<$routing;$i++){
			my $sth = $dbh->prepare("SELECT * FROM reserves WHERE biblionumber = ? AND borrowernumber = ?");
				$sth->execute($biblio,$routinglist[$i]->{'borrowernumber'});
				my $data = $sth->fetchrow_hashref;

		#       warn "$routinglist[$i]->{'borrowernumber'} is the same as $data->{'borrowernumber'}";
			if($routinglist[$i]->{'borrowernumber'} == $data->{'borrowernumber'}){
				ModReserve($routinglist[$i]->{'ranking'},$biblio,$routinglist[$i]->{'borrowernumber'},$branch);
				} else {
				AddReserve($branch,$routinglist[$i]->{'borrowernumber'},$biblio,$const,\@bibitems,$routinglist[$i]->{'ranking'},'',$notes,$title);
			}
    	}
	}

    ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "serials/routing-preview-slip.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {serials => 'routing'},
				debug => 1,
				});
    $template->param("libraryname"=>$branchname);
} else {
    ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "serials/routing-preview.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {serials => 'routing'},
				debug => 1,
				});
}

my @results;
my $data;
for(my $i=0;$i<$routing;$i++){
    $data=GetMember('borrowernumber' => $routinglist[$i]->{'borrowernumber'});
    $data->{'location'}=$data->{'branchcode'};
    $data->{'name'}="$data->{'firstname'} $data->{'surname'}";
    $data->{'routingid'}=$routinglist[$i]->{'routingid'};
    $data->{'subscriptionid'}=$subscriptionid;
    push(@results, $data);
}

my $routingnotes = $serials[0]->{'routingnotes'};
$routingnotes =~ s/\n/\<br \/\>/g;

$template->param(
    title => $subs->{'bibliotitle'},
    issue => $issue,
    issue_escaped => URI::Escape::uri_escape($issue),
    subscriptionid => $subscriptionid,
    memberloop => \@results,
    routingnotes => $routingnotes,
    hasRouting => check_routing($subscriptionid),
    );

output_html_with_http_headers $query, $cookie, $template->output;
