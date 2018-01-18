#!/usr/bin/perl

#written 7/3/2002 by Finlay
#script to display reports

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Debug;
use C4::Context;
use C4::Circulation;
use C4::Output;
use C4::Koha;
use C4::Auth;
use C4::Biblio; # GetBiblioItemData
use Koha::DateUtils;
use Koha::Libraries;

my $input        = new CGI;
my $itm          = $input->param('itm');
my $bi           = $input->param('bi');
my $biblionumber = $input->param('biblionumber');

my $idata = itemdatanum($itm);
my $data  = GetBiblioItemData($bi);

my $lastmove = lastmove($itm);

my $lastdate;
my $count;
if ( not $lastmove ) {
    $count = issuessince( $itm, 0 );
} else {
    $lastdate = $lastmove->{'datearrived'};
    $count = issuessince( $itm, $lastdate );
}

# make the page ...

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "circ/bookcount.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => "circulate_remaining_permissions" },
        debug           => 1,
    }
);

my $libraries = Koha::Libraries->search({}, { order_by => ['branchname'] })->unblessed;
for my $library ( @$libraries ) {
    $library->{selected} = 1 if $library->{branchcode} eq C4::Context->userenv->{branch};
    $library->{issues}     = issuesat($itm, $library->{branchcode});
    $library->{seen}       = lastseenat( $itm, $library->{branchcode} ) || undef;
}

$template->param(
    biblionumber            => $biblionumber,
    title                   => $data->{'title'},
    author                  => $data->{'author'},
    barcode                 => $idata->{'barcode'},
    biblioitemnumber        => $bi,
    homebranch              => $idata->{homebranch},
    holdingbranch           => $idata->{holdingbranch},
    lastdate                => $lastdate ? $lastdate : 0,
    count                   => $count,
    libraries               => $libraries,
);

output_html_with_http_headers $input, $cookie, $template->output;
exit;

sub itemdatanum {
    my ($itemnumber) = @_;
    my $sth = C4::Context->dbh->prepare("SELECT * FROM items WHERE itemnumber=?");
    $sth->execute($itemnumber);
    return $sth->fetchrow_hashref;
}

sub lastmove {
    my ($itemnumber) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(
"SELECT max(branchtransfers.datearrived) FROM branchtransfers WHERE branchtransfers.itemnumber=?"
    );
    $sth->execute($itemnumber);
    my ($date) = $sth->fetchrow_array;
    return 0 unless $date;
    $sth = $dbh->prepare(
"SELECT * FROM branchtransfers WHERE branchtransfers.itemnumber=? and branchtransfers.datearrived=?"
    );
    $sth->execute( $itemnumber, $date );
    my ($data) = $sth->fetchrow_hashref;
    return 0 unless $data;
    return $data;
}

sub issuessince {
    my ( $itemnumber, $date ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth =
      $dbh->prepare("SELECT SUM(count) FROM (
                        SELECT COUNT(*) AS count FROM issues WHERE itemnumber = ? and timestamp > ?
                        UNION ALL
                        SELECT COUNT(*) AS count FROM old_issues WHERE itemnumber = ? and timestamp > ?
                     ) tmp");
    $sth->execute( $itemnumber, $date, $itemnumber, $date );
    return $sth->fetchrow_arrayref->[0];
}

sub issuesat {
    my ( $itemnumber, $brcd ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(
    "SELECT SUM(count) FROM (
        SELECT COUNT(*) AS count FROM     issues WHERE itemnumber = ? AND branchcode = ?
        UNION ALL
        SELECT COUNT(*) AS count FROM old_issues WHERE itemnumber = ? AND branchcode = ?
     ) tmp"
    );
    $sth->execute( $itemnumber, $brcd, $itemnumber, $brcd );
    return $sth->fetchrow_array;
}

sub lastseenat {
    my ( $itm, $brc ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(
    "SELECT MAX(tstamp) FROM (
        SELECT MAX(timestamp) AS tstamp FROM     issues WHERE itemnumber = ? AND branchcode = ?
        UNION ALL
        SELECT MAX(timestamp) AS tstamp FROM old_issues WHERE itemnumber = ? AND branchcode = ?
     ) tmp"
    );
    $sth->execute( $itm, $brc, $itm, $brc );
    my ($date1) = $sth->fetchrow_array;
    $sth = $dbh->prepare(
    "SELECT MAX(transfer) FROM (SELECT max(datearrived) AS transfer FROM branchtransfers WHERE itemnumber=? AND tobranch = ?
     UNION ALL
     SELECT max(datesent) AS transfer FROM branchtransfers WHERE itemnumber=? AND frombranch = ?
    ) tmp"
    );
    $sth->execute( $itm, $brc, $itm, $brc );
    my ($date2) = $sth->fetchrow_array;

    my $date = ( $date1 lt $date2 ) ? $date2 : $date1 ;
    return ($date);
}
