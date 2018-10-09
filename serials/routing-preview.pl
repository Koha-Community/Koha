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
use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Koha;
use C4::Auth;
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

use Koha::Biblios;
use Koha::Libraries;
use Koha::Patrons;

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

my $library;
if($ok){
    # get biblio information....
    my $biblionumber = $subs->{'bibnum'};
    my @itemresults = GetItemsInfo( $biblionumber );
    my $branch = @itemresults ? $itemresults[0]->{'holdingbranch'} : $subs->{branchcode};
    $library = Koha::Libraries->find($branch);

	if (C4::Context->preference('RoutingListAddReserves')){
		# get existing reserves .....

        my $biblio = Koha::Biblios->find( $biblionumber );
        my $holds = $biblio->current_holds;
        my $count = $holds->count;
        while ( my $hold = $holds->next ) {
            $count-- if $hold->is_waiting;
        }
		my $notes;
		my $title = $subs->{'bibliotitle'};
        for my $routing ( @routinglist ) {
            my $sth = $dbh->prepare('SELECT * FROM reserves WHERE biblionumber = ? AND borrowernumber = ? LIMIT 1');
            $sth->execute($biblionumber,$routing->{borrowernumber});
            my $reserve = $sth->fetchrow_hashref;

            if($routing->{borrowernumber} == $reserve->{borrowernumber}){
                ModReserve({
                    rank           => $routing->{ranking},
                    biblionumber   => $biblionumber,
                    borrowernumber => $routing->{borrowernumber},
                    branchcode     => $branch
                });
            } else {
                AddReserve($branch,$routing->{borrowernumber},$biblionumber,undef,$routing->{ranking}, undef, undef, $notes,$title);
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

$template->param( libraryname => $library->branchname ) if $library;

my $memberloop = [];
for my $routing (@routinglist) {
    my $member = Koha::Patrons->find( $routing->{borrowernumber} )->unblessed;
    $member->{name}           = "$member->{firstname} $member->{surname}";
    push @{$memberloop}, $member;
}

my $routingnotes = $serials[0]->{'routingnotes'};
$routingnotes =~ s/\n/\<br \/\>/g;

$template->param(
    title => $subs->{'bibliotitle'},
    issue => $issue,
    issue_escaped => URI::Escape::uri_escape_utf8($issue),
    subscriptionid => $subscriptionid,
    memberloop => $memberloop,
    routingnotes => $routingnotes,
    hasRouting => check_routing($subscriptionid),
    (uc(C4::Context->preference("marcflavour"))) => 1
    );

output_html_with_http_headers $query, $cookie, $template->output;
