#!/usr/bin/perl

#script to place reserves/requests
#writen 2/1/00 by chris@katipo.oc.nz


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
#use DBI;
use C4::Search;
use C4::Output;
use C4::Reserves2;
use C4::Acquisitions;
use C4::Koha;
use C4::Circulation::Circ2;

use CGI;
my $input = new CGI;

# get biblio information....
my $bib = $input->param('bib');
my $dat = bibdata($bib);

# get existing reserves .....
my ($count,$reserves) = FindReserves($bib);
my $totalcount = $count;
foreach my $res (@$reserves) {
    if ($res->{'found'} eq 'W') {
	$count--;
    }
}

# make priorities options
my $num = $count + 1;
my $priorityoptions = priorityoptions($num, $num);


# get branch information
my $branch = $input->cookie('branch');
($branch) || ($branch = 'L');
my $branches = getbranches();
my $branchoptions = branchoptions($branch);


# todays date
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =localtime(time);
$year=$year+1900;
$mon++;
my $date="$mday/$mon/$year";




# get biblioitem information and build rows for form
my ($count2,@data) = bibitems($bib);
my $bibitemrows = "";


foreach my $dat (sort {$b->{'dateaccessioned'} cmp $a->{'dateaccessioned'}} @data) {
    my @barcodes = barcodes($dat->{'biblioitemnumber'});
    my $barcodestext = "";
    foreach my $num (@barcodes) {
	my $message = $num->{'itemlost'} == 1 ? "(lost)" :
	    $num->{'itemlost'} == 2 ? "(long overdue)" : "";
	$barcodestext .= "$num->{'barcode'} $message <br>";
    }
    $barcodestext = substr($barcodestext, 0, -4);

    $dat->{'dewey'}="" if ($dat->{'dewey'} == 0);

    $dat->{'volumeddesc'} = "&nbsp;" unless $dat->{'volumeddesc'};
    $dat->{'dewey'}=~ s/\.0000$//;
    $dat->{'dewey'}=~ s/00$//;
    my $class="$dat->{'classification'}$dat->{'dewey'}$dat->{'subclass'}";
    my $select;
    if (($dat->{'notforloan'}) 
	|| ($dat->{'itemlost'} == 1))  {
	$select = "Cannot be reserved.";
    } else {
	$select = " <input type=checkbox name=reqbib value=$dat->{'biblioitemnumber'}><input type=hidden name=biblioitem value=$dat->{'biblioitemnumber'}>";
    }
    $bibitemrows .= <<"EOF";
<tr VALIGN=TOP>
<TD>$select</td>
<TD>$dat->{'description'}</td>
<TD>$class</td>
<td>$dat->{'volumeddesc'}</td>
<td>$dat->{'publicationyear'}</td>
<td>$barcodestext</td>
</tr>
EOF
}




my $existingreserves = "";
foreach my $res (sort {$a->{'found'} cmp $b->{'found'}} @$reserves){
    my $prioropt = priorityoptions($totalcount, $res->{'priority'});
    my $bropt = branchoptions($res->{'branchcode'});
    my $bor=$res->{'borrowernumber'};
    $date = slashifyDate($res->{'reservedate'});

    my $type=$res->{'constrainttype'};
    if ($type eq 'a'){
	$type='Next Available';
    } elsif ($type eq 'o'){
	$type="This type only $res->{'volumeddesc'} $res->{'itemtype'}";
    }

    my $notes = $res->{'reservenotes'}." ";
    my $rank;
    my $pickup;
    if ($res->{'found'} eq 'W') {
	my %env;
	my $item = $res->{'itemnumber'};
	$item = getiteminformation(\%env,$item);
	$item = "<a href=/cgi-bin/koha/detail.pl?bib=$item->{'biblionumber'} &type=intra onClick=\"openWindow(this, 'Item', 480, 640)\">$item->{'barcode'}</a>";
	my $wbrcd = $res->{'branchcode'};
	my $wbra = $branches->{$wbrcd}->{'branchname'};
	$type = $item;
	$rank = "<select name=rank-request><option value=W selected>Waiting</option>$prioropt<option value=del>Del</option></select>";
	$pickup = "Item waiting at <b>".$wbra."</b> <input type=hidden name=pickup value=$wbrcd>";
    } else {
	$rank = "<select name=rank-request>$prioropt<option value=del>Del</option></select>";
	$pickup = "<select name=pickup>$bropt</select>";
    }
    $existingreserves .= <<"EOF";
<tr VALIGN=TOP>
<TD>
<input type=hidden name=borrower value=$res->{'borrowernumber'}>
<input type=hidden name=biblio value=$res->{'biblionumber'}>
$rank</td>
<TD>
<a href=/cgi-bin/koha/moremember.pl?bornum=$bor>$res->{'firstname'} $res->{'surname'}</a>
</td>
<td>$notes</td>
<TD>$date</td>
<TD>$pickup</td>
<TD>$type</td>
</tr>
EOF
}



