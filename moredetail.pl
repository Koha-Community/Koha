#!/usr/bin/perl
# NOTE: Use standard 8-space tabs for this file (indents are 4 spaces)

# $Id$

# Copyright 2000-2003 Katipo Communications
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
use C4::Koha;
use CGI;
use C4::Search;
use C4::Catalogue;
use C4::Output; # contains gettemplate
use C4::Auth;
use C4::Interface::CGI::Output;

my $query=new CGI;

# FIXME  subject is not exported to the template?
my $subject=$query->param('subject');

# if its a subject we need to use the subject.tmpl
my ($template, $loggedinuser, $cookie) = get_template_and_user({
	template_name   => ($subject? 'catalogue/subject.tmpl':
				      'catalogue/moredetail.tmpl'),
	query           => $query,
	type            => "intranet",
	authnotrequired => 0,
	flagsrequired   => {catalogue => 1},
    });

# get variables

my $biblionumber=$query->param('bib');
my $title=$query->param('title');
my $bi=$query->param('bi');

my $data=bibitemdata($bi);
my $dewey = $data->{'dewey'};
# FIXME Dewey is a string, not a number, & we should use a function
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

foreach my $item (@items){
    $item->{'itemlost'}=~ s/0/No/;
    $item->{'itemlost'}=~ s/1/Yes/;
    $item->{'withdrawn'}=~ s/0/No/;
    $item->{'withdrawn'}=~ s/1/Yes/;
    $item->{'replacementprice'}+=0.00;
    my $year=substr($item->{'timestamp0'},0,4);
    my $mon=substr($item->{'timestamp0'},4,2);
    my $day=substr($item->{'timestamp0'},6,2);
    $item->{'timestamp0'}="$day/$mon/$year";
    $item->{'dateaccessioned'} = slashifyDate($item->{'dateaccessioned'});
    $item->{'datelastseen'} = slashifyDate($item->{'datelastseen'});
    $item->{'ordernumber'} = $ordernum;
    $item->{'booksellerinvoicenumber'} = $order->{'booksellerinvoicenumber'};

    # FIXME untranslatable strings
    if ($item->{'date_due'} eq 'Available'){
	$item->{'issue'}="<b>Available</b><br>";
    } else {
	$item->{'issue'}="<b>Currently on issue to:</b> <a href=/cgi-bin/koha/moremember.pl?bornum=$item->{'borrower0'}>$item->{'card'}</a><br>";
    }
}

$template->param(BIBITEM_DATA => \@results);
$template->param(ITEM_DATA => \@items);
$template->param(loggedinuser => $loggedinuser);

output_html_with_http_headers $query, $cookie, $template->output;


# Local Variables:
# tab-width: 8
# End:
