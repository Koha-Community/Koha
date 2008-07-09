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
use C4::Branch;
use C4::Dates qw/format_date/;
use Date::Calc qw/Today/;

my $input = new CGI;
my $type    = $input->param('type');
my $theme   = $input->param('theme');    # only used if allowthemeoverride is set
my $order   = $input->param('order');
my $showall = $input->param('showall');

my  $bornamefilter = $input->param('borname');
my   $borcatfilter = $input->param('borcat');
my $itemtypefilter = $input->param('itemtype');
my $borflagsfilter = $input->param('borflags') || " ";
my   $branchfilter = $input->param('branch');
my $op             = $input->param('op');

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
my $dbh = C4::Context->dbh;


# download the complete CSV
if ($op eq 'csv') {
warn "BRANCH : $branchfilter";
    my $csv = `../misc/cronjobs/overdue_notices.pl -csv -n -b $branchfilter`;
    print $input->header(-type => 'application/vnd.sun.xml.calc',
                        -encoding    => 'utf-8',
                        -attachment=>"overdues.csv",
                        -filename=>"overdues.csv" );
    print $csv;
    exit;
}
my $req;
$req = $dbh->prepare( "select categorycode, description from categories order by description");
$req->execute;
my @borcatloop;
while (my ($catcode, $description) =$req->fetchrow) {
  my $selected = 1 if $catcode eq $borcatfilter;
  my %row =(value => $catcode,
        selected => $selected,
        catname => $description,
      );
  push @borcatloop, \%row;
}

$req = $dbh->prepare( "select itemtype, description from itemtypes order by description");
$req->execute;
my @itemtypeloop;
while (my ($itemtype, $description) =$req->fetchrow) {
  my $selected = 1 if $itemtype eq $itemtypefilter;
  my %row =(value => $itemtype,
        selected => $selected,
        itemtypename => $description,
      );
  push @itemtypeloop, \%row;
}
my $onlymine=C4::Context->preference('IndependantBranches') && 
             C4::Context->userenv && 
             C4::Context->userenv->{flags}!=1 && 
             C4::Context->userenv->{branch};
my $branches = GetBranches($onlymine);
my @branchloop;

foreach my $thisbranch ( sort keys %$branches ) {
     my %row = (
        value      => $thisbranch,
        branchname => $branches->{$thisbranch}->{'branchname'},
        selected   => ($branches->{$thisbranch}->{'branchcode'} eq $branchfilter)
    );
    push @branchloop, \%row;
}
$branchfilter=C4::Context->userenv->{'branch'} if ($onlymine && !$branchfilter);

$template->param( branchloop => \@branchloop,
                  branchfilter => $branchfilter);
$template->param(borcatloop=> \@borcatloop,
          itemtypeloop => \@itemtypeloop,
          branchloop=> \@branchloop,
          borname => $bornamefilter,
          order => $order,
          showall => $showall);

my $duedate;
my $borrowernumber;
my $itemnum;
my $data1;
my $data2;
my $data3;
my $name;
my $phone;
my $email;
my $title;
my $author;

my $todaysdate = sprintf("%-04.4d-%-02.2d-%02.2d", Today());

$bornamefilter =~s/\*/\%/g;
$bornamefilter =~s/\?/\_/g;

my $strsth="SELECT date_due,concat(surname,' ', firstname) as borrower, 
  borrowers.phone, borrowers.email,issues.itemnumber, items.barcode, biblio.title, biblio.author,borrowers.borrowernumber,biblio.biblionumber,borrowers.branchcode 
  FROM issues
LEFT JOIN borrowers ON (issues.borrowernumber=borrowers.borrowernumber )
LEFT JOIN items ON (issues.itemnumber=items.itemnumber)
LEFT JOIN biblioitems ON (biblioitems.biblioitemnumber=items.biblioitemnumber)
LEFT JOIN biblio ON (biblio.biblionumber=items.biblionumber )
WHERE 1=1 "; # placeholder, since it is possible that none of the additional
             # conditions will be selected by user
$strsth.= " && date_due<'".$todaysdate."' " unless ($showall);
$strsth.=" && (borrowers.firstname like '".$bornamefilter."%' or borrowers.surname like '".$bornamefilter."%' or borrowers.cardnumber like '".$bornamefilter."%')" if($bornamefilter) ;
$strsth.=" && borrowers.categorycode = '".$borcatfilter."' " if($borcatfilter) ;
$strsth.=" && biblioitems.itemtype = '".$itemtypefilter."' " if($itemtypefilter) ;
$strsth.=" && borrowers.flags = '".$borflagsfilter."' " if ($borflagsfilter ne " ") ;
$strsth.=" && borrowers.branchcode = '".$branchfilter."' " if($branchfilter) ;
if ($order eq "borrower"){
  $strsth.=" ORDER BY borrower,date_due " ;
} elsif ($order eq "title"){
  $strsth.=" ORDER BY title,date_due,borrower ";
} elsif ($order eq "barcode"){
  $strsth.=" ORDER BY items.barcode,date_due,borrower ";
}elsif ($order eq "borrower DESC"){
  $strsth.=" ORDER BY borrower desc,date_due " ;
} elsif ($order eq "title DESC"){
  $strsth.=" ORDER BY title desc,date_due,borrower ";
} elsif ($order eq "barcode DESC"){
  $strsth.=" ORDER BY items.barcode desc,date_due,borrower ";
} elsif ($order eq "date_due DESC"){
  $strsth.=" ORDER BY date_due DESC,borrower ";
} else {
  $strsth.=" ORDER BY date_due,borrower ";
}
my $sth=$dbh->prepare($strsth);
#warn "overdue.pl : query string ".$strsth;
$sth->execute();

my @overduedata;
while (my $data=$sth->fetchrow_hashref) {
  $duedate=$data->{'date_due'};
  $duedate = format_date($duedate);
  $itemnum=$data->{'itemnumber'};

  $name=$data->{'borrower'};
  $phone=$data->{'phone'};
  $email=$data->{'email'};

  $title=$data->{'title'};
  $author=$data->{'author'};
  push (@overduedata, {
                        duedate        => $duedate,
                        borrowernumber => $data->{borrowernumber},
                        barcode        => $data->{barcode},
                        itemnum        => $itemnum,
                        name           => $name,
                        phone          => $phone,
                        email          => $email,
                        biblionumber   => $data->{'biblionumber'},
                        title          => $title,
                        author         => $author,
                        branchcode     => $data->{'branchcode'} });
}

$template->param(
    todaysdate  => format_date($todaysdate),
    overdueloop => \@overduedata
);

output_html_with_http_headers $input, $cookie, $template->output;
