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

my $input = new CGI;
my $type=$input->param('type');

my $theme = $input->param('theme'); # only used if allowthemeoverride is set
my ($template, $loggedinuser, $cookie)
	= get_template_and_user({template_name => "overdue.tmpl",
		     query => $query,
		     type => "intranet",
		     authnotrequired => 0,
		     flagsrequired => {catalogue => 1},
		     debug => 1,
		     });
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

my $query="select date_due,borrowernumber,itemnumber from issues where isnull(returndate) && date_due<'$todaysdate' order by date_due,borrowernumber";
my $sth=$dbh->prepare($query);
$sth->execute;

my @overduedata;
while (my $data=$sth->fetchrow_hashref) {
  $duedate=$data->{'date_due'};
  $bornum=$data->{'borrowernumber'};
  $itemnum=$data->{'itemnumber'};

  my $query="select concat(firstname,' ',surname),phone,emailaddress from borrowers where borrowernumber='$bornum'";
  my $sth1=$dbh->prepare($query);
  $sth1->execute;
  $data1=$sth1->fetchrow_hashref;
  $name=$data1->{'concat(firstname,\' \',surname)'};
  $phone=$data1->{'phone'};
  $email=$data1->{'emailaddress'};
  $sth1->finish;

  # FIXME - There's already a $query in this scope.
  my $query="select biblionumber from items where itemnumber='$itemnum'";
  my $sth2=$dbh->prepare($query);
  $sth2->execute;
  $data2=$sth2->fetchrow_hashref;
  $biblionumber=$data2->{'biblionumber'};
  $sth2->finish;

  # FIXME - There's already a $query in this scope.
  my $query="select title,author from biblio where biblionumber='$biblionumber'";
  my $sth3=$dbh->prepare($query);
  $sth3->execute;
  $data3=$sth3->fetchrow_hashref;
  $title=$data3->{'title'};
  $author=$data3->{'author'};
  $sth3->finish;
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

$template->param( startmenureport => join ('', startmenu('report')),
		endmenureport     => join ('', endmenu('report')),
		todaysdate        => $todaysdate,
		overdueloop       => \@overduedata );

print "Content-Type: text/html\n\n", $template->output;
