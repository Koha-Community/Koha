#!/usr/bin/perl
use HTML::Template;
use strict;
require Exporter;
use C4::Database;
use C4::Output;  # contains picktemplate
use CGI;
use C4::Search;
use C4::Auth;
 
my $query=new CGI;
my ($loggedinuser, $cookie, $sessionID) = checkauth($query);



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



my $includes=$configfile{'includes'};
($includes) || ($includes="/usr/local/www/hdl/htdocs/includes");
my $templatebase="user/userpage.tmpl";
my $theme=picktemplate($includes, $templatebase);

my $template = HTML::Template->new(filename => "$includes/templates/$theme/$templatebase", die_on_bad_params => 0, path => [$includes]);

$template->param(loggedinuser => $loggedinuser);

print $query->header(-cookie => $cookie), $template->output;
