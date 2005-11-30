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
use C4::Output;
use CGI;
use HTML::Template;
use C4::Auth;
use C4::Koha;
use C4::Acquisition;

my $input = new CGI;
my $type=$input->param('type');
my $order=$input->param('order');
my $bornamefilter=$input->param('borname');
my $borcatfilter=$input->param('borcat');
my $itemtypefilter=$input->param('itemtype');
my $borflagsfilter=$input->param('borflags');
my $branchfilter=$input->param('branch');
my $showall=$input->param('showall');
warn "shoall :".$showall;
my $theme = $input->param('theme'); # only used if allowthemeoverride is set

my ($template, $loggedinuser, $cookie)
      = get_template_and_user({template_name => "overdue.tmpl",
	                                 query => $input,
	                                 type => "intranet",
	                                 authnotrequired => 0,
	                                 flagsrequired => {borrowers => 1},
	                                 debug => 1,
	                                 });
my $dbh = C4::Context->dbh;
my $req;
$req = $dbh->prepare( "select categorycode, description from categories order by description");
$req->execute;
my %select_catcode;
my @select_catcode;
push @select_catcode,"";
$select_catcode{""} = "";
while (my ($catcode, $description) =$req->fetchrow) {
	push @select_catcode, $catcode;
	$select_catcode{$catcode} = $description
}
my $CGIcatcode=CGI::scrolling_list( -name     => 'borcat',
			-id => 'borcat',
			-values   => \@select_catcode,
			-labels   => \%select_catcode,
			-size     => 1,
			-multiple => 0 );
$req = $dbh->prepare( "select itemtype, description from itemtypes order by description");
$req->execute;
my %select_itemtype;
my @select_itemtype;
push @select_itemtype,"";
$select_itemtype{""} = "";
while (my ($itemtype, $description) =$req->fetchrow) {
	push @select_itemtype, $itemtype;
	$select_itemtype{$itemtype} = $description
}
my $CGIitemtype=CGI::scrolling_list( -name     => 'itemtype',
			-id => 'itemtype',
			-values   => \@select_itemtype,
			-labels   => \%select_itemtype,
			-size     => 1,
			-multiple => 0 );
my @branches;
my @select_branch;
my %select_branches;
my ($count2,@branches)=branches();
push @select_branch,"";
$select_branches{''}='';
for (my $i=0;$i<$count2;$i++){
		push @select_branch, $branches[$i]->{'branchcode'};#
		$select_branches{$branches[$i]->{'branchcode'}} = $branches[$i]->{'branchname'};
}
my $CGIbranch=CGI::scrolling_list( -name     => 'branch',
						-values   => \@select_branch,
						-labels   => \%select_branches,
						-size     => 1,
						-multiple => 0 );
my @selectflags;
push @selectflags, " ";#
push @selectflags,"gonenoaddress";#
push @selectflags,"debarred";#
push @selectflags,"lost";#
my $CGIflags=CGI::scrolling_list( -name     => 'borflags',
						-id =>'borflags',
 						-values   => \@selectflags,
# 						-labels   => \%selectflags,
						-size     => 1,
						-multiple => 0 );
$template->param(CGIcatcodes        => $CGIcatcode,
					CGIitemtypes    => $CGIitemtype,
					CGIbranches     => $CGIbranch,
					CGIflags     => $CGIflags,
					borname => $bornamefilter,
					showall => $showall);

my $duedate;
my $bornum;
my $itemnum;
my $data1;
my $data2;
my $data3;
my $name;
my $phone;
my $email;
my $biblionumber;
my $title;
my $author;
my @datearr = localtime(time());
my $todaysdate = (1900+$datearr[5]).'-'.sprintf ("%0.2d", ($datearr[4]+1)).'-'.sprintf ("%0.2d", $datearr[3]);

my $dbh = C4::Context->dbh;
my $strsth="select date_due,concat(firstname,' ',surname) as borrower, borrowers.phone, borrowers.emailaddress,issues.itemnumber, biblio.title, biblio.author from issues, borrowers,items,biblioitems, biblio where isnull(returndate) ";
$strsth.= " && date_due<'".$todaysdate."' " unless ($showall);
$strsth.= " && issues.borrowernumber=borrowers.borrowernumber && issues.itemnumber=items.itemnumber && biblioitems.biblioitemnumber=items.itemnumber && biblio.biblionumber=items.biblionumber ";
$strsth.=" && (borrowers.firstname like '".$bornamefilter."%' or borrowers.surname like '".$bornamefilter."%' or borrowers.cardnumber like '".$bornamefilter."%')" if($bornamefilter) ;
$strsth.=" && borrowers.categorycode = '".$borcatfilter."' " if($borcatfilter) ;
$strsth.=" && biblioitems.itemtype = '".$itemtypefilter."' " if($itemtypefilter) ;
$strsth.=" && borrowers.flags = '".$borflagsfilter."' " if ($borflagsfilter ne " ") ;
$strsth.=" && issues.issuingbranch = '".$branchfilter."' " if($branchfilter) ;
# my $bornamefilter=$input->param('borname');
# my $borcatfilter=$input->param('borcat');
# my $itemtypefilter=$input->param('itemtype');
# my $borflagsfilter=$input->param('borflags');
# my $branchfilter=$input->param('branch');

if ($order eq "borrower"){
	$strsth.=" order by borrower,date_due " ;
} else {
	$strsth.=" order by date_due,borrower ";
}
my $sth=$dbh->prepare($strsth);
warn "".$strsth;
$sth->execute();

my @overduedata;
while (my $data=$sth->fetchrow_hashref) {
  $duedate=$data->{'date_due'};
  $itemnum=$data->{'itemnumber'};

  $name=$data->{'borrower'};
  $phone=$data->{'phone'};
  $email=$data->{'emailaddress'};

  $title=$data->{'title'};
  $author=$data->{'author'};
  push (@overduedata, {	duedate      => $duedate,
			bornum       => $bornum,
			itemnum      => $itemnum,
			name         => $name,
			phone        => $phone,
			email        => $email,
			biblionumber => $biblionumber,
			title        => $title,
			author       => $author });

}

$sth->finish;
$template->param(		todaysdate        => $todaysdate,
		overdueloop       => \@overduedata );

print "Content-Type: text/html\n\n", $template->output;
