#!/usr/bin/perl

#script to show display basket of orders
#written by chris@katipo.co.nz 24/2/2000


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
use CGI;
use C4::Context;
use C4::Catalogue;
use C4::Biblio;
use C4::Output;
use C4::Search;
use C4::Auth;
use C4::Biblio;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Database;
use HTML::Template;

my $input=new CGI;
my $id=$input->param('id');
my $title=$input->param('title');
my $author=$input->param('author');
my $copyright=$input->param('copyright');
my ($count,@booksellers)=bookseller($id);
my $ordnum=$input->param('ordnum');
my $biblio=$input->param('biblio');
my $basket=$input->param('basket');
my $data;
my $new;
my $dbh = C4::Context->dbh;
if ($ordnum eq ''){
	$new='yes';
	warn "NEW : YES";
	$ordnum=newordernum;
	if ($biblio) {
			$data=bibdata($biblio);
	}
	if ($data->{'title'} eq ''){
		$data->{'title'}=$title;
		$data->{'author'}=$author;
		$data->{'copyrightdate'}=$copyright;
	}
}else {
	$data=getsingleorder($ordnum);
	$biblio=$data->{'biblionumber'};
}
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "acqui/newbiblio.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {acquisition => 1},
			     debug => 1,
			     });

#my ($count2,$currencies)=getcurrencies;
my ($count,$rates)=getcurrencies();
my @loop_currency = ();
for (my $i=0;$i<$count;$i++){
	my %line;
	$line{currency} = $rates->[$i]->{'currency'};
	$line{rate} = $rates->[$i]->{'rate'};
	push @loop_currency, \%line;
}

my $query="Select itemtype,description from itemtypes order by description";
my $sth=$dbh->prepare($query);
$sth->execute;
my  @itemtype;
my %itemtypes;
push @itemtype, "";
$itemtypes{''} = "Please choose";
while (my ($value,$lib) = $sth->fetchrow_array) {
	push @itemtype, $value;
	$itemtypes{$value}=$lib;
}

my $CGIitemtype=CGI::scrolling_list( -name     => 'format',
			-values   => \@itemtype,
			-default  => $data->{'itemtype'},
			-labels   => \%itemtypes,
			-size     => 1,
			-multiple => 0 );
$sth->finish;

my @branches;
my @select_branch;
my %select_branches;
my ($count2,@branches)=branches();
for (my $i=0;$i<$count2;$i++){
	push @select_branch, $branches[$i]->{'branchcode'};#
  	$select_branches{$branches[$i]->{'branchcode'}} = $branches[$i]->{'branchname'};
}
my $CGIbranch=CGI::scrolling_list( -name     => 'branch',
			-values   => \@select_branch,
			-default  => $data->{'branchcode'},
			-labels   => \%select_branches,
			-size     => 1,
			-multiple => 0 );

my $auto_barcode = C4::Context->boolean_preference("autoBarcode") || 0;
	# See whether barcodes should be automatically allocated.
	# Defaults to 0, meaning "no".
my $barcode;
if ($auto_barcode eq '1') {
	$sth=$dbh->prepare("Select max(barcode) from items");
	$sth->execute;
	my $data=$sth->fetchrow_hashref;
	$barcode = $data->{'barcode'}+1;
	$sth->finish;
}

my @bookfund;
my @select_bookfund;
my %select_bookfunds;
($count2,@bookfund)=bookfunds();
for (my $i=0;$i<$count2;$i++){
	push @select_bookfund, $bookfund[$i]->{'bookfundid'};
	$select_bookfunds{$bookfund[$i]->{'bookfundid'}} = $bookfund[$i]->{'bookfundname'}
}
my $CGIbookfund=CGI::scrolling_list( -name     => 'bookfund',
			-values   => \@select_bookfund,
			-default  => $data->{'bookfundid'},
			-labels   => \%select_bookfunds,
			-size     => 1,
			-multiple => 0 );

$template->param( existing => $biblio,
						title => $title,
						ordnum => $ordnum,
						basket => $basket,
						id => $id,
						biblio => $biblio,
						biblioitemnumber => $data->{'biblioitemnumber'},
						itemtype => $data->{'itemtype'},
						discount => $booksellers[0]->{'discount'},
      					listingcst => $booksellers[0]->{'listincgst'},
						listprice => $booksellers[0]->{'listprice'},
						gstreg => $booksellers[0]->{'gstreg'},
						name => $booksellers[0]->{'name'},
						loop_currencies => \@loop_currency,
						orderexists => ($new eq 'yes')?0:1,
						title => $data->{'title'},
						author => $data->{'author'},
						copyrightdate => $data->{'copyrightdate'},
						CGIitemtype => $CGIitemtype,
						CGIbranch => $CGIbranch,
						CGIbookfund => $CGIbookfund,
						isbn => $data->{'isbn'},
						seriestitle => $data->{'seriestitle'},
						quantity => $data->{'quantity'},
						listprice => $data->{'listprice'},
						rrp => $data->{'rrp'},
						ecost => $data->{'ecost'},
						notes => $data->{'notes'},
						barcode => $data->{'barcode'},);

output_html_with_http_headers $input, $cookie, $template->output;

