#!/usr/bin/perl

# $Id$

#script to recieve orders
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
use C4::Interface::CGI::Output;
use C4::Database;
use HTML::Template;

my $input=new CGI;
my $id=$input->param('id');
my $dbh = C4::Context->dbh;

my $search=$input->param('recieve');
my $invoice=$input->param('invoice');
my $freight=$input->param('freight');
my $biblio=$input->param('biblio');
my $catview=$input->param('catview');
my $gst=$input->param('gst');
my ($count,@results)=ordersearch($search,$id,$biblio,$catview);
my ($count2,@booksellers)=bookseller($results[0]->{'booksellerid'});
my @date=split('-',$results[0]->{'entrydate'});
my $date="$date[2]/$date[1]/$date[0]";

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "acqui/acquire.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {acquisition => 1},
			     debug => 1,
			     });

$template->param($count);
if ($count == 1){
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
				-default  => $results[0]->{'itemtype'},
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
				-default  => $results[0]->{'branchcode'},
				-labels   => \%select_branches,
				-size     => 1,
				-multiple => 0 );
	$sth->finish;

	my $auto_barcode = C4::Context->boolean_preference("autoBarcode") || 0;
		# See whether barcodes should be automatically allocated.
		# Defaults to 0, meaning "no".
	my $barcode;
	if ($auto_barcode eq '1') {
		$sth=$dbh->prepare("Select max(barcode) from items");
		$sth->execute;
		my $data=$sth->fetchrow_hashref;
		$barcode = $results[0]->{'barcode'}+1;
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
				-default  => $results[0]->{'bookfundid'},
				-labels   => \%select_bookfunds,
				-size     => 1,
				-multiple => 0 );

	my $rrp=$results[0]->{'rrp'};
	if ($results[0]->{'quantityreceived'} == 0){
	$results[0]->{'quantityreceived'}='';
	}
	if ($results[0]->{'unitprice'} == 0){
	$results[0]->{'unitprice'}='';
	}
	$template->param(
		count => 1,
		biblionumber => $results[0]->{'biblionumber'},
		ordernumber => $results[0]->{'ordernumber'},
		biblioitemnumber => $results[0]->{'biblioitemnumber'},
		booksellerid => $results[0]->{'booksellerid'},
		freight => $freight,
		gst => $gst,
		catview => ($catview ne 'yes'?1:0),
		name => $booksellers[0]->{'name'},
		date => $date,
		title => $results[0]->{'title'},
		author => $results[0]->{'author'},
		copyrightdate => $results[0]->{'copyrightdate'},
		CGIitemtype => $CGIitemtype,
		CGIbranch => $CGIbranch,
		isbn => $results[0]->{'isbn'},
		seriestitle => $results[0]->{'seriestitle'},
		barcode => $barcode,
		CGIbookfund => $CGIbookfund,
		quantity => $results[0]->{'quantity'},
		quantityreceived => $results[0]->{'quantityreceived'},
		rrp => $rrp,
		ecost => $results[0]->{'ecost'},
		unitprice => $results[0]->{'unitprice'},
		invoice => $invoice,
		notes => $results[0]->{'notes'},
	);
} else {
	my @loop;
	for (my $i=0;$i<$count;$i++){
		my %line;
		$line{isbn} = $results[$i]->{'isbn'};
		$line{basketno} = $results[$i]->{'basketno'};
		$line{quantity} = $results[$i]->{'quantity'};
		$line{quantityrecieved} = $results[$i]->{'quantityreceived'};
		$line{ordernumber} = $results[$i]->{'ordernumber'};
		$line{biblionumber} = $results[$i]->{'biblionumber'};
		$line{invoice} = $invoice;
		$line{freight} = $freight;
		$line{gst} = $gst;
		$line{title} = $results[$i]->{'title'};
		$line{author} = $results[$i]->{'author'};
		$line{id} = $id;
		push @loop,\%line;
	}
	$template->param( loop => \@loop,
						user => $loggedinuser,
						date => $date,
						name => $booksellers[0]->{'name'},
						id => $id,
						invoice => $invoice,
);

}
output_html_with_http_headers $input, $cookie, $template->output;
