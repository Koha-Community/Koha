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
use C4::Date;

my $input = new CGI;
my $type=$input->param('type');
my $order=$input->param('order');

my $theme = $input->param('theme'); # only used if allowthemeoverride is set

my ($template, $loggedinuser, $cookie)
      = get_template_and_user({template_name => "circ/reserve.tmpl",
	                                 query => $input,
	                                 type => "intranet",
	                                 authnotrequired => 0,
	                                 flagsrequired => {borrowers => 1},
	                                 debug => 1,
	                                 });
# borrowernumber   	int(11) 
# 	 reservedate  	date 	
# 	 biblionumber  	int(11) 
# 	 constrainttype  	char(1)
# 	 branchcode  	varchar(4) 
# 	 notificationdate  	date 	
# 	 reminderdate  	date 	  	
# 	 cancellationdate  	date 	
# 	 reservenotes  	text 	
# 	 priority  	smallint(6) 
# 	 found  	char(1) 	
# 	 timestamp  	timestamp 	  	ON UPDATE CURRENT_TIMESTAMP 	Oui  	CURRENT_TIMESTAMP  	  	Modifier 	Supprimer 	Primaire 	Index 	Unique 	Texte entier
# 	 itemnumber  	int(11) 	
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
my $strsth="select reservedate,reserves.borrowernumber as bornum, concat(firstname,' ',surname) as borrower, borrowers.phone, borrowers.emailaddress,reserves.biblionumber, reserves.branchcode as branch, items.holdingbranch, items.itemcallnumber, items.itemnumber, notes, notificationdate, reminderdate, priority, reserves.found, biblio.title, biblio.author from reserves left join items on items.itemnumber=reserves.itemnumber, borrowers,biblio where isnull(cancellationdate) && reserves.borrowernumber=borrowers.borrowernumber && reserves.biblionumber=biblio.biblionumber order by reservedate, borrower ";
$strsth="select reservedate,reserves.borrowernumber as bornum,concat(firstname,' ',surname) as borrower, borrowers.phone, borrowers.emailaddress,reserves.biblionumber, reserves.branchcode as branch, items.holdingbranch, items.itemcallnumber, items.itemnumber, notes, notificationdate, reminderdate, priority, reserves.found, biblio.title, biblio.author from reserves left join items on  items.itemnumber=reserves.itemnumber , borrowers,biblio where isnull(cancellationdate) && reserves.borrowernumber=borrowers.borrowernumber && reserves.biblionumber=biblio.biblionumber order by borrower,reservedate " if ($order eq "borrower");
$strsth="select reservedate,reserves.borrowernumber as bornum,concat(firstname,' ',surname) as borrower, borrowers.phone, borrowers.emailaddress,reserves.biblionumber, reserves.branchcode as branch, items.holdingbranch, items.itemcallnumber, items.itemnumber, notes, notificationdate, reminderdate, priority, reserves.found, biblio.title, biblio.author from reserves left join items on items.itemnumber=reserves.itemnumber, borrowers,biblio where isnull(cancellationdate) && reserves.borrowernumber=borrowers.borrowernumber && reserves.biblionumber=biblio.biblionumber order by biblio.title, priority,reservedate " if ($order eq "biblio");
my $sth=$dbh->prepare($strsth);
warn "".$strsth;
$sth->execute();

my @reservedata;
while (my $data=$sth->fetchrow_hashref) {
  push (@reservedata, 
			{
				reservedate  => format_date($data->{reservedate}),
				priority	 => $data->{priority},
				name         => $data->{borrower},
				title        => $data->{title},
				author       => $data->{author},
				bornum       => $data->{bornum},
				itemnum      => $data->{itemnumber},
				phone        => $data->{phone},
				email        => $data->{email},
				biblionumber => $data->{biblionumber},
				statusw		 => ($data->{found} eq "w"),
				statusf		 => ($data->{found} eq "f"),
				holdingbranch		 => $data->{holdingbranch},
				branch		 => $data->{branch},
				itemcallnumber => $data->{itemcallnumber},
				notes		 => $data->{notes},
				notificationdate => $data->{notificationdate},
				reminderdate => $data->{reminderdate}
			}
	
	);

}

$sth->finish;

$template->param(todaysdate        => format_date($todaysdate),
		reserveloop       => \@reservedata,
		intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
		intranetstylesheet => C4::Context->preference("intranetstylesheet"),
		IntranetNav => C4::Context->preference("IntranetNav"),
		);

print "Content-Type: text/html\n\n", $template->output;
