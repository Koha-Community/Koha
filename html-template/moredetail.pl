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
use C4::Context;
use C4::Koha;
use CGI;
use C4::Search;
use C4::Acquisitions;
use C4::Output; # contains picktemplate
  
my $query=new CGI;

my $includes = C4::Context->config('includes') ||
	"/usr/local/www/hdl/htdocs/includes";
my $templatebase="catalogue/moredetail.tmpl";
my $startfrom=$query->param('startfrom') || 0;
my $theme=picktemplate($includes, $templatebase);

my $subject=$query->param('subject');
# if its a subject we need to use the subject.tmpl
if ($subject){
  $templatebase=~ s/searchresults\.tmpl/subject\.tmpl/;
}
my $template = HTML::Template->new(filename => "$includes/templates/$theme/$templatebase", die_on_bad_params => 0, path => [$includes]);

# get variables 

my $biblionumber=$query->param('bib');
my $title=$query->param('title');
my $bi=$query->param('bi');

my $data=bibitemdata($bi);
my $dewey = $data->{'dewey'};
$dewey =~ s/0+$//;
if ($dewey eq "000.") { $dewey = "";};
if ($dewey < 10){$dewey='00'.$dewey;}
if ($dewey < 100 && $dewey > 10){$dewey='0'.$dewey;}
if ($dewey <= 0){
      $dewey='';
}
$dewey=~ s/\.$//;
$data->{'dewey'}=$dewey;

my @results;

my (@items)=itemissues($bi);
my $count=@items;
$data->{'count'}=$count;
my ($order,$ordernum)=getorder($bi,$biblionumber);

my $env;
$env->{itemcount}=1;

$results[0]=$data;

$template->param(includesdir => $includes);
$template->param(BIBITEM_DATA => \@results);
$template->param(ITEM_DATA => \@items);
print "Content-Type: text/html\n\n", $template->output;

