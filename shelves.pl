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

my $env;
my $query = new CGI;
print $query->header;
my $headerbackgroundcolor='#663266';
my $circbackgroundcolor='#555555';
my $circbackgroundcolor='#550000';
my $linecolor1='#bbbbbb';
my $linecolor2='#dddddd';

print startpage();
print startmenu('catalogue');




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
    <input type=submit value="Modify Shelf List">
    </form>
EOF
}



#
# $Log$
# Revision 1.1  2001/02/07 20:27:16  tonnesen
# Start of code to implement virtual bookshelves in Koha.
#
#
#



