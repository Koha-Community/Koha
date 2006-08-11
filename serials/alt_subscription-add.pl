#!/usr/bin/perl


use strict;
use CGI;
use C4::Koha;
use C4::Auth;
use C4::Date;
use C4::Output;
use C4::Acquisition;
use C4::Interface::CGI::Output;
use C4::Context;
use HTML::Template;
use C4::Serials;
use Date::Manip;

my $query = new CGI;
my $op = $query->param('op');
my $dbh = C4::Context->dbh;
my ($subscriptionid,$auser,$librarian,$cost,$aqbooksellerid, $aqbooksellername,$aqbudgetid, $bookfundid, $startdate, $periodicity,
	$firstacquidate, $dow, $irregularity, $numberpattern, $numberlength, $weeklength, $monthlength, $sublength,
	$add1,$every1,$whenmorethan1,$setto1,$lastvalue1,$innerloop1,
	$add2,$every2,$whenmorethan2,$setto2,$lastvalue2,$innerloop2,
	$add3,$every3,$whenmorethan3,$setto3,$lastvalue3,$innerloop3,
	$numberingmethod, $status, $biblionumber, 
	$bibliotitle, $callnumber, $notes, $hemisphere);

	my @budgets;
my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "serials/alt_subscription-add.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});


my $weekarrayjs='';
my $count = 0;
my ($year, $month, $day) = UnixDate("today", "%Y", "%m", "%d");
my $firstday = Date_DayOfYear($month,$day,$year);
my $wkno = Date_WeekOfYear($month,$day,$year,1); # week starting monday
my $weekno = $wkno;
for(my $i=$firstday;$i<($firstday+365);$i=$i+7){
        $count = $i;
        if($wkno > 52){$year++; $wkno=1;}
        if($count>365){$count=$i-365;}    
        my ($y,$m,$d) = Date_NthDayOfYear($year,$count);
        my $output = "$y-$m-$d";
        $weekarrayjs .= "'Wk $wkno: ".format_date($output)."',";
        $wkno++;    
}
chop($weekarrayjs);
# warn $weekarrayjs;

my $sub_on;
my @subscription_types = (
            'issues', 'weeks', 'months'
        ); 
