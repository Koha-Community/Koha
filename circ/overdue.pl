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
use C4::Auth;
use C4::Date;

my $input = new CGI;
my $type  = $input->param('type');

my $theme = $input->param('theme');    # only used if allowthemeoverride is set

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "circ/overdue.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { reports => 1, circulate => 1 },
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

my $dbh = C4::Context->dbh;

my $sth =
  $dbh->prepare(
    "select date_due,borrowernumber,itemnumber
     from issues
     where isnull(returndate) && date_due<? order by date_due,borrowernumber"
  );
$sth->execute($todaysdate);

my @overduedata;
while ( my $data = $sth->fetchrow_hashref ) {
    $duedate        = format_date($data->{'date_due'});
    $borrowernumber = $data->{'borrowernumber'};
    $itemnum        = $data->{'itemnumber'};

    my $sth1 =
      $dbh->prepare(
"select concat(firstname,' ',surname),phone,email from borrowers where borrowernumber=?"
      );
    $sth1->execute($borrowernumber);
    $data1 = $sth1->fetchrow_hashref;
    $name  = $data1->{'concat(firstname,\' \',surname)'};
    $phone = $data1->{'phone'};
    $email = $data1->{'email'};
    $sth1->finish;

    my $sth2 =
      $dbh->prepare("select biblionumber from items where itemnumber=?");
    $sth2->execute($itemnum);
    $data2        = $sth2->fetchrow_hashref;
    $biblionumber = $data2->{'biblionumber'};
    $sth2->finish;

    my $sth3 =
      $dbh->prepare("select title,author from biblio where biblionumber=?");
    $sth3->execute($biblionumber);
    $data3  = $sth3->fetchrow_hashref;
    $title  = $data3->{'title'};
    $author = $data3->{'author'};
    $sth3->finish;
    push(
        @overduedata,
        {
            duedate        => $duedate,
            borrowernumber => $borrowernumber,
            itemnum        => $itemnum,
            name           => $name,
            phone          => $phone,
            email          => $email,
            biblionumber   => $biblionumber,
            title          => $title,
            author         => $author
        }
    );
}

$template->param(
    todaysdate  => $todaysdate,
    overdueloop => \@overduedata
);

output_html_with_http_headers $input, $cookie, $template->output;
