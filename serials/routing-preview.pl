#!/usr/bin/perl

# Routing Preview.pl script used to view a routing list after creation
# lets one print out routing slip and create (in this instance) the heirarchy
# of reserves for the serial
use strict;
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
my ($count,@serials) = GetSerials($subscriptionid);
my ($template, $loggedinuser, $cookie);

if($ok){
    # get biblio information....
    my $biblio = $subs->{'biblionumber'};
    
    # get existing reserves .....
    my ($count,$reserves) = GetReservesFromBiblionumber($biblio);
    my $totalcount = $count;
    foreach my $res (@$reserves) {
        if ($res->{'found'} eq 'W') {
	    $count--;
        }
    }
    my ($count2,@bibitems) = GetBiblioItemByBiblioNumber($biblio);
    my @itemresults = GetItemsInfo($subs->{'biblionumber'}, 'intra');
    my $branch = $itemresults[0]->{'holdingbranch'};
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
        AddReserve($branch,$routinglist[$i]->{'borrowernumber'},$biblio,$const,\@bibitems,$routinglist[$i]->{'ranking'},$notes,$title);
	}
    }
    
    
    ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "serials/routing-preview-slip.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {serials => 1},
				debug => 1,
				});
    $template->param("libraryname"=>C4::Context->preference("LibraryName"));
} else {
    ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "serials/routing-preview.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {serials => 1},
				debug => 1,
				});
}    

# my $firstdate = "$serials[0]->{'serialseq'} ($serials[0]->{'planneddate'})";
my @results;
my $data;
for(my $i=0;$i<$routing;$i++){
    $data=GetMember($routinglist[$i]->{'borrowernumber'},'borrowernumber');
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
    subscriptionid => $subscriptionid,
    memberloop => \@results,    
    routingnotes => $routingnotes,
    );

        output_html_with_http_headers $query, $cookie, $template->output;
