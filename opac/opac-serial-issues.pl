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
my $selectview = C4::Context->preference("SubscriptionHistory");
warn "selectview : ".$selectview;

my $sth;
# my $id;
my ($template, $loggedinuser, $cookie);
my $biblionumber = $query->param('biblionumber');
if ($selectview eq "full"){
my $subscriptions = get_full_subscription_list_from_biblionumber($biblionumber);

my $year;
my $yearmin=$subscriptions->[1]{year};
warn "yearmin".$yearmin;
my $yearmax;
my @loopissues;
my $yearmax=$subscriptions->[scalar(@$subscriptions)]{year};
warn "yearmax".$yearmax;


($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "opac-full-serial-issues.tmpl",
				query => $query,
				type => "opac",
				authnotrequired => 1,
				debug => 1,
				});

# replace CR by <br> in librarian note
# $subscription->{opacnote} =~ s/\n/\<br\/\>/g;

$template->param(
	biblionumber => $query->param('biblionumber'),
	years => $subscriptions,
	yearmin => $yearmin,
	yearmax =>$yearmax,
	suggestion => C4::Context->preference("suggestion"),
	virtualshelves => C4::Context->preference("virtualshelves"),
	);

} else {
my $subscriptions = get_subscription_list_from_biblionumber($biblionumber);

($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "opac-serial-issues.tmpl",
				query => $query,
				type => "opac",
				authnotrequired => 1,
				debug => 1,
				});

# replace CR by <br> in librarian note
# $subscription->{opacnote} =~ s/\n/\<br\/\>/g;

$template->param(
	biblionumber => $query->param('biblionumber'),
	subscription_LOOP => $subscriptions,
	suggestion => C4::Context->preference("suggestion"),
	virtualshelves => C4::Context->preference("virtualshelves"),
	);
}
output_html_with_http_headers $query, $cookie, $template->output;
