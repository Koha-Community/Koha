#!/usr/bin/perl


use strict;
use CGI;
use C4::Koha;
use C4::Auth;
use C4::Date;
use C4::Output;
use C4::Bull;
use C4::Acquisition;
use C4::Interface::CGI::Output;
use C4::Context;
use HTML::Template;
use C4::Bull;

my $query = new CGI;
my $op = $query->param('op');
my $dbh = C4::Context->dbh;
my ($subscriptionid,$auser,$librarian,$cost,$aqbooksellerid, $aqbooksellername,$aqbudgetid, $bookfundid, $startdate, $periodicity,
	$dow, $numberlength, $weeklength, $monthlength,
	$add1,$every1,$whenmorethan1,$setto1,$lastvalue1,
	$add2,$every2,$whenmorethan2,$setto2,$lastvalue2,
	$add3,$every3,$whenmorethan3,$setto3,$lastvalue3,
	$numberingmethod, $status, $biblionumber, 
	$bibliotitle, $notes);

	my @budgets;
my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "bull/subscription-add.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});


if ($op eq 'mod') {
	my $subscriptionid = $query->param('subscriptionid');
	my $subs = &getsubscription($subscriptionid);
	$auser = $subs->{'user'};
	$librarian => $subs->{'librarian'},
	$cost = $subs->{'cost'};
	$aqbooksellerid = $subs->{'aqbooksellerid'};
	$aqbooksellername = $subs->{'aqbooksellername'};
	$bookfundid = $subs->{'bookfundid'};
	$aqbudgetid = $subs->{'aqbudgetid'};
	$startdate = $subs->{'startdate'};
	$periodicity = $subs->{'periodicity'};
	$dow = $subs->{'dow'};
	$numberlength = $subs->{'numberlength'};
	$weeklength = $subs->{'weeklength'};
	$monthlength = $subs->{'monthlength'};
	$add1 = $subs->{'add1'};
	$every1 = $subs->{'every1'};
	$whenmorethan1 = $subs->{'whenmorethan1'};
	$setto1 = $subs->{'setto1'};
	$lastvalue1 = $subs->{'lastvalue1'};
	$add2 = $subs->{'add2'};
	$every2 = $subs->{'every2'};
	$whenmorethan2 = $subs->{'whenmorethan2'};
	$setto2 = $subs->{'setto2'};
	$lastvalue2 = $subs->{'lastvalue2'};
	$add3 = $subs->{'add3'};
	$every3 = $subs->{'every3'};
	$whenmorethan3 = $subs->{'whenmorethan3'};
	$setto3 = $subs->{'setto3'};
	$lastvalue3 = $subs->{'lastvalue3'};
	$numberingmethod = $subs->{'numberingmethod'};
	$status = $subs->{status};
	$biblionumber = $subs->{'biblionumber'};
	$bibliotitle = $subs->{'bibliotitle'},
	$notes = $subs->{'notes'};
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
		periodicity => $periodicity,
		dow => $dow,
		numberlength => $numberlength,
		weeklength => $weeklength,
		monthlength => $monthlength,
		add1 => $add1,
		every1 => $every1,
		whenmorethan1 => $whenmorethan1,
		setto1 => $setto1,
		lastvalue1 => $lastvalue1,
		add2 => $add2,
		every2 => $every2,
		whenmorethan2 => $whenmorethan2,
		setto2 => $setto2,
		lastvalue2 => $lastvalue2,
		add3 => $add3,
		every3 => $every3,
		whenmorethan3 => $whenmorethan3,
		setto3 => $setto3,
		lastvalue3 => $lastvalue3,
		numberingmethod => $numberingmethod,
		status => $status,
		biblionumber => $biblionumber,
		bibliotitle => $bibliotitle,
		notes => $notes,
		subscriptionid => $subscriptionid,
		);
	$template->param(
				"periodicity$periodicity" => 1,
				"dow$dow" => 1,
				);
}
(my $temp,@budgets) = bookfunds();
# find default value & set it for the template
for (my $i=0;$i<=$#budgets;$i++) {
	if ($budgets[$i]->{'aqbudgetid'} eq $aqbudgetid) {
		$budgets[$i]->{'selected'}=1;
	}
}
$template->param(budgets => \@budgets);

if ($op eq 'addsubscription') {
	my $auser = $query->param('user');
	my $aqbooksellerid = $query->param('aqbooksellerid');
	my $cost = $query->param('cost');
	my $aqbudgetid = $query->param('aqbudgetid'); 
	my $startdate = $query->param('startdate');
	my $periodicity = $query->param('periodicity');
	my $dow = $query->param('dow');
	my $numberlength = $query->param('numberlength');
	my $weeklength = $query->param('weeklength');
	my $monthlength = $query->param('monthlength');
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
	my $notes = $query->param('notes');
	my $subscriptionid = newsubscription($auser,$aqbooksellerid,$cost,$aqbudgetid,$biblionumber,
					$startdate,$periodicity,$dow,$numberlength,$weeklength,$monthlength,
					$add1,$every1,$whenmorethan1,$setto1,$lastvalue1,
					$add2,$every2,$whenmorethan2,$setto2,$lastvalue2,
					$add3,$every3,$whenmorethan3,$setto3,$lastvalue3,
					$numberingmethod, $status, $notes
				);
	print $query->redirect("/cgi-bin/koha/bull/subscription-detail.pl?subscriptionid=$subscriptionid");
} else {
	output_html_with_http_headers $query, $cookie, $template->output;
}
