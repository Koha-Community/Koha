#!/usr/bin/perl
# NOTE: Use standard 8-space tabs for this file (indents are 4 spaces)

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
use C4::Output;  # contains gettemplate
use CGI;
use C4::Search;
use C4::Auth;
use C4::Interface::CGI::Output;

my $query=new CGI;
my $type=$query->param('type');
($type) || ($type='intra');

my $biblionumber=$query->param('bib');
#my $type='intra';	# FIXME - There's already a $type in this scope


# change back when ive fixed request.pl
my @items = ItemInfo(undef, $biblionumber, $type);
my $norequests = 1;
foreach my $itm (@items) {
     $norequests = 0 unless $itm->{'notforloan'};
}



my $dat=bibdata($biblionumber);
my ($authorcount, $addauthor)= &addauthor($biblionumber);
my ($webbiblioitemcount, @webbiblioitems) = &getwebbiblioitems($biblionumber);
my ($websitecount, @websites)             = &getwebsites($biblionumber);

$dat->{'count'}=@items;
$dat->{'norequests'} = $norequests;

$dat->{'additional'}=$addauthor->[0]->{'author'};
for (my $i = 1; $i < $authorcount; $i++) {
        $dat->{'additional'} .= "|" . $addauthor->[$i]->{'author'};
} # for

my @results;

$results[0]=$dat;

my $resultsarray=\@results;
my $itemsarray=\@items;
my $webarray=\@webbiblioitems;
my $sitearray=\@websites;

my $startfrom=$query->param('startfrom');
($startfrom) || ($startfrom=0);

my ($template, $loggedinuser, $cookie) = get_template_and_user({
	template_name   => ($type eq 'opac'? 'catalogue/detail-opac.tmpl':
					     'catalogue/detail.tmpl'),
	query           => $query,
	type            => "intranet",
	authnotrequired => ($type eq 'opac'),
	flagsrequired   => {catalogue => 1},
    });

my $count=1;

# now to get the items into a hash we can use and whack that thru


$template->param(startfrom => $startfrom+1);
$template->param(endat => $startfrom+20);
$template->param(numrecords => $count);
my $nextstartfrom=($startfrom+20<$count-20) ? ($startfrom+20) : ($count-20);
my $prevstartfrom=($startfrom-20>0) ? ($startfrom-20) : (0);
$template->param(nextstartfrom => $nextstartfrom);
$template->param(prevstartfrom => $prevstartfrom);
$template->param(BIBLIO_RESULTS => $resultsarray);
$template->param(ITEM_RESULTS => $itemsarray);
$template->param(WEB_RESULTS => $webarray);
$template->param(SITE_RESULTS => $sitearray);
$template->param(loggedinuser => $loggedinuser);
output_html_with_http_headers $query, $cookie, $template->output;


# Local Variables:
# tab-width: 8
# End:
