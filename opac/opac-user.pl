#!/usr/bin/perl
use strict;
require Exporter;
use CGI;

use C4::Search;       # borrdata
use C4::Output;       # gettemplate
use C4::Auth;         # checkauth, getborrowernumber.
use C4::Koha;
use C4::Circulation::Circ2;
use C4::Reserves2;

my $query = new CGI;

my ($loggedinuser, $cookie, $sessionID) = checkauth($query);

my $template = gettemplate("opac-user.tmpl", "opac");

# get borrower information ....
my $borrowernumber = getborrowernumber($loggedinuser);
my ($borr, $flags) = getpatroninformation(undef, $borrowernumber);

$borr->{'dateenrolled'} = slashifyDate($borr->{'dateenrolled'});
$borr->{'expiry'}       = slashifyDate($borr->{'expiry'});
$borr->{'dateofbirth'}  = slashifyDate($borr->{'dateofbirth'});
$borr->{'ethnicity'}    = fixEthnicity($borr->{'ethnicity'});

if ($borr->{'amountoutstanding'} > 5) {
    $borr->{'amountoverfive'} = 1;
} else {
    $borr->{'amountoverfive'} = 0;
}

$borr->{'amountoutstanding'} = sprintf "\$%.02f", $borr->{'amountoutstanding'};

my @bordat;
$bordat[0] = $borr;

$template->param(BORROWER_INFO => \@bordat);

#get issued items ....
my $issues = getissues($borr);

my $count=0;
my @issuedat;
foreach my $key (keys %$issues) {
    my $issue = $issues->{$key};
    $issue->{'date_due'}  = slashifyDate($issue->{'date_due'});
    if ($issue->{'overdue'}) {
	$issue->{'status'} = "OVERDUE";
    } else {
	$issue->{'status'} = "Issued";
    }
# check for reserves
    my ($restype, $res) = CheckReserves($issue->{'itemnumber'});
    if ($restype) {
	$issue->{'status'} .= "Reserved";
    }
    my ($charges, $itemtype) = calc_charges(undef, undef, $issue->{'itemnumber'}, $borrowernumber);
    $issue->{'charges'} = $charges; 
    push @issuedat, $issue;
    $count++;
} 

$template->param(ISSUES => \@issuedat); 
$template->param(issues_count => $count); 

# now the reserved items....
my ($rcount, $reserves) = FindReserves(undef, $borrowernumber);

$template->param(RESERVES => $reserves);
$template->param(reserves_count => $rcount);

my $branches = getbranches();
my @waiting;
my $wcount = 0;
foreach my $res (@$reserves) {
    if ($res->{'itemnumber'}) {
	$res->{'branch'} = $branches->{$res->{'branchcode'}}->{'branchname'};
	push @waiting, $res;
	$wcount++;
    }
}

$template->param(WAITING => \@waiting);
$template->param(waiting_count => $wcount);

$template->param(loggedinuser => $loggedinuser);
print "Content-Type: text/html\n\n", $template->output; 
