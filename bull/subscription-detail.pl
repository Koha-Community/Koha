#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Koha;
use C4::Date;
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
	$add1,$every1,$whenmorethan1,$setto1,$lastvalue1,
	$add2,$every2,$whenmorethan2,$setto2,$lastvalue2,
	$add3,$every3,$whenmorethan3,$setto3,$lastvalue3,
	$numberingmethod, $status, $biblionumber, $bibliotitle, $notes);

$subscriptionid = $query->param('subscriptionid');

if ($op eq 'modsubscription') {
	$auser = $query->param('user');
	$librarian => $query->param('librarian'),
	$cost = $query->param('cost');
	$aqbooksellerid = $query->param('aqbooksellerid');
	$biblionumber = $query->param('biblionumber');
	$aqbudgetid = $query->param('aqbudgetid');
	$startdate = format_date_in_iso($query->param('startdate'));
	$periodicity = $query->param('periodicity');
	$dow = $query->param('dow');
	$numberlength = $query->param('numberlength');
	$weeklength = $query->param('weeklength');
	$monthlength = $query->param('monthlength');
	$add1 = $query->param('add1');
	$every1 = $query->param('every1');
	$whenmorethan1 = $query->param('whenmorethan1');
	$setto1 = $query->param('setto1');
	$lastvalue1 = $query->param('lastvalue1');
	$add2 = $query->param('add2');
	$every2 = $query->param('every2');
	$whenmorethan2 = $query->param('whenmorethan2');
	$setto2 = $query->param('setto2');
	$lastvalue2 = $query->param('lastvalue2');
	$add3 = $query->param('add3');
	$every3 = $query->param('every3');
	$whenmorethan3 = $query->param('whenmorethan3');
	$setto3 = $query->param('setto3');
	$lastvalue3 = $query->param('lastvalue3');
	$numberingmethod = $query->param('numberingmethod');
	$status = 1;
	$notes = $query->param('notes');
    
	&modsubscription($auser,$aqbooksellerid,$cost,$aqbudgetid,$startdate,
					$periodicity,$dow,$numberlength,$weeklength,$monthlength,
					$add1,$every1,$whenmorethan1,$setto1,$lastvalue1,
					$add2,$every2,$whenmorethan2,$setto2,$lastvalue2,
					$add3,$every3,$whenmorethan3,$setto3,$lastvalue3,
					$numberingmethod, $status, $biblionumber, $notes, $subscriptionid);
}

my $subs = &getsubscription($subscriptionid);
my @serialslist = getserials($subscriptionid);

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
	user => $subs->{auser},
	librarian => $subs->{librarian},
	aqbooksellerid => $subs->{aqbooksellerid},
	aqbooksellername => $subs->{aqbooksellername},
	cost => $subs->{cost},
	aqbudgetid => $subs->{aqbudgetid},
	bookfundid => $subs->{bookfundid},
	startdate => format_date($subs->{startdate}),
	periodicity => $subs->{periodicity},
	dow => $subs->{dow},
	numberlength => $subs->{numberlength},
	weeklength => $subs->{weeklength},
	monthlength => $subs->{monthlength},
	add1 => $subs->{add1},
	every1 => $subs->{every1},
	whenmorethan1 => $subs->{whenmorethan1},
	setto1 => $subs->{setto1},
	lastvalue1 => $subs->{lastvalue1},
	add2 => $subs->{add2},
	every2 => $subs->{every2},
	whenmorethan2 => $subs->{whenmorethan2},
	setto2 => $subs->{setto2},
	lastvalue2 => $subs->{lastvalue2},
	add3 => $subs->{add3},
	every3 => $subs->{every3},
	whenmorethan3 => $subs->{whenmorethan3},
	setto3 => $subs->{setto3},
	lastvalue3 => $subs->{lastvalue3},
	numberingmethod => $subs->{numberingmethod},
	status => $subs->{status},
	biblionumber => $subs->{biblionumber},
	bibliotitle => $subs->{bibliotitle},
	notes => $subs->{notes},
	subscriptionid => $subs->{subscriptionid},
	serialslist => \@serialslist,
	);
$template->param(
			"periodicity$subs->{periodicity}" => 1,
			"arrival$subs->{dow}" => 1,
			);

output_html_with_http_headers $query, $cookie, $template->output;
