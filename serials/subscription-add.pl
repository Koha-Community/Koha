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

use strict;
use warnings;

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
use Carp;

#use Smart::Comments;

our $query = CGI->new;
my $op = $query->param('op') || '';
my $dbh = C4::Context->dbh;
my $sub_length;

my @budgets;

# Permission needed if it is a modification : edit_subscription
# Permission needed otherwise (nothing or dup) : create_subscription
my $permission = ($op eq "modify") ? "edit_subscription" : "create_subscription";

my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "serials/subscription-add.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {serials => $permission},
				debug => 1,
				});



my $sub_on;
my @subscription_types = (
            'issues', 'weeks', 'months'
        );
my @sub_type_data;

my $subs;
our $firstissuedate;

if ($op eq 'modify' || $op eq 'dup' || $op eq 'modsubscription') {

    my $subscriptionid = $query->param('subscriptionid');
    $subs = GetSubscription($subscriptionid);
## FIXME : Check rights to edit if mod. Could/Should display an error message.
    if ($subs->{'cannotedit'} && $op eq 'modify'){
      carp "Attempt to modify subscription $subscriptionid by ".C4::Context->userenv->{'id'}." not allowed";
      print $query->redirect("/cgi-bin/koha/serials/subscription-detail.pl?subscriptionid=$subscriptionid");
    }
    $firstissuedate = $subs->{firstacquidate} || '';  # in iso format.
    for (qw(startdate firstacquidate histstartdate enddate histenddate)) {
        next unless defined $subs->{$_};
	# TODO : Handle date formats properly.
         if ($subs->{$_} eq '0000-00-00') {
            $subs->{$_} = ''
    	} else {
            $subs->{$_} = format_date($subs->{$_});
        }
	  }
      if (!defined $subs->{letter}) {
          $subs->{letter}= q{};
      }
    letter_loop($subs->{'letter'}, $template);
    my $nextexpected = GetNextExpected($subscriptionid);
    $nextexpected->{'isfirstissue'} = $nextexpected->{planneddate}->output('iso') eq $firstissuedate ;
    $subs->{nextacquidate} = $nextexpected->{planneddate}->output()  if($op eq 'modify');
    unless($op eq 'modsubscription') {
        foreach my $length_unit (qw(numberlength weeklength monthlength)) {
			if ($subs->{$length_unit}){
				$sub_length=$subs->{$length_unit};
				$sub_on=$length_unit;
				last;
			}
		}

        $template->param( %{$subs} );
        $template->param("dow".$subs->{'dow'} => 1) if defined $subs->{'dow'};
        $template->param(
                    $op => 1,
                    "subtype_$sub_on" => 1,
                    sublength =>$sub_length,
                    history => ($op eq 'modify'),
                    "periodicity".$subs->{'periodicity'} => 1,
                    "numberpattern".$subs->{'numberpattern'} => 1,
                    firstacquiyear => substr($firstissuedate,0,4),
                    );
    }

    if ( $op eq 'dup' ) {
        my $dont_copy_fields = C4::Context->preference('SubscriptionDuplicateDroppedInput');
        my @fields_id = map { fieldid => $_ }, split '\|', $dont_copy_fields;
        $template->param( dont_export_field_loop => \@fields_id );
    }
}

my $onlymine=C4::Context->preference('IndependantBranches') &&
             C4::Context->userenv &&
             C4::Context->userenv->{flags} % 2 !=1 &&
             C4::Context->userenv->{branch};
my $branches = GetBranches($onlymine);
my $branchloop;
for my $thisbranch (sort { $branches->{$a}->{branchname} cmp $branches->{$b}->{branchname} } keys %{$branches}) {
    my $selected = 0;
    $selected = 1 if (defined($subs) && $thisbranch eq $subs->{'branchcode'});
    push @{$branchloop}, {
        value => $thisbranch,
        selected => $selected,
        branchname => $branches->{$thisbranch}->{'branchname'},
    };
}

my $locations_loop = GetAuthorisedValues("LOC",$subs->{'location'});

$template->param(branchloop => $branchloop,
    DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
    locations_loop=>$locations_loop,
);
# prepare template variables common to all $op conditions:
$template->param(  'dateformat_' . C4::Context->preference('dateformat') => 1 );
if ($op!~/^mod/) {
    letter_loop(q{}, $template);
}