sub priorityoptions {
    my ($count, $sel) = @_;
    my $out = "";
    for (my $i=1; $i<=$count; $i++){
	$out .= "<option value=$i";
	if ($sel == $i){
	    $out .= " selected";
	}
	$out .= ">$i</option>\n";
    }
    return $out;
}

# make branch selection options...
sub branchoptions {
    my ($selbr) = @_;
    my $out = "";
    foreach my $br (keys %$branches) {
	(next) unless $branches->{$br}->{'IS'};
	my $selected = "";
	if ($br eq $selbr) {
	    $selected = "selected";
	}
	$out .= "<option value=$br $selected>$branches->{$br}->{'branchname'}</option>\n";
    }
    return $out;
}


#get the time for the form name...
my $time = time();


# printout the page




print $input->header(-expires=>'now');


#setup colours
print startmenu('catalogue');




print <<printend

<form action="placerequest.pl" method=post>
<INPUT TYPE="image" name="submit"  VALUE="request" height=42  WIDTH=187 BORDER=0 src="/images/place-request.gif" align=right >
<input type=hidden name=biblio value=$bib>
<input type=hidden name=type value=str8>
<input type=hidden name=title value="$dat->{'title'}">
<FONT SIZE=6><em>Requesting: <br>
<a href=/cgi-bin/koha/detail.pl?bib=$bib>$dat->{'title'}</a> 
($dat->{'author'})</em></FONT><P>
<p>





<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 >
<TR VALIGN=TOP>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Rank</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Member Number</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Notes</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Date</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Pickup</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Request</b></TD>
</TR>
<tr VALIGN=TOP  >
<td><select name=rank-request>
$priorityoptions
</select></td>
<td><input type=text size=10 name=member></td>
<td><input type=text size=20 name=notes></td>
<td>$date</td>
<td><select name=pickup>
$branchoptions
</select></td>
<td><input type=checkbox name=request value=any>Next Available, 
<br>(or choose from list below)</td>
</tr></table>



<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 >
<TR VALIGN=TOP>

<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Request</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Item Type</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Classification</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Volume</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Pubdate</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Copies</b></TD>
</TR>
$bibitemrows
</table>

</form>
<p>&nbsp;</p>





<form name=T$time action=modrequest.pl method=post>

<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 >

<TR VALIGN=TOP>

<td  bgcolor="99cc33" background="/images/background-mem.gif" colspan=7><B>MODIFY EXISTING REQUESTS </b></TD>
</TR>
<TR VALIGN=TOP>

<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Rank</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Member</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Notes</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Date</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Pickup</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Request</b></TD>
</TR>
$existingreserves
<tr VALIGN=TOP>
<TD colspan=6 align=right>
Delete a request by selecting "del" from the rank list.
<INPUT TYPE="image" name="submit"  VALUE="request" height=42  WIDTH=64 BORDER=0 src="/images/ok.gif"></td>
</tr>
</table>
<P>
<br>
</form>

printend
;

print endmenu();
print endpage();
