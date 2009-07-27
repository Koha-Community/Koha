#!/usr/bin/perl

# This file is part of Koha
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


=head1 Routing.pl

script used to create a routing list for a serial subscription
In this instance it is in fact a setting up of a list of reserves for the item
where the hierarchical order can be changed on the fly and a routing list can be
printed out

=cut

use strict;
use CGI;
use C4::Koha;
use C4::Auth;
use C4::Dates;
use C4::Output;
use C4::Acquisition;
use C4::Output;
use C4::Context;

use C4::Members;
use C4::Serials;

use URI::Escape;

my $query = new CGI;
my $subscriptionid = $query->param('subscriptionid');
my $serialseq = $query->param('serialseq');
my $routingid = $query->param('routingid');
my $borrowernumber = $query->param('borrowernumber');
my $notes = $query->param('notes');
my $op = $query->param('op');
my $date_selected = $query->param('date_selected');
my $dbh = C4::Context->dbh;

if($op eq 'delete'){
    delroutingmember($routingid,$subscriptionid);
}

if($op eq 'add'){
    addroutingmember($borrowernumber,$subscriptionid);
}
if($op eq 'save'){
    my $sth = $dbh->prepare("UPDATE serial SET routingnotes = ? WHERE subscriptionid = ?");
    $sth->execute($notes,$subscriptionid);
    my $urldate = URI::Escape::uri_escape($date_selected);
    print $query->redirect("routing-preview.pl?subscriptionid=$subscriptionid&issue=$urldate");
}
    
my ($routing, @routinglist) = getroutinglist($subscriptionid);
my $subs = GetSubscription($subscriptionid);
my ($count,@serials) = GetSerials($subscriptionid);
my ($serialdates) = GetLatestSerials($subscriptionid,$count);

my @dates;
my $i=0;
foreach my $dateseq (@$serialdates) {
        $dates[$i]->{'planneddate'} = $dateseq->{'planneddate'};
        $dates[$i]->{'serialseq'} = $dateseq->{'serialseq'};
        $dates[$i]->{'serialid'} = $dateseq->{'serialid'};
        if($date_selected eq $dateseq->{'serialid'}){
            $dates[$i]->{'selected'} = ' selected';
        } else {
            $dates[$i]->{'selected'} = '';
        }
        $i++;
}

my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "serials/routing.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {serials => 1},
				debug => 1,
				});
# my $date;
# if($serialseq){
#    for(my $i = 0;$i<@serials; $i++){
#	if($serials[$i]->{'serialseq'} eq $serialseq){
#	    $date = $serials[$i]->{'planneddate'}
#	}
#    }
# } else {
#    $serialseq = $serials[0]->{'serialseq'};
#    $date = $serials[0]->{'planneddate'};
# }

# my $issue = "$serialseq ($date)";
  
my @results;
my $data;
for(my $i=0;$i<$routing;$i++){
    $data=GetMember($routinglist[$i]->{'borrowernumber'},'borrowernumber');
    $data->{'location'}=$data->{'branchcode'};
    $data->{'name'}="$data->{'firstname'} $data->{'surname'}";
    $data->{'routingid'}=$routinglist[$i]->{'routingid'};
    $data->{'subscriptionid'}=$subscriptionid;
    my $rankingbox = '<select name="itemrank" onchange="reorder_item('.$subscriptionid.','.$routinglist[$i]->{'routingid'}.',this.options[this.selectedIndex].value)">';
    for(my $j=1; $j <= $routing; $j++) {
	$rankingbox .= "<option ";
	if($routinglist[$i]->{'ranking'} == $j){
	    $rankingbox .= " selected=\"selected\"";
	}
	$rankingbox .= " value=\"$j\">$j</option>";
    }
    $rankingbox .= "</select>";
    $data->{'routingbox'} = $rankingbox;
    
    push(@results, $data);
}

# for adding routing list
my $new;
if ($op eq 'new') {
    $new = 1;
} else {
# for modify routing list default
    $new = 0;
}

$template->param(
    title => $subs->{'bibliotitle'},
    subscriptionid => $subscriptionid,
    memberloop => \@results,    
    op => $new,
    dates => \@dates,
    routingnotes => $serials[0]->{'routingnotes'},
    );

        output_html_with_http_headers $query, $cookie, $template->output;
