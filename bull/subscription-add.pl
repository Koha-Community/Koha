#!/usr/bin/perl

use strict;
use CGI;
use C4::Koha;
use C4::Auth;
use C4::Output;
use C4::Bull;
use C4::Interface::CGI::Output;
use C4::Context;
use HTML::Template;
use C4::Bull;

my $query = new CGI;
my $op = $query->param('op');
my $dbh = C4::Context->dbh;
my ($subscriptionid,$auser,$librarian,$cost,$aqbooksellerid, $aqbooksellername,$aqbudgetid, $bookfundid, $startdate, $periodicity,
	$dow, $numberlength, $weeklength, $monthlength,
	$seqnum1,$startseqnum1,$seqtype1,$freq1,$step1,
	$seqnum2,$startseqnum2,$seqtype2,$freq2,$step2,
	$seqnum3,$startseqnum3,$seqtype3,$freq3,$step3,
	$numberingmethod, $arrivalplanified, $status, $biblionumber, 
	$bibliotitle, $notes);

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
	$seqnum1 = $subs->{'seqnum1'};
	$startseqnum1 = $subs->{'startseqnum1'};
	$seqtype1 = $subs->{'seqtype1'};
	$freq1 = $subs->{'freq1'};
	$step1 = $subs->{'step1'};
	$seqnum2 = $subs->{'seqnum2'};
	$startseqnum2 = $subs->{'startseqnum2'};
	$seqtype2 = $subs->{'seqtype2'};
	$freq2 = $subs->{'freq2'};
	$step2 = $subs->{'step2'};
	$seqnum3 = $subs->{'seqnum3'};
	$startseqnum3 = $subs->{'startseqnum3'};
	$seqtype3 = $subs->{'seqtype3'};
	$freq3 = $subs->{'freq3'};
	$step3 = $subs->{'step3'};
	$numberingmethod = $subs->{'numberingmethod'};
	$arrivalplanified = $subs->{'arrivalplanified'};
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
		startdate => $startdate,
		periodicity => $periodicity,
		dow => $dow,
		numberlength => $numberlength,
		weeklength => $weeklength,
		monthlength => $monthlength,
		seqnum1 =>$seqnum1,
		startseqnum =>$startseqnum1,
		seqtype1 =>$seqtype1,
		freq1 =>$freq1,
		step1 =>$step1,
		seqnum2 => $seqnum2,
		startseqnum2 => $startseqnum2,
		seqtype2 => $seqtype2,
		freq2 => $freq2,
		step2 => $step2,
		seqnum3 => $seqnum3,
		startseqnum3 => $startseqnum3,
		seqtype3 => $seqtype3,
		freq3 => $freq3,
		step3 => $step3,
		numberingmethod => $numberingmethod,
		arrivalplanified => $arrivalplanified,
		status => $status,
		biblionumber => $biblionumber,
		bibliotitle => $bibliotitle,
		notes => $notes,
		subscriptionid => $subscriptionid
		);
	$template->param(
				"periodicity$periodicity" => 1,
				"seqtype1$seqtype1" => 1,
				"seqtype2$seqtype2" => 1,
				"seqtype3$seqtype3" => 1,
				"dow$dow" => 1,
				);
} else {
# fill seqtype with 0 to avoid a javascript error
	$template->param(
				"seqtype1" => 0,
				"seqtype2" => 0,
				"seqtype3" => 0,
		);
}
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
	my $seqnum1 = $query->param('seqnum1');
	my $seqtype1 = $query->param('seqtype1');
	my $freq1 = $query->param('freq1');
	my $step1 = $query->param('step1');
	my $seqnum2 = $query->param('seqnum2');
	my $seqtype2 = $query->param('seqtype2');
	my $freq2 = $query->param('freq2');
	my $step2 = $query->param('step2');
	my $seqnum3 = $query->param('seqnum3');
	my $seqtype3 = $query->param('seqtype3');
	my $freq3 = $query->param('freq3');
	my $step3 = $query->param('step3');
	my $numberingmethod = $query->param('numberingmethod');
	my $arrivalplanified = $query->param('arrivalplanified');
	my $status = 1;
	my $biblionumber = $query->param('biblionumber');
	my $notes = $query->param('notes');

	my $sth=$dbh->prepare("insert into subscription (librarian, aqbooksellerid,cost,aqbudgetid,biblionumber,startdate, periodicity,dow,numberlength,weeklength,monthlength,seqnum1,startseqnum1,seqtype1,freq1,step1,seqnum2,startseqnum2,seqtype2,freq2, step2, seqnum3,startseqnum3,seqtype3, freq3, step3,numberingmethod, arrivalplanified, status, notes, pos1, pos2, pos3) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?, 0, 0, 0)");
	newsubscription($auser,$aqbooksellerid,$cost,$aqbudgetid,$biblionumber,$startdate,$periodicity,$dow,$numberlength,$weeklength,$monthlength,$seqnum1,$seqnum1,$seqtype1,$freq1, $step1,$seqnum2,$seqnum2,$seqtype2,$freq2, $step2,$seqnum3,$seqnum3,$seqtype3,$freq3, $step3, $numberingmethod, $arrivalplanified, $status, $notes);
	
}

output_html_with_http_headers $query, $cookie, $template->output;
