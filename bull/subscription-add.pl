#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;
use HTML::Template;
use C4::Bull;

my $query = new CGI;
my $op = $query->param('op');
my $dbh = C4::Context->dbh;
if ($op eq 'addsubscription')
{
   my $auser = $query->param('user');
  my $supplier = $query->param('supplier');
   my $cost = $query->param('cost');
   my $budget = $query->param('budget'); 
   my $begin = $query->param('begin');
   my $frequency = $query->param('frequency');
   my $dow = $query->param('arrival');
    my $numberlength = $query->param('numberlength');
    my $weeklength = $query->param('weeklength');
    my $monthlength = $query->param('monthlength');
    my $X = $query->param('X');
    my $Xstate = $query->param('Xstate');
    my $Xfreq = $query->param('Xfreq');
    my $Xstep = $query->param('Xstep');
    my $Y = $query->param('Y');
    my $Ystate = $query->param('Ystate');
    my $Yfreq = $query->param('Yfreq');
    my $Ystep = $query->param('Ystep');
    my $Z = $query->param('Z');
    my $Zstate = $query->param('Zstate');
    my $Zfreq = $query->param('Zfreq');
    my $Zstep = $query->param('Zstep');
    my $sequence = $query->param('sequence');
    my $arrivalplanified = $query->param('arrivalplanified');
    my $status = 1;
    my $perioid = $query->param('biblioid');
    my $notes = $query->param('notes');

    my $sth=$dbh->prepare("insert into subscription (librarian, aqbooksellerid,cost,aqbudgetid,startdate, periodicity,dow,numberlength,weeklength,monthlength,seqnum1,startseqnum1,seqtype1,freq1,step1,seqnum2,startseqnum2,seqtype2,freq2, step2, seqnum3,startseqnum3,seqtype3, freq3, step3,numberingmethod, arrivalplanified, status, perioid, notes, pos1, pos2, pos3) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?, 0, 0, 0)");
 $sth->execute($auser,$supplier,$cost,$budget,$begin,$frequency,$dow,$numberlength,$weeklength,$monthlength,$X,$X,$Xstate,$Xfreq, $Xstep,$Y,$Y,$Ystate,$Yfreq, $Ystep,$Z,$Z,$Zstate,$Zfreq, $Zstep, $sequence, $arrivalplanified, $status, $perioid, $notes);
   $sth = $dbh->prepare("select subscriptionid from subscription where perioid = ? and numberingmethod = ?");
   $sth->execute($perioid, $sequence);
   my $subid = $sth->fetchrow;
   
   $sth = $dbh->prepare("insert into subscriptionhistory (biblioid, subscriptionid, startdate, enddate, missinglist, recievedlist, opacnote, librariannote) values (?,?,?,?,?,?,?,?)");
   $sth->execute($perioid, $subid, $begin, 0, "", "", 0, $notes);
   $sth = $dbh->prepare("insert into serial (biblionumber, subscriptionid, serialseq, status, planneddate) values (?,?,?,?,?)");

   $sth->execute($perioid, $subid, Initialize_Sequence($sequence, $X, $Xstate, $Xfreq, $Xstep, $Y, $Ystate, $Yfreq, $Ystep, $Z, $Zstate, $Zfreq, $Zstep), $status, C4::Bull::Find_Next_Date());
# biblionumber,
# subscriptionid,
# startdate, enddate,
# missinglist,
# recievedlist,
# opacnote,
# librariannote
  $sth->finish;

    
    
}
my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "bull/subscription-add.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});

	my ($user, $cookie, $sessionID, $flags)
		= checkauth($query, 0, {catalogue => 1}, "intranet");
	$template->param(
		user             => $user,
		);
output_html_with_http_headers $query, $cookie, $template->output;
