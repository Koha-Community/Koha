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
my $subscriptionid = $query->param('subscriptionid');
# warn "$ser la valeur du nom du formulaire";
my $auser = $query->param('user');
my $startdate = $query->param('startdate');
my $enddate = $query->param('enddate');
my $recievedlist = $query->param('recievedlist');
my $missinglist = $query->param('missinglist');
my $opacnote = $query->param('opacnote');
my $librariannote = $query->param('librariannote');
my @serialids = $query->param('serialid');
my @serialseqs = $query->param('serialseq');
my @planneddates = $query->param('planneddate');
my @status = $query->param('status');
if ($op eq 'modsubscriptionhistory') {
	modsubscriptionhistory($subscriptionid,$startdate,$enddate,$recievedlist,$missinglist,$opacnote,$librariannote);
}
if ($op eq 'serialchangestatus') {
	for (my $i=0;$i<=$#serialids;$i++) {
		serialchangestatus($serialids[$i],$serialseqs[$i],$planneddates[$i],$status[$i]);
	}
}
my @serialslist = getserials($subscriptionid);

my $sth=$dbh->prepare("select * from subscriptionhistory where subscriptionid = ?");
$sth->execute($subscriptionid);
my $solhistory = $sth->fetchrow_hashref;
my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "bull/statecollection.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});

	$template->param(
# 			user => $user,
			serialslist => \@serialslist,
# 			status  => $sol->{'status'},
# 			waited  => $sol->{'serialseq'},
			startdate => $solhistory->{'startdate'},
			enddate => $solhistory->{'enddate'},
			recievedlist => $solhistory->{'recievedlist'},
			missinglist => $solhistory->{'missinglist'},
			opacnote => $solhistory->{'opacnote'},
			librariannote => $solhistory->{'librariannote'},
			subscriptionid => $subscriptionid,
		);
output_html_with_http_headers $query, $cookie, $template->output;
