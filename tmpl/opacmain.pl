#!/usr/bin/perl
use HTML::Template;   # new Template
use strict;
require Exporter;
use C4::Database;     # configfile
use C4::Output;       # themelanguage
use CGI;              # new CGI
use C4::Auth;         # checkauth

my $query = new CGI;
#my ($loggedinuser, $cookie, $sessionID) = checkauth($query);

my $configfile = configfile();

my $htdocs = $configfile->{'opachtdocs'};

my $templatebase = "opac-main.tmpl";

my ($theme, $lang) = themelanguage($htdocs, $templatebase);

my $template = HTML::Template->new(filename => "$htdocs/$theme/$lang/$templatebase", die_on_bad_params => 0, path => ["$htdocs/includes"]);

#$template->param(SITE_RESULTS => $sitearray);
print "Content-Type: text/html\n\n", $template->output;
