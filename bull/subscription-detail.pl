#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;
use HTML::Template;

my $query = new CGI;
my $op = $query->param('op');
my $dbh = C4::Context->dbh;
my $sth;
my $id;
my ($template, $loggedinuser, $cookie, $subs);

if ($op eq 'modsubscription')
{


# if ($op eq 'addsubscription')
# {
    my $id = $query->param('suscr');
    my $auser = $query->param('user');
    my $cost = $query->param('cost');
    my $supplier = $query->param('supplier');
    my $budget = $query->param('budget'); #stocker le id pas le number
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
    
  
    my $sth=$dbh->prepare("update subscription set librarian=?, aqbooksellerid=?,cost=?,aqbudgetid=?,startdate=?, periodicity=?,dow=?,numberlength=?,weeklength=?,monthlength=?,seqnum1=?,startseqnum1=?,seqtype1=?,freq1=?,step1=?,seqnum2=?,startseqnum2=?,seqtype2=?,freq2=?, step2=?, seqnum3=?,startseqnum3=?,seqtype3=?, freq3=?, step3=?,numberingmethod=?, arrivalplanified=?, status=?, perioid=?, notes=? where subscriptionid = ?");
  $sth->execute($auser,$supplier,$cost,$budget,$begin,$frequency,$dow,$numberlength,$weeklength,$monthlength,$X,$X,$Xstate,$Xfreq, $Xstep,$Y,$Y,$Ystate,$Yfreq, $Ystep,$Z,$Z,$Zstate,$Zfreq, $Zstep, $sequence, $arrivalplanified, $status, $perioid, $notes, $id);
   $sth->finish;
  ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "bull/subscription-detail.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});

# }
	my ($user, $cookie, $sessionID, $flags)
		= checkauth($query, 0, {catalogue => 1}, "intranet");
    $template->param(
    user => $auser, ,librarian => $auser,
    aqbooksellerid => $supplier,
    cost => $cost,
    aqbudgetid => $budget,
    startdate => $begin,
    frequency => $frequency,
    arrival => $dow,
    numberlength => $numberlength,
    weeklength => $weeklength,
    monthlength => $monthlength,
    seqnum1 => $X,
    startseqnum1 => $X,
    seqtype1 => $Xstate,
    freq1 => $Xfreq,
    step1 => $Xstep,
    seqnum2 => $Y,
    startseqnum2 => $Y,
    seqtype2 => $Ystate,
    freq2 => $Yfreq,
    step2 => $Ystep,
    seqnum3 => $Z,
    startseqnum3 => $Z,
    seqtype3 => $Zstate,
    freq3 => $Zfreq,
    step3 => $Zstep,
    sequence => $sequence,
    arrivalplanified => $arrivalplanified,
    status => $status,
    biblioid => $perioid,
    notes => $notes,
    suscr => $id,);


    $template->param(
		     "frequency$frequency" => 1,
		     "Xstate$Xstate" => 1,
		     "Ystate$Ystate" => 1,
		     "Zstate$Zstate" => 1,
		     "arrival$dow" => 1,
		     );

 }
 else
 {
    $sth = $dbh->prepare('select * from subscription where subscriptionid = ?');
    $id = $query->param('suscr');
    $sth->execute($id);
    $subs = $sth->fetchrow_hashref;
    $sth->finish;

($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "bull/subscription-detail.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});

# }
	my ($user, $cookie, $sessionID, $flags)
		= checkauth($query, 0, {catalogue => 1}, "intranet");
	$template->param(
		user             => $user,
			 );
    $template->param(librarian => $subs->{'librarian'},
    aqbooksellerid => $subs->{'aqbooksellerid'},
    cost => $subs->{'cost'},
    aqbudgetid => $subs->{'aqbudgetid'},
    startdate => $subs->{'startdate'},
    frequency => $subs->{'periodicity'},
    arrival => $subs->{'dow'},
    numberlength => $subs->{'numberlength'},
    weeklength => $subs->{'weeklength'},
    monthlength => $subs->{'monthlength'},
    seqnum1 => $subs->{'seqnum1'},
    startseqnum1 => $subs->{'startseqnum1'},
    seqtype1 => $subs->{'seqtype1'},
    freq1 => $subs->{'freq1'},
    step1 => $subs->{'step1'},
    seqnum2 => $subs->{'seqnum2'},
    startseqnum2 => $subs->{'startseqnum2'},
    seqtype2 => $subs->{'seqtype2'},
    freq2 => $subs->{'freq2'},
    step2 => $subs->{'step2'},
    seqnum3 => $subs->{'seqnum3'},
    startseqnum3 => $subs->{'startseqnum3'},
    seqtype3 => $subs->{'seqtype3'},
    freq3 => $subs->{'freq3'},
    step3 => $subs->{'step3'},
    sequence => $subs->{'numberingmethod'},
    arrivalplanified => $subs->{'arrivalplanified'},
    status => $subs->{'status'},
    biblioid => $subs->{'perioid'},
    notes => $subs->{'notes'},
    suscr => $id,		   
);

    $template->param(

		     "frequency$subs->{'periodicity'}" => 1,
		     "Xstate$subs->{'seqtype1'}" => 1,
		     "Ystate$subs->{'seqtype2'}" => 1,
		     "Zstate$subs->{'seqtype3'}" => 1,
		     "arrival$subs->{'dow'}" => 1,
		     );

}
# }
#     my $sth=$dbh->prepare("insert into subscription (librarian, aqbooksellerid,cost,aqbudgetid,startdate, periodicity,dow,numberlength,weeklength,monthlength,seqnum1,startseqnum1,seqtype1,freq1,step1,seqnum2,startseqnum2,seqtype2,freq2, step2, seqnum3,startseqnum3,seqtype3, freq3, step3,numberingmethod, arrivalplanified, status, perioid, notes) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");

output_html_with_http_headers $query, $cookie, $template->output;
