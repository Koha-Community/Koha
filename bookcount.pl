#!/usr/bin/perl

# $Id$

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
use C4::Context;
use C4::Search;
use C4::Circulation::Circ2;
use C4::Output;

# get all the data ....
my %env;
my $main='#cccc99';
my $secondary='#ffffcc';

my $input = new CGI;

# Authentication script added, superlibrarian set as default requirement

my $flagsrequired;
$flagsrequired->{superlibrarian}=1;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0, $flagsrequired);

my $itm = $input->param('itm');
my $bi = $input->param('bi');
my $bib = $input->param('bib');
my $branches = getbranches(\%env);

my $idata = itemdatanum($itm);
my $data = bibitemdata($bi);

my $homebranch = $branches->{$idata->{'homebranch'}}->{'branchname'};
my $holdingbranch = $branches->{$idata->{'holdingbranch'}}->{'branchname'};

my ($lastmove, $message) = lastmove($itm);

my $lastdate;
my $count;
if (not $lastmove) {
    $lastdate = $message;
    $count = issuessince($itm , 0);
} else {
    $lastdate = $lastmove->{'datearrived'};
    $count = issuessince($itm ,$lastdate);
}


# make the page ...
print $input->header;


print startpage;
print startmenu('report');
print center;

print <<"EOF";
<br>
<FONT SIZE=6><em><a href=/cgi-bin/koha/detail.pl?bib=$bib&type=intra>$data->{'title'} ($data->{'author'})</a></em></FONT><P>
<p>
<img src="/images/holder.gif" width=16 height=200 align=left>
<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 width=440 >
  <TR VALIGN=TOP><td  bgcolor="99cc33" background="/images/background-mem.gif">
  <B>BARCODE $idata->{'barcode'}</b></TD>
</TR>
<TR VALIGN=TOP  >
<TD width=440 >

<b>Home Branch: </b> $homebranch <br>
<b>Current Branch: </b> $holdingbranch<br>
<b>Date arrived at current branch: </b> $lastdate <br>
<b>Number of issues since since the above date :</b> $count <br>

<table cellspacing =0 cellpadding=5 border=1 width = 440>
<TR><TD > <b>Branch</b></td>  <TD >   <b>No. of Issues</b></td>   <td><b>Last seen at branch</b></td></TR>
EOF

foreach my $branchcode (keys %$branches) {
    my $issues = issuesat($itm, $branchcode);
    my $date = lastseenat($itm, $branchcode);
    my $seen = slashdate($date);
    print << "EOF";
<TR><TD > <b>$branches->{$branchcode}->{'branchname'}</b></td>
<TD >    <b> $issues </b></td>             <td><b> $seen</b></td></TR>
EOF
}
print <<"EOF";
</table>
</TR>

</table>
EOF


print endmenu('report');
print endpage;


##############################################
# This stuff should probably go into C4::Search
# database includes
use DBI;

sub itemdatanum {
    my ($itemnumber)=@_;
    my $dbh = C4::Context->dbh;
    my $itm = $dbh->quote("$itemnumber");
    my $query = "select * from items where itemnumber=$itm";
    my $sth=$dbh->prepare($query);
    $sth->execute;
    my $data=$sth->fetchrow_hashref;
    $sth->finish;
    return($data);
}

sub lastmove {
      my ($itemnumber)=@_;
      my $dbh = C4::Context->dbh;
      my $var1 = $dbh->quote($itemnumber);
      my $sth =$dbh->prepare("select max(branchtransfers.datearrived) from branchtransfers where branchtransfers.itemnumber=$var1");
      $sth->execute;
      my ($date) = $sth->fetchrow_array;
      return(0, "Item has no branch transfers record") if not $date;
      my $var2 = $dbh->quote($date);
      $sth=$dbh->prepare("Select * from branchtransfers where branchtransfers.itemnumber=$var1 and branchtransfers.datearrived=$var2");
      $sth->execute;
      my ($data) = $sth->fetchrow_hashref;
      return(0, "Item has no branch transfers record") if not $data;
      $sth->finish;
      return($data,"");
 }

sub issuessince {
      my ($itemnumber, $date)=@_;
      my $dbh = C4::Context->dbh;
      my $itm = $dbh->quote($itemnumber);
      my $dat = $dbh->quote($date);
      my $sth=$dbh->prepare("Select count(*) from issues where issues.itemnumber=$itm and issues.timestamp > $dat");
      $sth->execute;
      my $count=$sth->fetchrow_hashref;
      $sth->finish;
      return($count->{'count(*)'});
}

sub issuesat {
      my ($itemnumber, $brcd)=@_;
      my $dbh = C4::Context->dbh;
      my $itm = $dbh->quote($itemnumber);
      my $brc = $dbh->quote($brcd);
      my $query = "Select count(*) from issues where itemnumber=$itm and branchcode = $brc";
      my $sth=$dbh->prepare($query);
      $sth->execute;
      my ($count)=$sth->fetchrow_array;
      $sth->finish;
      return($count);
}

sub lastseenat {
      my ($itemnumber, $brcd)=@_;
      my $dbh = C4::Context->dbh;
      my $itm = $dbh->quote($itemnumber);
      my $brc = $dbh->quote($brcd);
      my $query = "Select max(timestamp) from issues where itemnumber=$itm and branchcode = $brc";
      my $sth=$dbh->prepare($query);
      $sth->execute;
      my ($date1)=$sth->fetchrow_array;
      $sth->finish;
      $query = "Select max(datearrived) from branchtransfers where itemnumber=$itm and tobranch = $brc";
      # FIXME - There's already a $sth in this scope.
      my $sth=$dbh->prepare($query);
      $sth->execute;
      my ($date2)=$sth->fetchrow_array;
      $sth->finish;
      $date2 =~ s/-//g;
      $date2 =~ s/://g;
      $date2 =~ s/ //g;
      my $date;
      if ($date1 < $date2) {
	  $date = $date2;
      } else {
	  $date = $date1;
      }
      return($date);
}


#####################################################
# write date....
sub slashdate {
    my ($date) = @_;
    if (not $date) {
	return "never";
    }
    my ($yr, $mo, $da, $hr, $mi) = (substr($date, 0, 4), substr($date, 4, 2), substr($date, 6, 2), substr($date, 8, 2), substr($date, 10, 2));
    return "$hr:$mi  $da/$mo/$yr";
}
