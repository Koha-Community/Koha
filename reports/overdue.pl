#!/usr/bin/perl

# $Id$

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
use C4::Context;
use CGI;

use C4::Auth;
use C4::Date;
use C4::Biblio;
use C4::Search;
use C4::Interface::CGI::Output;
use C4::Date;
my $input = new CGI;
my $type=$input->param('type');

my $theme = $input->param('theme'); # only used if allowthemeoverride is set

my ($template, $loggedinuser, $cookie)
      = get_template_and_user({template_name => "reports/overdue.tmpl",
	                                 query => $input,
	                                 type => "intranet",
	                                 authnotrequired => 0,
	                                 flagsrequired => {borrowers => 1},
	                                 debug => 1,
	                                 });
my $duedate;
my $bornum;
my $itemnumber;
my $barcode;
my $data1;
my $data2;
my $data3;
my $name;
my $categorycode;
my $phone;
my $email;
my $biblionumber;
my $title;
my $author;
my @datearr = localtime(time());
my $todaysdate = (1900+$datearr[5]).'-'.sprintf ("%0.2d", ($datearr[4]+1)).'-'.sprintf ("%0.2d", $datearr[3]);
my $dateformatted= sprintf ("%0.2d", $datearr[3]).'-'.sprintf ("%0.2d", ($datearr[4]+1)).'-'.(1900+$datearr[5]);
my $dbh = C4::Context->dbh;
my $count=0;
my @results;
my @kohafields;
my @values;
my @relations;
my $sort;
my @and_or;
push @kohafields, "date_due","date_due";
push @values,$todaysdate,"0000-00-00";
push @relations ,"\@attr 2=1","\@attr 2=5"; ## 
push @and_or,"\@and";
	($count,@results)=ZEBRAsearch_kohafields(\@kohafields,\@values,\@relations,$sort,\@and_or);



my @overduedata;
foreach my $xml(@results) {
my @kohafields; ## just parse the fields required
push @kohafields,"title","author","biblionumber","itemnumber","barcode","date_due","borrowernumber";
my ($biblio,@itemrecords) = XMLmarc2koha($dbh,$xml,"",@kohafields);
 foreach my $data(@itemrecords){
   if ($data->{'date_due'} lt $todaysdate && $data->{'date_due'} gt "0000-00-00" ){
  $duedate=format_date($data->{'date_due'});
  $bornum=$data->{'borrowernumber'};
  $itemnumber=$data->{'itemnumber'};
  $biblionumber=$data->{'biblionumber'};
  $barcode=$data->{'barcode'};

  my $sth1=$dbh->prepare("select concat(firstname,' ',surname),phone,emailaddress,categorycode from borrowers where borrowernumber=?");
  $sth1->execute($bornum);
  $data1=$sth1->fetchrow_hashref;
  $name=$data1->{'concat(firstname,\' \',surname)'};
  $phone=$data1->{'phone'};
  $categorycode=$data1->{'categorycode'};
  $email=$data1->{'emailaddress'};
  $sth1->finish;

 



  $title=$biblio->{'title'};
  $author=$biblio->{'author'};
   push (@overduedata, {	duedate      => format_date($duedate),
			bornum       => $bornum,
			itemnum      => $itemnumber,
			name         => $name,
			categorycode         => $categorycode,
			phone        => $phone,
			email        => $email,
			biblionumber => $biblionumber,

			barcode		=>$barcode,
			title        => $title,
			author       => $author });
  }## if overdue

  }##foreach item
}## for each biblio

$template->param(		dateformatted      => $dateformatted, count=>$count,
		overdueloop       => \@overduedata );

output_html_with_http_headers $input, $cookie, $template->output;
