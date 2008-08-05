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
use Date::Calc qw(Today Day_of_Year Week_of_Year Add_Delta_Days);
use C4::Koha;
use C4::Biblio;
use C4::Auth;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Acquisition;
use C4::Output;
use C4::Context;
use C4::Branch; # GetBranches
use C4::Serials;
use C4::Letters;

#use Smart::Comments;

my $query = new CGI;
my $op = $query->param('op');
my $dbh = C4::Context->dbh;
my ($subscriptionid,$auser,$branchcode,$librarian,$cost,$aqbooksellerid, $aqbooksellername,$aqbudgetid, $bookfundid, $startdate, $periodicity,
	$firstacquidate, $dow, $irregularity, $numberpattern, $numberlength, $weeklength, $monthlength, $sublength,
	$add1,$every1,$whenmorethan1,$setto1,$lastvalue1,$innerloop1,
	$add2,$every2,$whenmorethan2,$setto2,$lastvalue2,$innerloop2,
	$add3,$every3,$whenmorethan3,$setto3,$lastvalue3,$innerloop3,
	$numberingmethod, $status, $biblionumber, 
	$bibliotitle, $callnumber, $notes, $hemisphere, $letter, $manualhistory,$serialsadditems);

	my @budgets;
my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "serials/subscription-add.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {serials => 1},
				debug => 1,
				});



my $sub_on;
my @subscription_types = (
            'issues', 'weeks', 'months'
        ); 
my @sub_type_data;

my $letters = GetLetters('serial');
my @letterloop;
foreach my $thisletter (keys %$letters) {
    my $selected = 1 if $thisletter eq $letter;
    my %row =(value => $thisletter,
                selected => $selected,
                lettername => $letters->{$thisletter},
            );
    push @letterloop, \%row;
}
$template->param(letterloop => \@letterloop);

my $onlymine=C4::Context->preference('IndependantBranches') && 
             C4::Context->userenv && 
             C4::Context->userenv->{flags}!=1 && 
             C4::Context->userenv->{branch};
my $branches = GetBranches($onlymine);
my @branchloop;
for my $thisbranch (sort { $branches->{$a}->{branchname} cmp $branches->{$b}->{branchname} } keys %$branches) {
    my $selected = 1 if $thisbranch eq C4::Context->userenv->{'branch'};
    my %row =(value => $thisbranch,
                selected => $selected,
                branchname => $branches->{$thisbranch}->{'branchname'},
            );
    push @branchloop, \%row;
}
$template->param(branchloop => \@branchloop,
    DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
);
my $subscriptionid;
my $subs;
my $firstissuedate;
my $nextexpected;

if ($op eq 'mod' || $op eq 'dup' || $op eq 'modsubscription') {

    $subscriptionid = $query->param('subscriptionid');
    $subs = &GetSubscription($subscriptionid);
## FIXME : Check rights to edit if mod. Could/Should display an error message.
    if ($subs->{'cannotedit'} && $op eq 'mod'){
      warn "Attempt to modify subscription $subscriptionid by ".C4::Context->userenv->{'id'}." not allowed";
      print $query->redirect("/cgi-bin/koha/serials/subscription-detail.pl?subscriptionid=$subscriptionid");
    } 
    $firstissuedate = $subs->{firstacquidate};  # in iso format.
    for (qw(startdate firstacquidate histstartdate enddate histenddate)) {
	# TODO : Handle date formats properly.
         if ($subs->{$_} eq '0000-00-00') {
            $subs->{$_} = ''
    	} else {
            $subs->{$_} = format_date($subs->{$_});  
        }
	}
    $subs->{'letter'}='' unless($subs->{'letter'});
    $irregularity   = $subs->{'irregularity'};
    $numberpattern  = $subs->{'numberpattern'};
    $nextexpected = GetNextExpected($subscriptionid);
    $nextexpected->{'isfirstissue'} = $nextexpected->{planneddate}->output('iso') eq $firstissuedate ;
    $subs->{nextacquidate} = $nextexpected->{planneddate}->output()  if($op eq 'mod');
  unless($op eq 'modsubscription') {
    if($subs->{numberlength} > 0){
        $sublength = $subs->{numberlength};
        $sub_on = $subscription_types[0];
    } elsif ($subs->{weeklength}>0){
        $sublength = $subs->{weeklength};
        $sub_on = $subscription_types[1];
    } else {
        $sublength = $subs->{monthlength};
        $sub_on = $subscription_types[2];
    }
    while (@subscription_types) {
        my $sub_type = shift @subscription_types;
        my %row = ( 'name' => $sub_type );
        if ( $sub_on eq $sub_type ) {
            $row{'selected'} = ' selected';
        } else {
            $row{'selected'} = '';
        }
        push( @sub_type_data, \%row );
    }

    $template->param($subs);
    $template->param(
                $op => 1,
                subtype => \@sub_type_data,
                sublength =>$sublength,
                history => ($op eq 'mod' && ($subs->{recievedlist}||$subs->{missinglist}||$subs->{opacnote}||$subs->{librariannote})),
                "periodicity".$subs->{'periodicity'} => 1,
                "dow".$subs->{'dow'} => 1,
                "numberpattern".$subs->{'numberpattern'} => 1,
                firstacquiyear => substr($firstissuedate,0,4),
                );
  }
}

