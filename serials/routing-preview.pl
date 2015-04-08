#!/usr/bin/perl

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

my @routinglist = getroutinglist($subscriptionid);
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
        my $reserves = GetReservesFromBiblionumber({ biblionumber => $biblio });
        my $count = scalar( @$reserves );
        my $totalcount = $count;
		foreach my $res (@$reserves) {
			if ($res->{'found'} eq 'W') {
				$count--;
			}
		}
		my $const = 'o';
		my $notes;
		my $title = $subs->{'bibliotitle'};
        for my $routing ( @routinglist ) {
            my $sth = $dbh->prepare('SELECT * FROM reserves WHERE biblionumber = ? AND borrowernumber = ? LIMIT 1');
            $sth->execute($biblio,$routing->{borrowernumber});
            my $reserve = $sth->fetchrow_hashref;

            if($routing->{borrowernumber} == $reserve->{borrowernumber}){
                ModReserve({
                    rank           => $routing->{ranking},
                    biblionumber   => $biblio,
                    borrowernumber => $routing->{borrowernumber},
                    branchcode     => $branch
                });
            } else {
                AddReserve($branch,$routing->{borrowernumber},$biblio,$const,\@bibitems,$routing->{ranking}, undef, undef, $notes,$title);
        }
    }
	}

    ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "serials/routing-preview-slip.tt",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {serials => '*'},
				debug => 1,
				});
    $template->param("libraryname"=>$branchname);
} else {
    ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "serials/routing-preview.tt",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {serials => '*'},
				debug => 1,
				});
}

my $memberloop = [];
for my $routing (@routinglist) {
    my $member = GetMember( borrowernumber => $routing->{borrowernumber} );
    $member->{name}           = "$member->{firstname} $member->{surname}";
    push @{$memberloop}, $member;
}

my $routingnotes = $serials[0]->{'routingnotes'};
$routingnotes =~ s/\n/\<br \/\>/g;

$template->param(
    title => $subs->{'bibliotitle'},
    issue => $issue,
    issue_escaped => URI::Escape::uri_escape($issue),
    subscriptionid => $subscriptionid,
    memberloop => $memberloop,
    routingnotes => $routingnotes,
    generalroutingnote => C4::Context->preference('RoutingListNote'),
    hasRouting => check_routing($subscriptionid),
    (uc(C4::Context->preference("marcflavour"))) => 1
    );

output_html_with_http_headers $query, $cookie, $template->output;