if ($op eq 'addsubscription') {
    redirect_add_subscription();
} elsif ($op eq 'modsubscription') {
    redirect_mod_subscription();
} else {
        while (@subscription_types) {
           my $sub_type = shift @subscription_types;
           my %row = ( 'name' => $sub_type );
           if ( defined $sub_on and $sub_on eq $sub_type ) {
	     $row{'selected'} = ' selected';
           } else {
	     $row{'selected'} = '';
           }
           push( @sub_type_data, \%row );
        }
    $template->param(subtype => \@sub_type_data);

    letter_loop( '', $template ) if ($op ne 'modsubscription' && $op ne 'dup' && $op ne 'modify');

    my $new_biblionumber = $query->param('biblionumber_for_new_subscription');
    if (defined $new_biblionumber) {
        my $bib = GetBiblioData($new_biblionumber);
        if (defined $bib) {
            $template->param(bibnum      => $new_biblionumber);
            $template->param(bibliotitle => $bib->{title});
        }
    }
        $template->param((uc(C4::Context->preference("marcflavour"))) => 1);
	output_html_with_http_headers $query, $cookie, $template->output;
}

sub letter_loop {
    my ($selected_letter, $templte) = @_;
    my $letters = GetLetters('serial');
    my $letterloop;
    foreach my $thisletter (keys %{$letters}) {
        push @{$letterloop}, {
            value => $thisletter,
            selected => $thisletter eq $selected_letter,
            lettername => $letters->{$thisletter},
        };
    }
    $templte->param(letterloop => $letterloop);
    return;
}

sub _get_sub_length {
    my ($type, $length) = @_;
    return
        (
            $type eq 'numberlength' ? $length : 0,
            $type eq 'weeklength'   ? $length : 0,
            $type eq 'monthlength'  ? $length : 0,
        );
}

sub redirect_add_subscription {
    my $auser          = $query->param('user');
    my $branchcode     = $query->param('branchcode');
    my $aqbooksellerid = $query->param('aqbooksellerid');
    my $cost           = $query->param('cost');
    my $aqbudgetid     = $query->param('aqbudgetid');
    my $periodicity    = $query->param('periodicity');
    my $dow            = $query->param('dow');
    my @irregularity   = $query->param('irregularity_select');
    my $numberpattern  = $query->param('numbering_pattern');
    my $graceperiod    = $query->param('graceperiod') || 0;

    my ( $numberlength, $weeklength, $monthlength )
        = _get_sub_length( $query->param('subtype'), $query->param('sublength') );
    my $add1              = $query->param('add1');
    my $every1            = $query->param('every1');
    my $whenmorethan1     = $query->param('whenmorethan1');
    my $setto1            = $query->param('setto1');
    my $lastvalue1        = $query->param('lastvalue1');
    my $innerloop1        = $query->param('innerloop1');
    my $add2              = $query->param('add2');
    my $every2            = $query->param('every2');
    my $whenmorethan2     = $query->param('whenmorethan2');
    my $setto2            = $query->param('setto2');
    my $innerloop2        = $query->param('innerloop2');
    my $lastvalue2        = $query->param('lastvalue2');
    my $add3              = $query->param('add3');
    my $every3            = $query->param('every3');
    my $whenmorethan3     = $query->param('whenmorethan3');
    my $setto3            = $query->param('setto3');
    my $lastvalue3        = $query->param('lastvalue3');
    my $innerloop3        = $query->param('innerloop3');
    my $numberingmethod   = $query->param('numberingmethod');
    my $status            = 1;
    my $biblionumber      = $query->param('biblionumber');
    my $callnumber        = $query->param('callnumber');
    my $notes             = $query->param('notes');
    my $internalnotes     = $query->param('internalnotes');
    my $hemisphere        = $query->param('hemisphere') || 1;
    my $letter            = $query->param('letter');
    my $manualhistory     = $query->param('manualhist');
    my $serialsadditems   = $query->param('serialsadditems');
    my $staffdisplaycount = $query->param('staffdisplaycount');
    my $opacdisplaycount  = $query->param('opacdisplaycount');
    my $location          = $query->param('location');
    my $startdate = format_date_in_iso( $query->param('startdate') );
    my $enddate = format_date_in_iso( $query->param('enddate') );
    my $firstacquidate  = format_date_in_iso($query->param('firstacquidate'));
    my $histenddate = format_date_in_iso($query->param('histenddate'));
    my $histstartdate = format_date_in_iso($query->param('histstartdate'));
    my $recievedlist = $query->param('recievedlist');
    my $missinglist = $query->param('missinglist');
    my $opacnote = $query->param('opacnote');
    my $librariannote = $query->param('librariannote');
	my $subscriptionid = NewSubscription($auser,$branchcode,$aqbooksellerid,$cost,$aqbudgetid,$biblionumber,
					$startdate,$periodicity,$dow,$numberlength,$weeklength,$monthlength,
					$add1,$every1,$whenmorethan1,$setto1,$lastvalue1,$innerloop1,
					$add2,$every2,$whenmorethan2,$setto2,$lastvalue2,$innerloop2,
					$add3,$every3,$whenmorethan3,$setto3,$lastvalue3,$innerloop3,
					$numberingmethod, $status, $notes,$letter,$firstacquidate,join(",",@irregularity),
                    $numberpattern, $callnumber, $hemisphere,($manualhistory?$manualhistory:0),$internalnotes,
                    $serialsadditems,$staffdisplaycount,$opacdisplaycount,$graceperiod,$location,$enddate
				);
    ModSubscriptionHistory ($subscriptionid,$histstartdate,$histenddate,$recievedlist,$missinglist,$opacnote,$librariannote);

    print $query->redirect("/cgi-bin/koha/serials/subscription-detail.pl?subscriptionid=$subscriptionid");
    return;
}

