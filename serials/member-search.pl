#!/usr/bin/perl

# Member Search.pl script used to search for members to add to a routing list
use strict;
use CGI;
use C4::Koha;
use C4::Auth;
use C4::Date;
use C4::Acquisition;
use C4::Interface::CGI::Output;
use C4::Context;
use C4::Search;
use C4::Serials;

my $query = new CGI;
my $subscriptionid = $query->param('subscriptionid');
my $op = $query->param('op');
my $searchstring = $query->param('member');
my $dbh = C4::Context->dbh;

my $env;    
    
    my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "serials/member-search.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});


if($searchstring){
    my ($count, $members) = &BornameSearch($env, $searchstring, "surname", "advanced");
    
    $template->param(
	subscriptionid => $subscriptionid,
 	    memberloop => $members,
	        member => $searchstring,
    );
} else {
    $template->param(
	subscriptionid => $subscriptionid,
    );
}
        output_html_with_http_headers $query, $cookie, $template->output;
