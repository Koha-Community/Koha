#!/usr/bin/perl
#script to provide bookshelf management
#
# $Header$
#

use strict;
use C4::Search;
use CGI;
use C4::Output;
use C4::BookShelves;
use C4::Circulation::Circ2;
use C4::Auth;

my $env;
my $query = new CGI;
my ($loggedinuser, $cookie, $sessionID) = checkauth($query);
print $query->header(-cookie => $cookie);
my $headerbackgroundcolor='#663266';
my $circbackgroundcolor='#555555';
my $circbackgroundcolor='#550000';
my $linecolor1='#bbbbbb';
my $linecolor2='#dddddd';

print startpage();
print startmenu('catalogue');


print "Logged in as: $loggedinuser<br><a href=logout.pl>Log Out</a><br>\n";


my ($shelflist) = GetShelfList();

if ($query->param('modifyshelfcontents')) {
    my $shelfnumber=$query->param('shelfnumber');
    my $barcode=$query->param('addbarcode');
    my ($item) = getiteminformation($env, 0, $barcode);
    AddToShelf($env, $item->{'itemnumber'}, $shelfnumber);
    foreach ($query->param) {
	if (/REM-(\d*)/) {
	    my $itemnumber=$1;
	    RemoveFromShelf($env, $itemnumber, $shelfnumber);
	}
    }
}

SWITCH: {
    if ($query->param('viewshelf')) {  viewshelf($query->param('viewshelf')); last SWITCH;}
    if ($query->param('shelves')) {  shelves(); last SWITCH;}
    print << "EOF";
    <center>
    <table border=0 cellpadding=4 cellspacing=0>
    <tr><td bgcolor=$headerbackgroundcolor>
    <table border=0 cellpadding=5 cellspacing=0 width=100%>
    <tr><th bgcolor=$headerbackgroundcolor>
    <font color=white>Shelf List</font>
    </th></tr>
    </table>
    </td></tr>
EOF
    my $color='';
    foreach (sort keys %$shelflist) {
	($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
	print "<tr><td bgcolor=$color><a href=shelves.pl?viewshelf=$_>$shelflist->{$_}->{'shelfname'} ($shelflist->{$_}->{'count'} books)</a></td></tr>\n";
    }
    print "</table>\n";
    print "<P><a href=shelves.pl?shelves=1>Add or Remove Book Shelves</a>\n";
}



sub shelves {
    if (my $newshelf=$query->param('addshelf')) {
	my ($status, $string) = AddShelf($env,$newshelf);
	if ($status) {
	    print "<font color=red>$string</font><p>\n";
	}
    }
    foreach ($query->param()) {
	if (/DEL-(\d+)/) {
	    my $delshelf=$1;
	    my ($status, $string) = RemoveShelf($env,$delshelf);
	    if ($status) {
		print "<font color=red>$string</font><p>\n";
	    }
	}
    }
    my ($shelflist) = GetShelfList();
    print << "EOF";
<center>
<a href=shelves.pl>Modify Shelf Contents</a><p>
<h1>Bookshelves</h1>
<table border=0 cellpadding=7>
<tr><td align=center>
<form method=post>
<input type=hidden name=shelves value=1>
<table border=0 cellpadding=0 cellspacing=0>
<tr><th bgcolor=$headerbackgroundcolor>
<font color=white>Select Shelves to Delete</font>
</th></tr>
EOF
    my $color='';
    my $color='';
    foreach (sort keys %$shelflist) {
	($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
	print "<tr><td bgcolor=$color><input type=checkbox name=DEL-$_> $shelflist->{$_}->{'shelfname'} ($shelflist->{$_}->{'count'} books)</td></tr>\n";
    }
    print "</table>\n";
    print '<p><input type=submit value="Delete Shelves"><p>';
    print "</td><td align=center valign=top>\n";
    print "<form method=post>\n";
    print "<input type=hidden name=shelves value=1>\n";
    print "<p>Add Shelf: <input name=addshelf size=25><p>\n";
    print '<p><input type=submit value="Add New Shelf"><p>';
    print "</form>\n";
    print "</td></tr></table>\n";
}



sub viewshelf {
    my $shelfnumber=shift;
    my ($itemlist) = GetShelfContents($env, $shelfnumber);
    my $item='';
    print << "EOF";
    <center>
    <form>
    <a href=shelves.pl>Shelf List</a><p>
    <table border=0 cellpadding=0 cellspacing=0>
    <tr><td colspan=7>
    <table>
    <tr><td>Add a book by barcode:</td><td><input name=addbarcode></td></tr>
    </table>
    <br>
    <table border=0 cellpadding=5 cellspacing=0 width=100%>
    <tr><th bgcolor=$headerbackgroundcolor>
    <font color=white>Contents of $shelflist->{$shelfnumber}->{'shelfname'} shelf</font>
    </th></tr>
    </table>
    </td></tr>
EOF
    my $color='';
    foreach $item (sort {$a->{'barcode'} cmp $b->{'barcode'}} @$itemlist) {
	($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
	print << "EOF";
	<tr>
	<td bgcolor=$color><input type=checkbox name=REM-$item->{'itemnumber'}></td>
	<td bgcolor=$color width=10 align=center><img src=/images/blankdot.gif></td>
	<td bgcolor=$color>$item->{'barcode'}</td>
	<td bgcolor=$color width=10 align=center><img src=/images/blankdot.gif></td>
	<td bgcolor=$color>$item->{'title'}</td>
	<td bgcolor=$color width=10 align=center><img src=/images/blankdot.gif></td>
	<td bgcolor=$color>$item->{'author'}</td>
	</tr>
EOF
    }
    print << "EOF";
    </table>
    <br>
    <input type=hidden name=shelfnumber value=$shelfnumber>
    <input type=hidden name=modifyshelfcontents value=1>
    <input type=hidden name=viewshelf value=$shelfnumber>
    <input type=submit value="Remove Selected Items">
    </form>
EOF
}



#
# $Log$
# Revision 1.6  2002/07/04 21:09:43  tonnesen
# Additions to authentication scheme.  Logs to /tmp/sessionlog.  Will move this
# to a db table.
#
# Revision 1.5  2002/07/04 19:42:48  tonnesen
# Minor changes
#
# Revision 1.4  2002/07/04 19:21:29  tonnesen
# Beginning of authentication api.  Applied to shelves.pl for now as a test case.
#
# Revision 1.2.2.1  2002/06/26 20:28:15  tonnesen
# Some udpates that I made here locally a while ago.  Still won't be useful, but
# should be functional
#
#
#



print endpage();
print endmenu('catalogue');
