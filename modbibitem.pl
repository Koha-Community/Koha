#!/usr/bin/perl

# $Id$

#script to modify/delete groups

#written 8/11/99
# modified 11/11/99 by chris@katipo.co.nz
# modified 18/4/00 by chris@katipo.co.nz

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
use C4::Output;
use C4::Koha;
use CGI;
use HTML::Template;

use C4::Biblio;
use C4::Catalogue;
use C4::Auth;
use C4::Interface::CGI::Output;

my $input = new CGI;
my $bibitemnum=$input->param('bibitem');
my $data=bibitemdata($bibitemnum);
my $biblio=$input->param('biblio');
my $submit=$input->param('submit.x');
if ($submit eq ''){
  print $input->redirect("deletebiblioitem.pl?biblioitemnumber=$bibitemnum&biblionumber=$biblio");
}

my ($template, $loggedinuser, $cookie) = get_template_and_user({
	template_name   => 'modbibitem.tmpl',
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
my $dewey = $data->{'dewey'};
$dewey =~ s/0+$//;
if ($dewey eq "000.") { $dewey = "";};
if ($dewey < 10){$dewey='00'.$dewey;}
if ($dewey < 100 && $dewey > 10){$dewey='0'.$dewey;}
if ($dewey <= 0){
  $dewey='';
}
$dewey=~ s/\.$//;
$inputs{'Class'}="text\t$data->{'classification'}$dewey$data->{'subclass'}\t2";
$inputs{'Item Type'}="text\t$data->{'itemtype'}\t3";
$inputs{'URL'}="text\t$data->{'url'}\t4";
$inputs{'Publisher'}="text\t$data->{'publishercode'}\t5";
#$inputs{'Copyright date'}="text\t$data->{'copyrightdate'}\t6";
$inputs{'ISBN'}="text\t$data->{'isbn'}\t7";
$inputs{'Publication Year'}="text\t$data->{'publicationyear'}\t8";
$inputs{'Pages'}="text\t$data->{'pages'}\t9";
$inputs{'Illustrations'}="text\t$data->{'illustration'}\t10";
#$inputs{'Series Title'}="text\t$data->{'seriestitle'}\t11";
#$inputs{'Additional Author'}="text\t$additional\t12";
#$inputs{'Subtitle'}="text\t$subtitle->[0]->{'subtitle'}\t13";
#$inputs{'Unititle'}="text\t$data->{'unititle'}\t14";
#$inputs{'Notes'}="textarea\t$data->{'notes'}\t15";
#$inputs{'Serial'}="text\t$data->{'serial'}\t16";
$inputs{'Volume'}="text\t$data->{'volumeddesc'}\t17";
#$inputs{'Analytic author'}="text\t\t18";
#$inputs{'Analytic title'}="text\t\t19";

$inputs{'bibnum'}="hidden\t$data->{'biblionumber'}\t20";
$inputs{'bibitemnum'}="hidden\t$data->{'biblioitemnumber'}\t21";

$template->param( biblionumber => $data->{'biblionumber'},
								title => $data->{'title'},
								author => $data->{'author'},
								description => $data->{'description'},
								loggedinuser => $loggedinuser,
								);

my ($count,@bibitems)=bibitems($data->{'biblionumber'});

my @bibitemloop;

for (my $i=0;$i<$count;$i++){
	my %line;
	$line{biblioitemnumber} = $bibitems[$i]->{'biblioitemnumber'};
	$line{description} = $bibitems[$i]->{'description'};
	$line{isbn} = $bibitems[$i]->{'isbn'};
	push(@bibitemloop,\%line);
}
$template->param(bibitemloop =>\@bibitemloop);


#my $notesinput=$input->textfield(-name=>'Notes', -default=>$data->{'bnotes'}, -size=>20);
$template->param(bnotes=>$data->{'bnotes'});

$template->param(itemtype => $data->{'itemtype'});

$template->param(url => $data->{'url'});
$template->param(classification => $data->{'classification'},
								dewey => $dewey,
								subclass => $data->{'subclass'},
								publishercode => $data->{'publishercode'},
								place => $data->{'place'},
								isbn => $data->{'isbn'},
								publicationyear => $data->{'publicationyear'},
								pages => $data->{'pages'},
								illustration => $data->{'illustration'},
								volumeddesc => $data->{'volumeddesc'},
								size => $data->{'size'},
								biblionumber => $data->{'biblionumber'},
								biblioitemnumber => $data->{'biblioitemnumber'});

my (@items)=itemissues($data->{'biblioitemnumber'});
#print @items;
my @itemloop;
my $count=@items;
for (my $i=0;$i<$count;$i++){
	my %line;
  	$items[$i]->{'datelastseen'} = slashifyDate($items[$i]->{'datelastseen'});
	$line{barcode}=$items[$i]->{'barcode'};
	$line{itemnumber}=$items[$i]->{'itemnumber'};
	$line{biblionumber}=$data->{'biblionumber'};
	$line{biblioitemnumber}=$data->{'biblioitemnumber'};
	$line{holdingbranch}=$items[$i]->{'holdingbranch'};
	$line{datelastseen}=$items[$i]->{'datelastseen'};
	push(@itemloop,\%line);
}
$template->param(itemloop => \@itemloop);
print "Content-Type: text/html\n\n", $template->output;

