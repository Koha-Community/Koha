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

# modified by hdl@ifrance.com 12/16/2002, templating

use strict;

use C4::Search;
use CGI;
use C4::Output;
use HTML::Template;
use C4::Auth;

my $input = new CGI;
my $biblionumber       = $input->param('biblionumber');
my ($count, @websites) = &getwebsites($biblionumber);

if ($biblionumber eq '') {
  print $input->redirect("/catalogue/");
} # if

#print $input->header;
#print startpage();
#print startmenu();
my ($template, $loggedinuser, $cookie) = get_template_and_user({
                            template_name   => "modwebsites.tmpl",
                              query           => $input,
                              type            => "intranet",
                              flagsrequired   => {catalogue => 1},
                      });



my @websitesloop;
for (my $i = 0; $i < $count; $i++) {
	my %website;
	$website{'biblionumber'}=$biblionumber;
	$website{'websitenumber'}=$websites[$i]->{'websitenumber'};
	$website{'title'}=$websites[$i]->{'title'};
	$website{'description'}=$websites[$i]->{'description'};
	$website{'url'}=$websites[$i]->{'url'};
	push (@websitesloop, \%website);
} # for

$template->param(	biblionumber => $biblionumber,
								websitesloop => \@websitesloop);

print "Content-Type: text/html\n\n", $template->output;
