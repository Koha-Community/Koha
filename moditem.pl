#!/usr/bin/perl

# $Id$


#script to modify/delete biblios
#written 8/11/99
# modified 11/11/99 by chris@katipo.co.nz
# modified 12/16/02 by hdl@ifrance.com : Templating

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

use strict;
require Exporter;

use C4::Search;
use CGI;
use C4::Output;
#use C4::Acquisitions;
use C4::Biblio;
use HTML::Template;
use C4::Koha;
use C4::Acquisition;
use C4::Auth;
use C4::Interface::CGI::Output;

my $input = new CGI;
my $submit=$input->param('delete.x');
my $itemnum=$input->param('item');
my $bibitemnum=$input->param('bibitem');
if ($submit ne ''){
  print $input->redirect("/cgi-bin/koha/delitem.pl?itemnum=$itemnum&bibitemnum=$bibitemnum");
}

my $data=bibitemdata($bibitemnum);

my $item=itemnodata('blah','',$itemnum);
#my ($analytictitle)=analytic($biblionumber,'t');
#my ($analyticauthor)=analytic($biblionumber,'a');


my ($template, $loggedinuser, $cookie) = get_template_and_user({
	template_name   => 'moditem.tmpl',
	query           => $input,
	type            => "intranet",
	authnotrequired => 0,
	flagsrequired   => {catalogue => 1},
    });

my %inputs;



#hash is set up with input name being the key then
#the value is a tab separated list, the first item being the input type
#$inputs{'Author'}="text\t$data->{'author'}\t0";
#$inputs{'Title'}="text\t$data->{'title'}\t1";
# FIXME - The Dewey code is a string, not a number. And "000" is a
# perfectly acceptable value.
my $dewey = $data->{'dewey'};
$dewey =~ s/0+$//;
if ($dewey eq "000.") { $dewey = "";};
if ($dewey < 10){$dewey='00'.$dewey;}
if ($dewey < 100 && $dewey > 10){$dewey='0'.$dewey;}
if ($dewey <= 0){
  $dewey='';
}
$dewey=~ s/\.$//;

# 12/16/2002 hdl@ifrance.com : all these inputs seem unused !!!

$inputs{'Barcode'}="text\t$item->{'barcode'}\t0";
$inputs{'Class'}="hidden\t$data->{'classification'}$dewey$data->{'subclass'}\t2";
#$inputs{'Item Type'}="text\t$data->{'itemtype'}\t3";
#$inputs{'Subject'}="textarea\t$sub\t4";
$inputs{'Publisher'}="hidden\t$data->{'publishercode'}\t5";
#$inputs{'Copyright date'}="text\t$data->{'copyrightdate'}\t6";
$inputs{'ISBN'}="hidden\t$data->{'isbn'}\t7";
$inputs{'Publication Year'}="hidden\t$data->{'publicationyear'}\t8";
$inputs{'Pages'}="hidden\t$data->{'pages'}\t9";
$inputs{'Illustrations'}="hidden\t$data->{'illustration'}\t10";
#$inputs{'Series Title'}="text\t$data->{'seriestitle'}\t11";
#$inputs{'Additional Author'}="text\t$additional\t12";
#$inputs{'Subtitle'}="text\t$subtitle->[0]->{'subtitle'}\t13";
#$inputs{'Unititle'}="text\t$data->{'unititle'}\t14";
$inputs{'ItemNotes'}="textarea\t$item->{'itemnotes'}\t15";
#$inputs{'Serial'}="text\t$data->{'serial'}\t16";
$inputs{'Volume'}="hidden\t$data->{'volumeddesc'}\t17";
$inputs{'Home Branch'}="text\t$item->{'homebranch'}\t18";
$inputs{'Lost'}="radio\t$item->{'itemlost'}\t19";
#$inputs{'Analytic author'}="text\t\t18";
#$inputs{'Analytic title'}="text\t\t19";
$inputs{'bibnum'}="hidden\t$data->{'biblionumber'}\t20";
$inputs{'bibitemnum'}="hidden\t$data->{'biblioitemnumber'}\t21";
$inputs{'itemnumber'}="hidden\t$itemnum\t22";

#12/16/2002 hdl@ifrance.com : end of comment



#12/16/2002 hdl@ifrance.com : templating
$template->param(	title => $data->{'title'},
								author => $data->{'author'},
								barcode => $item->{'barcode'},
								classification => "$data->{'classification'}$dewey$data->{'subclass'}",
								publisher => $data->{'publisher'},
								publicationyear => $data->{'publicationyear'},
								pages => $data->{'pages'},
								illustration => $data->{'illustration'},
								itemnotes => $item->{'itemnotes'},
								volumedesc => $data->{'volumedesc'},
								homebranch => $data->{'homebranch'},
								itemlost => ($item->{'itemlost'} ==1),
								itemwithdrawn => ($item->{'wthdrawn'} ==1),
								biblionumber => $data->{'biblionumber'},
								biblioitemnumber => $data->{'biblioitemnumber'},
								itemnumber => $itemnum);

print "Content-Type: text/html\n\n", $template->output;
#12/16/2002 hdl@ifrance.com : templating
