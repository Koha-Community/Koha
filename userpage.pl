#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

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
