#!/usr/bin/perl
use strict;
require Exporter;
use CGI;

use C4::Auth;       # get_template_and_user
use HTML::Template;

my $query = new CGI;

my ($template, $borrowernumber, $cookie) 
    = get_template_and_user({template_name => "loggedin.tmpl",
			     query => $query,
			     type => "opac",
			     authnotrequired => 1,
			     flagsrequired => {borrow => 1},
			 });

my @inputs =();
foreach my $name (param $query) {
    (next) if ($name eq 'userid' || $name eq 'password');
    my $value = $query->param($name);
    push @inputs, {name => $name , value => $value};
}

$template->param(INPUTS => \@inputs);

my $self_url = $query->url(-absolute => 1);
$template->param(url => $self_url);

output_html_with_http_headers $query, $cookie, $template->output;
