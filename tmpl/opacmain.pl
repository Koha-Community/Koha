#!/usr/bin/perl
use HTML::Template;
use strict;
require Exporter;
use C4::Database;
use C4::Output;  # contains picktemplate
use CGI;
use C4::Auth;

my $query = new CGI;
#my ($loggedinuser, $cookie, $sessionID) = checkauth($query);

my %configfile;
open (KC, "/etc/koha.conf");
while (<KC>) {
 chomp;
 (next) if (/^\s*#/);
 if (/(.*)\s*=\s*(.*)/) {
   my $variable=$1;
   my $value=$2;
   # Clean up white space at beginning and end
   $variable=~s/^\s*//g;
   $variable=~s/\s*$//g;
   $value=~s/^\s*//g;
   $value=~s/\s*$//g;
   $configfile{$variable}=$value;
 }
}

my $htdocs=$configfile{'opachtdocs'};
my $templatebase="opac-main.tmpl";
my ($theme, $lang)=themelanguage($htdocs, $templatebase);

my $template = HTML::Template->new(filename => "$htdocs/$theme/$lang/$templatebase", die_on_bad_params => 0, path => ["$htdocs/includes"]);

#$template->param(SITE_RESULTS => $sitearray);
print "Content-Type: text/html\n\n", $template->output;
