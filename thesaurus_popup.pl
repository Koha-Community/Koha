#!/usr/bin/perl

# written 10/5/2002 by Paul
# build result field using bibliothesaurus table


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
use C4::Auth;
use CGI;
use C4::Context;
use HTML::Template;
use C4::Search;
use C4::Output;
use C4::Authorities;
use C4::Interface::CGI::Output;
# get all the data ....
my %env;

my $input = new CGI;
my $result = $input->param('result');
my $search_string= $input->param('search_string');
my $op = $input->param('op');
my $id = $input->param('id');
my $category = $input->param('category');
my $index= $input->param('index');
my $insert = $input->param('insert');

my $dbh = C4::Context->dbh;

# make the page ...
#print $input->header;
if ($op eq "select") {
	my $sti = $dbh->prepare("select father,stdlib from bibliothesaurus where id=?");
	$sti->execute($id);
	my ($father,$freelib_text) = $sti->fetchrow_array;
	if (length($result)>0) {
		$result .= "|$father $freelib_text";
	} else {
		$result = "$father $freelib_text";
	}
}
if ($op eq "add") {
	newauthority($dbh,$category,$insert,$insert,'',1,'');
	$search_string=$insert;
}
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "thesaurus_popup.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });
# /search thesaurus terms starting by search_string
my @freelib;
my %stdlib;
my $select_list;
if ($search_string) {
#	my $sti=$dbh->prepare("select id,freelib from bibliothesaurus where freelib like '".$search_string."%' and category ='$category'");
	my $sti=$dbh->prepare("select id,freelib,father from bibliothesaurus where match (category,freelib) AGAINST (?) and category ='$category'");
	$sti->execute($search_string);
	while (my $line=$sti->fetchrow_hashref) {
		$stdlib{$line->{'id'}} = "$line->{'father'} $line->{'freelib'}";
		push(@freelib,$line->{'id'});
	}
	$select_list= CGI::scrolling_list( -name=>'id',
			-values=> \@freelib,
			-default=> "",
			-size=>1,
			-multiple=>0,
			-labels=> \%stdlib
			);
}
my $x = SearchDeeper('',$category,$search_string);
#my @son;
#foreach (my $value @$x) {
#	warn \@$x[$value]->{'stdlib'};
#}
my $dig_list= CGI::scrolling_list( -name=>'search_string',
		-values=> \@$x,
		-default=> "",
		-size=>1,
		-multiple=>0,
		);

$template->param(select_list => $select_list,
						search_string => $search_string,
						dig_list => $dig_list,
						result => $result,
						category => $category,
						index => $index
						);
output_html_with_http_headers $input, $cookie, $template->output;


