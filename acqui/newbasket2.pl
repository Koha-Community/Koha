#!/usr/bin/perl
#origninally script to provide intranet (librarian) advanced search facility
#now script to do searching for acquisitions


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
use C4::Search;
use CGI;
use C4::Output;
use C4::Acquisition;
use C4::Biblio;
use HTML::Template;
use C4::Auth;
use C4::Interface::CGI::Output;

my $env;
my $input = new CGI;

#print $input->header;

#whether it is called from the opac of the intranet
my $type=$input->param('type');
if ($type eq ''){
  $type = 'intra';
}

#print $input->dump;
my $blah;
my %search;
#build hash of users input
my $title=$input->param('search');
$search{'title'}=$title;
my $keyword=$input->param('d');
$search{'keyword'}=$keyword;
my $author=$input->param('author');
$search{'author'}=$author;

my @results;
my $offset=$input->param('offset');
if ($offset eq ''){
  $offset=0;
}
my $num=$input->param('num');
if ($num eq ''){
  $num=10;
}
my $id=$input->param('id');
my $basket=$input->param('basket');
my $sub=$input->param('sub');
my $donation;
if ($id == 72){
  $donation='yes';
}
#print $sub;
my ($count,@booksellers)=bookseller($id);
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "acqui/newbasket2.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {superlibrarian => 1},
			     debug => 1,
			     });

#my $template = gettemplate("acqui/newbasket2.tmpl");
#print startpage();
#print startmenu('acquisitions');

my $testdonation = ($donation ne 'yes'); #tests if donation = true
if ($keyword ne ''){
	($count,@results)=KeywordSearch(undef,'intra',\%search,$num,$offset);
} elsif ($search{'front'} ne '') {
	($count,@results)=FrontSearch(undef,'intra',\%search,$num,$offset);
}else {
	($count,@results)=CatSearch(undef,'loose',\%search,$num,$offset);
}

my @loopsearch;

while ( my ($key, $value) = each %search) {
	if ($value ne ''){
		my %linesearch;
		$value=~ s/\\//g;
		$linesearch{key}=$key;
		$linesearch{value}=$value;
		push(@loopsearch,\%linesearch);
	}
}

my $offset2=$num+$offset;
my $dispnum=$offset+1;
if ($offset2>$count) {
	$offset2=$count
}


my $count2=@results;
if ($keyword ne '' && $offset > 0){
	$count2=$count-$offset;
	if ($count2 > 10){
		$count2=10;
	}
}
my $i=0;
my $colour=0;

my @loopresult;

while ($i < $count2){
		my %lineres;
		my $toggle;

	my $result=$results[$i];
	$result->{'title'}=~ s/\`/\\\'/g;
	my $title2=$result->{'title'};
	my $author2=$result->{'author'};
	$author2=~ s/ /%20/g;
	$title2=~ s/ /%20/g;
	$title2=~ s/\#/\&\#x23;/g;
	$title2=~ s/\"/\&quot\;/g;

		my $itemcount;
	my $location='';
	my $location_only='';
	my $word=$result->{'author'};
	$word=~ s/([a-z]) +([a-z])/$1%20$2/ig;
	$word=~ s/  //g;
	$word=~ s/ /%20/g;
	$word=~ s/\,/\,%20/g;
	$word=~ s/\n//g;
	$lineres{word}=$word;
	$lineres{type}=$type;

	my ($count,$lcount,$nacount,$fcount,$scount,$lostcount,$mending,$transit)=C4::Search::itemcount($env,$result->{'biblionumber'},$type);
	if ($nacount > 0){
		$location .= "On Loan";
		if ($nacount >1 ){
			$location .= " ($nacount)";
		}
		$location.=" ";
		$lineres{'on-loan-p'}=1;
	}
	if ($lcount > 0){
		$location .= "Levin";
		$location_only .= "Levin";
		if ($lcount >1 ){
			$location .= " ($lcount)";
			$location_only .= " ($lcount)";
		}
		$location.=" ";
		$location_only.=" ";
	}
	if ($fcount > 0){
		$location .= "Foxton";
		$location_only .= "Foxton";
		if ($fcount >1 ){
			$location .= " ($fcount)";
			$location_only .= " ($fcount)";
		}
		$location.=" ";
		$location_only.=" ";
	}
	if ($scount > 0){
		$location .= "Shannon";
		$location_only .= "Shannon";
		if ($scount >1 ){
			$location .= " ($scount)";
			$location_only .= " ($scount)";
		}
		$location.=" ";
		$location_only.=" ";
	}
	if ($lostcount > 0){
		$location .= "Lost";
		if ($lostcount >1 ){
			$location .= " ($lostcount)";
		}
		$location.=" ";
		$lineres{'lost-p'}=1;
	}
	if ($mending > 0){
		$location .= "Mending";
		if ($mending >1 ){
			$location .= " ($mending)";
		}
		$location.=" ";
		$lineres{'mending-p'}=1;
	}
	if ($transit > 0){
		$location .= "In Transit";
		if ($transit >1 ){
			$location .= " ($transit)";
		}
		$location.=" ";
		$lineres{'in-transit-p'}=1;
	}
	if ($colour == 1){
		$toggle='#ffffcc';
		$colour = 0;
	} else{
		$colour = 1;
		$toggle='white';
	}
	$lineres{author2}=$author2;
	$lineres{title2}=$title2;
	$lineres{copyright}=$result->{'copyrightdate'};
	$lineres{id}=$id;
	$lineres{basket}=$basket;
	$lineres{sub}=$sub;
	$lineres{biblionumber}=$result->{biblionumber};
	$lineres{title}=$result->{title};
	$lineres{author}=$result->{author};
	$lineres{toggle}=$toggle;
	$lineres{itemcount}=$count;
	$lineres{location}=$location;
	$lineres{'location-only'}=$location_only;
	push(@loopresult,\%lineres);
	$i++;
}

$offset=$num+$offset;
$template->param(	bookselname => $booksellers[0]->{'name'},
								id => $id,
								basket => $basket,
								parsub => $sub,
								testdonation => $testdonation,
								count => $count,
								offset2 =>$offset2,
								dispnum => $dispnum,
								offsetover => ($offset < $count ),
								num => $num,
								offset => $offset,
								type =>  $type,
								id => $id,
								basket => $basket,
								title => $title,
								author => $author,
								loopsearch =>\@loopsearch,
								loopresult =>\@loopresult,
								'use-location-flags-p' => 1);

output_html_with_http_headers $input, $cookie, $template->output;
