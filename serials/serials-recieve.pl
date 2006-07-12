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
my @publisheddates = $query->param('publisheddate');
my @status = $query->param('status');

my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "serials/statecollection.tmpl",
                query => $query,
                type => "intranet",
                authnotrequired => 0,
                flagsrequired => {catalogue => 1},
                debug => 1,
                });

my $hassubscriptionexpired = HasSubscriptionExpired($subscriptionid);
my $subscription=GetSubscription($subscriptionid);


if ($op eq 'modsubscriptionhistory') {
    ModSubscriptionHistory($subscriptionid,$histstartdate,$enddate,$recievedlist,$missinglist,$opacnote,$librariannote);
}
# change status except, if subscription has expired, for the "waited" issue.
if ($op eq 'modserialstatus') {
    my $sth = GetSerialStatusFromSerialId();
    for (my $i=0;$i<=$#serialids;$i++) {
        $sth->execute($serialids[$i]);

        my ($oldstatus) = $sth->fetchrow;
        if ($serialids[$i]) {
            ModSerialStatus($serialids[$i],$serialseqs[$i],format_date_in_iso($publisheddates[$i]),($planneddates[$i]?format_date_in_iso($planneddates[$i]):format_date_in_iso(localtime(time()))),$status[$i],$notes[$i]) unless ($hassubscriptionexpired && $oldstatus == 1);
            if (($status[$i]==2) && C4::Context->preference("serialsadditems")){
                my %info;
                $info{branch}=$homebranches[$i];
#               $info{barcode}=$barcodes[$i];
                $info{itemcallnumber}=$itemcallnumbers[$i];
                $info{location}=$locations[$i];
                $info{status}=$itemstatus[$i];
                $info{notes}=$serialseqs[$i];
                my ($status, @errors)= ItemizeSerials($serialids[$i],\%info);
            }
        } else {
            # add a special issue
            if ($serialseqs[$i]) {
                my $subscription=GetSubscription($subscriptionid);
                NewIssue($serialseqs[$i],$subscriptionid,$subscription->{biblionumber},$status[$i], format_date_in_iso($planneddates[$i]));
            }
            if (($status[$i]==2) && C4::Context->preference("serialsadditems") && !HasSubscriptionExpired($subscriptionid)){
                my %info;
                $info{branch}=$homebranches[$i];
#                 $info{barcode}=$barcodes[$i];
                $info{itemcallnumber}=$itemcallnumbers[$i];
                $info{location}=$locations[$i];
                $info{status}=$itemstatus[$i];
                $info{notes}=$serialseqs[$i];
                my ($status, @errors)= ItemizeSerials($serialids[$i],\%info);
            }
        }
    }
}
my $subs = &GetSubscription($subscriptionid);
my ($totalissues,@serialslist) = GetSerials($subscriptionid,10);

my $sth= GetSubscriptionHistoryFromSubscriptionId();

$sth->execute($subscriptionid);
my $solhistory = $sth->fetchrow_hashref;

my $subs = &GetSubscription($subscriptionid);
my ($totalissues,@serialslist) = GetSerials($subscriptionid);

if (C4::Context->preference("serialsadditems")){
    my $bibid=MARCfind_MARCbibid_from_oldbiblionumber($dbh,$subscription->{biblionumber});
    my $fwk=MARCfind_frameworkcode($dbh,$bibid);

    my $branches = getbranches;
    my @branchloop;
    foreach my $thisbranch (keys %$branches) {
        my %row =(value => $thisbranch,
                    branchname => $branches->{$thisbranch}->{'branchname'},
                );
        push @branchloop, \%row;
    }
    
    my $itemstatushash = getitemstatus($fwk);
    my @itemstatusloop;
    foreach my $thisitemstatus (keys %$itemstatushash) {
        my %row =(itemval => $thisitemstatus,
                    itemlib => $itemstatushash->{$thisitemstatus},
                );
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
    foreach my $data (@serialslist){
        if (scalar(@itemstatusloop)){$data->{"itemstatusloop"}=\@itemstatusloop;}
        else { $data->{"itemstatusloop"}=[];}
        if (scalar(@itemlocationloop)){$data->{"itemlocationloop"}=\@itemlocationloop;}
        else {$data->{"itemlocationloop"}=[];}
        $data->{"branchloop"}=\@branchloop ;
    }
    $template->param(serialadditems =>C4::Context->preference("serialsadditems"),
                    branchloop => \@branchloop,
                    ) ;
    $template->param(itemstatus=>1,itemstatusloop=>\@itemstatusloop) if (scalar(@itemstatusloop));
    $template->param(itemlocation=>1,itemlocationloop=>\@itemlocationloop) if (scalar(@itemlocationloop));
}else{
    $template->param(branchloop=>[],itemstatusloop=>[],itemlocationloop=>[]) ;
}

my $sth= GetSubscriptionHistoryFromSubscriptionId();
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
            hassubscriptionexpired =>$hassubscriptionexpired,
            intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
            intranetstylesheet => C4::Context->preference("intranetstylesheet"),
            IntranetNav => C4::Context->preference("IntranetNav"),
        );
output_html_with_http_headers $query, $cookie, $template->output;
