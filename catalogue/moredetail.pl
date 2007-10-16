#!/usr/bin/perl

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

# $Id$

use strict;
require Exporter;
use C4::Koha;
use CGI;
use C4::Biblio;             # to use &GetBiblioItemData &GetItemsByBiblioitemnumber
use C4::Acquisition;
use C4::Output;             # contains gettemplate
use C4::Auth;
use C4::Date;
use C4::Circulation;  # to use itemissues

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

my $biblionumber=$query->param('biblionumber');
my $title=$query->param('title');
my $bi=$query->param('bi');
$bi = $biblionumber unless $bi;
my $data=GetBiblioItemData($bi);
my $dewey = $data->{'dewey'};

# FIXME Dewey is a string, not a number, & we should use a function
# $dewey =~ s/0+$//;
# if ($dewey eq "000.") { $dewey = "";};
# if ($dewey < 10){$dewey='00'.$dewey;}
# if ($dewey < 100 && $dewey > 10){$dewey='0'.$dewey;}
# if ($dewey <= 0){
#      $dewey='';
# }
# $dewey=~ s/\.$//;
# $data->{'dewey'}=$dewey;

my @results;

my $items= GetItemsByBiblioitemnumber($bi);
my $count=@$items;
$data->{'count'}=$count;

my $ordernum = GetOrderNumber($biblionumber,$bi);
my $order = GetOrder($ordernum);

$results[0]=$data;

foreach my $item (@$items){
	$item->{itemlostloop}= GetAuthorisedValues('ITEMLOST');
	$item->{itemdamagedloop}= GetAuthorisedValues('DAMAGED');
    $item->{'replacementprice'}=sprintf("%.2f", $item->{'replacementprice'});
    $item->{'datelastborrowed'}= format_date($item->{'datelastborrowed'});
    $item->{'dateaccessioned'} = format_date($item->{'dateaccessioned'});
    $item->{'datelastseen'} = format_date($item->{'datelastseen'});
    $item->{'ordernumber'} = $ordernum;
    $item->{'booksellerinvoicenumber'} = $order->{'booksellerinvoicenumber'};

    if ($item->{'date_due'} eq ''){
        $item->{'issue'}= 0;
    } else {
        $item->{'date_due'} = format_date($item->{'date_due'});
        $item->{'issue'}= 1;
    }
}

$template->param(BIBITEM_DATA => \@results);
$template->param(ITEM_DATA => $items);
$template->param(loggedinuser => $loggedinuser);
$template->param(biblionumber => $biblionumber);

output_html_with_http_headers $query, $cookie, $template->output;

