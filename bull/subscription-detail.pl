#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Koha;
use C4::Bull;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;
use HTML::Template;

my $query = new CGI;
my $op = $query->param('op');
my $dbh = C4::Context->dbh;
my $sth;
# my $id;
my ($template, $loggedinuser, $cookie, $subs);
my ($subscriptionid,$auser,$librarian,$cost,$aqbooksellerid, $aqbooksellername,$aqbudgetid, $bookfundid, $startdate, $periodicity,
	$dow, $numberlength, $weeklength, $monthlength,
	$seqnum1,$startseqnum1,$seqtype1,$freq1,$step1,
	$seqnum2,$startseqnum2,$seqtype2,$freq2,$step2,
	$seqnum3,$startseqnum3,$seqtype3,$freq3,$step3,
	$numberingmethod, $arrivalplanified, $status, $biblionumber, $bibliotitle, $notes);

$subscriptionid = $query->param('subscriptionid');

if ($op eq 'modsubscription') {
	$auser = $query->param('user');
	$librarian => $query->param('librarian'),
	$cost = $query->param('cost');
	$aqbooksellerid = $query->param('aqbooksellerid');
	$biblionumber = $query->param('biblionumber');
	$aqbudgetid = $query->param('aqbudgetid');
	$startdate = $query->param('startdate');
	$periodicity = $query->param('periodicity');
	$dow = $query->param('dow');
	$numberlength = $query->param('numberlength');
	$weeklength = $query->param('weeklength');
	$monthlength = $query->param('monthlength');
	$seqnum1 = $query->param('seqnum1');
	$startseqnum1 = $query->param('startseqnum1');
	$seqtype1 = $query->param('seqtype1');
	$freq1 = $query->param('freq1');
	$step1 = $query->param('step1');
	$seqnum2 = $query->param('seqnum2');
	$startseqnum2 = $query->param('startseqnum2');
	$seqtype2 = $query->param('seqtype2');
	$freq2 = $query->param('freq2');
	$step2 = $query->param('step2');
	$seqnum3 = $query->param('seqnum3');
	$startseqnum3 = $query->param('startseqnum3');
	$seqtype3 = $query->param('seqtype3');
	$freq3 = $query->param('freq3');
	$step3 = $query->param('step3');
	$numberingmethod = $query->param('numberingmethod');
	$arrivalplanified = $query->param('arrivalplanified');
	$status = 1;
	$notes = $query->param('notes');
    
	&modsubscription($auser,$aqbooksellerid,$cost,$aqbudgetid,$startdate,
					$periodicity,$dow,$numberlength,$weeklength,$monthlength,
					$seqnum1,$startseqnum1,$seqtype1,$freq1,$step1,
					$seqnum2,$startseqnum2,$seqtype2,$freq2,$step2,
					$seqnum3,$startseqnum3,$seqtype3,$freq3,$step3,
					$numberingmethod, $arrivalplanified, $status, $biblionumber, $notes, $subscriptionid);
	
 } else {
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
	
}

($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "bull/subscription-detail.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});

my ($user, $cookie, $sessionID, $flags)
	= checkauth($query, 0, {catalogue => 1}, "intranet");

$template->param(
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
	startseqnum1 =>$startseqnum1,
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
			"arrival$dow" => 1,
			);


output_html_with_http_headers $query, $cookie, $template->output;
