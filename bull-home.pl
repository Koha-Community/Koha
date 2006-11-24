#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Bull;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;
use HTML::Template;

my $query = new CGI;
my $title = $query->param('title');
my $ISSN = $query->param('ISSN');
my $routing = $query->param('routing');
my $searched = $query->param('searched');
my $biblionumber = $query->param('biblionumber');
my @subscriptions = getsubscriptions($title,$ISSN,$biblionumber);
my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "bull/bull-home.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});

# to toggle between create or edit routing list options
if($routing){
    for(my $i=0;$i<@subscriptions;$i++){
            my $checkrouting = check_routing($subscriptions[$i]->{'subscriptionid'});
            $subscriptions[$i]->{'routingedit'} = $checkrouting;
            # warn "check $checkrouting";
    }
}

$template->param(
            subscriptions => \@subscriptions,
            title => $title,
            ISSN => $ISSN,
            done_searched => $searched,
            routing => $routing,
	intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
		intranetstylesheet => C4::Context->preference("intranetstylesheet"),
		IntranetNav => C4::Context->preference("IntranetNav"),
	);
output_html_with_http_headers $query, $cookie, $template->output;
