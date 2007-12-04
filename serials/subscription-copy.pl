#!/usr/bin/perl


use strict;
use CGI;

use C4::Koha;
use C4::Auth;
use C4::Dates;
use C4::Output;
use C4::Acquisition;
use C4::Context;
use C4::Serials;

my $query = new CGI;
my $subscriptionid = $query->param('subscriptionid');
my $dbh = C4::Context->dbh;
# get old subscription
my $subs = &GetSubscription($subscriptionid);

# make newsubscription()
$subscriptionid =  old_newsubscription(
	$subs->{'auser'},$subs->{'aqbooksellerid'},$subs->{'cost'},$subs->{'aqbudgetid'},
	$subs->{'biblionumber'},$subs->{'startdate'},$subs->{'periodicity'},$subs->{'firstacquidate'},
	$subs->{'dow'},$subs->{'irregularity'},$subs->{'numberpattern'},$subs->{'numberlength'},
	$subs->{'weeklength'},$subs->{'monthlength'},$subs->{'add1'},$subs->{'every1'},
	$subs->{'whenmorethan1'},$subs->{'setto1'},$subs->{'lastvalue1'},$subs->{'add2'},
	$subs->{'every2'},$subs->{'whenmorethan2'},$subs->{'setto2'},$subs->{'lastvalue2'},$subs->{'add3'},
	$subs->{'every3'},$subs->{'whenmorethan3'},$subs->{'setto3'},$subs->{'lastvalue3'},
	$subs->{'numberingmethod'},$subs->{'status'},$subs->{'notes'},
);
print $query->redirect("/cgi-bin/koha/serials/subscription-detail.pl?subscriptionid=$subscriptionid");