my @sub_type_data;
if ($op eq 'mod') {
	my $subscriptionid = $query->param('subscriptionid');
	my $subs = &GetSubscription($subscriptionid);
	$auser = $subs->{'user'};
	$librarian => $subs->{'librarian'},
	$cost = $subs->{'cost'};
	$aqbooksellerid = $subs->{'aqbooksellerid'};
	$aqbooksellername = $subs->{'aqbooksellername'};
	$startdate = $subs->{'startdate'};
	$firstacquidate = $subs->{'firstacquidate'};    
	$periodicity = $subs->{'periodicity'};
	$dow = $subs->{'dow'};
        $irregularity = $subs->{'irregularity'};
        $numberpattern = $subs->{'numberpattern'};
	$numberlength = $subs->{'numberlength'};
	$weeklength = $subs->{'weeklength'};
	$monthlength = $subs->{'monthlength'};

        if($monthlength > 0){
	    $sublength = $monthlength;
	    $sub_on = $subscription_types[2];
	} elsif ($weeklength>0){
	    $sublength = $weeklength;
	    $sub_on = $subscription_types[1];
	} else {
	    $sublength = $numberlength;
	    $sub_on = $subscription_types[0];
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
    
	$add1 = $subs->{'add1'};
	$every1 = $subs->{'every1'};
	$whenmorethan1 = $subs->{'whenmorethan1'};
	$setto1 = $subs->{'setto1'};
	$lastvalue1 = $subs->{'lastvalue1'};
	$innerloop1 = $subs->{'innerloop1'};
	$add2 = $subs->{'add2'};
	$every2 = $subs->{'every2'};
	$whenmorethan2 = $subs->{'whenmorethan2'};
	$setto2 = $subs->{'setto2'};
	$lastvalue2 = $subs->{'lastvalue2'};
	$innerloop2 = $subs->{'innerloop2'};
	$add3 = $subs->{'add3'};
	$every3 = $subs->{'every3'};
	$whenmorethan3 = $subs->{'whenmorethan3'};
	$setto3 = $subs->{'setto3'};
	$lastvalue3 = $subs->{'lastvalue3'};
	$innerloop3 = $subs->{'innerloop3'};
	$numberingmethod = $subs->{'numberingmethod'};
	$status = $subs->{status};
	$biblionumber = $subs->{'biblionumber'};
	$bibliotitle = $subs->{'bibliotitle'};
        $callnumber = $subs->{'callnumber'};
	$notes = $subs->{'notes'};
        $hemisphere = $subs->{'hemisphere'};
	$template->param(
		$op => 1,
		user => $auser,
		librarian => $librarian,
		aqbooksellerid => $aqbooksellerid,
		aqbooksellername => $aqbooksellername,
		cost => $cost,
		aqbudgetid => $aqbudgetid,
		bookfundid => $bookfundid,
		startdate => format_date($startdate),
		firstacquidate => format_date($firstacquidate),	    
		periodicity => $periodicity,
		dow => $dow,
	        irregularity => $irregularity,
	        numberpattern => $numberpattern,
		sublength => $sublength,
	        subtype => \@sub_type_data,
		add1 => $add1,
		every1 => $every1,
		whenmorethan1 => $whenmorethan1,
		setto1 => $setto1,
		lastvalue1 => $lastvalue1,
		innerloop1 => $innerloop1,
		add2 => $add2,
		every2 => $every2,
		whenmorethan2 => $whenmorethan2,
		setto2 => $setto2,
		lastvalue2 => $lastvalue2,
		innerloop2 => $innerloop2,
		add3 => $add3,
		every3 => $every3,
		whenmorethan3 => $whenmorethan3,
		setto3 => $setto3,
		lastvalue3 => $lastvalue3,
		innerloop3 => $innerloop3,
		numberingmethod => $numberingmethod,
		status => $status,
		biblionumber => $biblionumber,
		bibliotitle => $bibliotitle,
	        callnumber => $callnumber,
		notes => $notes,
		subscriptionid => $subscriptionid,
	        weekarrayjs => $weekarrayjs,
	        weekno => $weekno,
	        hemisphere => $hemisphere,
		);

	$template->param(
				"periodicity$periodicity" => 1,
				"dow$dow" => 1,
	                        "numberpattern$numberpattern" => 1,
				);
}

if ($op eq 'addsubscription') {
        my @irregular = $query->param('irregular');
        my $irregular_count = @irregular;
        for(my $i =0;$i<$irregular_count;$i++){
            $irregularity .=$irregular[$i]."|";
        }
        $irregularity =~ s/\|$//;

	my $auser = $query->param('user');
	my $aqbooksellerid = $query->param('aqbooksellerid');
	my $cost = $query->param('cost');
	my $aqbudgetid = $query->param('aqbudgetid'); 
	my $startdate = $query->param('startdate');
	my $firstacquidate = $query->param('firstacquidate');    
	my $periodicity = $query->param('periodicity');
	my $dow = $query->param('dow');
        # my $irregularity = $query->param('irregularity');
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
	my $add2 = $query->param('add2');
	my $every2 = $query->param('every2');
	my $whenmorethan2 = $query->param('whenmorethan2');
	my $setto2 = $query->param('setto2');
	my $lastvalue2 = $query->param('lastvalue2');
	my $add3 = $query->param('add3');
	my $every3 = $query->param('every3');
	my $whenmorethan3 = $query->param('whenmorethan3');
	my $setto3 = $query->param('setto3');
	my $lastvalue3 = $query->param('lastvalue3');
	my $numberingmethod = $query->param('numberingmethod');
	my $status = 1;
	my $biblionumber = $query->param('biblionumber');
        my $callnumber = $query->param('callnumber');
	my $notes = $query->param('notes');
        my $hemisphere = $query->param('hemisphere') || 1;

	my $subscriptionid = old_newsubscription($auser,$aqbooksellerid,$cost,$aqbudgetid,$biblionumber,
					$startdate,$periodicity,$firstacquidate,$dow,$irregularity,$numberpattern,$numberlength,$weeklength,$monthlength,
					$add1,$every1,$whenmorethan1,$setto1,$lastvalue1,
					$add2,$every2,$whenmorethan2,$setto2,$lastvalue2,
					$add3,$every3,$whenmorethan3,$setto3,$lastvalue3,
					$numberingmethod, $status, $callnumber, $notes, $hemisphere
				);
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
 	         weekarrayjs => $weekarrayjs,
	         weekno => $weekno,
	);
	output_html_with_http_headers $query, $cookie, $template->output;
}
