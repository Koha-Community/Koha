#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;
use C4::Bull;
use HTML::Template;

my $query = new CGI;
my $op = $query->param('op');
my $dbh = C4::Context->dbh;
my $sid = $query->param('subsid');
my $ser = $query->param('serial');
warn "$ser la valeur du nom du formulaire";
if ($op eq 'modsubscriptionhistory')
{
   my $auser = $query->param('user');
   my $status = $query->param('status');
   my $waited = $query->param('waited');
   my $begin = $query->param('begin');
   my $end = $query->param('end');
   my $arrived = $query->param('arrived');
   my $gapped = $query->param('gapped');
   my $opac = $query->param('opac');
   my $intra = $query->param('intra');

    my $sth=$dbh->prepare("update subscriptionhistory set startdate=?, enddate=?,missinglist=?, recievedlist=?, opacnote=?, librariannote=? where subscriptionid = ?");
 $sth->execute($begin, $end, $gapped, $arrived, $opac, $intra, $sid);

   if ($status != 1)
   {
       if ($status == 2)
       {
	   $sth = $dbh->prepare("select recievedlist from subscriptionhistory where subscriptionid = ?");
	   $sth->execute($sid);
	   my $received = $sth->fetchrow;
	   $sth = $dbh->prepare("select * from subscription where subscriptionid = ? ");
	   $sth->execute($sid);
	   my $val = $sth->fetchrow_hashref;
	   $sth = $dbh->prepare("update serial set serialseq = ? where subscriptionid = ? and status = 1");
	   my ($temp, $X, $Y, $Z, $Xpos, $Ypos, $Zpos) = Get_Next_Seq($val->{'numberingmethod'},$val->{'seqnum1'},$val->{'freq1'}, $val->{'step1'}, $val->{'seqtype1'}, $val->{'seqnum2'}, $val->{'freq2'}, $val->{'step2'}, $val->{'seqtype2'}, $val->{'seqnum3'}, $val->{'freq3'}, $val->{'step3'}, $val->{'seqtype3'}, $val->{'pos1'}, $val->{'pos2'}, $val->{'pos3'});
	   $sth->execute($temp, $sid);
	   $sth = $dbh->prepare("update subscription set seqnum1=?, seqnum2=?,seqnum3=?,pos1=?,pos2=?,pos3=? where subscriptionid = ?");
	   $sth->execute($X, $Y, $Z, $Xpos, $Ypos, $Zpos, $sid);
	   $sth = $dbh->prepare("update subscriptionhistory set recievedlist=? where subscriptionid = ?");
	   if (length($received) > 2)
	   {
	       $sth->execute("$received,$waited", $sid);
	   }
	   else
	   {
	       $sth->execute($waited, $sid);
	   }
	   
       }
       elsif ($status == 3)
       {
	   $sth = $dbh->prepare("select missinglist from subscriptionhistory where subscriptionid = ?");
	   $sth->execute($sid);
	   my $missing = $sth->fetchrow;
	   $sth = $dbh->prepare("select * from subscription where subscriptionid = ? ");
	   $sth->execute($sid);
	   my $val = $sth->fetchrow_hashref;
	   $sth = $dbh->prepare("update serial set status = 2 where subscriptionid = ? and status = 1");
	   $sth->execute($sid);
	   $sth = $dbh->prepare("insert into serial (serialseq,subscriptionid,biblionumber,status, planneddate) values (?,?,?,?,?)");
	   my ($temp, $X, $Y, $Z, $Xpos, $Ypos, $Zpos) = Get_Next_Seq($val->{'numberingmethod'},$val->{'seqnum1'},$val->{'freq1'}, $val->{'step1'}, $val->{'seqtype1'}, $val->{'seqnum2'}, $val->{'freq2'}, $val->{'step2'}, $val->{'seqtype2'}, $val->{'seqnum3'}, $val->{'freq3'}, $val->{'step3'}, $val->{'seqtype3'}, $val->{'pos1'}, $val->{'pos2'}, $val->{'pos3'});
	   $sth->execute($temp, $sid, $val->{'biblionumber'}, 1, 0);
	   $sth = $dbh->prepare("update subscription set seqnum1=?, seqnum2=?,seqnum3=?,pos1=?,pos2=?,pos3=? where subscriptionid = ?");
	   $sth->execute($X, $Y, $Z, $Xpos, $Ypos, $Zpos, $sid);
	   $sth = $dbh->prepare("update subscriptionhistory set missinglist=? where subscriptionid = ?");
	   if (length($missing) > 2)
	   {
	       $sth->execute("$missing,$waited", $sid);
	   }
	   else
	   {
	       $sth->execute($waited, $sid);
	   }

       }
       else
       {
	   warn ("Error vous avez fait None dans le formulaire receipt\n");
       }
   }
    
  $sth->finish;
}
my $sth=$dbh->prepare("select serialseq, status, planneddate from serial where subscriptionid = ? and status = ?");
$sth->execute($sid, 1);
my $sol = $sth->fetchrow_hashref;
my $sth=$dbh->prepare("select * from subscriptionhistory where subscriptionid = ?");
$sth->execute($sid);
my $solhistory = $sth->fetchrow_hashref;
my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "bull/statecollection.tmpl",
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
		      serial => $ser,
			 status  => $sol->{'status'},
			 waited  => $sol->{'serialseq'},
			 begin => $solhistory->{'startdate'},
			 end => $solhistory->{'enddate'},
			 arrived => $solhistory->{'recievedlist'},
			 gapped => $solhistory->{'missinglist'},
			 opac => $solhistory->{'opacnote'},
			 intra => $solhistory->{'librariannote'},
			 sid => $sid,
		);
output_html_with_http_headers $query, $cookie, $template->output;