sub redirect_mod_subscription {
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
    my $nextacquidate = $query->param('nextacquidate') ?
                            format_date_in_iso($query->param('nextacquidate')):
                            format_date_in_iso($query->param('startdate'));
    my $enddate = format_date_in_iso($query->param('enddate'));
    my $periodicity = $query->param('periodicity');
    my $dow = $query->param('dow');

    my ($numberlength, $weeklength, $monthlength)
        = _get_sub_length( $query->param('subtype'), $query->param('sublength') );
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
    my $serialsadditems = $query->param('serialsadditems');
    # subscription history
    my $histenddate = format_date_in_iso($query->param('histenddate'));
    my $histstartdate = format_date_in_iso($query->param('histstartdate'));
    my $recievedlist = $query->param('recievedlist');
    my $missinglist = $query->param('missinglist');
    my $opacnote = $query->param('opacnote');
    my $librariannote = $query->param('librariannote');
	my $staffdisplaycount = $query->param('staffdisplaycount');
	my $opacdisplaycount = $query->param('opacdisplaycount');
    my $graceperiod     = $query->param('graceperiod') || 0;
    my $location = $query->param('location');
    my $nextexpected = GetNextExpected($subscriptionid);
	#  If it's  a mod, we need to check the current 'expected' issue, and mod it in the serials table if necessary.
    if ( $nextacquidate ne $nextexpected->{planneddate}->output('iso') ) {
        ModNextExpected($subscriptionid,C4::Dates->new($nextacquidate,'iso'));
        # if we have not received any issues yet, then we also must change the firstacquidate for the subs.
        $firstissuedate = $nextacquidate if($nextexpected->{isfirstissue});
    }

        ModSubscription(
            $auser,           $branchcode,   $aqbooksellerid, $cost,
            $aqbudgetid,      $startdate,    $periodicity,    $firstissuedate,
            $dow,             join(q{,},@irregularity), $numberpattern,  $numberlength,
            $weeklength,      $monthlength,  $add1,           $every1,
            $whenmorethan1,   $setto1,       $lastvalue1,     $innerloop1,
            $add2,            $every2,       $whenmorethan2,  $setto2,
            $lastvalue2,      $innerloop2,   $add3,           $every3,
            $whenmorethan3,   $setto3,       $lastvalue3,     $innerloop3,
            $numberingmethod, $status,       $biblionumber,   $callnumber,
            $notes,           $letter,       $hemisphere,     $manualhistory,$internalnotes,
            $serialsadditems, $staffdisplaycount,$opacdisplaycount,$graceperiod,$location,$enddate,$subscriptionid
        );
        ModSubscriptionHistory ($subscriptionid,$histstartdate,$histenddate,$recievedlist,$missinglist,$opacnote,$librariannote);
    print $query->redirect("/cgi-bin/koha/serials/subscription-detail.pl?subscriptionid=$subscriptionid");
    return;
}
