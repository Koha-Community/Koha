#!/usr/bin/perl
use strict;
require Exporter;
use CGI;

use C4::Auth;
use C4::Koha;
use C4::Circulation::Circ2;
use C4::Circulation::Renewals2;
use C4::Reserves2;
use C4::Search;

my $query = new CGI;
my ($template, $borrowernumber, $cookie) 
    = get_template_and_user({template_name => "opac-user.tmpl",
			     query => $query,
			     type => "opac",
			     authnotrequired => 0,
			     flagsrequired => {borrow => 1},
			     debug => 1,
			     });

# get borrower information ....
my ($borr, $flags) = getpatroninformation(undef, $borrowernumber);

$borr->{'dateenrolled'} = slashifyDate($borr->{'dateenrolled'});
$borr->{'expiry'}       = slashifyDate($borr->{'expiry'});
$borr->{'dateofbirth'}  = slashifyDate($borr->{'dateofbirth'});
$borr->{'ethnicity'}    = fixEthnicity($borr->{'ethnicity'});

if ($borr->{'amountoutstanding'} > 5) {
    $borr->{'amountoverfive'} = 1;
}
if (5 >= $borr->{'amountoutstanding'} && $borr->{'amountoutstanding'} > 0 ) {
    $borr->{'amountoverzero'} = 1;
}
if ($borr->{'amountoutstanding'} < 0) {
    $borr->{'amountlessthanzero'} = 1;
    $borr->{'amountoutstanding'} = -1*($borr->{'amountoutstanding'});
}

$borr->{'amountoutstanding'} = sprintf "\$%.02f", $borr->{'amountoutstanding'};

my @bordat;
$bordat[0] = $borr;

$template->param(BORROWER_INFO => \@bordat);
$template->param(borrowernumber => $borrowernumber);

#get issued items ....
my $issues = getissues($borr);

my $count = 0;
my $overdues_count = 0;
my @overdues;
my @issuedat;
foreach my $key (keys %$issues) {
    my $issue = $issues->{$key};
    $issue->{'date_due'}  = slashifyDate($issue->{'date_due'});

    # check for reserves
    my ($restype, $res) = CheckReserves($issue->{'itemnumber'});
    if ($restype) {
	$issue->{'reserved'} = 1;
    }

    my ($numaccts,$accts,$total) = getboracctrecord(undef,$borr);
    my $charges = 0;
    foreach my $ac (@$accts) {
	if ($ac->{'itemnumber'} == $issue->{'itemnumber'}) {
	    $charges += $ac->{'amountoutstanding'} if $ac->{'accounttype'} eq 'F'; 
	    $charges += $ac->{'amountoutstanding'} if $ac->{'accounttype'} eq 'L';
	} 
    }
    $issue->{'charges'} = $charges;

    # get publictype for icon
    
    my $publictype = $issue->{'publictype'};
    $issue->{$publictype} = 1;

    # check if item is renewable
    my %env;
    my $status = renewstatus(\%env,$borrowernumber, $issue->{'itemnumber'});

    $issue->{'renewable'} = $status;
    
    if ($issue->{'overdue'}) {
	push @overdues, $issue;
	$overdues_count++;
	$issue->{'overdue'} = 1;
    } else {
	$issue->{'issued'} = 1;
    }
    push @issuedat, $issue;
    $count++;
}

$template->param(ISSUES => \@issuedat);
$template->param(issues_count => $count);

$template->param(OVERDUES => \@overdues);
$template->param(overdues_count => $overdues_count);

my $branches = getbranches();

# now the reserved items....
my ($rcount, $reserves) = FindReserves(undef, $borrowernumber);
foreach my $res (@$reserves) {
    $res->{'reservedate'}  = slashifyDate($res->{'reservedate'});
    my $publictype = $res->{'publictype'};
    $res->{$publictype} = 1;
    $res->{'waiting'} = 1 if $res->{'found'} eq 'W';
    $res->{'branch'} = $branches->{$res->{'branchcode'}}->{'branchname'};
}

$template->param(RESERVES => $reserves);
$template->param(reserves_count => $rcount);

my @waiting;
my $wcount = 0;
foreach my $res (@$reserves) {
    if ($res->{'itemnumber'}) {
	$res->{'branch'} = $branches->{$res->{'branchcode'}}->{'branchname'};
	push @waiting, $res;
	$wcount++;
    }
}

# $template->param(WAITING => \@waiting);
$template->param(waiting_count => $wcount);

print $query->header(-cookie => $cookie), $template->output;

