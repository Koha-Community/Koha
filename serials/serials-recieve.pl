#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
#
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


=head1 NAME

serials-recieve.pl

=head1 Parameters

=over 4

=item op
op can be :
    * modsubscriptionhistory :to modify the subscription history
    * serialchangestatus     :to modify the status of this subscription

=item subscriptionid

=item user

=item histstartdate

=item enddate

=item recievedlist

=item missinglist

=item opacnote

=item librariannote

=item serialid

=item serialseq

=item planneddate

=item notes

=item status

=back

=cut


use strict;
use warnings;
use CGI;
use C4::Auth;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Biblio;
use C4::Items;
use C4::Koha;
use C4::Output;
use C4::Context;
use C4::Serials;
use C4::Branch; # GetBranches

my $query = new CGI;
my $op = $query->param('op') || q{};
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
my @publisheddates = $query->param('publisheddate');
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
            ModSerialStatus($serialids[$i],$serialseqs[$i],format_date_in_iso($planneddates[$i]),format_date_in_iso($publisheddates[$i]),$status[$i],$notes[$i]) unless ($hassubscriptionexpired && $oldstatus == 1);
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
                NewIssue($serialseqs[$i],$subscriptionid,$subscription->{biblionumber},$status[$i] ,format_date_in_iso($publisheddates[$i]),format_date_in_iso($planneddates[$i]));
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
= get_template_and_user({template_name => "serials/serials-recieve.tt",
                query => $query,
                type => "intranet",
                authnotrequired => 0,
                flagsrequired => {serials => 1},
                debug => 1,
                });

my $subs = &GetSubscription($subscriptionid);
my ($totalissues,@serialslist) = GetSerials($subscriptionid);
my $count = @serialslist;
for(my $i=0;$i<$count;$i++){
    #warn "la : $i";
    $serialslist[$i]->{'callnumber'} = $subscription->{'callnumber'};
    my $temp = rand(10000000);
    $serialslist[$i]->{'barcode'} = "TEMP" . sprintf("%.0f",$temp);
}

my $solhistory = GetSubscriptionHistoryFromSubscriptionId($subscriptionid);

$subs = &GetSubscription($subscriptionid);
($totalissues,@serialslist) = GetSerials($subscriptionid);

if (C4::Context->preference("serialsadditems")){
    my $fwk=GetFrameworkCode($subscription->{biblionumber});

    my $branches = GetBranches;
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
    my $itemstatushash = GetItemStatus($fwk);
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
    my $itemlocationhash = GetItemLocation($fwk);
    my @itemlocationloop;
    foreach my $thisitemlocation (keys %$itemlocationhash) {
        my %row =(value => $thisitemlocation,
                    itemlocationname => $itemlocationhash->{$thisitemlocation},
                );
        push @itemlocationloop, \%row;
    }

	my $choice = ($itemstatusloopcount == 1) ? 1 : 0;
	foreach my $data (@serialslist){
		$data->{"itemstatusloop"}   = (scalar(@itemstatusloop  )) ? \@itemstatusloop   : [];
		$data->{"itemlocationloop"} = (scalar(@itemlocationloop)) ? \@itemlocationloop : [];
		$data->{"branchloop"} = \@branchloop ;
	}
# warn "Choice: $choice";
    $template->param(choice => $choice);
    $template->param(serialadditems =>C4::Context->preference("serialsadditems"),
                    branchloop => \@branchloop,
                    ) ;
	$template->param(  itemstatus=>1,  itemstatusloop=>\@itemstatusloop  ) if (scalar(@itemstatusloop  ));
	$template->param(itemlocation=>1,itemlocationloop=>\@itemlocationloop) if (scalar(@itemlocationloop));
} else {
    $template->param(branchloop=>[],itemstatusloop=>[],itemlocationloop=>[]) ;
}

$solhistory = GetSubscriptionHistoryFromSubscriptionId($subscriptionid);

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
            routing => $routing,
            missingseq => $manualissue,
            frommissing => $manualstatus,
            missingdate => $manualdate,
            missingid => $manualid,
            (uc(C4::Context->preference("marcflavour"))) => 1
        );
output_html_with_http_headers $query, $cookie, $template->output;
