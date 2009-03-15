#!/usr/bin/perl


#written 7/3/2002 by Finlay
#script to display reports

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
use C4::Debug;
use C4::Context;
use C4::Circulation;
use C4::Output;
use C4::Koha;
use C4::Auth;
use C4::Branch; # GetBranches
use C4::Biblio; # GetBiblioItemData
use C4::Dates qw/format_date/;

my $input        = new CGI;
my $itm          = $input->param('itm');
my $bi           = $input->param('bi');
my $biblionumber = $input->param('biblionumber');
my $branches     = GetBranches;

my $idata = itemdatanum($itm);
my $data  = GetBiblioItemData($bi);

my $homebranch    = $branches->{ $idata->{'homebranch'} }->{'branchname'};
my $holdingbranch = $branches->{ $idata->{'holdingbranch'} }->{'branchname'};

my ( $lastmove, $message ) = lastmove($itm);

my $lastdate;
my $count;
if ( not $lastmove ) {
#    $lastdate = $message;
    $count = issuessince( $itm, 0 );
}
else {
    $lastdate = $lastmove->{'datearrived'};
    $count = issuessince( $itm, $lastdate );
}

# make the page ...

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "circ/bookcount.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => "circulate_remaining_permissions" },
        debug           => 1,
    }
);

my @branchloop;

foreach my $branchcode ( keys %$branches ) {
    my %linebranch;
    $linebranch{issues} = issuesat( $itm, $branchcode );
    my $date = lastseenat( $itm, $branchcode );
    $linebranch{seen}       = slashdate($date);
    $linebranch{branchname} = $branches->{$branchcode}->{'branchname'};
    push( @branchloop, \%linebranch );
}

### $lastdate

$template->param(
    biblionumber            => $biblionumber,
    title                   => $data->{'title'},
    author                  => $data->{'author'},
    barcode                 => $idata->{'barcode'},
    biblioitemnumber        => $bi,
    homebranch              => $homebranch,
    holdingbranch           => $holdingbranch,
    lastdate                => $lastdate ?  format_date($lastdate) : $message,
    count                   => $count,
    branchloop              => \@branchloop,
);

output_html_with_http_headers $input, $cookie, $template->output;


sub itemdatanum {
    my ($itemnumber) = @_;
    my $dbh          = C4::Context->dbh;
    my $sth          = $dbh->prepare("select * from items where itemnumber=?");
    $sth->execute($itemnumber);
    my $data = $sth->fetchrow_hashref;
    $sth->finish;
    return ($data);
}

sub lastmove {
    my ($itemnumber) = @_;
    my $dbh          = C4::Context->dbh;
    my $sth          =
      $dbh->prepare(
"select max(branchtransfers.datearrived) from branchtransfers where branchtransfers.itemnumber=?"
      );
    $sth->execute($itemnumber);
    my ($date) = $sth->fetchrow_array;
    return ( 0, "Item has no branch transfers record" ) if not $date;
    $sth =
      $dbh->prepare(
"Select * from branchtransfers where branchtransfers.itemnumber=? and branchtransfers.datearrived=?"
      );
    $sth->execute( $itemnumber, $date );
    my ($data) = $sth->fetchrow_hashref;
    return ( 0, "Item has no branch transfers record" ) if not $data;
    $sth->finish;
    return ( $data, "" );
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
    my $count = $sth->fetchrow_arrayref->[0];
    $sth->finish;
    return ( $count );
}

sub issuesat {
    my ( $itemnumber, $brcd ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth =
      $dbh->prepare("SELECT SUM(count) FROM (
                        SELECT COUNT(*) AS count FROM issues WHERE itemnumber = ? and branchcode = ?
                        UNION ALL
                        SELECT COUNT(*) AS count FROM old_issues WHERE itemnumber = ? and branchcode = ?
                     ) tmp");
    $sth->execute( $itemnumber, $brcd, $itemnumber, $brcd );
    my ($count) = $sth->fetchrow_array;
    $sth->finish;
    return ($count);
}

sub lastseenat {
    my ( $itm, $brc ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth =
      $dbh->prepare("SELECT MAX(tstamp) FROM (
                        SELECT MAX(timestamp) AS tstamp FROM issues WHERE itemnumber = ? and branchcode = ?
                        UNION ALL
                        SELECT MAX(timestamp) AS tstamp FROM old_issues WHERE itemnumber = ? and branchcode = ?
                     ) tmp");
    $sth->execute( $itm, $brc, $itm, $brc );
    my ($date1) = $sth->fetchrow_array;
    $sth->finish;
    $sth =
      $dbh->prepare(
"Select max(datearrived) from branchtransfers where itemnumber=? and tobranch = ?"
      );
    $sth->execute( $itm, $brc );
    my ($date2) = $sth->fetchrow_array;
    $sth->finish;

    #FIXME: MJR thinks unsafe
    $date1 =~ s/-//g;
    $date1 =~ s/://g;
    $date1 =~ s/ //g;
    $date2 =~ s/-//g;
    $date2 =~ s/://g;
    $date2 =~ s/ //g;
    my $date;
    if ( $date1 < $date2 ) {
        $date = $date2;
    }
    else {
        $date = $date1;
    }
    return ($date);
}

#####################################################
# write date....
sub slashdate {
    my ($date) = @_;
    if ( not $date ) {
        return "never";
    }
    my ( $yr, $mo, $da, $hr, $mi ) = (
        substr( $date, 0,  4 ),
        substr( $date, 4,  2 ),
        substr( $date, 6,  2 ),
        substr( $date, 8,  2 ),
        substr( $date, 10, 2 )
    );
    return "$hr:$mi  " . format_date("$yr-$mo-$da");
}
