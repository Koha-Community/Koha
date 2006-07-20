#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Date;
use C4::Biblio;
use C4::Koha;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;
use C4::Serials;
use HTML::Template;

my $query = new CGI;
my $op = $query->param('op');
my $dbh = C4::Context->dbh;
my $subscriptionid = $query->param('subscriptionid');
# my $auser = $query->param('user');
my $histstartdate = format_date_in_iso($query->param('histstartdate'));
my $enddate = format_date_in_iso($query->param('enddate'));
my $recievedlist = $query->param('recievedlist');
my $missinglist = $query->param('missinglist');
my $opacnote = $query->param('opacnote');
my $librariannote = $query->param('librariannote');
my @serialids = $query->param('serialid');
my @serialseqs = $query->param('serialseq');
my @planneddates = $query->param('planneddate');
my @status = $query->param('status');
my @notes = $query->param('notes');
my @barcodes = $query->param('barcode');
my @itemcallnumbers = $query->param('itemcallnumber');
my @locations = $query->param('location');
my @itemstatus = $query->param('itemstatus');
my @homebranches = $query->param('branch');
my $hassubscriptionexpired = HasSubscriptionExpired($subscriptionid);
my $abouttoexpire = abouttoexpire($subscriptionid);

my $subscription=GetSubscription($subscriptionid);
my $auser = $subscription->{'librarian'}; # bob
my $routing = check_routing($subscriptionid); # to see if routing list exists
my $manualdate ='';
my $manualissue ='';
my $manualstatus =0;
my $manualid ='';
if ($op eq 'found'){
    $manualdate = $query->param('planneddate');
    $manualissue = $query->param('missingissue');
    $manualstatus = 1;
    my $sth = $dbh->prepare("select serialid from serial where subscriptionid = ? AND serialseq = ? AND planneddate = ?");
    $sth->execute($subscriptionid,$manualissue,format_date_in_iso($manualdate));
    $manualid = $sth->fetchrow;
}

if ($op eq 'modsubscriptionhistory') {
	ModSubscriptionHistory($subscriptionid,$histstartdate,$enddate,$recievedlist,$missinglist,$opacnote,$librariannote);
}

# change status except, if subscription has expired, for the "waited" issue.
if ($op eq 'serialchangestatus') {
	my $sth = $dbh->prepare("select status from serial where serialid=?");
	for (my $i=0;$i<=$#serialids;$i++) {
		$sth->execute($serialids[$i]);
		
		my ($oldstatus) = $sth->fetchrow;
		if ($serialids[$i]) {
			serialchangestatus($serialids[$i],$serialseqs[$i],format_date_in_iso($planneddates[$i]),$status[$i],$notes[$i]) unless ($hassubscriptionexpired && $oldstatus == 1);
			if (($status[$i]==2) && C4::Context->preference("serialsadditems")){
				my %info;
				$info{branch}=$homebranches[$i];
				$info{barcode}=$barcodes[$i];
				$info{itemcallnumber}=$itemcallnumbers[$i];
				$info{location}=$locations[$i];
				$info{status}=$itemstatus[$i];
				$info{notes}=$serialseqs[$i]." (".$planneddates[$i].")";
				my ($status2, @errors)= ItemizeSerials($serialids[$i],\%info);
			        my $sth2 = $dbh->prepare("UPDATE subscriptionhistory SET lastbranch = ? WHERE subscriptionid = ?");
			        $sth2->execute($homebranches[$i],$subscriptionid);
			        $sth2->finish;			    
			        # remove from missing list if item being checked in is on it
			        if ($status2 ==1){
				    removeMissingIssue($serialseqs[$i],$subscriptionid);
			        }			    
			}
		} else {
			# add a special issue
			if ($serialseqs[$i]) {
				NewIssue($serialseqs[$i],$subscriptionid,$subscription->{biblionumber},$status[$i], format_date_in_iso($planneddates[$i]));
			}
			if (($status[$i]==2) && C4::Context->preference("serialsadditems") && !hassubscriptionexpired($subscriptionid)){
				my %info;
				$info{branch}=$homebranches[$i];
				$info{barcode}=$barcodes[$i];
				$info{itemcallnumber}=$itemcallnumbers[$i];
				$info{location}=$locations[$i];
				$info{status}=$itemstatus[$i];
				$info{notes}=$serialseqs[$i]." (".$planneddates[$i].")";
				my ($status2, @errors)= ItemizeSerials($serialids[$i],\%info);
			        my $sth2 = $dbh->prepare("UPDATE subscriptionhistory SET lastbranch = ? WHERE subscriptionid = ?");
			        $sth2->execute($homebranches[$i],$subscriptionid);
			        $sth2->finish;
			        # remove from missing list if item being checked in is on it
			        if ($status2 ==1){
				    removeMissingIssue($serialseqs[$i],$subscriptionid);
			        }
			}

		}
	}
}
my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "serials/statecollection.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});

