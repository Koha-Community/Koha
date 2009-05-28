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
# use warnings; # FIXME
use C4::Context;
use C4::Output;
use CGI;
use C4::Auth;
use C4::Branch;
use C4::Dates qw/format_date/;
use Date::Calc qw/Today/;

my $input = new CGI;
my $order   = $input->param( 'order' ) || '';
my $showall = $input->param('showall');

my  $bornamefilter = $input->param( 'borname');
my   $borcatfilter = $input->param( 'borcat' );
my $itemtypefilter = $input->param('itemtype');
my $borflagsfilter = $input->param('borflags') || "";
my   $branchfilter = $input->param( 'branch' );
my $op             = $input->param(   'op'   ) || '';

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "circ/overdue.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { reports => 1, circulate => "circulate_remaining_permissions" },
        debug           => 1,
    }
);

my $dbh = C4::Context->dbh;

# download the complete CSV
if ($op eq 'csv') {
warn "BRANCH : $branchfilter";
    my $lib = $branchfilter ? "-library $branchfilter" :'';
    my $csv = `../misc/cronjobs/overdue_notices.pl -csv -n $lib`;
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
    push @borcatloop, {
        value    => $catcode,
        selected => $catcode eq $borcatfilter ? 1 : 0,
        catname  => $description,
    };
}

$req = $dbh->prepare( "select itemtype, description from itemtypes order by description");
$req->execute;
my @itemtypeloop;
while (my ($itemtype, $description) =$req->fetchrow) {
    push @itemtypeloop, {
        value        => $itemtype,
        selected     => $itemtype eq $itemtypefilter ? 1 : 0,
        itemtypename => $description,
    };
}
my $onlymine=C4::Context->preference('IndependantBranches') && 
             C4::Context->userenv && 
             C4::Context->userenv->{flags} % 2 !=1 && 
             C4::Context->userenv->{branch};

$branchfilter = C4::Context->userenv->{'branch'} if ($onlymine && !$branchfilter);

$template->param(
    branchloop   => GetBranchesLoop($branchfilter, $onlymine),
    branchfilter => $branchfilter,
    borcatloop   => \@borcatloop,
    itemtypeloop => \@itemtypeloop,
    borname      => $bornamefilter,
    order        => $order,
    showall      => $showall,
);

my @sort_roots = qw(borrower title barcode date_due);
push @sort_roots, map {$_ . " desc"} @sort_roots;
my @order_loop = ({selected => $order ? 0 : 1});   # initial blank row
foreach (@sort_roots) {
    my $tmpl_name = $_;
    $tmpl_name =~ s/\s/_/g;
    push @order_loop, {
        selected => $order eq $_ ? 1 : 0,
        ordervalue => $_,
        foo => $tmpl_name,
        'order_' . $tmpl_name => 1,
    };
}
$template->param(ORDER_LOOP => \@order_loop);

my $todaysdate = sprintf("%-04.4d-%-02.2d-%02.2d", Today());

$bornamefilter =~s/\*/\%/g;
$bornamefilter =~s/\?/\_/g;

my $strsth="SELECT date_due,
  concat(surname,' ', firstname) as borrower, 
  borrowers.phone,
  borrowers.email,
  issues.itemnumber,
  items.barcode,
  biblio.title,
  biblio.author,
  borrowers.borrowernumber,
  biblio.biblionumber,
  borrowers.branchcode 
  FROM issues
LEFT JOIN borrowers   ON (issues.borrowernumber=borrowers.borrowernumber )
LEFT JOIN items       ON (issues.itemnumber=items.itemnumber)
LEFT JOIN biblioitems ON (biblioitems.biblioitemnumber=items.biblioitemnumber)
LEFT JOIN biblio      ON (biblio.biblionumber=items.biblionumber )
WHERE 1=1 "; # placeholder, since it is possible that none of the additional
             # conditions will be selected by user
$strsth.=" AND date_due               < '" . $todaysdate     . "' " unless ($showall);
$strsth.=" AND (borrowers.firstname like '".$bornamefilter."%' or borrowers.surname like '".$bornamefilter."%' or borrowers.cardnumber like '".$bornamefilter."%')" if($bornamefilter) ;
$strsth.=" AND borrowers.categorycode = '" . $borcatfilter   . "' " if $borcatfilter;
$strsth.=" AND biblioitems.itemtype   = '" . $itemtypefilter . "' " if $itemtypefilter;
$strsth.=" AND borrowers.flags        = '" . $borflagsfilter . "' " if $borflagsfilter;
$strsth.=" AND borrowers.branchcode   = '" . $branchfilter   . "' " if $branchfilter;
$strsth.=" ORDER BY " . (
    ($order eq "borrower" or $order eq "borrower desc") ? "$order, date_due"                 : 
    ($order eq "title"    or $order eq    "title desc") ? "$order, date_due, borrower"       :
    ($order eq "barcode"  or $order eq  "barcode desc") ? "items.$order, date_due, borrower" :
                            ($order eq "date_due desc") ? "date_due DESC, borrower"          :
                                                          "date_due, borrower"  # default sort order
);
$template->param(sql=>$strsth);
my $sth=$dbh->prepare($strsth);
#warn "overdue.pl : query string ".$strsth;
$sth->execute();

my @overduedata;
while (my $data=$sth->fetchrow_hashref) {
    push @overduedata, {
        duedate        => format_date($data->{date_due}),
        borrowernumber => $data->{borrowernumber},
        barcode        => $data->{barcode},
        itemnum        => $data->{itemnumber},
        name           => $data->{borrower},
        phone          => $data->{phone},
        email          => $data->{email},
        biblionumber   => $data->{biblionumber},
        title          => $data->{title},
        author         => $data->{author},
        branchcode     => $data->{branchcode},
    };
}

$template->param(
    todaysdate  => format_date($todaysdate),
    overdueloop => \@overduedata
);

output_html_with_http_headers $input, $cookie, $template->output;
