#!/usr/bin/perl


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
use C4::Auth;
use C4::Dates qw/format_date format_date_in_iso/;

use vars qw($debug);

BEGIN {
    $debug = $ENV{DEBUG} || 0;
}

my $input = new CGI;
my $order = $input->param('order');
my $startdate=$input->param('from');
my $enddate=$input->param('to');

my $theme = $input->param('theme');    # only used if allowthemeoverride is set

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "circ/pendingreserves.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => 1 },
        debug           => 1,
    }
);

my $duedate;
my $borrowernumber;
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

my @datearr    = localtime( time() );
my $todaysdate =
    ( 1900 + $datearr[5] ) . '-'
  . sprintf( "%0.2d", ( $datearr[4] + 1 ) ) . '-'
  . sprintf( "%0.2d", $datearr[3] );

my $dbh    = C4::Context->dbh;
my ($sqlorderby, $sqldatewhere) = ("","");
$debug and warn format_date_in_iso($startdate) . "\n" . format_date_in_iso($enddate);
$sqldatewhere .= " AND reservedate >= " . $dbh->quote(format_date_in_iso($startdate))  if ($startdate) ;
$sqldatewhere .= " AND reservedate <= " . $dbh->quote(format_date_in_iso($enddate))  if ($enddate) ;

if ($order eq "borrower") {
	$sqlorderby = " order by  borrower, reservedate";
} elsif ($order eq "biblio") {
	$sqlorderby = " order by biblio.title, priority,reservedate";
} elsif ($order eq "priority") {
    $sqlorderby = "order by priority DESC";
} else {
	$sqlorderby = " order by reservedate, borrower";
}
my $strsth =
"SELECT reservedate,
        reserves.borrowernumber as borrowernumber,
        concat(firstname,' ',surname) as borrower,
        borrowers.phone,
        borrowers.email,
        reserves.biblionumber,
        reserves.branchcode as branch,
        items.holdingbranch,
        items.itemcallnumber,
        items.itemnumber,
        notes,
        notificationdate,
        reminderdate,
        priority,
        reserves.found,
        biblio.title,
        biblio.author
 FROM  reserves
 LEFT JOIN items ON items.biblionumber=reserves.biblionumber 
 LEFT JOIN borrowers ON reserves.borrowernumber=borrowers.borrowernumber
 LEFT JOIN biblio ON reserves.biblionumber=biblio.biblionumber
 WHERE isnull(cancellationdate)
 $sqldatewhere
 AND reserves.found is NULL 
 AND reserves.itemnumber is NULL";

if (C4::Context->preference('IndependantBranches')){
	$strsth .= " AND items.holdingbranch=? ";
}
$strsth .= $sqlorderby;
my $sth = $dbh->prepare($strsth);

if (C4::Context->preference('IndependantBranches')){
	$sth->execute(C4::Context->userenv->{'branch'});
}
else {
	$sth->execute();
}	
my @reservedata;
my $previous;
my $this;
while ( my $data = $sth->fetchrow_hashref ) {
    $this=$data->{biblionumber}.":".$data->{borrowernumber};
    my @itemlist;
    push(
        @reservedata,
        {
            reservedate      => $previous eq $this?"":format_date( $data->{reservedate} ),
            priority         => $previous eq $this?"":$data->{priority},
            name             => $previous eq $this?"":$data->{borrower},
            title            => $previous eq $this?"":$data->{title},
            author           => $previous eq $this?"":$data->{author},
            borrowernumber   => $previous eq $this?"":$data->{borrowernumber},
            itemnum          => $previous eq $this?"":$data->{itemnumber},
            phone            => $previous eq $this?"":$data->{phone},
            email            => $previous eq $this?"":$data->{email},
            biblionumber     => $previous eq $this?"":$data->{biblionumber},
            statusw          => ( $data->{found} eq "w" ),
            statusf          => ( $data->{found} eq "f" ),
            holdingbranch    => $data->{holdingbranch},
            branch           => $previous eq $this?"":$data->{branch},
            itemcallnumber   => $data->{itemcallnumber},
            notes            => $previous eq $this?"":$data->{notes},
            notificationdate => $previous eq $this?"":$data->{notificationdate},
            reminderdate     => $previous eq $this?"":$data->{reminderdate}
        }
    );
    $previous=$this;
}

$sth->finish;
$strsth=~ s/AND reserves.itemnumber is NULL/AND reserves.itemnumber is NOT NULL/;
$strsth=~ s/LEFT JOIN items ON items.biblionumber=reserves.biblionumber/LEFT JOIN items ON items.biblionumber=reserves.itemnumber/;
$sth = $dbh->prepare($strsth);                                                                                                                          
if (C4::Context->preference('IndependantBranches')){
	$sth->execute(C4::Context->userenv->{'branch'});
}     
else {
	$sth->execute(); 
}              
while ( my $data = $sth->fetchrow_hashref ) {
    $this=$data->{biblionumber}.":".$data->{borrowernumber};
    my @itemlist;
    push(
        @reservedata,
        {
            reservedate      => $previous eq $this?"":format_date( $data->{reservedate} ),
            priority         => $previous eq $this?"":$data->{priority},
            name             => $previous eq $this?"":$data->{borrower},
            title            => $previous eq $this?"":$data->{title},
            author           => $previous eq $this?"":$data->{author},
            borrowernumber   => $previous eq $this?"":$data->{borrowernumber},
            itemnum          => $previous eq $this?"":$data->{itemnumber},
            phone            => $previous eq $this?"":$data->{phone},
            email            => $previous eq $this?"":$data->{email},
            biblionumber     => $previous eq $this?"":$data->{biblionumber},
            statusw          => ( $data->{found} eq "w" ),
            statusf          => ( $data->{found} eq "f" ),
            holdingbranch    => $data->{holdingbranch},
            branch           => $previous eq $this?"":$data->{branch},
            itemcallnumber   => $data->{itemcallnumber},
            notes            => $previous eq $this?"":$data->{notes},
            notificationdate => $previous eq $this?"":$data->{notificationdate},
            reminderdate     => $previous eq $this?"":$data->{reminderdate},
			thisitemonly     => 1,
        }
    );
    $previous=$this;
}

$sth->finish;

$template->param(
    todaysdate      => format_date($todaysdate),
    from             => $startdate,
    to              => $enddate,
    reserveloop     => \@reservedata,
    "BiblioDefaultView".C4::Context->preference("BiblioDefaultView") => 1,
    DHTMLcalendar_dateformat =>  C4::Dates->DHTMLcalendar(),
);

output_html_with_http_headers $input, $cookie, $template->output;
