#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

# $Id$

=head1 NAME

serials-receive.pl

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

=item receivedlist

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
use CGI;
use C4::Auth;
use C4::Date;
use C4::Biblio;
use C4::Koha;
use C4::Interface::CGI::Output;
use C4::Context;
use C4::Serials;

my $query = new CGI;
my $op = $query->param('op');
my $dbh = C4::Context->dbh;
my $subscriptionid = $query->param('subscriptionid');
my $histstartdate = format_date_in_iso($query->param('histstartdate'));
my $enddate = format_date_in_iso($query->param('enddate'));
my $receivedlist = $query->param('receivedlist');
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
my @holdingbranches = $query->param('holdingbranch');
my $hassubscriptionexpired = HasSubscriptionExpired($subscriptionid);
my $abouttoexpire = abouttoexpire($subscriptionid);
my @itemnumbers=$query->param('itemnumber');
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
	ModSubscriptionHistory($subscriptionid,$histstartdate,$enddate,$receivedlist,$missinglist,$opacnote,$librariannote);
}

# change status except, if subscription has expired, for the "waited" issue.
if ($op eq 'serialchangestatus') {
	my $sth = $dbh->prepare("select status from serial where serialid=?");
	for (my $i=0;$i<=$#serialids;$i++) {
		$sth->execute($serialids[$i]);
		
		my ($oldstatus) = $sth->fetchrow;
		if ($serialids[$i]) {

	 my $planneddate = ($planneddates[$i]?format_date_in_iso($planneddates[$i]):format_date_in_iso("today")) if ($status[$i]==2);
			ModSerialStatus($serialids[$i],$serialseqs[$i],format_date_in_iso($publisheddates[$i]),format_date_in_iso($planneddates[$i]),$status[$i],$notes[$i],$itemnumbers[$i]) unless ($hassubscriptionexpired && $oldstatus ==1 );
			if (($status[$i]==2) && $itemnumbers[$i]){
				my %info;
				my $status2;
			        my $sth2 = $dbh->prepare("UPDATE subscriptionhistory SET lastbranch = ? WHERE subscriptionid = ?");
			        $sth2->execute($holdingbranches[$i],$subscriptionid);
			        $sth2->finish;			    
			        # remove from missing list if item being checked in is on it
				    removeMissingIssue($serialseqs[$i],$subscriptionid);
			}
		} else {
			# add a special issue
			if ($serialseqs[$i]) {
				NewIssue($serialseqs[$i],$subscriptionid,$subscription->{biblionumber},$status[$i],format_date_in_iso($publisheddates[$i]), format_date_in_iso($planneddates[$i]),$itemnumbers[$i]);
			}
			if (($status[$i]==2) &&  $itemnumbers[$i] && !$hassubscriptionexpired){
				my %info;
				my $status2;
			        my $sth2 = $dbh->prepare("UPDATE subscriptionhistory SET lastbranch = ? WHERE subscriptionid = ?");
			        $sth2->execute($holdingbranches[$i],$subscriptionid);
			        $sth2->finish;
			        # remove from missing list if item being checked in is on it
#			        if ($status2 ==1){
				    removeMissingIssue($serialseqs[$i],$subscriptionid);
#			        }
			}

		}
	}

}
my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "serials/serials-receive.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});

my $subs = &GetSubscription($subscriptionid);
my ($totalissues,@serialslist) = GetSerials($subscriptionid);
my $count = @serialslist;
for(my $i=0;$i<$count;$i++){
    $serialslist[$i]->{'callnumber'} = $subscription->{'callnumber'};
    my $temp = rand(10000000);
    $serialslist[$i]->{'barcode'} = "TEMP" . sprintf("%.0f",$temp);
}
# use Data::Dumper;
# warn Dumper(@serialslist);

my $sth= C4::Serials::GetSubscriptionHistoryFromSubscriptionId();

$sth->execute($subscriptionid);
my $solhistory = $sth->fetchrow_hashref;

my $subs = &GetSubscription($subscriptionid);
my ($totalissues,@serialslist) = GetSerials($subscriptionid);

if (C4::Context->preference("serialsadditems")){
    $template->param(scriptaddserials=>"/cgi-bin/koha/cataloguing/additem.pl?biblionumber=  $serialslist[0]->{'biblionumber'}&fromserials=1&serialid=",
				serialsadditems=>1	) ;
}

my $sth= C4::Serials::GetSubscriptionHistoryFromSubscriptionId();
$sth->execute($subscriptionid);
my $solhistory = $sth->fetchrow_hashref;

    
$template->param(
                        user => $auser,
			serialslist => \@serialslist,
                        count => $count,
			biblionumber => $subscription->{biblionumber},
			histstartdate => format_date($solhistory->{'histstartdate'}),
			enddate => format_date($solhistory->{'enddate'}),
			receivedlist => $solhistory->{'receivedlist'},
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