my $subs = &GetSubscription($subscriptionid);
my ($totalissues,@serialslist) = old_getserials($subscriptionid);
my $count = @serialslist;
for(my $i=0;$i<$count;$i++){
    $serialslist[$i]->{'callnumber'} = $subscription->{'callnumber'};
    my $temp = rand(10000000);
    $serialslist[$i]->{'barcode'} = "TEMP" . sprintf("%.0f",$temp);
}
# use Data::Dumper;
# warn Dumper(@serialslist);

my $sth=$dbh->prepare("select * from subscriptionhistory where subscriptionid = ?");
$sth->execute($subscriptionid);
my $solhistory = $sth->fetchrow_hashref;

if (C4::Context->preference("serialsadditems")){
	my $bibid=MARCfind_MARCbibid_from_oldbiblionumber($dbh,$subscription->{biblionumber});
	my $fwk=MARCfind_frameworkcode($dbh,$bibid);

	my $branches = getbranches;
	my @branchloop;
	foreach my $thisbranch (keys %$branches) {
	    my $selected = 0;
	    if($thisbranch eq $solhistory->{'lastbranch'}){
		$selected = 1;
	    }
		my %row =(value => $thisbranch,
			  branchname => $branches->{$thisbranch}->{'branchname'},
		          selected => $selected,
				);
		push @branchloop, \%row;
	}
	
	my $itemstatushash = getitemstatus($fwk);
	my @itemstatusloop;
        my $itemstatusloopcount=0;    
	foreach my $thisitemstatus (keys %$itemstatushash) {
		my %row =(itemval => $thisitemstatus,
					itemlib => $itemstatushash->{$thisitemstatus},
				);
#		warn "".$row{'itemval'}.", ". $row{"itemlib"};
    	        $itemstatusloopcount++;
		push @itemstatusloop, \%row;
	}
	
	my $itemlocationhash = getitemlocation($fwk);
	my @itemlocationloop;
	foreach my $thisitemlocation (keys %$itemlocationhash) {
		my %row =(value => $thisitemlocation,
					itemlocationname => $itemlocationhash->{$thisitemlocation},
				);
		push @itemlocationloop, \%row;
	}

        my $choice = 0;
        if($itemstatusloopcount == 1){ $choice = 1;}   
        foreach my $data (@serialslist){
	        if (scalar(@itemstatusloop)){$data->{"itemstatusloop"}=\@itemstatusloop;}
	        else { $data->{"itemstatusloop"}=[];}
	        if (scalar(@itemlocationloop)){$data->{"itemlocationloop"}=\@itemlocationloop;}
	        else {$data->{"itemlocationloop"}=[];}
	        $data->{"branchloop"}=\@branchloop ;
	}
# warn "Choice: $choice";
	$template->param(choice => $choice);    
	$template->param(serialadditems =>C4::Context->preference("serialsadditems"),
					branchloop => \@branchloop,
					) ;
	$template->param(itemstatus=>1,itemstatusloop=>\@itemstatusloop) if (scalar(@itemstatusloop));
	$template->param(itemlocation=>1,itemlocationloop=>\@itemlocationloop) if (scalar(@itemlocationloop));
}else{
	$template->param(branchloop=>[],itemstatusloop=>[],itemlocationloop=>[]) ;
}
	

$template->param(
                        user => $auser,
			serialslist => \@serialslist,
                        count => $count,
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
			hassubscriptionexpired =>$hassubscriptionexpired,
			abouttoexpire =>$abouttoexpire,    
			intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
			intranetstylesheet => C4::Context->preference("intranetstylesheet"),
			IntranetNav => C4::Context->preference("IntranetNav"),
                        routing => $routing,
                        missingseq => $manualissue,
                        frommissing => $manualstatus,
                        missingdate => $manualdate,
                        missingid => $manualid,
		);
output_html_with_http_headers $query, $cookie, $template->output;