my $count = 0;
# prepare template variables common to all $op conditions:
$template->param(  'dateformat_' . C4::Context->preference('dateformat') => 1 ,
                );

if ($op eq 'addsubscription') {
    my $auser = $query->param('user');
    my $branchcode = $query->param('branchcode');
    my $aqbooksellerid = $query->param('aqbooksellerid');
    my $cost = $query->param('cost');
    my $aqbudgetid = $query->param('aqbudgetid'); 
    my $startdate = $query->param('startdate');
    my $firstacquidate = $query->param('firstacquidate');    
    my $periodicity = $query->param('periodicity');
    my $dow = $query->param('dow');
    my @irregularity = $query->param('irregularity_select');
    my $numberlength = 0;
    my $weeklength = 0;
    my $monthlength = 0;
    my $numberpattern = $query->param('numbering_pattern');
    my $sublength = $query->param('sublength');
    my $subtype = $query->param('subtype');
    if ($subtype eq 'months'){
        $monthlength = $sublength;
    } elsif ($subtype eq 'weeks'){
        $weeklength = $sublength;
    } else {
        $numberlength = $sublength;
    }
    my $add1 = $query->param('add1');
    my $every1 = $query->param('every1');
    my $whenmorethan1 = $query->param('whenmorethan1');
    my $setto1 = $query->param('setto1');
    my $lastvalue1 = $query->param('lastvalue1');
    my $innerloop1 =$query->param('innerloop1');
    my $add2 = $query->param('add2');
    my $every2 = $query->param('every2');
    my $whenmorethan2 = $query->param('whenmorethan2');
    my $setto2 = $query->param('setto2');
    my $innerloop2 =$query->param('innerloop2');
    my $lastvalue2 = $query->param('lastvalue2');
    my $add3 = $query->param('add3');
    my $every3 = $query->param('every3');
    my $whenmorethan3 = $query->param('whenmorethan3');
    my $setto3 = $query->param('setto3');
    my $lastvalue3 = $query->param('lastvalue3');
    my $innerloop3 =$query->param('innerloop3');
    my $numberingmethod = $query->param('numberingmethod');
    my $status = 1;
    my $biblionumber = $query->param('biblionumber');
    my $callnumber = $query->param('callnumber');
    my $notes = $query->param('notes');
    my $internalnotes = $query->param('internalnotes');
    my $hemisphere = $query->param('hemisphere') || 1;
	my $letter = $query->param('letter');
    # ## BugFIX : hdl doesnot know what innerloops or letter stand for but it seems necessary. So he adds them.
    my $manualhistory = $query->param('manualhist');
    my $serialsadditems = $query->param('serialsadditems');
	my $subscriptionid = NewSubscription($auser,$branchcode,$aqbooksellerid,$cost,$aqbudgetid,$biblionumber,
					$startdate,$periodicity,$dow,$numberlength,$weeklength,$monthlength,
					$add1,$every1,$whenmorethan1,$setto1,$lastvalue1,$innerloop1,
					$add2,$every2,$whenmorethan2,$setto2,$lastvalue2,$innerloop2,
					$add3,$every3,$whenmorethan3,$setto3,$lastvalue3,$innerloop3,
					$numberingmethod, $status, $notes,$letter,$firstacquidate,join(",",@irregularity),
                    $numberpattern, $callnumber, $hemisphere,($manualhistory?$manualhistory:0),$internalnotes,
                    $serialsadditems,
				);

    print $query->redirect("/cgi-bin/koha/serials/subscription-detail.pl?subscriptionid=$subscriptionid");
} elsif ($op eq 'modsubscription') {
    my $subscriptionid = $query->param('subscriptionid');
	my @irregularity = $query->param('irregularity_select');
    my $auser = $query->param('user');
    my $librarian => $query->param('librarian'),
    my $branchcode = $query->param('branchcode');
    my $cost = $query->param('cost');
    my $aqbooksellerid = $query->param('aqbooksellerid');
    my $biblionumber = $query->param('biblionumber');
    my $aqbudgetid = $query->param('aqbudgetid');
    my $startdate = format_date_in_iso($query->param('startdate'));
    my $nextacquidate = format_date_in_iso($query->param('nextacquidate'));    
    my $periodicity = $query->param('periodicity');
    my $dow = $query->param('dow');
    my $sublength = $query->param('sublength');
    my $subtype = $query->param('subtype');

    if($subtype eq 'months'){
        $monthlength = $sublength;
    } elsif ($subtype eq 'weeks'){
        $weeklength = $sublength;
    } else {
        $numberlength = $sublength;
    }
    my $numberpattern = $query->param('numbering_pattern');
    my $add1 = $query->param('add1');
    my $every1 = $query->param('every1');
    my $whenmorethan1 = $query->param('whenmorethan1');
    my $setto1 = $query->param('setto1');
    my $lastvalue1 = $query->param('lastvalue1');
    my $innerloop1 = $query->param('innerloop1');
    my $add2 = $query->param('add2');
    my $every2 = $query->param('every2');
    my $whenmorethan2 = $query->param('whenmorethan2');
    my $setto2 = $query->param('setto2');
    my $lastvalue2 = $query->param('lastvalue2');
    my $innerloop2 = $query->param('innerloop2');
    my $add3 = $query->param('add3');
    my $every3 = $query->param('every3');
    my $whenmorethan3 = $query->param('whenmorethan3');
    my $setto3 = $query->param('setto3');
    my $lastvalue3 = $query->param('lastvalue3');
    my $innerloop3 = $query->param('innerloop3');
    my $numberingmethod = $query->param('numberingmethod');
    my $status = 1;
    my $callnumber = $query->param('callnumber');
    my $notes = $query->param('notes');
    my $internalnotes = $query->param('internalnotes');
    my $hemisphere = $query->param('hemisphere');
    my $letter = $query->param('letter');
    my $manualhistory = $query->param('manualhist');
    my $enddate = $query->param('enddate');
    my $serialsadditems = $query->param('serialsadditems');
    # subscription history
    my $histenddate = format_date_in_iso($query->param('histenddate'));
    my $histstartdate = format_date_in_iso($query->param('histstartdate'));
    my $recievedlist = $query->param('recievedlist');
    my $missinglist = $query->param('missinglist');
    my $opacnote = $query->param('opacnote');
    my $librariannote = $query->param('librariannote');
    my $history_only = $query->param('history_only');
	#  If it's  a mod, we need to check the current 'expected' issue, and mod it in the serials table if necessary.
    if ( $nextacquidate ne $nextexpected->{planneddate}->output('iso') ) {
        ModNextExpected($subscriptionid,C4::Dates->new($nextacquidate,'iso'));
        # if we have not received any issues yet, then we also must change the firstacquidate for the subs.
        $firstissuedate = $nextacquidate if($nextexpected->{isfirstissue});
    }
    
    if ($history_only) {
        ModSubscriptionHistory ($subscriptionid,$histstartdate,$histenddate,$recievedlist,$missinglist,$opacnote,$librariannote);
    } else {
        &ModSubscription(
            $auser,           $branchcode,   $aqbooksellerid, $cost,
            $aqbudgetid,      $startdate,    $periodicity,    $firstissuedate,
            $dow,             join(",",@irregularity), $numberpattern,  $numberlength,
            $weeklength,      $monthlength,  $add1,           $every1,
            $whenmorethan1,   $setto1,       $lastvalue1,     $innerloop1,
            $add2,            $every2,       $whenmorethan2,  $setto2,
            $lastvalue2,      $innerloop2,   $add3,           $every3,
            $whenmorethan3,   $setto3,       $lastvalue3,     $innerloop3,
            $numberingmethod, $status,       $biblionumber,   $callnumber,
            $notes,           $letter,       $hemisphere,     $manualhistory,$internalnotes,
            $serialsadditems, $subscriptionid,
        );
    }
    print $query->redirect("/cgi-bin/koha/serials/subscription-detail.pl?subscriptionid=$subscriptionid");
} else {

        while (@subscription_types) {
           my $sub_type = shift @subscription_types;
           my %row = ( 'name' => $sub_type );
           if ( $sub_on eq $sub_type ) {
	     $row{'selected'} = ' selected';
           } else {
	     $row{'selected'} = '';
           }
           push( @sub_type_data, \%row );
        }    
    $template->param(subtype => \@sub_type_data,
	);
	output_html_with_http_headers $query, $cookie, $template->output;
}
